`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2026 12:05:43 AM
// Design Name: 
// Module Name: Register
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


module Register(
input clk,
input RegWrite,
input [4:0] Rs1Add, Rs2Add, RdAdd,
input [31:0] WData,
output [31:0] Rs1Data, Rs2Data
    );
    reg [31:0] register [31:0];
    
        assign Rs1Data = (Rs1Add == 5'd0) ? 32'd0 : register[Rs1Add];
        assign Rs2Data = (Rs2Add == 5'd0) ? 32'd0 : register[Rs2Add];
    
        always @(posedge clk) begin
            if (RegWrite && RdAdd != 5'd0)
                register[RdAdd] <= WData;
        end
endmodule
