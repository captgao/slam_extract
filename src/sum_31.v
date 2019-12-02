`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/02 16:28:53
// Design Name: 
// Module Name: sum_31
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


module sum_31 #
	(
		parameter integer WIDTH = 16
	)
    (
        input clk,
        input start,

        input [WIDTH-1:0] i1,
        input [WIDTH-1:0] i2,
        input [WIDTH-1:0] i3,
        input [WIDTH-1:0] i4,
        input [WIDTH-1:0] i5,
        input [WIDTH-1:0] i6,
        input [WIDTH-1:0] i7,
        input [WIDTH-1:0] i8,
        input [WIDTH-1:0] i9,
        input [WIDTH-1:0] i10,
        input [WIDTH-1:0] i11,
        input [WIDTH-1:0] i12,
        input [WIDTH-1:0] i13,
        input [WIDTH-1:0] i14,
        input [WIDTH-1:0] i15,
        input [WIDTH-1:0] i16,
        input [WIDTH-1:0] i17,
        input [WIDTH-1:0] i18,
        input [WIDTH-1:0] i19,
        input [WIDTH-1:0] i20,
        input [WIDTH-1:0] i21,
        input [WIDTH-1:0] i22,
        input [WIDTH-1:0] i23,
        input [WIDTH-1:0] i24,
        input [WIDTH-1:0] i25,
        input [WIDTH-1:0] i26,
        input [WIDTH-1:0] i27,
        input [WIDTH-1:0] i28,
        input [WIDTH-1:0] i29,
        input [WIDTH-1:0] i30,
        input [WIDTH-1:0] i31,

        output [WIDTH+3:0] sum,
        output finish

    );

    reg startS2   = 0;
    reg startS3   = 0;
    reg startS4   = 0;
    reg startS5   = 0;
    reg finishReg = 0;

    assign finish = finishReg;

    reg [WIDTH+3:0] sum2  [0:15] ;
    reg [WIDTH+3:0] sum4  [0:7]  ;
    reg [WIDTH+3:0] sum8  [0:3]  ;
    reg [WIDTH+3:0] sum16 [0:1]  ;
    reg [WIDTH+3:0] sum31        = 0;

    assign sum = sum31;

    always @(posedge clk)
    begin
        /* s1
         */
        startS2 <= start;
        if(start)
        begin
            sum2[0]  <= i1    -  i31;
            sum2[1]  <= i2    -  i30;
            sum2[2]  <= i3    -  i29;
            sum2[3]  <= i4    -  i28;
            sum2[4]  <= i5    -  i27;
            sum2[5]  <= i6    -  i26;
            sum2[6]  <= i7    -  i25;
            sum2[7]  <= i8    -  i24;
            sum2[8]  <= i9    -  i23;
            sum2[9]  <= i10   -  i22;
            sum2[10] <= i11   -  i21;
            sum2[11] <= i12   -  i20;
            sum2[12] <= i13   -  i19;
            sum2[13] <= i14   -  i18;
            sum2[14] <= i15   -  i17;
            sum2[15] <= i16;
        end
		

        /* s2
         */
		startS3 <= startS2;
        if(startS2)
        begin
            sum4[0]  <= sum2[0]  +  sum2[1];
            sum4[1]  <= sum2[2]  +  sum2[3];
            sum4[2]  <= sum2[4]  +  sum2[5];
            sum4[3]  <= sum2[6]  +  sum2[7];
            sum4[4]  <= sum2[8]  +  sum2[9];
            sum4[5]  <= sum2[10] +  sum2[11];
            sum4[6]  <= sum2[12] +  sum2[13];
            sum4[7]  <= sum2[14] +  sum2[15];

        end

        /* s3
         */
		startS4 <= startS3;
        if(startS3)
        begin

            sum8[0]  <= sum4[0]  +  sum4[1];
            sum8[1]  <= sum4[2]  +  sum4[3];
            sum8[2]  <= sum4[4]  +  sum4[5];
            sum8[3]  <= sum4[6]  +  sum4[7];

        end

        /* s4
         */
		startS5 <= startS4;
        if(startS4)
        begin
            sum16[0]  <= sum8[0]  +  sum8[1];
            sum16[1]  <= sum8[2]  +  sum8[3];
        end

        /* s5
         */
        finishReg <= startS5;
        if(startS5)
        begin
            sum31 <= sum16[0] + sum16[1];
        end

    end
endmodule
