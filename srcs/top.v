`timescale 1ns / 1ps

module top(
input clk, 
input rst
    );
    wire pc_funct, ALUSrcA, ALUSrcB, 
         RegWrite, 
         MemRead, MemWrite, jalr;
    wire [31:0] datain1, datain2, dataout,
                rs1data, rs2data,
                imm,
                MemOut,
                WData, 
                jalr_target;
    wire [3:0] funct;
    wire [31:0] pc;
    wire [31:0] instr;
    wire [2:0] imm_sel;
    wire [1:0] WBSel;
    
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] pc_plus4 = pc + 32'd4;
    
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    assign jalr_target = dataout;
    
    PC pc_mod (.rst(rst), 
               .clk(clk), 
               .pc_funct(pc_funct),
               .pc_plus4(pc_plus4),
               .jalr(jalr),
               .jalr_target(jalr_target), 
               .currPC(pc), 
               .imm(imm), 
               .nextPC(pc));
               
    mux2to1 #(.DATAWIDTH(32)) alu_mux1 (
                   .in1 (rs1data),
                   .in2 (pc),
                   .sel (ALUSrcA),
                   .out (datain1)
               );
               
    mux2to1 #(.DATAWIDTH(32)) alu_mux2 (
                                  .in1 (rs2data),
                                  .in2 (imm),
                                  .sel (ALUSrcB),
                                  .out (datain2)
                              );
               
    ALU alu_mod (.DataIn1(datain1), 
                 .DataIn2(datain2), 
                 .funct(funct), 
                 .DataOut(dataout));
                 
    Controller cont_mod (.opcode(opcode), 
                         .funct3(funct3), 
                         .funct7(funct7), 
                         .ALUoutLSB(dataout[0]), .RegWrite(RegWrite), 
                         .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB), 
                         .imm_sel(imm_sel), .WBSel(WBSel), 
                         .MemRead(MemRead), .MemWrite(MemWrite), 
                         .pc_funct(pc_funct), 
                         .jalr(jalr), 
                         .ALUop(funct));
                         
    DataMem datamem_mod (.clk(clk), 
                         .MemRead(MemRead), .MemWrite(MemWrite), 
                         .funct3(funct3), 
                         .ALUout(dataout), 
                         .wdata(rs2data), .rdata(MemOut));
                         
    ImmGen immgen_mod (.instr(instr), .imm_sel(imm_sel), .imm_out(imm));
    
    mux4to1 #(.DATAWIDTH(32)) reg_mux(
                    .in1 (dataout),
                    .in2 (MemOut),
                    .in3 (pc_plus4),
                    .in4 (imm),
                    .sel (WBSel),
                    .out (WData)
                );
                
     Register reg_mod (.clk(clk), 
                       .RegWrite(RegWrite), 
                       .Rs1Add(instr[19:15]), .Rs2Add(instr[24:20]), .RdAdd(instr[11:7]), 
                       .WData(WData), .Rs1Data(rs1data), .Rs2Data(rs2data));
     
     inst_reg inst_reg_mod (.pc(pc), .inst(instr));
     
endmodule
