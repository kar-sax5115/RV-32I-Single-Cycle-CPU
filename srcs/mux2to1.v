`timescale 1ns / 1ps

module mux2to1#(parameter DATAWIDTH =1)(
    input [DATAWIDTH-1:0] in1,
    input [DATAWIDTH-1:0] in2,
    input sel,
    output [DATAWIDTH-1:0] out
    );
    
    assign out = sel?in2:in1;
endmodule
