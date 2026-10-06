`timescale 1ns / 1ps

module DataMem(
    input clk,
    input MemRead,
    input MemWrite,
    input [2:0] funct3,
    input [31:0] ALUout,
    input [31:0] wdata,
    output reg [31:0] rdata
    );
    parameter F3_BYTE = 3'b000,       
    F3_HALF = 3'b001,
    F3_WORD = 3'b010,
    F3_LBU = 3'b100,
    F3_LHU = 3'b101; 
    
    reg [31:0] mem [0:1023]; // 1024 * 32 = 4 KB Memory
    
    wire [9:0]addr = ALUout[11:2];
    wire [1:0]Byte = ALUout[1:0];
    
      
    wire [31:0] word = mem[addr];
    reg  [7:0]  b;
    wire [15:0] h = Byte[1] ? word[31:16] : word[15:0];
    
    always @(*) begin
            case (Byte)
                2'b00: b = word[7:0];
                2'b01: b = word[15:8];
                2'b10: b = word[23:16];
                2'b11: b = word[31:24];
            endcase
            rdata = 32'b0;                 // default
            if (MemRead) begin
                        case (funct3)
                            F3_BYTE: rdata = {{24{b[7]}},  b};
                            F3_HALF: rdata = {{16{h[15]}}, h};
                            F3_WORD: rdata = word;
                            F3_LBU : rdata = {24'b0, b};
                            F3_LHU : rdata = {16'b0, h};
                            default: rdata = 32'b0;
                        endcase
                    end
            end
    
    always @ (posedge clk) begin
        if (MemWrite) begin
            case (funct3)
            F3_BYTE: case(Byte)
                        2'b00: mem[addr][7:0] <= wdata[7:0];
                        2'b01: mem[addr][15:8] <= wdata[7:0];
                        2'b10: mem[addr][23:16] <= wdata[7:0];
                        2'b11: mem[addr][31:24] <= wdata[7:0];
                        endcase
            F3_HALF: case (Byte[1])
                        1'b0: mem[addr][15:0] <= wdata[15:0];
                        1'b1: mem[addr][31:16] <= wdata[15:0];
                        endcase
            F3_WORD: mem[addr] <= wdata;
            endcase
            end
            end
    
    
endmodule
