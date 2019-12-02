`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/07 21:42:17
// Design Name: 
// Module Name: gaus_line
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


module gaus_line(
    input clk,
    input start,
    input [55:0] a,
    input [55:0] b,

    output [15:0] result,
    output finish
    );

    reg startReg[0:4];
    reg finishReg;

    assign finish = finishReg;

    always @(posedge clk)
    begin
        startReg[0] <= start;
        startReg[1] <= startReg[0];
        startReg[2] <= startReg[1];

        startReg[3] <= startReg[2];
        sum4[0] <= mult[0] + mult[1];
        sum4[1] <= mult[2] + mult[3];
        sum4[2] <= mult[4] + mult[5];
        sum4[3] <= mult[6];

        startReg[4] <= startReg[3];
        sum2[0] <= sum4[0] + sum4[1];
        sum2[1] <= sum4[2] + sum4[3];

        finishReg <= startReg[4];
        resultReg <= sum2[0] + sum2[1];
    end

    wire [15:0] mult[0:6];
    reg [15:0] sum4[0:3];
    reg [15:0] sum2[0:1];
    reg [15:0] resultReg;

    assign result = resultReg;

    mult_gen_1 mult1
    (
        .CLK(clk),
        .A(a[7:0]),
        .B(b[7:0]),
        .P(mult[0])
    );

    mult_gen_1 mult2
    (
        .CLK(clk),
        .A(a[15:8]),
        .B(b[15:8]),
        .P(mult[1])
    );

    mult_gen_1 mult3
    (
        .CLK(clk),
        .A(a[23:16]),
        .B(b[23:16]),
        .P(mult[2])
    );

    mult_gen_1 mult4
    (
        .CLK(clk),
        .A(a[31:24]),
        .B(b[31:24]),
        .P(mult[3])
    );

    mult_gen_1 mult5
    (
        .CLK(clk),
        .A(a[39:32]),
        .B(b[39:32]),
        .P(mult[4])
    );

    mult_gen_1 mult6
    (
        .CLK(clk),
        .A(a[47:40]),
        .B(b[47:40]),
        .P(mult[5])
    );

    mult_gen_1 mult7
    (
        .CLK(clk),
        .A(a[55:48]),
        .B(b[55:48]),
        .P(mult[6])
    );

endmodule
