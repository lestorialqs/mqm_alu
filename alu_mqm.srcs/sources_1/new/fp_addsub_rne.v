`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2025 11:36:58
// Design Name: 
// Module Name: fp_addsub_rne
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


////////////////////////////////////////////////////////////////////
module fp_addsub_rne(
  input         clk, rst, start,
  input         sub,            // 0=ADD, 1=SUB  (y = a + (-1)^sub b)
  input  [31:0] a, b,
  output reg [31:0] y,
  output reg [4:0]  flags,      // {NV,DZ,OF,UF,NX}
  output reg        valid
);
  // Unpack
  wire sa=a[31]; wire [7:0] ea=a[30:23]; wire [22:0] fa=a[22:0];
  wire sb=b[31]; wire [7:0] eb=b[30:23]; wire [22:0] fb=b[22:0];

  // Efectivo signo de B en suma/resta
  wire sb_eff = sb ^ sub;

  // Añadir bit implícito (1 para normales, 0 para subnormales)
  wire a_den = (ea==8'd0);
  wire b_den = (eb==8'd0);
  wire [24:0] ma0 = {~a_den, fa, 1'b0}; // 1.mantisa + bit extra
  wire [24:0] mb0 = {~b_den, fb, 1'b0};

  // Alinear al mayor exponente
  wire [7:0] e_max = (ea>=eb)? ea : eb;
  wire [7:0] da = e_max - ea;
  wire [7:0] db = e_max - eb;

  wire [49:0] ma_sh = {ma0, 25'd0} >> da;
  wire [49:0] mb_sh = {mb0, 25'd0} >> db;

  // Suma/resta según signos efectivos
  wire same_sign = (sa == sb_eff);
  wire [50:0] sum_raw = same_sign ? ({1'b0,ma_sh} + {1'b0,mb_sh})
                                   : (ma_sh >= mb_sh ? ({1'b0,ma_sh} - {1'b0,mb_sh})
                                                     : ({1'b0,mb_sh} - {1'b0,ma_sh}));

  // Signo del resultado
  wire sign_out = same_sign ? sa : (ma_sh >= mb_sh ? sa : sb_eff);

  // Normalización usando priority encoder simplificado
  wire [7:0]  exp_norm;
  wire [26:0] mant_norm;
  
  // Detectar la posición del bit más significativo
  assign exp_norm = sum_raw[50] ? (e_max + 8'd1) :
                    sum_raw[49] ? e_max :
                    sum_raw[48] ? (e_max - 8'd1) :
                    sum_raw[47] ? (e_max - 8'd2) :
                    sum_raw[46] ? (e_max - 8'd3) :
                    sum_raw[45] ? (e_max - 8'd4) :
                    sum_raw[44] ? (e_max - 8'd5) :
                    sum_raw[43] ? (e_max - 8'd6) :
                    sum_raw[42] ? (e_max - 8'd7) :
                    sum_raw[41] ? (e_max - 8'd8) :
                    sum_raw[40] ? (e_max - 8'd9) :
                    sum_raw[39] ? (e_max - 8'd10) :
                    sum_raw[38] ? (e_max - 8'd11) :
                    sum_raw[37] ? (e_max - 8'd12) :
                    sum_raw[36] ? (e_max - 8'd13) :
                    sum_raw[35] ? (e_max - 8'd14) :
                    sum_raw[34] ? (e_max - 8'd15) :
                    sum_raw[33] ? (e_max - 8'd16) :
                    sum_raw[32] ? (e_max - 8'd17) :
                    sum_raw[31] ? (e_max - 8'd18) :
                    sum_raw[30] ? (e_max - 8'd19) :
                    sum_raw[29] ? (e_max - 8'd20) :
                    sum_raw[28] ? (e_max - 8'd21) :
                    sum_raw[27] ? (e_max - 8'd22) :
                    sum_raw[26] ? (e_max - 8'd23) :
                    sum_raw[25] ? (e_max - 8'd24) :
                    sum_raw[24] ? (e_max - 8'd25) : 8'd0;

  assign mant_norm = sum_raw[50] ? sum_raw[50:24] :
                     sum_raw[49] ? sum_raw[49:23] :
                     sum_raw[48] ? sum_raw[48:22] :
                     sum_raw[47] ? sum_raw[47:21] :
                     sum_raw[46] ? sum_raw[46:20] :
                     sum_raw[45] ? sum_raw[45:19] :
                     sum_raw[44] ? sum_raw[44:18] :
                     sum_raw[43] ? sum_raw[43:17] :
                     sum_raw[42] ? sum_raw[42:16] :
                     sum_raw[41] ? sum_raw[41:15] :
                     sum_raw[40] ? sum_raw[40:14] :
                     sum_raw[39] ? sum_raw[39:13] :
                     sum_raw[38] ? sum_raw[38:12] :
                     sum_raw[37] ? sum_raw[37:11] :
                     sum_raw[36] ? sum_raw[36:10] :
                     sum_raw[35] ? sum_raw[35:9] :
                     sum_raw[34] ? sum_raw[34:8] :
                     sum_raw[33] ? sum_raw[33:7] :
                     sum_raw[32] ? sum_raw[32:6] :
                     sum_raw[31] ? sum_raw[31:5] :
                     sum_raw[30] ? sum_raw[30:4] :
                     sum_raw[29] ? sum_raw[29:3] :
                     sum_raw[28] ? sum_raw[28:2] :
                     sum_raw[27] ? sum_raw[27:1] :
                     sum_raw[26] ? sum_raw[26:0] :
                     sum_raw[25] ? {sum_raw[25:0], 1'b0} :
                     sum_raw[24] ? {sum_raw[24:0], 2'b0} : 27'd0;

  // Round to nearest even
  wire [23:0] mant = mant_norm[26:3];   // Mantisa de 24 bits
  wire        G    = mant_norm[2];       // Guard
  wire        R    = mant_norm[1];       // Round
  wire        S    = mant_norm[0];       // Sticky
  wire        tie  = G & ~R & ~S;
  wire        incr = (G & (R|S)) | (tie & mant[0]);

  wire [24:0] mant_rounded = {1'b0, mant} + (incr ? 25'd1 : 25'd0);

  // Si el redondeo causa overflow en la mantisa
  wire [7:0]  exp_final = mant_rounded[24] ? (exp_norm + 8'd1) : exp_norm;
  wire [22:0] frac_final = mant_rounded[24] ? mant_rounded[23:1] : mant_rounded[22:0];

  // Flags
  wire NV = 1'b0;
  wire DZ = 1'b0;
  wire OF = (exp_final >= 8'hFF);
  wire UF = (exp_final == 8'h00) && (|frac_final);
  wire NX = (G|R|S) | OF | UF;

  // Empaquetar resultado
  wire [31:0] pack = { sign_out, exp_final, frac_final };

  // Registro de salida
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      y <= 32'd0;
      flags <= 5'd0;
      valid <= 1'b0;
    end else if (start) begin
      y <= pack;
      flags <= {NV, DZ, OF, UF, NX};
      valid <= 1'b1;
    end else begin
      valid <= 1'b0;
    end
  end
  
endmodule
