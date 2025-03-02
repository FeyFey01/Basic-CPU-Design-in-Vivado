`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2024 05:02:17 PM
// Design Name: 
// Module Name: CPUSimulation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPUSimFeyza();
    reg Clock, Reset;
    wire [7:0] Tx;
    integer test_no;
    
    FileOperation F();
    
    always 
    begin
        Clock = 1; 
        #50; 
        Clock = 0; 
        #50; // 50 ns period
    end
    initial begin
        F.SimulationName ="CPUSystem";
        #1;
        Reset = 1;
        #1;
        Reset = 0;
        #1;
        Reset = 1;
        test_no = 0;
    end
    CPUSystem _CPUSystem( 
            .Clock(Clock),
            .Reset(Reset),
            .T(Tx)    
        );
    always @(negedge Clock)
        if (Reset && Tx == 0) // skip during reset and T != 0
        begin
            F.InitializeSimulation(0);
            case (test_no)
                0: begin
                    // Registers
                    $display("Initial");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 0, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 16'hxxxx, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 0, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 0, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 0, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 0, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 1'bx, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[1], _CPUSystem._ALUSystem.MEM.RAM_DATA[0]}, 16'h000C, test_no, "Memory");
                end
                1: begin
                    $display("BRA PC 16");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 14, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 16'hxxxx, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 0, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 0, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 0, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 0, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 1'bx, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[1], _CPUSystem._ALUSystem.MEM.RAM_DATA[0]}, 16'h000C, test_no, "Memory");
                end
                2: begin
                    $display("MOVL R1 127 Decimal");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 16, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 16'hxxxx, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 127, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 0, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 0, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 0, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 1'bx, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[1], _CPUSystem._ALUSystem.MEM.RAM_DATA[0]}, 16'h000C, test_no, "Memory");
                end
                3: begin
                    $display("MOVH R1 0 Decimal");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 18, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 16'hxxxx, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 127, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 0, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 0, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 0, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 1'bx, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 1'bx, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[1], _CPUSystem._ALUSystem.MEM.RAM_DATA[0]}, 16'h000C, test_no, "Memory");
                end
                4: begin
                    $display("MOVS ");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 20, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 127, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 127, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 0, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 0, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 0, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[1], _CPUSystem._ALUSystem.MEM.RAM_DATA[0]}, 16'h000C, test_no, "Memory");
                end
                5: begin
                    $display("PSH R1 -> M[SP]");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 22, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 16'h007D, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 127, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 0, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 0, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 0, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[127], _CPUSystem._ALUSystem.MEM.RAM_DATA[126]}, 16'h007F, test_no, "Memory");
                end
                6: begin
                    $display("INC SP");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 24, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 126, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 127, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 0, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 0, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 0, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[127], _CPUSystem._ALUSystem.MEM.RAM_DATA[126]}, 16'h007F, test_no, "Memory");
                end
                7: begin
                    $display("POP M[SP] -> R2");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 26, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 128, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 127, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h7F, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 0, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 0, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[127], _CPUSystem._ALUSystem.MEM.RAM_DATA[126]}, 16'h007F, test_no, "Memory");
                end
                8: begin
                    $display("LDRIM R3 = 16'h0011");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 28, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 128, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 127, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h7F, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 0, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[127], _CPUSystem._ALUSystem.MEM.RAM_DATA[126]}, 16'h007F, test_no, "Memory");
                end
                9: begin
                    $display("LDRIM R4 = 16'h00FF");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 30, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 128, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 127, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h7F, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'h00FF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[127], _CPUSystem._ALUSystem.MEM.RAM_DATA[126]}, 16'h007F, test_no, "Memory");
                end
                10: begin
                    $display("DEC R2");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 32, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 128, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 127, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h7E, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'h00FF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[127], _CPUSystem._ALUSystem.MEM.RAM_DATA[126]}, 16'h007F, test_no, "Memory");
                end
                11: begin
                    $display("MOVH FF -> R4");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 34, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 128, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 127, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h7E, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'hFFFF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[127], _CPUSystem._ALUSystem.MEM.RAM_DATA[126]}, 16'h007F, test_no, "Memory");
                end
                12: begin
                    $display("ADD R3 + R4 = R1");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 36, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 128, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 16'h0010, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h7E, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'hFFFF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 1'bx, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1'bx, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[127], _CPUSystem._ALUSystem.MEM.RAM_DATA[126]}, 16'h007F, test_no, "Memory");
                end
                13: begin
                    $display("ADDS R3 + R4 = R1");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 38, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 128, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 16'h0010, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h7E, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'hFFFF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 0, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[127], _CPUSystem._ALUSystem.MEM.RAM_DATA[126]}, 16'h007F, test_no, "Memory");
                end
                14: begin
                    $display("LDRIM R2 <- 2E");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 40, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 128, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 16'h0010, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h2E, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'hFFFF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 0, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[127], _CPUSystem._ALUSystem.MEM.RAM_DATA[126]}, 16'h007F, test_no, "Memory");
                end
                15: begin
                    $display("BX M[SP] ? PC, PC ? R2");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 46, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 130, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 16'h0010, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h2E, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'hFFFF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 0, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[129], _CPUSystem._ALUSystem.MEM.RAM_DATA[128]}, 42, test_no, "Memory");
                end
                16: begin
                    $display("LDRIM R1 <- 19 DECÝMAL");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 48, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 16'hxxxx, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 130, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 19, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h2E, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'hFFFF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 0, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[129], _CPUSystem._ALUSystem.MEM.RAM_DATA[128]}, 42, test_no, "Memory");
                end
                17: begin
                    $display("MOVS R1 -> AR");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 50, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 19, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 130, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 19, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h2E, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'hFFFF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 0, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[129], _CPUSystem._ALUSystem.MEM.RAM_DATA[128]}, 42, test_no, "Memory");
                end
                18: begin
                    $display("LDR M[AR] -> R2");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 52, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 19, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 130, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 19, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h62, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'hFFFF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 0, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[19]}, 98, test_no, "Memory");
                end
                19: begin
                    $display("INC R2");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 54, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 19, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 130, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 19, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h63, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'hFFFF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 0, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[19]}, 98, test_no, "Memory");
                end
                20: begin
                    $display("STR R2 -> M[AR]");
                    // Registers
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.PC.Q, 56, test_no, "PC");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.AR.Q, 19, test_no, "AR");
                    F.CheckValues(_CPUSystem._ALUSystem.ARF.SP.Q, 130, test_no, "SP");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R1.Q, 19, test_no, "R1");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R2.Q, 8'h63, test_no, "R2");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R3.Q, 16'h0011, test_no, "R3");
                    F.CheckValues(_CPUSystem._ALUSystem.RF.R4.Q, 16'hFFFF, test_no, "R4");
                    
                    // Flags
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[0], 0, test_no, "Flag_O");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[1], 0, test_no, "Flag_N");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[2], 1, test_no, "Flag_C");
                    F.CheckValues(_CPUSystem._ALUSystem.ALU.FlagsOut[3], 0, test_no, "Flag_Z");
                    
                    // Memory
                    F.CheckValues({_CPUSystem._ALUSystem.MEM.RAM_DATA[19]}, 99, test_no, "Memory");
                end
            endcase
            test_no <= test_no + 1;
            F.FinishSimulation();
       end
endmodule

//            $display("Output Values:");
//            $display("T: %d, OPCODE : %d", Tx, _CPUSystem.OPCODE);
//            $display("Address Register File: PC: %d, AR: %d, SP: %d", _CPUSystem._ALUSystem.ARF.PC.Q, _CPUSystem._ALUSystem.ARF.AR.Q, _CPUSystem._ALUSystem.ARF.SP.Q);
//            $display("Instruction Register : %d", _CPUSystem._ALUSystem.IR.IROut);
//            $display("Register File Registers: R1: %d, R2: %d, R3: %d, R4: %d", _CPUSystem._ALUSystem.RF.R1.Q, _CPUSystem._ALUSystem.RF.R2.Q, _CPUSystem._ALUSystem.RF.R3.Q, _CPUSystem._ALUSystem.RF.R4.Q);
//            $display("Register File Scratch Registers: S1: %d, S2: %d, S3: %d, S4: %d", _CPUSystem._ALUSystem.RF.S1.Q, _CPUSystem._ALUSystem.RF.S2.Q, _CPUSystem._ALUSystem.RF.S3.Q, _CPUSystem._ALUSystem.RF.S4.Q);
//            $display("ALU Flags: Z: %d, N: %d, C: %d, O: %d", _CPUSystem._ALUSystem.ALU.FlagsOut[3], _CPUSystem._ALUSystem.ALU.FlagsOut[2], _CPUSystem._ALUSystem.ALU.FlagsOut[1], _CPUSystem._ALUSystem.ALU.FlagsOut[0]);
//            $display("ALU Result: ALUOut: %d", _CPUSystem._ALUSystem.ALU.ALUOut);
//            $display("\n"); 

