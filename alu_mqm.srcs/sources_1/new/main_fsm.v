`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2025 13:39:27
// Design Name: 
// Module Name: main_fsm
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


module mainfsm (
	clk,
	reset,
	entry,
	op_enable,
	isResult,
	partResult,
	alu_enable,
	showFlags,
	current_state,
	fpu_valid,
	start_fpu
	
    
);

	input wire clk;
	input wire reset;
	input wire [2:0] entry; // <-- MODIFICADO (de [3:0] a [2:0])
	input  wire fpu_valid;
    output wire showFlags;
	output wire op_enable;
	output wire isResult;
	output wire [1:0] partResult;
	output wire alu_enable;
	output wire [3:0] current_state;
	output wire start_fpu;
	
	reg [3:0] state;
	reg [3:0] nextstate;
	reg [5:0] controls;
	localparam [3:0] S0 = 0;
	localparam [3:0] S1 = 1;
	localparam [3:0] S2 = 2;
    localparam [3:0] S3 = 3;
    
    localparam [3:0] S4 = 4;
    localparam [3:0] S5 = 5;
    localparam [3:0] S6 = 6;
	localparam [3:0] S7 = 7;
	localparam [3:0] S8 = 8;
    localparam [3:0] S9 = 9;
    localparam [3:0] S10 = 10;
    localparam [3:0] S11 = 11;


	// state register
	always @(posedge clk or posedge reset)
		if (reset)
			state <= S0;
		else
			state <= nextstate;

  	// next state logic
	always @(*)
		casex (state)
			S0: if(entry[2] == 1'b0)
			      nextstate = S1;
			     else 
			     nextstate = S8; 
			S1: nextstate = S2;
			S2: nextstate = S3;
			S3: nextstate = S4;
			S4: nextstate = S5;
			S5: if (fpu_valid) nextstate = S6; // ESPERAR a que FPU termine (32b)
                else nextstate = S5; 
			S6: nextstate = S7;
			S7: nextstate = S0;
			S8: nextstate = S9;
			S9: nextstate = S10;
			S10: if (fpu_valid) nextstate = S11; // ESPERAR a que FPU termine (16b)
                 else nextstate = S10;
            S11: nextstate = S0;
            default: nextstate = S0;
		endcase

    

	always @(*)
		case (state)
            S0: controls = 7'b1_0_0_11_0_0; // op_enable=1
            S1: controls = 7'b0_0_0_11_0_0;
            S2: controls = 7'b0_0_0_11_0_0;
            S3: controls = 7'b0_0_0_11_0_0;
            S4: controls = 7'b0_0_0_11_0_0;
            S5: controls = 7'b0_1_0_11_1_0; // alu_enable=1 (Calculate 32b)
            S6: controls = 7'b0_0_1_00_0_0; // isResult=1, partResult=00 (Select d0=part_ab -> High 32b)
            S7: controls = 7'b0_0_1_01_0_1; // isResult=1, partResult=10 (Select d2=part_bb -> Low 32b), showFlags=1 <-- CORREGIDO
            S8: controls = 7'b0_0_0_11_0_0;
            S9: controls = 7'b0_0_0_11_0_0;
            S10: controls = 7'b0_1_0_11_1_0; // alu_enable=1 (Calculate 16b)
            S11: controls = 7'b0_0_1_10_0_1; // isResult=1, partResult=10 (Select d2=part_bb -> Low 16b), showFlags=1 <-- CORREGIDO
            default: controls = 7'bxxxxxxx;
		endcase
	assign {op_enable, start_fpu, isResult , partResult,alu_enable, showFlags} = controls;
	assign current_state = state;
endmodule
