`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2025 23:37:44
// Design Name: 
// Module Name: instance
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


module instance_top(
    clk,
     reset, 
     entry,
     result,
     flags,
     current_fsm_state
    );
    input clk;
    input reset;
    input [15:0] entry;
    
   
    output [15:0] result;
output [4:0] flags; // CORREGIDO: Ancho de [8:0] a [4:0]
output wire [3:0] current_fsm_state;
wire start_fpu;
    wire op_enable;
    
    wire isResult;
    wire [1:0] partResult;
    wire alu_enable;
    wire showFlags;
    wire [3:0] fsm_state_internal;
    wire fpu_valid;
mainfsm fsm_1(
        .clk(clk), // <-- Usa clk rápido
        .reset(reset),
        .entry(entry[2:0]),
        .fpu_valid(fpu_valid), // <-- Conecta valid de DP
        .op_enable(op_enable),
        .start_fpu(start_fpu), // <-- Conecta start a DP
        .isResult(isResult),
        .partResult(partResult),
        .alu_enable(alu_enable),
        .showFlags(showFlags),
        .current_state(fsm_state_internal)
    );
    
    
datapath dp(
        .clk(clk), // <-- Usa clk rápido
        .reset(reset),
        .entry(entry),
        .showFlags(showFlags),
        .op_enable(op_enable),
        .start_fpu(start_fpu), // <-- Conecta start de FSM
        .isResult(isResult),
        .partResult(partResult),
        .alu_enable(alu_enable),
        .result(result),
        .flags(flags),
        .fpu_valid(fpu_valid) // <-- Conecta valid a FSM
        // Quita fsm_state si no lo usas para logs
    );
    assign current_fsm_state = fsm_state_internal;
endmodule
