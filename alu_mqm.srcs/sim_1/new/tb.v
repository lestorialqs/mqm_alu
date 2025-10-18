`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2025 04:44:55
// Design Name: 
// Module Name: tb
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


module tb(

    );
    reg [15:0] entry; 
    reg clk;
    reg reset;
    
    wire [15:0] result;
    wire [4:0] flags;
    wire [3:0] current_fsm_state;
    instance_top top1(clk, reset,entry, result, flags,current_fsm_state);
    
    always #5 clk = ~clk;
    
    initial begin
    clk =1;reset=1;
    #5;
    reset =0;
    entry = 16'h0000;
    
    #10;
    
    entry = 16'h4000;
    
    #10;
    entry = 16'h0000;
    
    #10;
    entry = 16'h4000;
    
    #10;
    entry = 16'h0000;
    
    
    
    #30;
    
    
    
    
    $finish;
    end
    
    
    
    
        
endmodule
