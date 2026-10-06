`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2026 08:18:13 PM
// Design Name: 
// Module Name: mux2to1
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


module mux2to1#(parameter DATAWIDTH =1)(
    input [DATAWIDTH-1:0] in1,
    input [DATAWIDTH-1:0] in2,
    input sel,
    output [DATAWIDTH-1:0] out
    );
    
    assign out = sel?in2:in1;
endmodule
