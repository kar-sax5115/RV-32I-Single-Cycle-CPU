`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2026 12:05:43 AM
// Design Name: 
// Module Name: ALU
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


//module ALU #(                    
//parameter ADD = 4'b0000, SUB = 4'b0001, //Arithmetic
//parameter XOR = 4'b0010, OR = 4'b0011, AND = 4'b0100, //Logical
//parameter SLL = 4'b0101, SRL = 4'b0110, SRA = 4'b0111, //Shift
//parameter S_LT = 4'b1000, U_LT = 4'b1001,   //Signed/Unsigned Less than
//parameter B_EQ = 4'b1010, B_NEQ = 4'b1011,  B_GEQU = 4'b1100, B_GEQ = 4'b1101  // Boolean == | != | >=
//)(
//input [31:0] DataIn1, DataIn2,
//input [3:0] funct,
//output reg [31:0] DataOut
//);

//always @(*)begin
//DataOut = 0;
// case(funct)
//    //Arithmetic/Logical
//    ADD: DataOut = DataIn1 + DataIn2;
//    SUB: DataOut = DataIn1 - DataIn2;
//    XOR: DataOut = DataIn1 ^ DataIn2;
//    OR: DataOut = DataIn1 | DataIn2;
//    AND: DataOut = DataIn1 & DataIn2;
    
//    //Shift 
//    //Below 5 Bits are used for Shift
//    SLL: DataOut = DataIn1 << DataIn2[4:0];
//    SRL: DataOut = DataIn1 >> DataIn2[4:0];
//    SRA: DataOut = $signed(DataIn1) >>> DataIn2[4:0]; // $signed ensures MSB is copied.
    
//    //Signed/Unsigned Less than
//    S_LT: DataOut = {31'b0, $signed(DataIn1)<$signed(DataIn2)};
//    U_LT: DataOut = {31'b0, DataIn1<DataIn2};
    
//    //Boolean == | != | >=
//    B_EQ: DataOut = {31'b0,(DataIn1 == DataIn2)};
//    B_NEQ: DataOut = {31'b0,(DataIn1 != DataIn2)};
//    B_GEQU:  DataOut = {31'b0,(DataIn1 >= DataIn2)}; //
//    B_GEQ:  DataOut = {31'b0,($signed(DataIn1) >= $signed(DataIn2))}; //BLT and BLTU
//    endcase
//    end
//endmodule


module ALU #(
    parameter ADD = 4'b0000, SUB = 4'b0001,
    parameter XOR = 4'b0010, OR = 4'b0011, AND = 4'b0100,
    parameter SLL = 4'b0101, SRL = 4'b0110, SRA = 4'b0111,
    parameter S_LT = 4'b1000, U_LT = 4'b1001,
    parameter B_EQ = 4'b1010, B_NEQ = 4'b1011, B_GEQU = 4'b1100, B_GEQ = 4'b1101
)(
    input  [31:0] DataIn1, DataIn2,
    input  [3:0]  funct,
    output reg [31:0] DataOut
);
    // ---- ONE adder/subtractor (also used for all compares) ----
    wire        sub = (funct != ADD);
    wire [32:0] sum = {1'b0, DataIn1} + {1'b0, DataIn2 ^ {32{sub}}} + sub;
    wire        ltu = ~sum[32];                                   // A < B unsigned
    wire        lts = (DataIn1[31] ^ DataIn2[31]) ? DataIn1[31] : ltu; // A < B signed
    wire        eq  = (DataIn1 == DataIn2);

    // ---- ONE shifter (right shifter + bit reversal for SLL) ----
    function [31:0] rev;
        input [31:0] x;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1) rev[i] = x[31-i];
        end
    endfunction

    wire        left  = (funct == SLL);
    wire        fill  = (funct == SRA) & DataIn1[31];
    wire [32:0] shin  = {fill, left ? rev(DataIn1) : DataIn1};
    wire [32:0] shout = $signed(shin) >>> DataIn2[4:0];
    wire [31:0] shres = left ? rev(shout[31:0]) : shout[31:0];

    always @(*) begin
        case (funct)
            ADD, SUB:      DataOut = sum[31:0];
            XOR:           DataOut = DataIn1 ^ DataIn2;
            OR:            DataOut = DataIn1 | DataIn2;
            AND:           DataOut = DataIn1 & DataIn2;
            SLL, SRL, SRA: DataOut = shres;
            S_LT:          DataOut = {31'b0, lts};
            U_LT:          DataOut = {31'b0, ltu};
            B_EQ:          DataOut = {31'b0, eq};
            B_NEQ:         DataOut = {31'b0, ~eq};
            B_GEQU:        DataOut = {31'b0, ~ltu};
            B_GEQ:         DataOut = {31'b0, ~lts};
            default:       DataOut = 32'b0;
        endcase
    end
endmodule