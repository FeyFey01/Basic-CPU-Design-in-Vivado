`timescale 1ns / 1ps

module Register (
    input wire [2:0] FunSel,
    input wire E,
    input wire [15:0] I,
    input wire Clock, 
    output reg [15:0] Q
);

always @(posedge Clock) begin
    if(E)begin
        case({FunSel})
            3'b000: Q <= Q - 1; // Decrement
            3'b001: Q <= Q + 1; // Increment
            3'b010: Q <= I; // Load
            3'b011: Q <= 16'b0; // Clear
            3'b100: begin
                Q[15:8] <= 8'b0;
                Q[7:0] <= I[7:0];
            end 
            3'b101: Q[7:0] <= I[7:0]; // Only Write Low
            3'b110: Q[15:8] <= I[7:0]; // Only Write High
            3'b111: begin // Sign Extend + Write Low
                Q[15:8] <= {I[7], I[7], I[7], I[7], I[7], I[7], I[7], I[7]};
                Q[7:0] <= I[7:0];
            end
        endcase
    end
end

endmodule
