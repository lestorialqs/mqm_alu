`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2025 14:31:39
// Design Name: 
// Module Name: dff
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


module flopenr4 (
	clk,
	reset,
	en,
	d0,
    d1,
    d2,
    d3,
	q0,
    q1,
    q2,
    q3
);
	parameter WIDTH = 8;
	input wire clk;
	input wire reset;
	input wire en;
	input wire [WIDTH - 1:0] d0;
    input wire [WIDTH - 1:0] d1;
    input wire [WIDTH - 1:0] d2;
    input wire [WIDTH - 1:0] d3;

	output reg [WIDTH - 1:0] q0;
    output reg [WIDTH - 1:0] q1;
    
    output reg [WIDTH - 1:0] q2;
    output reg [WIDTH - 1:0] q3;

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			q0 <= 0;
            q1 <= 0;
            q2 <= 0;
            q3 <= 0;
        end
		else if(en)begin
			q0 <= d0;
            q1 <= d1;
            q2 <= d2;
            q3 <= d3;
        end
    end
endmodule


module flopr4 (
	clk,
	reset,
	d0,
    d1,
    d2,
    d3,
	q0,
    q1,
    q2,
    q3
);
	parameter WIDTH = 8;
	input wire clk;
	input wire reset;
	input wire [WIDTH - 1:0] d0;
    input wire [WIDTH - 1:0] d1;
    input wire [WIDTH - 1:0] d2;
    input wire [WIDTH - 1:0] d3;

	output reg [WIDTH - 1:0] q0;
    output reg [WIDTH - 1:0] q1;
    
    output reg [WIDTH - 1:0] q2;
    output reg [WIDTH - 1:0] q3;

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			q0 <= 0;
            q1 <= 0;
            q2 <= 0;
            q3 <= 0;
        end
		else begin
			q0 <= d0;
            q1 <= d1;
            q2 <= d2;
            q3 <= d3;
        end
    end
endmodule

module flopr3 (
	clk,
	reset,
	d0,
    d1,
    d2,
	q0,
    q1,
    q2
);
	parameter WIDTH = 8;
	input wire clk;
	input wire reset;
	input wire [WIDTH - 1:0] d0;
    input wire [WIDTH - 1:0] d1;
    input wire [WIDTH - 1:0] d2;

	output reg [WIDTH - 1:0] q0;
    output reg [WIDTH - 1:0] q1;
    
    output reg [WIDTH - 1:0] q2;
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			q0 <= 0;
            q1 <= 0;
            q2 <= 0;
        end
		else begin
			q0 <= d0;
            q1 <= d1;
            q2 <= d2;
        end
    end
endmodule
module flopr2 (
	clk,
	reset,
	d0,
    d1,
	q0,
    q1
);
	parameter WIDTH = 8;
	input wire clk;
	input wire reset;
	input wire [WIDTH - 1:0] d0;
    input wire [WIDTH - 1:0] d1;
	output reg [WIDTH - 1:0] q0;
    output reg [WIDTH - 1:0] q1;
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			q0 <= 0;
            q1 <= 0;
        end
		else begin
			q0 <= d0;
            q1 <= d1;
        end
    end
endmodule



module flopenr (
	clk,
	reset,
	en,
	d,
	q
);
	parameter WIDTH = 8;
	input wire clk;
	input wire reset;
	input wire en;
	input wire [WIDTH - 1:0] d;
	output reg [WIDTH - 1:0] q;
	always @(posedge clk or posedge reset)
		if (reset)
			q <= 0;
		else if (en)
			q <= d;
endmodule

module flopr (
	clk,
	reset,
	d,
	q
);
	parameter WIDTH = 8;
	input wire clk;
	input wire reset;
	input wire [WIDTH - 1:0] d;
	output reg [WIDTH - 1:0] q;

	always @(posedge clk or posedge reset) begin
		if (reset)
			q <= {WIDTH {1'b0}}; // Reset to 0
		else
			q <= d;
	end
endmodule


// module mux4(d0,d1,d2,d3,s,y); // <-- Elimina esta línea
module mux4( // <-- Añade #(...) para el parámetro
    d0,d1,d2,d3,s,y 
); // <-- Añade ( ) para los puertos
parameter WIDTH = 8;
    input  wire [WIDTH-1:0] d0;
    input  wire [WIDTH-1:0] d1;
    input  wire [WIDTH-1:0] d2;
    input  wire [WIDTH-1:0] d3;
    input  wire [1:0] s;
    output wire [WIDTH-1:0] y;
    // parameter WIDTH = 8; // <-- Elimina esta línea (ya está arriba)

    // Lógica corregida:
    assign y = s[1] ? (s[0] ? d3 : d2) : (s[0] ? d1 : d0);
endmodule
module mux2(
	d0,
	d1,
	s,
	y
);
	parameter WIDTH = 8;
	input wire [WIDTH - 1:0] d0;
	input wire [WIDTH - 1:0] d1;
	input wire s;
	output wire [WIDTH - 1:0] y;
	assign y = (s ? d1 : d0);
endmodule
