`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2025 11:40:05
// Design Name: 
// Module Name: convertion
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


module fp16_to_fp32(input [15:0] h, output [31:0] s);
  wire sign=h[15]; wire [4:0] eh=h[14:10]; wire [9:0] fh=h[9:0];
  wire is_den = (eh==0);
  wire is_inf = (eh==5'h1F) && (fh==0);
  wire is_nan = (eh==5'h1F) && (fh!=0);
  wire [7:0] e = is_den ? 8'd0 : (eh - 5'd15 + 8'd127);
  wire [22:0] f = {fh,13'd0};
  assign s = is_nan ? 32'h7FC0_0000 :
             is_inf ? {sign,8'hFF,23'd0} :
                      {sign,e,f};
endmodule

module fp32_to_fp16(input [31:0] s, output [15:0] h);
  wire sign=s[31]; wire [7:0] es=s[30:23]; wire [22:0] fs=s[22:0];
  wire is_den = (es==0);
  wire is_inf = (es==8'hFF) && (fs==0);
  wire is_nan = (es==8'hFF) && (fs!=0);
  wire [4:0] e = is_den ? 5'd0 : (es - 8'd127 + 5'd15);
  wire [9:0] f = fs[22:13]; // sin rounding aquí (puedes añadirlo)
  assign h = is_nan ? 16'h7E00 :
             is_inf ? {sign,5'h1F,10'd0} :
                      {sign,e,f};
endmodule

