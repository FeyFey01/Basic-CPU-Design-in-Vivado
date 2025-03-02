//When I use clock instead of *, it did not behavior truly
`timescale 1ns / 1ps

module AddressRegisterFile(
    input [2:0] FunSel,     // Function Select
    
    input [2:0] RegSel,     // Register Select
    input [1:0] OutCSel,    // Output C Select
    input [1:0] OutDSel,    // Output D Select
    input [15:0] I,         // Input
    input Clock,
    output reg [15:0] OutC, // Output C
    output reg [15:0] OutD  // Output D
);

reg PC_E;
wire [15:0] PC_Q;

Register PC (
    .FunSel(FunSel),  // Giriþ sinyalleri
    .E(PC_E),
    .I(I),
    .Clock(Clock),
    .Q(PC_Q)  // Çýkýþ sinyali
);

reg AR_E;
wire [15:0] AR_Q;

Register AR (
    .FunSel(FunSel),  // Giriþ sinyalleri
    .E(AR_E),
    .I(I),
    .Clock(Clock),
    .Q(AR_Q)  // Çýkýþ sinyali
);

reg SP_E;
wire [15:0] SP_Q;

Register SP (
    .FunSel(FunSel),  // Giriþ sinyalleri
    .E(SP_E),
    .I(I),
    .Clock(Clock),
    .Q(SP_Q)  // Çýkýþ sinyali
);



always @(*) begin
    case(RegSel)
        3'b000: begin // All address registers are enabled
            SP_E <= 1;
            AR_E <= 1;
            PC_E <= 1;
        end
        
        3'b001: begin // PC and AR are enabled
            SP_E <= 0;
            AR_E <= 1;
            PC_E <= 1;
        end
        
        3'b010: begin // PC and SP are enabled
            SP_E <= 1;
            AR_E <= 0;
            PC_E <= 1;
        end
        
        3'b011: begin // Only PC is enabled
            SP_E <= 0;
            AR_E <= 0;
            PC_E <= 1;
        end
        
        3'b100: begin // AR and SP are enabled
            AR_E <= 1;
            SP_E <= 1;
            PC_E <= 0;
        end
        
        3'b101: begin // Only AR is enabled
            AR_E <= 1;
            SP_E <= 0;
            PC_E <= 0;
        end
        
        3'b110: begin // Only SP is enabled
            SP_E <= 1;
            PC_E <= 0;
            AR_E <= 0;
        end
        3'b111: begin // All disabled
            SP_E <= 0;
            PC_E <= 0;
            AR_E <= 0;
        end
        default: begin // Tümü devre dýþý
            SP_E <= 0;
            PC_E <= 0;
            AR_E <= 0;
        end
    endcase
     case(OutCSel)
       
           3'b00: begin // PC Output
               OutC <= PC_Q;    
           end
           
           3'b01: begin // PC Output
               OutC <= PC_Q;    
           end
           
           3'b10: begin // PC Output
               OutC <= AR_Q;    
           end
           
           3'b11: begin // PC Output
               OutC <= SP_Q;    
           end
       endcase
       case(OutDSel)
           
               3'b00: begin //PC Output
                   OutD <= PC_Q;    
               end
               
               3'b01: begin //PC Output
                   OutD <= PC_Q;    
               end
               
               3'b10: begin //AR Output
                   OutD <= AR_Q;    
               end
               
               3'b11: begin //SP Output
                   OutD <= SP_Q;    
               end
       endcase
           
end
endmodule
