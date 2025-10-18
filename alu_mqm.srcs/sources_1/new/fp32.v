// MÓDULO FP32 MODIFICADO (Versión Corregida y Sintetizable)
module fp32_new (
    SrcA,
    SrcB,
    FPUControl,
    out_fp32,
    Flags32
);
    input wire [31:0] SrcA;
    input wire [31:0] SrcB;
    input wire FPUControl; // 0 = add 1 = mul
    output reg [31:0] out_fp32;
    output reg [4:0]  Flags32;
    
    // --- Descomposición y Detección de Casos Especiales ---
    wire sign1 = SrcA[31];
    wire sign2 = SrcB[31];
    wire [7:0] exp1 = SrcA[30:23];
    wire [7:0] exp2 = SrcB[30:23];
    wire [22:0] frac1 = SrcA[22:0];
    wire [22:0] frac2 = SrcB[22:0];
    
    // Detección de CERO (ignora denormalizados por simplicidad)
    wire is_zero1 = (exp1 == 8'h00) && (frac1 == 23'h00);
    wire is_zero2 = (exp2 == 8'h00) && (frac2 == 23'h00);
    
    // Bit implícito (solo si no es cero)
    wire [23:0] mant1 = {~is_zero1, frac1};
    wire [23:0] mant2 = {~is_zero2, frac2};
    
    // --- Registros intermedios ---
    reg [31:0] result;
    reg [4:0] flags;
    reg [23:0] mantissa_a, mantissa_b;
    reg [24:0] sum;
    reg [47:0] product;
    reg [7:0] exp_result;
    reg [22:0] frac_result;
    reg sign_result;

    // --- Lógica de Normalización de Resta (Reemplazo del 'while') ---
    reg [4:0] shift_amount; // Cantidad a desplazar (0 a 23)
    reg [24:0] sum_shifted;
    reg [7:0]  exp_shifted;

    always @(*) begin
        // Este bloque es un "Codificador de Prioridad"
        // Encuentra el primer '1' en 'sum' para saber cuánto desplazar
        // (Esto reemplaza al bucle 'while' y ES SINTETIZABLE)
        if      (sum[23]) shift_amount = 0;
        else if (sum[22]) shift_amount = 1;
        else if (sum[21]) shift_amount = 2;
        else if (sum[20]) shift_amount = 3;
        else if (sum[19]) shift_amount = 4;
        else if (sum[18]) shift_amount = 5;
        else if (sum[17]) shift_amount = 6;
        else if (sum[16]) shift_amount = 7;
        else if (sum[15]) shift_amount = 8;
        else if (sum[14]) shift_amount = 9;
        else if (sum[13]) shift_amount = 10;
        else if (sum[12]) shift_amount = 11;
        else if (sum[11]) shift_amount = 12;
        else if (sum[10]) shift_amount = 13;
        else if (sum[9])  shift_amount = 14;
        else if (sum[8])  shift_amount = 15;
        else if (sum[7])  shift_amount = 16;
        else if (sum[6])  shift_amount = 17;
        else if (sum[5])  shift_amount = 18;
        else if (sum[4])  shift_amount = 19;
        else if (sum[3])  shift_amount = 20;
        else if (sum[2])  shift_amount = 21;
        else if (sum[1])  shift_amount = 22;
        else if (sum[0])  shift_amount = 23;
        else              shift_amount = 0; // El resultado es cero

        // Aplica el desplazamiento y ajusta el exponente
        sum_shifted = sum << shift_amount;
        exp_shifted = exp_result - shift_amount;
    end

    // --- Lógica Principal ---
    always @(*) begin
        flags = 5'b00000;
        
        if (FPUControl == 1'b0) begin
            // === SUMA / RESTA ===
            
            // Detección simple de ceros
            if (is_zero1) begin
                result = SrcB; // A + B = B si A es 0
            end else if (is_zero2) begin
                result = SrcA; // A + B = A si B es 0
            end else begin
                // Alinear exponentes
                if (exp1 > exp2) begin
                    mantissa_a = mant1;
                    mantissa_b = mant2 >> (exp1 - exp2);
                    exp_result = exp1;
                    sign_result = sign1;
                end else begin
                    mantissa_a = mant2;
                    mantissa_b = mant1 >> (exp2 - exp1);
                    exp_result = exp2;
                    sign_result = sign2;
                end
                
                if (sign1 == sign2) begin
                    // Suma
                    sum = mantissa_a + mantissa_b;
                    if (sum[24]) begin // Overflow de mantisa
                        sum = sum >> 1;
                        exp_result = exp_result + 1;
                    end
                    frac_result = sum[22:0];
                end else begin
                    // Resta
                    if (mantissa_a >= mantissa_b) begin
                        sum = mantissa_a - mantissa_b;
                        sign_result = (exp1 > exp2) ? sign1 : sign2;
                    end else begin
                        sum = mantissa_b - mantissa_a;
                        sign_result = (exp1 > exp2) ? sign2 : sign1;
                    end
                    
                    // Aplicar la normalización (del bloque 'always' de arriba)
                    frac_result = sum_shifted[22:0];
                    exp_result = exp_shifted;
                end
                
                result = {sign_result, exp_result, frac_result};
            end
            
        end else begin
            // === MULTIPLICACIÓN ===
            if (is_zero1 || is_zero2) begin
                result = 32'h00000000; // A * B = 0 si alguno es 0
            end else begin
                sign_result = sign1 ^ sign2;
                exp_result = exp1 + exp2 - 8'd127;
                
                product = mant1 * mant2; // 24 x 24 = 48 bits
                
                if (product[47]) begin
                    frac_result = product[46:24];
                    exp_result = exp_result + 1;
                end else begin
                    frac_result = product[45:23];
                end
                
                result = {sign_result, exp_result, frac_result};
            end
        end

        // Salidas
        out_fp32 = result;
        Flags32 = flags;
    end
    
endmodule
