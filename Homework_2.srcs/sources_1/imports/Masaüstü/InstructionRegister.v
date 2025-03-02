   `timescale 1ns / 1ps
    
    module InstructionRegister(
        input wire [7:0] I,
        input wire Write,
        input wire LH,
        input wire Clock,
        output reg [15:0] IROut
    );
    
        always @(posedge Clock) begin
            if (Write) begin
                if (LH) 
                    IROut[15:8] <= I[7:0];
                else 
                    IROut[7:0] <= I[7:0];
            end
        end
    
    endmodule
