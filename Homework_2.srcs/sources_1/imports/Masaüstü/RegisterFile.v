`timescale 1ns / 1ps
module RegisterFile(
    input wire [2:0] OutASel,
    input wire [2:0] OutBSel,
    input wire [2:0] FunSel,
    input wire [3:0] RegSel,
    input wire [3:0] ScrSel,
    input wire [15:0] I,
    input wire Clock, 
    output reg [15:0] OutA,
    output reg [15:0] OutB
    );
    
    reg R1_E;
    wire [15:0] R1_Q;
    
    Register R1 (
        .FunSel(FunSel),  // Giriþ sinyalleri
        .E(R1_E),
        .I(I),
        .Clock(Clock),
        .Q(R1_Q)  // Çýkýþ sinyali
    );
    
    reg R2_E;
    wire [15:0] R2_Q;
    
    Register R2 (
        .FunSel(FunSel),
        .E(R2_E),
        .I(I),
        .Clock(Clock),
        .Q(R2_Q)
    );
    
    reg R3_E;
    wire [15:0] R3_Q;
    
    Register R3 (
        .FunSel(FunSel),
        .E(R3_E),
        .I(I),
        .Clock(Clock),
        .Q(R3_Q)
    );
    
    reg R4_E;
    wire [15:0] R4_Q;
    
    Register R4 (
        .FunSel(FunSel),
        .E(R4_E),
        .I(I),
        .Clock(Clock),
        .Q(R4_Q)
    );
    
    reg S1_E;
    wire [15:0] S1_Q;
    
    Register S1 (
        .FunSel(FunSel),
        .E(S1_E),
        .I(I),
        .Clock(Clock),
        .Q(S1_Q)
    );
    
    reg S2_E;
    wire [15:0] S2_Q;
    
    Register S2 (
        .FunSel(FunSel),
        .E(S2_E),
        .I(I),
        .Clock(Clock),
        .Q(S2_Q)
    );
    
    reg S3_E;
    wire [15:0] S3_Q;
    
    Register S3 (
        .FunSel(FunSel),
        .E(S3_E),
        .I(I),
        .Clock(Clock),
        .Q(S3_Q)
    );
    
    reg S4_E;
    wire [15:0] S4_Q;
    
    Register S4 (
        .FunSel(FunSel),
        .E(S4_E),
        .I(I),
        .Clock(Clock),
        .Q(S4_Q)
    );
    
    always @(*) begin

        case(RegSel)
            4'b0000: begin // All address registers are enabled
                S1_E <= 1;
                S2_E <= 1;
                S3_E <= 1;
                S4_E <= 1;
            end
            4'b0001: begin // R4 is disabled
                S1_E <= 1;
                S2_E <= 1;
                R3_E <= 1;
                R4_E <= 0;
            end
            4'b0010: begin // R3 is disabled
                R1_E <= 1;
                R2_E <= 1;
                R3_E <= 0;
                R4_E <= 1;
            end
            4'b0011: begin // R3 and R4 are disabled
                R1_E <= 1;
                R2_E <= 1;
                R3_E <= 0;
                R4_E <= 0;
            end
            4'b0100: begin // R2 is disabled
                R1_E <= 1;
                R2_E <= 0;
                R3_E <= 1;
                R4_E <= 1;
            end
            4'b0101: begin // R2 and R4 are disabled
                R1_E <= 1;
                R2_E <= 0;
                R3_E <= 1;
                R4_E <= 0;
            end
            4'b0110: begin // R2 and R3 are disabled
                R1_E <= 1;
                R2_E <= 0;
                R3_E <= 0;
                R4_E <= 1;
            end
            4'b0111: begin // R2, R3, and R4 are disabled
                R1_E <= 1;
                R2_E <= 0;
                R3_E <= 0;
                R4_E <= 0;
            end
            4'b1000: begin // R1 is disabled
                R1_E <= 0;
                R2_E <= 1;
                R3_E <= 1;
                R4_E <= 1;
            end
            4'b1001: begin // R1 and R4 are disabled
                R1_E <= 0;
                R2_E <= 1;
                R3_E <= 1;
                R4_E <= 0;
            end
            4'b1010: begin // R1 and R3 are disabled
                R1_E <= 0;
                R2_E <= 1;
                R3_E <= 0;
                R4_E <= 1;
            end
            4'b1011: begin // R1, R3, and R4 are disabled
                R1_E <= 0;
                R2_E <= 1;
                R3_E <= 0;
                R4_E <= 0;
            end
            4'b1100: begin // R1 and R2 are disabled
                R1_E <= 0;
                R2_E <= 0;
                R3_E <= 1;
                R4_E <= 1;
            end
            4'b1101: begin // R1, R2, and R4 are disabled
                R1_E <= 0;
                R2_E <= 0;
                R3_E <= 1;
                R4_E <= 0;
            end
            4'b1110: begin // R1, R2, and R3 are disabled
                R1_E <= 0;
                R2_E <= 0;
                R3_E <= 0;
                R4_E <= 1;
            end
            4'b1111: begin // All address registers are disabled
                R1_E <= 0;
                R2_E <= 0;
                R3_E <= 0;
                R4_E <= 0;
            end
        endcase

        case(ScrSel)
            4'b0000: begin // All address registers are enabled
                S1_E <= 1;
                S2_E <= 1;
                S3_E <= 1;
                S4_E <= 1;
            end
            4'b0001: begin // S4 is disabled
                S1_E <= 1;
                S2_E <= 1;
                S3_E <= 1;
                S4_E <= 0;
            end
            4'b0010: begin // S3 is disabled
                S1_E <= 1;
                S2_E <= 1;
                S3_E <= 0;
                S4_E <= 1;
            end
            4'b0011: begin // S3 and S4 are disabled
                S1_E <= 1;
                S2_E <= 1;
                S3_E <= 0;
                S4_E <= 0;
            end
            4'b0100: begin // S2 is disabled
                S1_E <= 1;
                S2_E <= 0;
                S3_E <= 1;
                S4_E <= 1;
            end
            4'b0101: begin // S2 and S4 are disabled
                S1_E <= 1;
                S2_E <= 0;
                S3_E <= 1;
                S4_E <= 0;
            end
            4'b0110: begin // S2 and S3 are disabled
                S1_E <= 1;
                S2_E <= 0;
                S3_E <= 0;
                S4_E <= 1;
            end
            4'b0111: begin // S2, S3, and S4 are disabled
                S1_E <= 1;
                S2_E <= 0;
                S3_E <= 0;
                S4_E <= 0;
            end
            4'b1000: begin // S1 is disabled
                S1_E <= 0;
                S2_E <= 1;
                S3_E <= 1;
                S4_E <= 1;
            end
            4'b1001: begin // S1 and S4 are disabled
                S1_E <= 0;
                S2_E <= 1;
                S3_E <= 1;
                S4_E <= 0;
            end
            4'b1010: begin // S1 and S3 are disabled
                S1_E <= 0;
                S2_E <= 1;
                S3_E <= 0;
                S4_E <= 1;
            end
            4'b1011: begin // S1, S3, and S4 are disabled
                S1_E <= 0;
                S2_E <= 1;
                S3_E <= 0;
                S4_E <= 0;
            end
            4'b1100: begin // S1 and S2 are disabled
                S1_E <= 0;
                S2_E <= 0;
                S3_E <= 1;
                S4_E <= 1;
            end
            4'b1101: begin // S1, S2, and S4 are disabled
                S1_E <= 0;
                S2_E <= 0;
                S3_E <= 1;
                S4_E <= 0;
            end
            4'b1110: begin // S1, S2, and S3 are disabled
                S1_E <= 0;
                S2_E <= 0;
                S3_E <= 0;
                S4_E <= 1;
            end
            4'b1111: begin // All address registers are disabled
                S1_E <= 0;
                S2_E <= 0;
                S3_E <= 0;
                S4_E <= 0;
            end
        endcase

        case(OutASel)
               
            3'b000: begin 
            OutA <= R1_Q;    
            end
            
            3'b001: begin 
            OutA <= R2_Q;    
            end
            
            3'b010: begin 
            OutA <= R3_Q;    
            end
            
            3'b011: begin 
            OutA <= R4_Q;    
            end
            
            3'b100: begin 
            OutA <= S1_Q;    
            end
            
            3'b101: begin 
            OutA <= S2_Q;    
            end
            
            3'b110: begin 
            OutA <= S3_Q;    
            end
            
            3'b111: begin 
            OutA <= S4_Q;    
            end

        endcase
        
        case(OutBSel)
               
            3'b000: begin 
            OutB <= R1_Q;    
            end
            
            3'b001: begin 
            OutB <= R2_Q;    
            end
            
            3'b010: begin 
            OutB <= R3_Q;    
            end
            
            3'b011: begin 
            OutB <= R4_Q;    
            end
            
            3'b100: begin 
            OutB <= S1_Q;    
            end
            
            3'b101: begin 
            OutB <= S2_Q;    
            end
            
            3'b110: begin 
            OutB <= S3_Q;    
            end
            
            3'b111: begin 
            OutB <= S4_Q;    
            end

        endcase
    end
    
    
    
endmodule