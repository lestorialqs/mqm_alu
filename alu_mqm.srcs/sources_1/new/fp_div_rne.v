`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2025 11:38:37
// Design Name: 
// Module Name: fp_div_rne
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
// DIVISIÓN CORREGIDA - IEEE 754 Single Precision
////////////////////////////////////////////////////////////////////////////////
module fp_div_rne(
  input clk, rst, start,
  input [31:0] a, b,
  output reg [31:0] y,
  output reg [4:0]  flags,    // {NV,DZ,OF,UF,NX}
  output reg        valid
);
  // Unpack
  wire sa=a[31]; wire [7:0] ea=a[30:23]; wire [22:0] fa=a[22:0];
  wire sb=b[31]; wire [7:0] eb=b[30:23]; wire [22:0] fb=b[22:0];

  // Denormales y mantisas con bit implícito (24 bits: 1.f)
  wire a_den = (ea==8'd0);
  wire b_den = (eb==8'd0);
  wire [23:0] ma = {~a_den, fa};
  wire [23:0] mb = {~b_den, fb};

  // Signo
  wire s = sa ^ sb;

  // Casos especiales básicos (div/0 se suele manejar arriba en fp_core32,
  // pero dejamos DZ defensivo aquí por si se llama directo).
  wire dz_local = ( (b_den && (fb==0)) );  // b == 0.0

  // Exponente base (con bias): (ea - eb + 127)
  // NOTA: esto ya está "biaseado" al formato final, y luego ajustamos por normalización/round
  wire signed [10:0] e_base = $signed({3'b0,ea}) - $signed({3'b0,eb}) + 11'sd127;

  // División fija:
  // Escalamos el dividendo para obtener de una sola vez 24 bits de mantisa + 3 GRS (=27 bits)
  // rango esperado de ma/mb ? [0.5, 2). Con <<26:
  //   - si ma/mb ? 1.0 -> cociente ? 2^26 (bit 26 = 1)
  //   - si ma/mb < 1.0 -> cociente ~ [2^25 .. <2^26) (bit 26 = 0) ? normalizar +1 bit
  //   - ma/mb no llega a 2.0 (porque mantisas ? [1,2)), así que no hay overflow por arriba
  wire [49:0] dividend = {ma, 26'd0};    // 24+26=50 bits
  wire [23:0] divisor  = mb;             // 24 bits (¡sin desplazar!)
  wire [49:0] q_full   = dividend / divisor;
  wire [23:0] r_full   = dividend % divisor;

  // Tomamos solo los 27 bits de interés (24 mant + 3 GRS)
  wire [26:0] q27 = q_full[26:0];

  // ¿Cociente tiene 1.xxxxxx (bit26=1) o 0.xxxxxx (bit26=0)?
  wire lead = q27[26];

  // Normalización:
  //  - lead=1 ? ya está en [1.0, 2.0). Mantisa+GRS = q27[26:0]
  //  - lead=0 ? está en [0.5, 1.0). Desplazar 1 a la izq y DECREMENTAR exponente
  wire [26:0] norm27   = lead ? q27           : {q27[25:0], 1'b0};
  wire signed [10:0] e_norm = lead ? e_base   : (e_base - 11'sd1);

  // Extraer mantisa(24) + GRS(3)
  wire [23:0] mant = norm27[26:3];  // [1].[22:0]
  wire        G    = norm27[2];
  wire        R    = norm27[1];
  wire        S    = norm27[0] | (|r_full); // residuo también indica inexacto
  // Round-to-nearest-even
  wire tie  = G & ~R & ~S;
  wire incr = (G & (R|S)) | (tie & mant[0]);
  wire [23:0] mant_r = mant + (incr ? 24'd1 : 24'd0);

  // Si se desborda la mantisa (10.xxxx), desplazamos y subimos exponente SOLO si aún no lo habíamos hecho
  reg [22:0] frac;
  reg signed [10:0] e_adj;
  always @* begin
    if (mant_r[23] && ~lead) begin
      // Caso 0.xxxxx que redondeó a 1.xxxxx ? se normaliza ahora
      frac  = mant_r[22:0];
      e_adj = e_norm + 11'sd1;
    end else if (mant_r[23] && lead) begin
      // Si ya estaba normalizado (lead=1), no volver a subir exponente
      frac  = mant_r[22:0];
      e_adj = e_norm;
    end else begin
      frac  = mant_r[22:0];
      e_adj = e_norm;
    end
  end

  // Saturación de exponente al empaquetar
  wire overflow  = (e_adj >  11'sd254); // 254 es el máx válido antes de 255 (Inf/NaN)
  wire underflow = (e_adj <= 11'sd0);

  wire [7:0] e_out = overflow  ? 8'hFF :
                     underflow ? 8'h00 :
                     e_adj[7:0];

  // Flags IEEE-754 mínimas
  wire NV = 1'b0;
  wire DZ = dz_local;
  wire OF = overflow;
  wire UF = underflow & (|mant); // si hay algo de mantisa, fue underflow con pérdida
  wire NX = (G|R|S) | OF | UF;

  // Registro de salida
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      y     <= 32'd0;
      flags <= 5'd0;
      valid <= 1'b0;
    end else if (start) begin
      // Si DZ, devolver ±Inf (lo normal es manejarlo arriba; aquí nos limitamos a setear flags)
      y     <= {s, e_out, frac};
      flags <= {NV, DZ, OF, UF, NX};
      valid <= 1'b1;
    end else begin
      valid <= 1'b0;
    end
  end
endmodule