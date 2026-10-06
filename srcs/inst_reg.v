`timescale 1ns / 1ps

module inst_reg(
    input [31:0] pc,
    output reg [31:0] inst
);

reg [31:0] mem [0:1023];    // 1024 x 32 = 4kb

always@(*) begin
    inst = mem[pc[11:2]];     // 2^10 = 1024
end

endmodule