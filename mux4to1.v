`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2026 09:14:30 PM
// Design Name: 
// Module Name: mux4to1
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

module mux4to1 #(parameter DATAWIDTH = 1)(
    input  [DATAWIDTH-1:0] in1,
    input  [DATAWIDTH-1:0] in2,
    input  [DATAWIDTH-1:0] in3,
    input  [DATAWIDTH-1:0] in4,
    input  [1:0]           sel,
    output reg [DATAWIDTH-1:0] out
);

    always @(*) begin
        case (sel)
            2'b00:   out = in1;
            2'b01:   out = in2;
            2'b10:   out = in3;
            2'b11:   out = in4;
            default: out = {DATAWIDTH{1'bx}};  // only reached if sel is X/Z in simulation
        endcase
    end

endmodule