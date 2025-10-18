`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2025 11:34:55
// Design Name: 
// Module Name: fp_core32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fp_core32(
  input         clk, rst, start,
  input  [2:0]  op,       // 000 add, 001 sub, 010 mul, 011 div
  input  [31:0] a, b,
  output [31:0] result,
  output [4:0]  flags,    // {NV, DZ, OF, UF, NX}
  output        valid_out
);
  // Desempaquetado
  wire sa = a[31], sb = b[31];
  wire [7:0] ea = a[30:23], eb = b[30:23];
  wire [22:0] fa = a[22:0], fb = b[22:0];

  // Predicados estándar
  wire a_is_nan = (ea==8'hFF) && (fa!=0);
  wire b_is_nan = (eb==8'hFF) && (fb!=0);
  wire a_is_inf = (ea==8'hFF) && (fa==0);
  wire b_is_inf = (eb==8'hFF) && (fb==0);
  wire a_is_zero= (ea==8'h00) && (fa==0);
  wire b_is_zero= (eb==8'h00) && (fb==0);

  // Caso especial prioritario: NaN
  reg [31:0] special_res;
  reg [4:0]  special_flags;
  reg        take_special;

  always @* begin
    take_special  = 1'b0;
    special_res   = 32'h7FC0_0000; // QNaN canon
    special_flags = 5'b00000;

    if (a_is_nan || b_is_nan) begin
      take_special  = 1'b1;
      special_flags = 5'b10000; // NV por operación inválida con NaN quiet? (depende del caso)
    end
    else if (op==3'b011 && b_is_zero) begin
      // DIV y b=0  -> ±Inf, flag DZ
      take_special  = 1'b1;
      special_res   = {sa^sb, 8'hFF, 23'd0};
      special_flags = 5'b01000; // DZ
    end
    else if ((a_is_inf && b_is_zero) || (a_is_zero && b_is_inf)) begin
      // 0 * Inf, Inf * 0 -> NaN, NV
      if (op==3'b010) begin
        take_special  = 1'b1;
        special_res   = 32'h7FC0_0000;
        special_flags = 5'b10000; // NV
      end
    end
    else if (a_is_inf || b_is_inf) begin
      // add/sub/mul con infinito (salvo casos ya tratados)
      if (op==3'b010) begin // MUL
        take_special = 1'b1;
        special_res  = {sa^sb, 8'hFF, 23'd0};
      end
      else if (op==3'b000 || op==3'b001) begin // ADD/SUB
        // inf ± finito = inf, inf + (-inf) = NaN (NV)
        if (a_is_inf && b_is_inf && (sa ^ sb) == (op==3'b001 ? 1'b0 : 1'b1)) begin
          take_special  = 1'b1;
          special_res   = 32'h7FC00000; // inf - inf -> NaN
          special_flags = 5'b10000;
        end else begin
          take_special = 1'b1;
          special_res  = a_is_inf ? {sa,8'hFF,23'd0} : {sb,8'hFF,23'd0};
        end
      end
    end
  end

  // Operadores "normales"
  wire [31:0] add_res;  wire [4:0] add_flg;  wire add_v;
  wire [31:0] sub_res;  wire [4:0] sub_flg;  wire sub_v;
  wire [31:0] mul_res;  wire [4:0] mul_flg;  wire mul_v;
  wire [31:0] div_res;  wire [4:0] div_flg;  wire div_v;

  // Round mode fijo: nearest-even (RNE)
  fp_addsub_rne u_add (.clk(clk),.rst(rst),.start(start & ~take_special),.sub(1'b0),
                       .a(a),.b(b),.y(add_res),.flags(add_flg),.valid(add_v));
  fp_addsub_rne u_sub (.clk(clk),.rst(rst),.start(start & ~take_special),.sub(1'b1),
                       .a(a),.b(b),.y(sub_res),.flags(sub_flg),.valid(sub_v));
  fp_mul_rne    u_mul (.clk(clk),.rst(rst),.start(start & ~take_special),
                       .a(a),.b(b),.y(mul_res),.flags(mul_flg),.valid(mul_v));
  fp_div_rne    u_div (.clk(clk),.rst(rst),.start(start & ~take_special),
                       .a(a),.b(b),.y(div_res),.flags(div_flg),.valid(div_v));

  reg [31:0] y_r;
  reg [4:0]  f_r;
  reg        v_r;

  always @* begin
    if (take_special) begin
      y_r = special_res;
      f_r = special_flags;
      v_r = start; // listo inmediato (1 ciclo) si así lo deseas
    end else begin
      case (op)
        3'b000: begin y_r = add_res; f_r = add_flg; v_r = add_v; end
        3'b001: begin y_r = sub_res; f_r = sub_flg; v_r = sub_v; end
        3'b010: begin y_r = mul_res; f_r = mul_flg; v_r = mul_v; end
        3'b011: begin y_r = div_res; f_r = div_flg; v_r = div_v; end
        default: begin y_r=32'd0; f_r=5'd0; v_r=1'b1; end
      endcase
    end
  end

  assign result    = y_r;
  assign flags     = f_r;
  assign valid_out = v_r;

endmodule
