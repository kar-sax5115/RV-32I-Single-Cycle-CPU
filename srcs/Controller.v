`timescale 1ns / 1ps

module Controller #(parameter ADD = 4'b0000, SUB = 4'b0001, //Arithmetic
    parameter XOR = 4'b0010, OR = 4'b0011, AND = 4'b0100, //Logical
    parameter SLL = 4'b0101, SRL = 4'b0110, SRA = 4'b0111, //Shift
    parameter S_LT = 4'b1000, U_LT = 4'b1001,   // Signed/Unsigned Less than
    parameter B_EQ = 4'b1010, B_NEQ = 4'b1011,  B_GEQU = 4'b1100,B_GEQ = 4'b1101,  // Boolean == | != | >=
    
    parameter [6:0] SUB_SRA = 7'b0100000, R_I_SRL = 7'b0000000, R_I_SRA = 7'b0100000, ZERO = 7'b0000000,
    
                    //Arithmetic            //Shift                 //Load/Store            //Branch
    parameter [2:0] F3_ADD_SUB = 3'b000,    F3_SLL = 3'b001,        F3_BYTE = 3'b000,       F3_BEQ = 3'b000,
                    F3_XOR = 3'b100,        F3_SRL_SRA = 3'b101,    F3_HALF = 3'b001,       F3_BNE = 3'b001,
                    F3_OR = 3'b110,         F3_S_LT = 3'b010,       F3_WORD = 3'b010,       F3_BGE = 3'b101,
                    F3_AND =3'b111,         F3_U_LT = 3'b011,       F3_LBU = 3'b100,        F3_BLT = 3'b100,
                                                                    F3_LHU = 3'b101,        F3_BLTU = 3'b110,
                                                                                            F3_BGEU = 3'b111,
                                                                                      
                                                                                      
    parameter [6:0] 
                    R_TYPE = 7'b0110011,
                    R_I_TYPE = 7'b0010011,
                    L_TYPE = 7'b0000011,
                    S_TYPE = 7'b0100011,
                    B_TYPE = 7'b1100011,
                    JAL_TYPE =7'b1101111,
                    JALR_TYPE = 7'b1100111,
                    LUI = 7'b0110111,
                    AUIPC = 7'b0010111,
                    Envi_Itype = 7'b1110011
    )(
input [6:0] opcode, 
input [2:0] funct3, 
input [6:0] funct7,
input ALUoutLSB,
output reg RegWrite,
output reg ALUSrcA, //rs1 or PC
output reg ALUSrcB, //rs2 or imm
output reg [2:0] imm_sel,
output reg [1:0] WBSel, 
output reg MemRead, MemWrite,
output reg pc_funct,
output reg jalr,
output reg [3:0] ALUop
    );
    
initial begin
ALUop    = 4'b0000;
pc_funct = 1'b0; //1 means next PC = PC + imm
RegWrite = 1'b0;
jalr = 1'b0;
ALUSrcA = 1'b0; //0 = rs1, 1 = PC
ALUSrcB = 1'b0; //0 = rs2, 1 = imm
imm_sel = 3'b000; //000 I, 001 S, 010 B, 011 J, 100 U
WBSel = 2'b00; //00 ALU, 01 MEM, 10 PC+4, 11 IMM
MemRead  = 1'b0;
MemWrite = 1'b0;
end
                    
always @(*) begin
ALUop    = 4'b0000;
pc_funct = 1'b0; //1 means next PC = PC + imm
jalr     = 1'b0; //1 means next PC = (rs1 + imm) & ~1
RegWrite = 1'b0;
ALUSrcA = 1'b0; //0 = rs1, 1 = PC
ALUSrcB = 1'b0; //0 = rs2, 1 = imm
imm_sel = 3'b000; //000 I, 001 S, 010 B, 011 J, 100 U
WBSel = 2'b00; //00 ALU, 01 MEM, 10 PC+4, 11 IMM
MemRead  = 1'b0;
MemWrite = 1'b0;

case (opcode)
        
    R_TYPE: begin 
    RegWrite = 1'b1;
        case (funct7)
            SUB_SRA: begin
                case (funct3)
                    F3_ADD_SUB: ALUop = SUB;
                    F3_SRL_SRA: ALUop = SRA;
                    default: ALUop = 4'b1111;
                endcase
                end
            ZERO: begin
                case (funct3)
                    F3_ADD_SUB: ALUop = ADD;
                    F3_XOR: ALUop = XOR;
                    F3_OR: ALUop = OR;
                    F3_AND: ALUop = AND;
                    F3_SLL: ALUop = SLL;
                    F3_SRL_SRA: ALUop = SRL;
                    F3_S_LT: ALUop = S_LT;
                    F3_U_LT: ALUop = U_LT;
                    default: ALUop = 4'b1111;
                endcase
                end
           default: ALUop = 4'b1111;
       endcase
       end
    
    R_I_TYPE: begin
    RegWrite = 1'b1;
    ALUSrcB = 1'b1;
        case (funct3)
            F3_ADD_SUB: ALUop = ADD;
            F3_XOR: ALUop = XOR;
            F3_OR: ALUop = OR;
            F3_AND: ALUop = AND;
            F3_SLL: ALUop = SLL;
            F3_SRL_SRA: begin
                     case (funct7)
                        R_I_SRL: ALUop = SRL;
                        R_I_SRA: ALUop = SRA;
                        default: ALUop = 4'b1111;
                     endcase
                        end
            F3_S_LT: ALUop = S_LT;
            F3_U_LT: ALUop = U_LT;
            default: ALUop = 4'b1111;
        endcase
        end
        
    L_TYPE: begin ALUop = ADD;
         RegWrite = 1'b1;
         ALUSrcB = 1'b1;
         WBSel = 2'b01;
         MemRead = 1'b1;
         MemWrite = 1'b0;
         end
        
    S_TYPE: begin ALUop = ADD;
          ALUSrcB = 1'b1;
          imm_sel = 3'b001;
          MemRead = 1'b0;
          MemWrite = 1'b1;
          end
        
    B_TYPE: begin
            imm_sel = 3'b010;
            case (funct3)
            F3_BEQ:  begin ALUop = B_EQ;   pc_funct = ALUoutLSB; end
            F3_BNE:  begin ALUop = B_NEQ;  pc_funct = ALUoutLSB; end
            F3_BLT:  begin ALUop = S_LT;   pc_funct = ALUoutLSB; end
            F3_BGE:  begin ALUop = B_GEQ;  pc_funct = ALUoutLSB; end
            F3_BLTU: begin ALUop = U_LT;   pc_funct = ALUoutLSB; end
            F3_BGEU: begin ALUop = B_GEQU; pc_funct = ALUoutLSB; end
            default: ALUop = 4'b1111;
            endcase
            end
    JAL_TYPE: begin
              RegWrite = 1'b1;
              imm_sel  = 3'b011;
              WBSel    = 2'b10;
              pc_funct = 1'b1;
              end
             
                // JALR: rd = PC + 4, next PC = (rs1 + I-imm) & ~1  (sum comes from ALU)
   JALR_TYPE: begin
              RegWrite = 1'b1;
              ALUSrcB  = 1'b1;
              imm_sel  = 3'b000;
              ALUop    = ADD;
              WBSel    = 2'b10;
              jalr     = 1'b1;
              end
             
                // LUI: rd = U-imm (passes through the write-back mux)
  LUI: begin
       RegWrite = 1'b1;
       imm_sel  = 3'b100;
       WBSel    = 2'b11;
       end
             
                // AUIPC: rd = PC + U-imm
 AUIPC: begin
        RegWrite = 1'b1;
        ALUSrcA  = 1'b1;
        ALUSrcB  = 1'b1;
        imm_sel  = 3'b100;
        ALUop    = ADD;
        WBSel    = 2'b00;
       end
       
       // ECALL / EBREAK / unknown opcodes: treated as NOP (defaults above)
       default: ;
        
endcase
end
    
endmodule
