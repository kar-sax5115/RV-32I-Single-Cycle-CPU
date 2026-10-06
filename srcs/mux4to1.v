`timescale 1ns / 1ps

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