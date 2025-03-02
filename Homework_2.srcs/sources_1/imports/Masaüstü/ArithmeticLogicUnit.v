`timescale 1ns / 1ps
//N,O,Z gibi deðerler always bloðunu çalýþtýrýyor, çalýþtýrmalý mý
module ArithmeticLogicUnit(
    input [15:0] A,          // Input A
    input [15:0] B,          // Input B
    input [4:0] FunSel,      // Function Select
    input WF,                // Write Flag
    input Clock,             // Clock input
    output reg [15:0] ALUOut,// ALU Output
    output reg [3:0] FlagsOut // Flags Output: Z, C, N, O
);

reg [7:0] sum, difference;
reg carry_out, overflow, negative;

// ALU function selection
always @(*) begin

    carry_out = FlagsOut[2];
    overflow = FlagsOut[0];
    negative = 1;
    
    case(FunSel)
        5'b00000: begin
            ALUOut <= {8'b00000000,A[7:0]};
        end
        5'b00001: begin
            ALUOut <= {8'b00000000,B[7:0]};
        end
        5'b00010: begin
            ALUOut <= {8'b00000000,~A[7:0]};
        end
        5'b00011: begin
            ALUOut <= {8'b00000000,~B[7:0]};
        end
        5'b00100: begin
            {carry_out, sum} = A[7:0] + B[7:0];
            ALUOut <= {8'b00000000,sum[7:0]};
            
            overflow = ((A[7] == B[7]) && (A[7] != ALUOut[7]));
        end
        5'b00101: begin
            {carry_out, sum} <= A[7:0] + B[7:0] + FlagsOut[2];
            ALUOut[7:0] <= {8'b00000000,sum[7:0]};
            
            overflow = ((A[7] == B[7]) && (A[7] != ALUOut[7]));
        end
        5'b00110: begin
            difference <= {8'b00000000, A[7:0] - B[7:0]};
            ALUOut <=  {8'b00000000,difference[7:0]};
            // For subtraction, if B is greater than A, a borrow is needed, so set carry if borrow occurs
            carry_out = (B[7] && !A[7]) || ((A[7:0] - B[7:0]) == 8'b11111111); // Assuming 8-bit subtraction    

            overflow = ((A[7] != B[7]) && (A[7] != ALUOut[7])); 
        end
        5'b00111: begin
            ALUOut <= {8'b00000000,A[7:0] & B[7:0]};
        end
        5'b01000: begin
            ALUOut <= {8'b00000000,A[7:0] | B[7:0]};
            
        end
        5'b01001: begin
           ALUOut <= {8'b00000000,A[7:0] ^ B[7:0]};
        end
        5'b01010: begin
            ALUOut[7:0] <= {8'b00000000,~{A[7:0] & B[7:0]}}; //nand
        end
        5'b01011: begin
            ALUOut <= {8'b00000000, A[6:0], 1'b0}; // LSL
            carry_out <= A[7];
        end
        5'b01100: begin
            ALUOut <= {8'b00000000, 1'b0, A[7:1]}; // LSR
            carry_out <= A[0];
        end
        5'b01101: begin
            ALUOut <= {8'b00000000, A[7], A[7:1]}; // ASR
            carry_out <= A[0];
            negative = 0;
        end
        5'b01110: begin
            ALUOut <= {8'b00000000, A[6:0], FlagsOut[2]}; // CSL
            carry_out <= A[7];
        end
        5'b01111: begin
            ALUOut <= {8'b00000000, FlagsOut[2], A[7:1]}; // CSR
            carry_out <= A[0];
        end
        5'b10000: begin
            ALUOut <= A;
        end
        5'b10001: begin
            ALUOut <= B;
        end
        5'b10010: begin
            ALUOut <= ~A;
        end
        5'b10011: begin
            ALUOut <= ~B;
        end
        5'b10100: begin
            {carry_out, ALUOut} <= A + B;

            // Overflow occurs if the result changes sign unexpectedly or if it's too large to fit in 16 bits
            overflow = ((A[15] == B[15]) && (A[15] != ALUOut[15]));
        end
        5'b10101: begin
            {carry_out, ALUOut} <= A + B + FlagsOut[2];

            // Overflow occurs if the result changes sign unexpectedly or if it's too large to fit in 16 bits
            overflow = ((A[15] == B[15]) && (A[15] != ALUOut[15]));
        end
        5'b10110: begin
            ALUOut <= A - B;    
            // Carry out occurs if B is greater than A, indicating a borrow
            carry_out = (B[15] && !A[15]) || ((A[15:0] - B[15:0]) == 16'hFFFF); // Assuming 16-bit subtraction
        
            // Overflow occurs if the result is negative or too large to fit in 16 bits
            overflow = ((A[15] != B[15]) && (A[15] != ALUOut[15])); // Overflow for different signs
        
        end
        5'b10111: begin
            ALUOut <= A & B;     
        end
        5'b11000: begin
            ALUOut <= A | B;
        end
        5'b11001: begin
            ALUOut <= A ^ B;
        end
        5'b11010: begin
            ALUOut <= ~(A & B);
        end
        5'b11011: begin
            ALUOut <= {A[14:0], 1'b0}; // LSL
            carry_out <= A[15];
        end
        5'b11100: begin
            ALUOut <= {1'b0, A[15:1]}; // LSR
            carry_out <= A[0];
        end
        5'b11101: begin
            ALUOut <= {A[15], A[15:1]}; // ASR // C deðiþiyo gözüküyo?
            carry_out <= A[0];
            negative = 0;
        end
        5'b11110: begin
            
            ALUOut <= {A[14:0], FlagsOut[2]}; // CSR
                        carry_out <= A[15];
        end
        5'b11111: begin
            ALUOut <= {FlagsOut[2], A[15:1]}; // CSL
            carry_out <= A[0];
        end
    endcase
end

always @(posedge Clock) begin
    if (WF == 1) begin
    //*********************//
        FlagsOut[3] <= (ALUOut == 0) ? 1 : 0; // Z
    //*********************//
        FlagsOut[2] = carry_out;
     //*********************//
	if(negative == 1) begin
		FlagsOut[1] <= (FunSel[4] == 0) ? ALUOut[7] : ALUOut[15]; // N
	end
    //*********************//
        FlagsOut[0] <= overflow;
    //*********************//
    end
end
endmodule