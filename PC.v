`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2026 12:05:43 AM
// Design Name: 
// Module Name: PC
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

module PC(
    input rst, clk,
    input pc_funct,            // 1 = PC + imm
    input jalr,                // 1 = ALU result
    input [31:0] currPC,
    input [31:0] imm,
    input [31:0] jalr_target,  // rs1 + imm from the ALU
    input [31:0] pc_plus4,
    output reg [31:0] nextPC
);
    always @(posedge clk or posedge rst) begin
        if (rst)           nextPC <= 32'd0;
        else if (jalr)     nextPC <= jalr_target & 32'hFFFFFFFE;
        else if (pc_funct) nextPC <= currPC + imm;
        else               nextPC <= pc_plus4;
    end
endmodule