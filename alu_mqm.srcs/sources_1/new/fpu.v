`timescale 1ns / 1ps
// MÓDULO FPU (sin cambios)
// Este módulo selecciona entre fp16_new y fp32_new
module fpu_new (
    // ---- NUEVAS ENTRADAS/SALIDAS DE CONTROL SECUENCIAL ----
    input  wire        clk,        // Reloj principal (rápido)
    input  wire        rst,        // Reset
    input  wire        start,      // Señal para iniciar la operación
    output wire        valid_out,  // Indica que el resultado está listo

    // ---- ENTRADAS/SALIDAS ORIGINALES (FPUControl ahora [1:0]) ----
    input  wire [31:0] SrcA,
    input  wire [31:0] SrcB,
    input  wire [1:0]  FPUControl, // 00 sum, 01 res, 10 mul, 11 div
    input  wire        precision,  // 0 = FP32, 1 = FP16
    output wire [31:0] FPUResult,
    output wire [4:0]  FPUFlags    // {NV, DZ, OF, UF, NX}
);

    // --- Conversores FP16 <-> FP32 ---
    wire [31:0] SrcA_fp32_from_fp16;
    wire [31:0] SrcB_fp32_from_fp16;
    wire [15:0] result_fp16_from_fp32;

    fp16_to_fp32 u_conv_a_in (.h(SrcA[15:0]), .s(SrcA_fp32_from_fp16));
    fp16_to_fp32 u_conv_b_in (.h(SrcB[15:0]), .s(SrcB_fp32_from_fp16));
    fp32_to_fp16 u_conv_res_out (.s(core32_result), .h(result_fp16_from_fp32)); // Conectado a la salida del core32

    // --- Selección de Operandos para los Cores ---
    wire [31:0] core32_a_in = SrcA; // Core32 siempre usa los 32 bits completos
    wire [31:0] core32_b_in = SrcB;
    wire [15:0] core16_a_in = SrcA[15:0]; // Core16 usa los 16 bits bajos
    wire [15:0] core16_b_in = SrcB[15:0];

    // --- Mapeo de Control (FPUControl -> op) ---
    // Asumiendo que op[2] siempre es 0 (antes era ALU/FPU select)
    wire [2:0] core_op = {1'b0, FPUControl};

    // --- Instancia del Core FP32 ---
    wire [31:0] core32_result;
    wire [4:0]  core32_flags;
    wire        core32_valid;

    fp_core32 u_core32 (
        .clk(clk), .rst(rst),
        .start(start & ~precision), // Activar solo si start=1 y precision=0
        .op(core_op),
        .a(core32_a_in), .b(core32_b_in),
        .result(core32_result),
        .flags(core32_flags),
        .valid_out(core32_valid)
    );

    // --- Instancia del Core FP16 (¡NECESITAS CREAR ESTE MÓDULO!) ---
    // Debería tener una interfaz similar a fp_core32 pero operar internamente con 16 bits
    // Podría reutilizar fp_addsub_rne, etc. si son parametrizables, o necesitar versiones _fp16.
    wire [15:0] core16_result;
    wire [4:0]  core16_flags;
    wire        core16_valid;

    /* // Descomenta cuando tengas el módulo fp_core16
    fp_core16 u_core16 (
        .clk(clk), .rst(rst),
        .start(start & precision), // Activar solo si start=1 y precision=1
        .op(core_op),
        .a(core16_a_in), .b(core16_b_in),
        .result(core16_result),
        .flags(core16_flags),
        .valid_out(core16_valid)
    );
    */
    // Temporalmente, asigna valores por defecto si fp_core16 no existe aún
     assign core16_result = 16'hDEAD;
     assign core16_flags = 5'b11111;
     assign core16_valid = start & precision; // Asume que termina en 1 ciclo


    // --- Selección de Salidas basado en Precision ---
    wire [31:0] selected_result_32; // Resultado antes de convertir a FP16 si es necesario
    wire [4:0]  selected_flags;
    wire        selected_valid;

    assign selected_result_32 = precision ? {16'h0000, core16_result} : core32_result; // Elige resultado del core activo
    assign selected_flags     = precision ? core16_flags : core32_flags;
    assign selected_valid     = precision ? core16_valid : core32_valid;

    // --- Formateo Final del Resultado ---
    // Si era FP16, usa el valor convertido y formateado. Si era FP32, usa el directo.
    assign FPUResult = precision ? {16'h0000, result_fp16_from_fp32} : selected_result_32;

    // --- Asignación Final de Salidas ---
    assign FPUFlags   = selected_flags;
    assign valid_out  = selected_valid; // Pasar la señal valid hacia arriba

endmodule
