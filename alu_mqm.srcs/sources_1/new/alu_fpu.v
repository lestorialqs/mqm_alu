`timescale 1ns / 1ps

module fpu_unit (
    // ---- NUEVAS ENTRADAS/SALIDAS SECUENCIALES ----
    input  wire        clk,
    input  wire        rst,
    input  wire        start,     // Recibe la señal de inicio
    output wire        valid_out, // Envía la señal de validez

    // ---- INTERFAZ ORIGINAL (Opcode ahora [1:0] si el bit[2] era solo ALU/FPU) ----
    // Si tu opcode[2] *REALMENTE* era precision, mantenlo [2:0]
    // Aquí asumo que tu FSM ahora genera solo la operación [1:0] y la precision [2]
    input  wire [2:0]  opcode,    // [2]=precision, [1:0]=operación
    input  wire [15:0] A1_d, A2_d, B1_d, B2_d, A1_b, A2_b,
    output wire [15:0] part_a,
    output wire [15:0] part_b,
    output wire [4:0]  fpu_flags
);

    wire is_16bit    = opcode[2];
    wire [1:0] op_select = opcode[1:0];

    wire [31:0] SrcA, SrcB;
    assign SrcA = is_16bit ? {16'h0000, A1_b} : {A1_d, A2_d};
    assign SrcB = is_16bit ? {16'h0000, A2_b} : {B1_d, B2_d};

    wire [31:0] fpu_result_internal;
    wire [4:0]  fpu_flags_internal;

    // Instancia el NUEVO fpu_new (secuencial)
    fpu_new fpu_inst (
        .clk(clk),         // <-- Pasa clk
        .rst(rst),         // <-- Pasa rst
        .start(start),     // <-- Pasa start
        .valid_out(valid_out), // <-- Recibe valid_out

        .SrcA(SrcA),
        .SrcB(SrcB),
        .FPUControl(op_select), // Pasa solo los bits de operación
        .precision(is_16bit), // Pasa el bit de precisión
        .FPUResult(fpu_result_internal),
        .FPUFlags(fpu_flags_internal)
    );

    // La lógica de salida no cambia
    assign part_a = is_16bit ? 16'h0000 : fpu_result_internal[31:16];
    assign part_b = fpu_result_internal[15:0];
    assign fpu_flags = fpu_flags_internal;

endmodule