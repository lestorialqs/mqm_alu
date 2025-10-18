`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2025 14:25:58
// Design Name: 
// Module Name: datapath
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


module datapath(
    
    

    clk,
    reset,
    
    
    entry,
    showFlags,
    op_enable,
    isResult,
    partResult,
    alu_enable,
    result,
    flags,
    fsm_state,
    fpu_valid,
    start_fpu


    );
    input [15:0] entry;
    input clk;
    input reset;
    input showFlags;
    input op_enable;
    input isResult;
    input alu_enable;
    input [1:0] partResult;
    input [3:0] fsm_state;
    input  start_fpu;
    output [15:0] result;
    output [4:0] flags;
    output fpu_valid;
    
     // <-- MODIFICADO (de [8:0] a [4:0])
wire [2:0] opcode; // <-- MODIFICADO (de [3:0] a [2:0])
    wire [2:0] op_save; // <-- MODIFICADO (de [3:0] a [2:0])
    
    
    
    wire [15:0] A1_a;
    wire [15:0] A1_b;
    wire [15:0] A2_b;
    wire [15:0] A1_c;
    wire [15:0] A2_c;
    wire [15:0] B1_c;
    wire [15:0] A1_d;
    wire [15:0] A2_d;
    wire [15:0] B1_d;
    wire [15:0] B2_d;
        wire [15:0] part_a;
    wire [15:0] part_b;
    
    wire [15:0] part_ab;
    wire [15:0] part_bb;
    wire [15:0] part_bc;
    
    wire [4:0] flags_save; // <-- MODIFICADO (de [8:0] a [4:0])
    wire [4:0] fpu_flags; // <-- MODIFICADO (de [8:0] alu_flags a [4:0] fpu_flags)    
    wire [15:0] zeros = 16'h0000;
    wire        fpu_valid_internal; // Renombrado valid_out
    flopenr #(3) op_reg(clk,reset,op_enable,entry[2:0],op_save);
    flopr #(3) op_reg_out(clk,reset,op_save,opcode);
    
    

    flopr #(16) regi1(clk, reset, entry,A1_a);
    
    flopr2 #(16) regi2(clk,reset,A1_a,entry,A1_b,A2_b);
    flopr3 #(16) regi3(clk,reset,A1_b,A2_b,entry,A1_c,A2_c,B1_c);
    flopr4 #(16) regi4(clk,reset,A1_c,A2_c,B1_c,entry,A1_d,A2_d,B1_d,B2_d);
    
    

    // <-- MODIFICADO: Instancia cambiada de 'alu_fpu' a 'fpu_unit'
    fpu_unit instanceFpu (
        .opcode(opcode), // Ahora conecta el opcode [2:0]
        .A1_d(A1_d),
        .A2_d(A2_d),
        .B1_d(B1_d),
        .B2_d(B2_d),
        .A1_b(A1_b),
        .A2_b(A2_b),
        .part_a(part_a),
        .part_b(part_b),
        .fpu_flags(fpu_flags) // Ahora conecta a la salida de 5 bits
    );
        
    
    flopenr #(5) flagreg(clk, reset, alu_enable, fpu_flags, flags_save);
    mux2#(5) mux2flags(5'b00000, flags_save, showFlags, flags);
    
    flopr2 #(16) regi5(clk,reset,part_a,part_b, part_ab, part_bb);
    flopr #(16) regi6(clk,reset,part_bb, part_bc);
    
    
    
    mux4 #(16) muxResult (
            .d0(part_ab),    // Seleccionado cuando s = 2'b00
            .d1(part_bc),    // Seleccionado cuando s = 2'b01
            .d2(part_bb),      // No usado (s = 2'b10)
            .d3(16'h0000),      // No usado (s = 2'b11)
            .s(partResult), // Concatena 0 con tu señal de 1 bit
            .y(result)
        );
    // Pasar la señal de validez hacia arriba
    assign fpu_valid = fpu_valid_internal;
        
endmodule
