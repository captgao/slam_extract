`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/07 21:29:17
// Design Name: 
// Module Name: gaus_conv
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


module gaus_conv(
    input clk,
    input rst,
    input start,


    input [55:0] col1,
    input [55:0] col2,
    input [55:0] col3,
    input [55:0] col4,
    input [55:0] col5,
    input [55:0] col6,
    input [55:0] col7,

    output [7:0] result,
    output val

    );

    reg [55:0] filter0 = {8'd1,   8'd2,   8'd3,   8'd4,   8'd3,   8'd2,   8'd1};
    reg [55:0] filter1 = {8'd2,   8'd4,   8'd6,   8'd7,   8'd6,   8'd4,   8'd2};
    reg [55:0] filter2 = {8'd3,   8'd6,   8'd9,   8'd11,  8'd9,   8'd6,   8'd3};
    reg [55:0] filter3 = {8'd4,   8'd7,   8'd11,  8'd12,  8'd11,  8'd7,   8'd4};
    reg [55:0] filter4 = {8'd3,   8'd6,   8'd9,   8'd11,  8'd9,   8'd6,   8'd3};
    reg [55:0] filter5 = {8'd2,   8'd4,   8'd6,   8'd7,   8'd6,   8'd4,   8'd2};
    reg [55:0] filter6 = {8'd1,   8'd2,   8'd3,   8'd4,   8'd3,   8'd2,   8'd1};
	
	wire [15:0] lineSum[0:6];
	wire lineFinish;

    reg [15:0] sum4[0:3];
    reg [15:0] sum2[0:1];
    reg [15:0] resultReg;
    reg startReg[0:1];
    reg finishReg;

    // assign val = finishReg;
    // assign result = resultReg[15:8];

    always @(posedge clk)
    begin
        startReg[0] <= lineFinish;
        sum4[0] <= lineSum[0] + lineSum[1];
        sum4[1] <= lineSum[2] + lineSum[3];
        sum4[2] <= lineSum[4] + lineSum[5];
        sum4[3] <= lineSum[6];

        startReg[1] <= startReg[0];
        sum2[0] <= sum4[0] + sum4[1];
        sum2[1] <= sum4[2] + sum4[3];

        finishReg <= startReg[1];
        resultReg <= sum2[0] + sum2[1];
    end

    gaus_line line1
    (
		.clk(clk),
		.start(start),
		.a(filter0),
		.b(col1),
	
		.result(lineSum[0]),
		.finish(lineFinish)
    );

    gaus_line line2
    (
		.clk(clk),
		.start(start),
		.a(filter1),
		.b(col2),
	
		.result(lineSum[1])
    );

    gaus_line line3
    (
		.clk(clk),
		.start(start),
		.a(filter2),
		.b(col3),
	
		.result(lineSum[2])
    );

    gaus_line line4
    (
		.clk(clk),
		.start(start),
		.a(filter3),
		.b(col4),
	
		.result(lineSum[3])
    );

    gaus_line line5
    (
		.clk(clk),
		.start(start),
		.a(filter4),
		.b(col5),
	
		.result(lineSum[4])
    );

    gaus_line line6
    (
		.clk(clk),
		.start(start),
		.a(filter5),
		.b(col6),
	
		.result(lineSum[5])
    );

    gaus_line line7
    (
		.clk(clk),
		.start(start),
		.a(filter6),
		.b(col7),
	
		.result(lineSum[6])
    );

    /* delay */
    reg [7:0] resultDelay[0:2];
    reg valDelay[0:2];

    assign result = resultDelay[2];
    assign val = valDelay[2];

    always @(posedge clk)
    begin
      resultDelay[0] <= resultReg[15:8];
      resultDelay[1] <= resultDelay[0];
      resultDelay[2] <= resultDelay[1];

      valDelay[0] <= finishReg;
      valDelay[1] <= valDelay[0];
      valDelay[2] <= valDelay[1];
    end

endmodule
