`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2025 11:37:29
// Design Name: 
// Module Name: fp_mul_rne
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

////////////////////////////////////////////////////////////////////////////////
// MULTIPLICACIÓN CORREGIDA - IEEE 754 Single Precision
////////////////////////////////////////////////////////////////////////////////
module fp_mul_rne(
  input clk, rst, start,
  input [31:0] a, b,
  output reg [31:0] y,
  output reg [4:0]  flags,    // {NV,DZ,OF,UF,NX}
  output reg        valid
);
  // Unpack IEEE-754 single precision
  wire sa=a[31]; wire [7:0] ea=a[30:23]; wire [22:0] fa=a[22:0];
  wire sb=b[31]; wire [7:0] eb=b[30:23]; wire [22:0] fb=b[22:0];

  wire a_den=(ea==8'd0), b_den=(eb==8'd0);
  
  // Mantisa completa: 1.fraction (24 bits)
  wire [23:0] ma = {~a_den, fa};  
  wire [23:0] mb = {~b_den, fb};
  
  wire s = sa ^ sb;

  // Producto: 24 × 24 = 48 bits
  wire [47:0] prod = ma * mb;

  // El producto está en el rango [1.0, 4.0) en formato de punto fijo
  // prod[47:46] contienen la parte entera (00, 01, 10, o 11)
  // Si prod[47]=1, el resultado es ?2.0, formato: 1X.FFFF...
  // Si prod[47]=0 y prod[46]=1, resultado en [1.0,2.0), formato: 01.FFFF...
  
  wire lead = prod[47];
  
  // Exponente sin bias: (ea-127) + (eb-127) = ea+eb-254
  wire [8:0] exp_raw = {1'b0, ea} + {1'b0, eb} - 9'd254;
  
  // Normalizar: si lead=1, incrementar exponente (shift der implícito)
  wire [8:0] exp_normalized = lead ? (exp_raw + 9'd1) : exp_raw;
  
  // Extraer mantisa: necesitamos los 24 bits DESPUÉS del bit implícito
  // Si lead=1: prod = 1X.FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF (48 bits)
  //            bit implícito está en prod[47]
  //            mantisa de 23 bits está en prod[46:24]
  // Si lead=0: prod = 01.FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  //            bit implícito está en prod[46]  
  //            mantisa de 23 bits está en prod[45:23]
  
  wire [22:0] mantissa_23 = lead ? prod[46:24] : prod[45:23];
  wire [23:0] round_bits  = lead ? prod[23:0]  : prod[22:0];
  
  // Guard, Round, Sticky para redondeo
  wire G = lead ? prod[23] : prod[22];
  wire R = lead ? prod[22] : prod[21];
  wire S = lead ? (|prod[21:0]) : (|prod[20:0]);
  
  // Round to nearest, ties to even
  wire lsb = mantissa_23[0];
  wire round_up = G & (R | S | lsb);
  
  wire [23:0] mantissa_rounded = {1'b0, mantissa_23} + (round_up ? 24'd1 : 24'd0);
  
  // Si el redondeo causa carry out, incrementar exponente
  wire carry_out = mantissa_rounded[23];
  wire [8:0] exp_final = carry_out ? (exp_normalized + 9'd1) : exp_normalized;
  
  // Fracción final (23 bits, sin bit implícito)
  wire [22:0] frac_final = carry_out ? mantissa_rounded[22:0] : mantissa_rounded[22:0];
  
  // Agregar bias de 127
  wire [8:0] exp_biased = exp_final + 9'd127;
  
  // Detectar overflow/underflow
  wire overflow  = (exp_biased >= 9'd255);
  wire underflow = (exp_biased <= 9'd0);
  
  wire [7:0] exp_out = overflow  ? 8'hFF :
                       underflow ? 8'h00 : 
                       exp_biased[7:0];

  wire NV = 1'b0;
  wire DZ = 1'b0;
  wire OF = overflow;
  wire UF = underflow && (|mantissa_23);
  wire NX = (G|R|S) || OF || UF;

  always @(posedge clk or posedge rst) begin
    if (rst) begin 
      y     <= 32'd0;
      flags <= 5'd0;
      valid <= 1'b0;
    end
    else if (start) begin
      y     <= {s, exp_out, frac_final};
      flags <= {NV, DZ, OF, UF, NX};
      valid <= 1'b1;
    end 
    else begin
      valid <= 1'b0;
    end
  end
  
endmodule
