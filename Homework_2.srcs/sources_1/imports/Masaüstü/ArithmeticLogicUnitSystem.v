`timescale 1ns / 1ps
module ArithmeticLogicUnitSystem(
    // RF
    input [2:0] RF_OutASel, RF_OutBSel, RF_FunSel,
    input [3:0] RF_RegSel, RF_ScrSel,
    // ALU
    input [4:0] ALU_FunSel,
    output [15:0] OutA, OutB,
    input ALU_WF,
    output [3:0] ALUOutFlag,
    output [15:0] ALUOut,
    // ARF
    input [1:0] ARF_OutCSel, ARF_OutDSel,
    input [2:0] ARF_FunSel, ARF_RegSel,
    output [15:0] OutC, OutD, // bunu napcam
    // IR
    input IR_LH, IR_Write,
    output [15:0] IROut,
    // MEM
    input Mem_WR, Mem_CS,
    input [15:0] Address,
    input [7:0] MemOut,
    // MUX
    input [1:0] MuxASel, MuxBSel,
    input MuxCSel, Clock,
    output reg [15:0] MuxAOut, MuxBOut,
    output reg [7:0] MuxCOut
);

    RegisterFile RF ( // I MUX A dan gelicek
        .OutASel(RF_OutASel), 
        .OutBSel(RF_OutBSel),
        .FunSel(RF_FunSel), 
        .RegSel(RF_RegSel), 
        .ScrSel(RF_ScrSel),
        .Clock(Clock), 
        .I(MuxAOut),
        .OutA(OutA), 
        .OutB(OutB)
    );
    
    ArithmeticLogicUnit ALU (
        .A(OutA),                
        .B(OutB),                
        .FunSel(ALU_FunSel),     
        .WF(ALU_WF),                  
        .Clock(Clock),           
        .ALUOut(ALUOut),         
        .FlagsOut(ALUOutFlag)    
    );
    
    AddressRegisterFile ARF ( // MUXB
        .FunSel(ARF_FunSel),
        .RegSel(ARF_RegSel),
        .OutCSel(ARF_OutCSel),
        .OutDSel(ARF_OutDSel),
        .I(MuxBOut),
        .Clock(Clock),
        .OutC(OutC),
        .OutD(Address)
    );
    
    InstructionRegister IR (
        .I(MemOut),
        .Write(IR_Write),
        .LH(IR_LH),
        .Clock(Clock),
        .IROut(IROut)
    );
    
    Memory MEM (
        .Address(Address),
        .Data(MuxCOut),
        .WR(Mem_WR),
        .CS(Mem_CS),
        .Clock(Clock),
        .MemOut(MemOut)
    );
    
    
    always @(*)
        case (MuxASel)
            2'b00: MuxAOut <= ALUOut;
            2'b01: MuxAOut <= OutC;
            2'b10: MuxAOut <= {8'b00000000, MemOut};
            2'b11: MuxAOut <= IROut[7:0];
        endcase
    always @(*)
        case (MuxBSel)
            2'b00: MuxBOut <= ALUOut;
            2'b01: MuxBOut <= OutC;
            2'b10: MuxBOut <= {8'b00000000, MemOut};
            2'b11: MuxBOut <= IROut[7:0];
        endcase
    always @(*)
        MuxCOut <= MuxCSel ? ALUOut[15:8] : ALUOut[7:0];
endmodule