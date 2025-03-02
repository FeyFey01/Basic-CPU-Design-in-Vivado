`timescale 1ns / 1ps

module CPUSystem (
    input wire Clock,
    input wire Reset,
    output reg [7:0] T
);

    // Control signals
    reg [5:0] OPCODE;
    reg [1:0] RSEL;
    reg [7:0] ADDRESS;
    reg S;
    reg [2:0] DSTREG;
    reg [2:0] SREG1;
    reg [2:0] SREG2;
    
    // For ALU System
    reg [2:0] RF_OutASel, RF_OutBSel, RF_FunSel;
    reg [3:0] RF_RegSel, RF_ScrSel;
    reg [4:0] ALU_FunSel;
    reg ALU_WF; 
    reg [1:0] ARF_OutCSel, ARF_OutDSel;
    reg [2:0] ARF_FunSel, ARF_RegSel;
    reg IR_LH, IR_Write, Mem_WR, Mem_CS;
    reg [1:0] MuxASel, MuxBSel;
    reg MuxCSel;
    wire Z, C, N, O;

    ArithmeticLogicUnitSystem _ALUSystem(
        .RF_OutASel(RF_OutASel),   .RF_OutBSel(RF_OutBSel), 
        .RF_FunSel(RF_FunSel),     .RF_RegSel(RF_RegSel),
        .RF_ScrSel(RF_ScrSel),     .ALU_FunSel(ALU_FunSel),
        .ALU_WF(ALU_WF),           .ARF_OutCSel(ARF_OutCSel), 
        .ARF_OutDSel(ARF_OutDSel), .ARF_FunSel(ARF_FunSel),
        .ARF_RegSel(ARF_RegSel),   .IR_LH(IR_LH),
        .IR_Write(IR_Write),       .Mem_WR(Mem_WR),
        .Mem_CS(Mem_CS),           .MuxASel(MuxASel),
        .MuxBSel(MuxBSel),         .MuxCSel(MuxCSel),
        .Clock(Clock)
    ); 
    
    task ClearRegisters;
    begin
        _ALUSystem.RF.R1.Q = 16'h0;
        _ALUSystem.RF.R2.Q = 16'h0;
        _ALUSystem.RF.R3.Q = 16'h0;
        _ALUSystem.RF.R4.Q = 16'h0;
        _ALUSystem.RF.S1.Q = 16'h0;
        _ALUSystem.RF.S2.Q = 16'h0;
        _ALUSystem.RF.S3.Q = 16'h0;
        _ALUSystem.RF.S4.Q = 16'h0;
        _ALUSystem.ALU.ALUOut = 0;
    end
    endtask
     
    task DisableAll;
    begin
         RF_RegSel = 4'b1111;
         RF_ScrSel = 4'b1111;
         ARF_RegSel = 3'b111;
         IR_Write = 0;
         ALU_WF = 0;
         Mem_CS = 1;
         Mem_WR = 0;
    end
    endtask
        
    task RF_RegSelSelector;
    input [1:0] RegSel_input; // Define input parameter
    begin
        case (RegSel_input)
            2'b00:begin
                RF_RegSel = 4'b0111;
            end
            2'b01:begin
                RF_RegSel = 4'b1011;
            end
            2'b10:begin
                RF_RegSel = 4'b1101;
            end
            2'b11:begin
                RF_RegSel = 4'b1110;
            end                        
        endcase
    end
    endtask
    
    task ARF_RegSelSelector;
    input [1:0] RegSel_input; // Define input parameter
    begin
        case (RegSel_input)
            2'b00, 2'b01: begin
                ARF_RegSel = 4'b011; // PC Enabled 
            end
            2'b10: begin
                ARF_RegSel = 4'b110; // SP Enabled
            end
            2'b11: begin
                ARF_RegSel = 4'b101; // AR Enabled
            end                        
        endcase 
    end
    endtask
    
    task RF_OutASelSelector;
    input [1:0] RegSel_input; // Define input parameter
    begin
        case (RegSel_input)
            2'b00:begin
                RF_OutASel = 3'b000;
            end
            2'b01:begin
                RF_OutASel = 3'b001;
            end
            2'b10:begin
                RF_OutASel = 3'b010;
            end
            2'b11:begin
                RF_OutASel = 3'b011;
            end                        
        endcase
    end
    endtask
    
    task RF_OutBSelSelector;
    input [1:0] RegSel_input; // Define input parameter
    begin
        case (RegSel_input)
            2'b00:begin
                RF_OutBSel = 3'b000;
            end
            2'b01:begin
                RF_OutBSel = 3'b001;
            end
            2'b10:begin
                RF_OutBSel = 3'b010;
            end
            2'b11:begin
                RF_OutBSel = 3'b011;
            end                        
        endcase 
    end
    endtask
    
    task ARF_OutCSelSelector;
    input [1:0] RegSel_input; // Define input parameter
    begin
        case (RegSel_input)
            2'b00, 2'b01: begin
                ARF_OutCSel = 2'b00; // PC Enabled 
            end
            2'b10: begin
                ARF_OutCSel = 2'b11; // SP Enabled
            end
            2'b11: begin
                ARF_OutCSel = 4'b10; // AR Enabled
            end                        
        endcase 
    end
    endtask
    
    task ARF_OutDSelSelector;
    input [1:0] RegSel_input; // Define input parameter
    begin
        case (RegSel_input)
            2'b00, 2'b01: begin
                ARF_OutDSel = 4'b011; // PC Enabled 
            end
            2'b10: begin
                ARF_OutDSel = 4'b110; // SP Enabled
            end
            2'b11: begin
                ARF_OutDSel = 4'b101; // AR Enabled
            end                        
        endcase 
    end
    endtask
    
    always @(*) begin
        if (!Reset) begin
            DisableAll();
            ClearRegisters();
            _ALUSystem.ARF.PC.Q <= 0;
            T <= 0;
        end
    end
    
    always @ (negedge Clock) begin
        case (T)
            0: begin
                DisableAll();
                ARF_FunSel = 3'b001; // Increment
                ARF_RegSel = 3'b011; // PC Enabled
                ARF_OutDSel = 2'b00; // PC -> OutD
                Mem_CS = 0; // enable
                Mem_WR = 0; // Read
                IR_Write = 1; // enable write to IR
                IR_LH = 0; // IR[7:0] a yazmak için
                T <= 1;
            end
                
            1: begin
                ARF_FunSel = 3'b001; // Increment
                ARF_RegSel = 3'b011; // PC Enabled
                ARF_OutDSel = 2'b00; // PC -> OutD
                IR_LH = 1'b1; // IR[15:7] a yazmak için
                T <= 2;
            end
            
            2: begin
                DisableAll();
                
                //decoding
                OPCODE = _ALUSystem.IR.IROut[15:10];
                RSEL = _ALUSystem.IR.IROut[9:8];
                ADDRESS = _ALUSystem.IR.IROut[7:0];
                S = _ALUSystem.IR.IROut[9];
                DSTREG = _ALUSystem.IR.IROut[8:6];
                SREG1 = _ALUSystem.IR.IROut[5:3];
                SREG2 = _ALUSystem.IR.IROut[2:0];
                
                //opcode cases
                case (OPCODE)
                    
                    6'h00: begin // BRA
                        // IR->S1
                        IR_Write = 1'b0; // Read
                        MuxASel = 2'b11; // IR Seçti
                        RF_ScrSel = 4'b0111; // S1 enabled
                        RF_FunSel = 3'b100; // Low Load
                        RF_OutASel = 3'b100; // S1 selected for OutA
                        RF_OutBSel = 3'b101; // S2 selected for OutB
                        // ALU = A + B
                        ALU_FunSel = 5'b10100; // A+B (16-bit)
                        T <= 3;
                    end // BRA ends


                    6'h01: begin // BNE
                        if(_ALUSystem.ALU.FlagsOut[0] == 0) begin
                            // IR->S1
                            IR_Write = 1'b0; // Read
                            MuxASel = 2'b11; // IR Seçti
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b100; // Low Load
                            RF_OutASel = 3'b100; // S1 selected for OutA
                            RF_OutBSel = 3'b101; // S2 selected for OutB
                            // ALU = A + B
                            ALU_FunSel = 5'b10100; // A+B (16-bit)
                            T <= 3;
                        end else begin
                            T <= 0;
                        end
                    end // BNE ends


                    6'h02: begin // BEQ
                        if(_ALUSystem.ALU.FlagsOut[0] == 0) begin
                            // IR->S1
                            IR_Write = 1'b0; // Read
                            MuxASel = 2'b11; // IR Seçti
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b100; // Low Load
                            RF_OutASel = 3'b100; // S1 selected for OutA
                            RF_OutBSel = 3'b101; // S2 selected for OutB
                            // ALU = A + B
                            ALU_FunSel = 5'b10100; // A+B (16-bit)
                            T <= 3;
                        end else begin
                            T <= 0;
                        end
                    end // BEQ ends
                    

                    6'h03: begin // POP
                        ARF_RegSel = 3'b110; // SP Enabled
                        ARF_FunSel = 3'b001; // SP Increment
                        ARF_OutDSel = 2'b11; // OUTDSel = SP
                        Mem_CS = 0; // Enable
                        Mem_WR = 0; // Read
                        MuxASel = 2'b10; // MemOut to MUXa
                        RF_RegSelSelector(RSEL); // Rx Enabled
                        RF_FunSel = 3'b101; // Only write to low to Rx
                        T <= 3;
                    end // POP Ends  


                    6'h04: begin // PSH
                        ARF_OutDSel = 2'b11; //SP to address
                        Mem_CS = 0; // enable
                        Mem_WR = 1; // Write
                        RF_OutASelSelector(RSEL);
                        ALU_FunSel = 5'b10000; // Load (16 bit)
                        ALU_WF = 0; // Flags wont change
                        MuxCSel = 1; // Write high first
                        T <= 3;
                    end //PSH end
                    

                    6'h05: begin // INC
                        ALU_WF <= S;
                        if(SREG1[2] == 0) begin // ARF Out
                            case (SREG1[1:0])
                                2'b00, 2'b01: ARF_OutCSel = 2'b00; // PC
                                2'b10: ARF_OutCSel = 2'b11; // SP
                                2'b11: ARF_OutCSel = 2'b10; // AR
                            endcase 
                            MuxASel = 2'b01; // OutC
                            MuxBSel = 2'b01; // OutC
                            
                        end else if(SREG1[2] == 1) begin // RF Out
                            case (SREG1[1:0])
                                2'b00: RF_OutASel = 3'b000;
                                2'b01: RF_OutASel = 3'b001;
                                2'b10: RF_OutASel = 3'b010;
                                2'b11: RF_OutASel = 3'b011;
                            endcase 
                            ALU_FunSel = 5'b10000;
                            MuxASel = 2'b00; // ALUOut
                            MuxBSel = 2'b00; // ALUOut
                        end
                        
                        if (DSTREG[2] == 0) begin //ARF Input
                            ARF_FunSel = 3'b010; // Load
                            ARF_RegSelSelector(DSTREG[1:0]);
                            
                        end else if (DSTREG[2] == 1) begin //RF Input
                            RF_FunSel = 3'b010; // Load
                            RF_RegSelSelector(DSTREG[1:0]);
                        end
                        T <= 3;
                    end// INC Ends
                    

                    6'h06: begin // DEC
                        ALU_WF <= S;
                        if(SREG1[2] == 0) begin // ARF Out
                            case (SREG1[1:0])
                                2'b00, 2'b01: ARF_OutCSel = 2'b00; // PC
                                2'b10: ARF_OutCSel = 2'b11; // SP
                                2'b11: ARF_OutCSel = 2'b10; // AR
                            endcase 
                            MuxASel = 2'b01; // OutC
                            MuxBSel = 2'b01; // OutC
                            
                        end else if(SREG1[2] == 1) begin // RF Out
                            case (SREG1[1:0])
                                2'b00: RF_OutASel = 3'b000;
                                2'b01: RF_OutASel = 3'b001;
                                2'b10: RF_OutASel = 3'b010;
                                2'b11: RF_OutASel = 3'b011;
                            endcase 
                            ALU_FunSel = 5'b10000;
                            MuxASel = 2'b00; // ALUOut
                            MuxBSel = 2'b00; // ALUOut
                        end
                        
                        if (DSTREG[2] == 0) begin //ARF Input
                            ARF_FunSel = 3'b010; // Load
                            ARF_RegSelSelector(DSTREG[1:0]);
                            
                        end else if (DSTREG[2] == 1) begin //RF Input
                            RF_FunSel = 3'b010; // Load
                            RF_RegSelSelector(DSTREG[1:0]);
                        end
                        T <= 3;
                    end //DEC Ends


                    6'h07: begin // LSL
                        if (SREG1[2] == 1) begin // Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            ALU_FunSel = 5'b11011; // LSL 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] == 0) begin // Out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // LSL end


                    6'h08: begin // LSR
                        if (SREG1[2] == 1) begin // Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            ALU_FunSel = 5'b11100; // LSR 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] == 0) begin // Out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // LSR end


                    6'h09: begin // ASR
                        if (SREG1[2] == 1) begin // Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            ALU_FunSel = 5'b11101; // ASR 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] == 0) begin // Out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // ASR end


                    6'h0A: begin // CSL
                        if (SREG1[2] == 1) begin // Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            ALU_FunSel = 5'b11110; // CSL 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] == 0) begin // Out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // CSL end


                    6'h0B: begin // CSR
                        if (SREG1[2] == 1) begin // Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            ALU_FunSel = 5'b11111; // CSR 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] == 0) begin // Out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // CSR end


                    6'h0C: begin // AND
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b10111; // AND 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // AND end


                    6'h0D: begin // ORR
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b11000; // OR 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // ORR end


                    6'h0E: begin // NOT
                        if (SREG1[2] == 1) begin // Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            ALU_FunSel = 5'b10010; // NOT 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] == 0) begin // Out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // NOT end


                    6'h0F: begin // XOR
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b11001; // XOR 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // XOR end


		            6'h10: begin // NAND
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b11010; // NAND 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // NAND end


                    6'h11: begin // MOVH
                        //DSTREG <= ADDRESS
                        RF_RegSelSelector(RSEL);
                        IR_Write = 1'b0; // Read from IR
                        MuxASel = 2'b11; // MUXAOut = IR
                        RF_FunSel = 3'b110; // Only Write High
                        T <= 0;
                    end // MOVH ends
                    

                    6'h12: begin // LDR
                        // M[AR] -> R
                        ARF_OutDSel = 2'b10; // AR -> OutD
                        Mem_CS = 0; // enable
                        Mem_WR = 0; // Read
                        MuxASel = 2'b10; // MemOut
                        RF_RegSelSelector(RSEL);
                        RF_FunSel = 3'b100; // Write to Low
                        T <= 0;
                    end // LDR end


		            6'h13: begin // STR
                        ARF_OutDSel = 2'b10; // AR OUT
                        Mem_CS = 0; // enable
                        Mem_WR = 1; // Write
                        RF_OutASelSelector(RSEL);
                        ALU_FunSel = 5'b10000; // Load
                        MuxCSel = 0; // Write low first
                        T <= 0;
                    end // STR end


                    6'h14: begin // MOVL
                        //DSTREG <= ADDRESS
                        RF_RegSelSelector(RSEL);
                        IR_Write = 1'b0; // Read from IR
                        MuxASel = 2'b11; // MUXAOut = IR
                        RF_FunSel = 3'b101; // Only Write Low
                        T <= 0;
                    end // MOVL ends
	
	
		            6'h15: begin // ADD
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b10100; // ADD 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // ADD end


		            6'h16: begin // ADC
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b10101; // ADC 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // ADC end


		            6'h17: begin // SUB
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b10110; // SUB 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // SUB end
                    

                    6'h18: begin // MOVS
                        ALU_WF <= S;
                        if(SREG1[2] == 0) begin // ARF Out
                            case (SREG1[1:0])
                                2'b00, 2'b01: ARF_OutCSel = 2'b00; // PC
                                2'b10: ARF_OutCSel = 2'b11; // SP
                                2'b11: ARF_OutCSel = 2'b10; // AR
                            endcase 
                            MuxASel = 2'b01; // OutC
                            MuxBSel = 2'b01; // OutC
                            
                        end else if(SREG1[2] == 1) begin // RF Out
                            case (SREG1[1:0])
                                2'b00: RF_OutASel = 3'b000;
                                2'b01: RF_OutASel = 3'b001;
                                2'b10: RF_OutASel = 3'b010;
                                2'b11: RF_OutASel = 3'b011;
                            endcase 
                            ALU_FunSel = 5'b10000;
                            MuxASel = 2'b00; // ALUOut
                            MuxBSel = 2'b00; // ALUOut
                        end
                        
                        if (DSTREG[2] == 0) begin //ARF Input
                            ARF_FunSel = 3'b010; // Load
                            ARF_RegSelSelector(DSTREG[1:0]);
                            
                        end else if (DSTREG[2] == 1) begin //RF Input
                            RF_FunSel = 3'b010; // Load
                            RF_RegSelSelector(DSTREG[1:0]);
                        end
                        T <= 0;
                    end // MOVS Ends
		   
		   
    		        6'h19: begin // ADDS
			         ALU_WF = S;
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b10100; // ADD 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // ADDS end
	
	
                    6'h1A: begin // SUBS
                        ALU_WF = S;
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b10110; // SUB 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // SUBS end
	
	
                    6'h1B: begin // ANDS
                        ALU_WF = S;
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b10111; // AND 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // ANDS end


		            6'h1C: begin // ORRS
			            ALU_WF = S;
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b11000; // OR 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // ORRS end


                    6'h1D: begin // XORS
			            ALU_WF = S;
                        if (SREG1[2] & SREG2[2]) begin // Both Out from RF
                            // RF Out to MUXA and MUXB
                            RF_OutASelSelector(SREG1[1:0]);
                            RF_OutBSelSelector(SREG2[1:0]);
                            ALU_FunSel = 5'b11001; // XOR 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            // select whichever is from RF and send the other one to ARF
                            if (SREG1[2]) begin
                                RF_OutASelSelector(SREG1[1:0]);
                                ARF_OutCSelSelector(SREG2[1:0]);
                            end else begin
                                RF_OutASelSelector(SREG2[1:0]);
                                ARF_OutCSelSelector(SREG1[1:0]);
                            end
                            
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            MuxASel = 2'b01; // ARF to MuxA
                            RF_ScrSel = 4'b0111; // S1 enabled
                            RF_FunSel = 3'b010; // Load
                            T<=3;
                        end
                    end // XORS end


		            6'h1E:begin // BX
                    	// PC => RF[S1]
                    	ARF_OutCSel = 2'b00; //RF PC Out
                    	MuxASel = 2'b01; //Mux A ARF Out    
                    	RF_ScrSel = 4'b0111; // S1 Enabled 
                    	RF_FunSel = 3'b010; // Load I
                        
                    	T <= 3;
                    end // BX Ends


                    6'h1F:begin // BL
                        // M[SP] => PC[7:0]
                        ARF_OutDSel = 2'b11; // SP ADDRESS
                        Mem_CS = 1'b0; // enable
                        Mem_WR = 1'b0; // Read
                        
                        MuxBSel = 2'b10 ; //Mem output
                        
                        ARF_FunSel = 3'b101; // Load I LSB
                        ARF_RegSel = 3'b011; // Enable PC
                        
                        T <= 3;
                    end // BL Ends
                    

                    6'h20: begin // LDRIM
                       MuxASel = 2'b11; // MUXAOut <- IROut
                       RF_RegSelSelector(RSEL); // RF RegSel is chosen
                       RF_FunSel = 3'b100; // Only write low
                       T <= 0;
                   end // LDRIM Ends


		            8'h21:begin // STRIM
			            //ARF[AR] -> RF[S1]
                        ARF_OutCSel = 2'b10; // AR out
                        MuxASel = 2'b01; // ARF_OUT selector
                        RF_ScrSel = 4'b0111; // S1 enabled
                        RF_FunSel = 3'b010; // Load I
                        T<=3; // To T3
                    end // STRIM Ends

         
                endcase  // opcode end
            end // t2 end
            
            3: begin
                case(OPCODE) 
                
                    6'h00: begin // BRA 
                        //PC -> S2
                        ARF_OutCSel = 2'b00; // PC selected
                        MuxASel = 2'b01; // ARF Selected
                        RF_ScrSel = 4'b1011; // S2 enabled
                        RF_FunSel = 3'b010; // Load 
                        T <= 4;
                    end // BRA Ends
                    

                    6'h01: begin // BNE
                        //PC -> S2
                        ARF_OutCSel = 2'b00; // PC selected
                        MuxASel = 2'b01; // ARF Selected
                        RF_ScrSel = 4'b1011; // S2 enabled
                        RF_FunSel = 3'b010; // Load 
                        T <= 4;
                    end
                    

                    6'h02: begin // BEQ
                        //PC -> S2
                        ARF_OutCSel = 2'b00; // PC selected
                        MuxASel = 2'b01; // ARF Selected
                        RF_ScrSel = 4'b1011; // S2 enabled
                        RF_FunSel = 3'b010; // Load 
                        T <= 4;
                    end // BEQ Ends


		            6'h03: begin // POP
                        RF_FunSel = 3'b110; // Only write to high to Rx
                        T <= 0;
                    end // POP Ends 


		            6'h04: begin // PSH
		                ARF_RegSel = 3'b110; // SP is enabled
                        ARF_FunSel = 3'b000; // Decrement
                        T <= 4;
                    end //PSH end


                    6'h05: begin // INC
                        if (DSTREG[2] == 0) begin //ARF Input
                            ARF_FunSel = 3'b001; // Increment
                        end else if (DSTREG[2] == 1) begin //RF Input
                            RF_FunSel = 3'b001; // Increment
                        end
                        T <= 0;
                    end // INC Ends
			

		            6'h06: begin // DEC
                        if (DSTREG[2] == 0) begin //ARF Input
                            ARF_FunSel = 3'b000; // Decrement
                        end else if (DSTREG[2] == 1) begin //RF Input
                            RF_FunSel = 3'b000; // Decrement
                        end
                        T <= 0;
                    end // DEC Ends
                

                    6'h07: begin // LSL
                        // RF Out to MUXA and MUXB
                        RF_OutASel = 3'b100; // S1 selector for A input ALU
                        ALU_FunSel = 5'b11011; // LSL 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // LSL end


		            6'h08: begin // LSR
                        // RF Out to MUXA and MUXB
                        RF_OutASel = 3'b100; // S1 selector for A input ALU
                        ALU_FunSel = 5'b11100; // LSR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // LSR end


                    6'h09: begin // ASR
                        // RF Out to MUXA and MUXB
                        RF_OutASel = 3'b100; // S1 selector for A input ALU
                        ALU_FunSel = 5'b11101; // ASR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // ASR end


		            6'h0A: begin // CSL
                        // RF Out to MUXA and MUXB
                        RF_OutASel = 3'b100; // S1 selector for A input ALU
                        ALU_FunSel = 5'b11110; // CSL 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // CSL end


                    6'h0B: begin // CSR
                        // RF Out to MUXA and MUXB
                        RF_OutASel = 3'b100; // S1 selector for A input ALU
                        ALU_FunSel = 5'b11111; // CSR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // CSR end


                    6'h0C: begin // AND
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b10111; // AND 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // AND end


                    6'h0D: begin // OR
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b11000; // OR 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // OR end


                    6'h0E: begin // NOT
                        // RF Out to MUXA and MUXB
                        RF_OutASel = 3'b100; // S1 selector for A input ALU
                        ALU_FunSel = 5'b10010; // NOT 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // NOT end


                    6'h0F: begin // XOR
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b11001; // XOR 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // XOR end


                    6'h10: begin // NAND
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b11010; // NAND 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // NAND end


                    6'h15: begin // ADD
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b10100; // ADD 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // ADD end


                    6'h16: begin // ADC
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b10101; // ADC 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // ADC end


                    6'h17: begin // SUB
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b10110; // SUB 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // SUB end


                    6'h19: begin // ADDS
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b10100; // ADD 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // ADDS end


                    6'h1A: begin // SUBS
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b10110; // SUB 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // SUBS end


                    6'h1B: begin // ANDS
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b10111; // AND 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // ANDS end


                    6'h1C: begin // ORRS
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b11000; // OR 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // ORRS end


                    6'h1D: begin // XORS
                        if (SREG1[2] | SREG2[2]) begin // One out from ARF
                            RF_OutBSel = 3'b100; // S1 to OutB
                            ALU_FunSel = 5'b11001; // XOR 16-bit
                            if (DSTREG[2] == 0) begin // Input to ARF
                                MuxBSel = 2'b00; // ALUOut
                                ARF_RegSelSelector(DSTREG[1:0]);
                                ARF_FunSel = 3'b010; // Load
                            end else if (DSTREG[2] == 1) begin // Input to RF
                                MuxASel = 2'b00; // ALUOut
                                RF_RegSelSelector(DSTREG[1:0]);
                                RF_FunSel = 3'b010; // Load
                            end // ARF Input end 
                            T<=0;
                        end else if (!(SREG1[2] & SREG2[2])) begin // both out from ARF
                            ARF_OutCSelSelector(SREG1[1:0]);
                            RF_ScrSel = 4'b1011; // S2 enabled
                            T<=4;
                        end
                    end // XORS end
			
			
		            6'h1E:begin // BX
                        // RF[S1][7:0] => MEM[SP]
                        ARF_OutDSel = 2'b11; //SP OUT
                        Mem_CS = 0; // enable
                        Mem_WR = 1; // Write
                        RF_OutASel = 3'b100; //OutA S1
                        ALU_FunSel = 5'b10000; // Load
                        ALU_WF = 0; // Flags wont change
                        MuxCSel = 0; // Write low first
                        ARF_RegSel = 3'b110; // SP is enabled
                        ARF_FunSel = 3'b001; // Increment SP
                        T <= 4;
                    end // BX Ends
	

		            6'h1F:begin // BL
                        // SP INC
                        ARF_FunSel = 3'b001; // Increment
                        ARF_RegSel = 3'b110; // Enable SP
                        T <= 4;
                    end // BL Ends


		            6'h21:begin // STRIM
			            //IR[7:0] => RF[S2]
                        IR_Write = 0; //IR Read Mode
                        MuxASel = 2'b11; // IR_OUT selector
                        RF_ScrSel = 4'b1011; // S2 enabled
                        RF_FunSel = 3'b100; // clear and load lsb
                        T<=4; // To T4
                    end // STRIM Ends

   
                endcase  // opcode end
            end // t3 end
            
            4: begin
                case(OPCODE) 
                   
                    6'h00: begin
                        // ALUOUT to PC
                        DisableAll();
                        MuxBSel = 2'b00; // ALUOut
                        ARF_FunSel = 3'b010; // LOad
                        ARF_RegSel = 3'b011; // PC enabled
                        
                        T <= 0;
                    end
                    

                    6'h01: begin // BNE
                        // ALUOUT to PC
                        DisableAll();
                        MuxBSel = 2'b00; // ALUOut
                        ARF_FunSel = 3'b010; // LOad
                        ARF_RegSel = 3'b011; // PC enabled
                        
                        T <= 0;
                    end
                    

                    6'h02: begin // BEQ
                        // ALUOUT to PC
                        DisableAll();
                        MuxBSel = 2'b00; // ALUOut
                        ARF_FunSel = 3'b010; // LOad
                        ARF_RegSel = 3'b011; // PC enabled
                        
                        T <= 0;
                    end


		            6'h04: begin // PSH
		                ARF_RegSel = 3'b111; // SP is disabled
                        MuxCSel = 0; // Write low
                        T <= 5;
                    end //PSH end


                    6'h0C: begin // AND
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b10111; // AND 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // AND end

		    
                    6'h0D: begin // OR
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b11000; // OR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // OR end


                    6'h0F: begin // XOR
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b11001; // XOR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // XOR end
		
		
		            6'h10: begin // NAND
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b11001; // XOR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // NAND end


		            6'h15: begin // ADD
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b11001; // XOR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // ADD end
	
	
		            6'h16: begin // ADC
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b11001; // XOR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // ADC end
	
	
	 	            6'h17: begin // SUB
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b11001; // XOR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // SUB end


	 	            6'h19: begin // ADDS
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b11001; // XOR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // ADDS end


	 	            6'h1A: begin // SUBS
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b11001; // XOR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // SUBS end


	 	            6'h1B: begin // ANDS
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b11001; // XOR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // ANDS end


	 	            6'h1C: begin // ORRS
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b11001; // XOR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // ORRS end


	 	            6'h1D: begin // XORS
                        RF_OutASel = 3'b100; // S1 to OutA
                        RF_OutBSel = 3'b101; // S2 to OutB
                        ALU_FunSel = 5'b11001; // XOR 16-bit
                        if (DSTREG[2] == 0) begin // Input to ARF
                            MuxBSel = 2'b00; // ALUOut
                            ARF_RegSelSelector(DSTREG[1:0]);
                            ARF_FunSel = 3'b010; // Load
                        end else if (DSTREG[2] == 1) begin // Input to RF
                            MuxASel = 2'b00; // ALUOut
                            RF_RegSelSelector(DSTREG[1:0]);
                            RF_FunSel = 3'b010; // Load
                        end // ARF Input end 
                        T<=0;
                    end // XORS end


 		            6'h1E:begin // BX
                        // RF[S1][15:8] => MEM[SP+1]
                        MuxCSel = 1; // Write high
                        
                        T <= 5;
                    end // BX Ends


		            6'h1F:begin // BL
                        // M[SP] => PC[15:8]
                        ARF_OutDSel = 2'b11; // SP ADDRESS
                        Mem_CS = 0; // enable
                        Mem_WR = 0; // Read
                        
                        MuxBSel = 2'b10; //Mem output
                        
                        ARF_FunSel = 3'b110; // Load I MSB
                        ARF_RegSel = 3'b011; // Enable PC
                        
                        T <= 5;
		            end // BL Ends
			

		            6'h21:begin // STRIM
			            //ALU Add Op => ARF[AR]
                        RF_OutASel = 3'b100; // Out A S1
                        RF_OutBSel = 3'b101; // Out B S2                     
                        ALU_FunSel = 5'b10100; // ADD 16bit
                        MuxBSel = 2'b00; // ALU Out
                        ARF_RegSel = 3'b101; // AR Selected
                        ARF_FunSel = 3'b010; // Load I
                      
                        T<=5; // To T5
                    end // STRIM Ends
                   
                endcase
            end // T4 End
            
            5: begin
                case(OPCODE) 


                    6'h04: begin // PSH
		                ARF_RegSel = 3'b110; // SP is enabled
                        ARF_FunSel = 3'b000; // Decrement
                        Mem_WR = 0;
                        T <= 0;
                    end //PSH end

                   
                    6'h1E:begin //BX
                        // RF[Rx] => PC
                        Mem_CS = 1'b1; // Mem Disable
                        
                        RF_OutASelSelector(RSEL); //Out A Rx
                        ALU_FunSel = 5'b10000; //Load A
                        
                        MuxBSel = 2'b00; // ALU Out
                        
                        ARF_FunSel = 3'b010; // Load I
                        ARF_RegSel = 3'b011; // PC Enabled  
                        
                        T <= 0;
                    end // BX Ends
                    
                    
                    6'h1F:begin // BL
                        // SP+1 -> SP+2
                        ARF_FunSel = 3'b001; // Increment
                        ARF_RegSel = 3'b110; // Enable SP
                        T <= 0;
		            end // BL Ends


		            6'h21:begin // STRIM
			            // Rx[7:0] => Memory
                        RF_OutASelSelector(RSEL); // RF Rsel Out
                        ALU_FunSel = 5'b10000; // A Load
                        ARF_OutDSel = 2'b10; // Adress AR
                        MuxCSel = 1'b0; // Mem input lsl bit
                        Mem_CS = 0; // enable
                        Mem_WR = 1; // Write
                        
                        ARF_FunSel = 3'b001; //ARF increment
                        ARF_RegSel = 3'b101; // AR Selected
                        T <= 6;
                    end // STRIM Ends

                   
                endcase
            end // T5 End
            
            6: begin
                case(OPCODE) 
                   
                   6'h21:begin // STRIM
			            // Rx[15:8] => Memory
                        RF_OutASelSelector(RSEL); // RF Rsel Out
                        ALU_FunSel = 5'b10000; // A Load
                        ARF_OutDSel = 2'b10; // Adress AR
                        MuxCSel = 1'b1; // Mem input msb bit
                        Mem_CS = 0; // enable
                        Mem_WR = 1; // Write
                        
                        ARF_RegSel = 3'b111; // None Selected     
                        T <= 0;
                    end // STRIM Ends     
                   
                endcase
            end // T6 End
        
        endcase // state case blocks end
    end // always blocks end
endmodule
