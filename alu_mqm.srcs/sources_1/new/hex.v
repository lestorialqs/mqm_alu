`timescale 1ns / 1ps


module hex_display(
    input clk,
    input reset,
    input [15:0] entry,
    output wire [7:0] catode,
    output wire [3:0] anode
);
    wire scl_clk;
    wire [3:0] digit;
    
clock_divider2 sc (
        .clk(clk),            // <-- El puerto se llama 'clk'
        .reset(reset),
        .slow_clk_enable(scl_clk) // <-- El puerto se llama 'slow_clk_enable'
    );
    
    DisplayMultiplexer mux(
        .clk(scl_clk),
        .reset(reset),
        .data(entry),
        .digit(digit),
        .anode(anode)
    );
    
    HexTo7Segment decoder(
        .digit(digit),
        .catode(catode)
    );
endmodule


module clock_divider2 #(
    // Parámetro para definir el factor de división.
    // El reloj de salida tendrá una frecuencia de clk_in / (2 * DIVISOR)
    // Ejemplo: Para dividir por 50,000,000 / 1000 Hz = 50,000
    parameter DIVISOR = 262144 // Equivalente a 2^18 para que divida por 2^19
) (
    input  wire clk,
    input  wire reset, // Señal de reset añadida
    output reg  slow_clk_enable // Se renombra para mayor claridad
);

    // El ancho del contador se calcula automáticamente
    reg [$clog2(DIVISOR)-1:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Estado inicial predecible
            counter <= 0;
            slow_clk_enable <= 1'b0;
        end else begin
            if (counter == DIVISOR - 1) begin
                counter <= 0;
                slow_clk_enable <= ~slow_clk_enable; // Conmuta la salida
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule

module DisplayMultiplexer (
    input clk, // Este es scl_clk
    input reset,
    input [15:0] data, // Señal asíncrona (result_from_instance)
    output reg [3:0] digit,
    output reg [3:0] anode
);
    reg [1:0] digit_counter;
    reg [15:0] data_sync; // Registro para sincronizar

    // Bloque Síncrono (manejado por scl_clk)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            digit_counter <= 2'b00;
            data_sync <= 16'h0000;
        end else begin
            digit_counter <= digit_counter + 1;
            data_sync <= data; // Muestrear 'data'
        end
    end

    // Bloque Combinacional (ORDEN CORREGIDO y usa data_sync)
    always @(*) begin
        case(digit_counter)
            // Dígito 0 (Menos significativo - Derecha)
            2'b00: begin
                digit = data_sync[3:0]; // <-- USA data_sync
                anode = 4'b1110; // Activa AN0
            end
            // Dígito 1
            2'b01: begin
                digit = data_sync[7:4]; // <-- USA data_sync
                anode = 4'b1101; // Activa AN1
            end
            // Dígito 2
            2'b10: begin
                digit = data_sync[11:8]; // <-- USA data_sync
                anode = 4'b1011; // Activa AN2
            end
            // Dígito 3 (Más significativo - Izquierda)
            2'b11: begin
                digit = data_sync[15:12]; // <-- USA data_sync
                anode = 4'b0111; // Activa AN3
            end
            default: begin
                digit = 4'hE;
                anode = 4'b1111;
            end
        endcase
    end
endmodule


module HexTo7Segment (
    input  [3:0] digit,      // Entrada hexadecimal de 4 bits
    output reg [7:0] catode  // Salida para cátodos (a,b,c,d,e,f,g,dp)
);
    // Mapeo de segmentos: 0 = ON, 1 = OFF (para ánodo común)
    // Orden: gfe_dcba. (Se omite el punto decimal 'dp')
    localparam ZERO  = 8'b1_000000;
    localparam ONE   = 8'b1_111001;
    localparam TWO   = 8'b0_100100;
    localparam THREE = 8'b0_110000;
    localparam FOUR  = 8'b0_011001;
    localparam FIVE  = 8'b0_010010;
    localparam SIX   = 8'b0_000010;
    localparam SEVEN = 8'b1_111000;
    localparam EIGHT = 8'b0_000000;
    localparam NINE  = 8'b0_010000;
    localparam A     = 8'b0_001000;
    localparam B     = 8'b0_000011;
    localparam C     = 8'b1_000110;
    localparam D     = 8'b0_100001;
    localparam E     = 8'b0_000110;
    localparam F     = 8'b0_001110;
    localparam BLANK = 8'b1_111111; // Display apagado

    // El punto decimal siempre está apagado, por eso catode[7] = 1
    always @(*) begin
        case(digit)
            4'h0: catode = {1'b1, ZERO[6:0]};
            4'h1: catode = {1'b1, ONE[6:0]};
            4'h2: catode = {1'b1, TWO[6:0]};
            4'h3: catode = {1'b1, THREE[6:0]};
            4'h4: catode = {1'b1, FOUR[6:0]};
            4'h5: catode = {1'b1, FIVE[6:0]};
            4'h6: catode = {1'b1, SIX[6:0]};
            4'h7: catode = {1'b1, SEVEN[6:0]};
            4'h8: catode = {1'b1, EIGHT[6:0]};
            4'h9: catode = {1'b1, NINE[6:0]};
            4'hA: catode = {1'b1, A[6:0]};
            4'hB: catode = {1'b1, B[6:0]};
            4'hC: catode = {1'b1, C[6:0]};
            4'hD: catode = {1'b1, D[6:0]};
            4'hE: catode = {1'b1, E[6:0]};
            4'hF: catode = {1'b1, F[6:0]};
            default: catode = BLANK;
        endcase
    end
endmodule


module clockdivider2_logic (
    input in_clk,
    input reset, // Añadido reset
    output reg out_clk
);
    reg [28:0] counter = 0;
    
    always @(posedge in_clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            out_clk <= 1'b0;
        end else begin
            counter <= counter + 1;
            // Genera un toggle (cambio) cuando el contador llega al final
            if (counter == 29'h1FFFFFFF) begin 
                out_clk <= ~out_clk;
            end
        end
    end
endmodule