`timescale 1ns / 1ps


module top(clk,
 reset,
  entry,
   catode,
    anode, 
    flags,
    led_clk_slow,
    current_fsm_state); // <--- 1. AÑADE EL NUEVO PUERTO);
    
    input clk;
    input reset;
    input [15:0] entry;
    output wire [7:0] catode;
    output wire [3:0] anode;
    output [4:0] flags;
    output wire led_clk_slow; // <--- 2. DECLARA EL PUERTO COMO SALIDA
   output wire [3:0] current_fsm_state;
    wire clk_slow;  
    wire [15:0] result_from_instance; // Cable para la salida
    wire [3:0] fsm_state_internal;
    
    assign led_clk_slow = clk_slow;
clockdivider2_logic clk_div_logic (
        .in_clk(clk),
        .reset(reset),
        .out_clk(clk_slow)
    );  
instance_top ins1 (
        .clk(clk_slow),
        .reset(reset),
        .entry(entry),
        .result(result_from_instance), // Conecta al cable de resultado
        .flags(flags),
        .current_fsm_state(fsm_state_internal)
    );
hex_display hx (
        .clk(clk), 
        .reset(reset),
        .entry(result_from_instance), // Muestra el resultado, no la entrada
        .catode(catode),
        .anode(anode)
    );
    
    assign current_fsm_state = fsm_state_internal;
    
    
    
    

endmodule
