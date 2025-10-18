// MÓDULO FP16 MODIFICADO (Versión Corregida y Sintetizable)
module fp16_new (
    SrcA,
    SrcB,
    FPUControl,
    out_fp16,
    Flags16
);
    input wire [31:0] SrcA;
    input wire [31:0] SrcB;
    input wire FPUControl; // 0 = add 1 = mul
    output wire [31:0] out_fp16;
    output reg [4:0] Flags16;

    // --- Descomposición y Detección de Ceros ---
    wire [15:0] a = SrcA[15:0];
    wire [15:0] b = SrcB[15:0];
    
    wire signA = a[15];
    wire signB = b[15];
    wire [4:0] expA = a[14:10];
    wire [4:0] expB = b[14:10];
    wire [9:0] fracA = a[9:0];
    wire [9:0] fracB = b[9:0];

    // Detección de CERO
    wire is_zeroA = (expA == 5'h00) && (fracA == 10'h00);
    wire is_zeroB = (expB == 5'h00) && (fracB == 10'h00);
    
    // Bit implícito (solo si no es cero)
    wire [10:0] mantA = {~is_zeroA, fracA};
    wire [10:0] mantB = {~is_zeroB, fracB};

    // --- Registros intermedios ---
    reg [10:0] mant_a, mant_b;
    reg [11:0] sum;
    reg [21:0] product;
    reg [4:0] exp_result;
    reg [9:0] frac_result;
    reg sign_result;
    reg [15:0] result;

    // --- Lógica de Normalización de Resta (Reemplazo del 'while') ---
    reg [3:0]  shift_amount; // Cantidad a desplazar (0 a 10)
    reg [11:0] sum_shifted;
    reg [4:0]  exp_shifted;

    always @(*) begin
        // Codificador de Prioridad para 'sum' (que es de 11 bits útiles [10:0])
        if      (sum[10]) shift_amount = 0;
        else if (sum[9])  shift_amount = 1;
        else if (sum[8])  shift_amount = 2;
        else if (sum[7])  shift_amount = 3;
        else if (sum[6])  shift_amount = 4;
        else if (sum[5])  shift_amount = 5;
        else if (sum[4])  shift_amount = 6;
        else if (sum[3])  shift_amount = 7;
        else if (sum[2])  shift_amount = 8;
        else if (sum[1])  shift_amount = 9;
        else if (sum[0])  shift_amount = 10;
        else              shift_amount = 0; // El resultado es cero

        // Aplicar desplazamiento y ajustar exponente
        sum_shifted = sum << shift_amount;
        exp_shifted = exp_result - shift_amount;
    end

    // --- Lógica Principal ---
    always @(*) begin
        Flags16 = 5'b00000; // CORREGIDO: 5 bits

        if (FPUControl == 1'b0) begin
            // === SUMA / RESTA ===
            
            // Detección de ceros
            if (is_zeroA) begin
                result = b; // A + B = B si A es 0
            end else if (is_zeroB) begin
                result = a; // A + B = A si B es 0
            end else begin
                // Alinear exponentes
                if (expA > expB) begin
                    mant_a = mantA;
                    mant_b = mantB >> (expA - expB);
                    exp_result = expA;
                    sign_result = signA;
                end else begin
                    mant_a = mantB;
                    mant_b = mantA >> (expB - expA);
                    exp_result = expB;
                    sign_result = signB;
                end

                if (signA == signB) begin
                    // Suma
                    sum = mant_a + mant_b;
                    if (sum[11]) begin // Overflow de mantisa
                        sum = sum >> 1;
                        exp_result = exp_result + 1;
                    end
                    frac_result = sum[9:0];
                end else begin
                    // Resta
                    if (mant_a >= mant_b) begin
                        sum = mant_a - mant_b;
                        sign_result = (expA > expB) ? signA : signB;
                    end else begin
                        sum = mant_b - mant_a;
                        sign_result = (expA > expB) ? signB : signA;
                    end

                    // Aplicar la normalización (del bloque 'always' de arriba)
                    frac_result = sum_shifted[9:0];
                    exp_result = exp_shifted;
                end
                
                result = {sign_result, exp_result, frac_result};
            end

        end else begin
            // === MULTIPLICACIÓN ===
            if (is_zeroA || is_zeroB) begin
                result = 16'h0000; // A * B = 0 si alguno es 0
            end else begin
                sign_result = signA ^ signB;
                exp_result = expA + expB - 5'd15; // bias = 15
                
                product = mantA * mantB; // 11 bits * 11 bits = 22 bits
                
                if (product[21]) begin
                    frac_result = product[20:11];
                    exp_result = exp_result + 1;
                end else begin
                    frac_result = product[19:10];
                end
                
                result = {sign_result, exp_result, frac_result};
            end
        end
    end
    
    // CORREGIDO: Escribe el resultado de 16 bits en la parte baja
    assign out_fp16 = {16'h0000, result};
    
endmodule