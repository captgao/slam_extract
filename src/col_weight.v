`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/30 13:11:46
// Design Name: 
// Module Name: col_weight
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


module col_weight(
    input clk,
    input start,

    input [247:0] pix,
    input [3:0] index,
    output finish,
    output [19:0] mult,
    output [15:0] sum
    );

    wire [7:0] pixs[0:30];

    assign pixs[0]   =  pix[7:0];
    assign pixs[1]   =  pix[15:8];
    assign pixs[2]   =  pix[23:16];
    assign pixs[3]   =  pix[31:24];
    assign pixs[4]   =  pix[39:32];
    assign pixs[5]   =  pix[47:40];
    assign pixs[6]   =  pix[55:48];
    assign pixs[7]   =  pix[63:56];
    assign pixs[8]   =  pix[71:64];
    assign pixs[9]   =  pix[79:72];
    assign pixs[10]  =  pix[87:80];
    assign pixs[11]  =  pix[95:88];
    assign pixs[12]  =  pix[103:96];
    assign pixs[13]  =  pix[111:104];
    assign pixs[14]  =  pix[119:112];
    assign pixs[15]  =  pix[127:120];
    assign pixs[16]  =  pix[135:128];
    assign pixs[17]  =  pix[143:136];
    assign pixs[18]  =  pix[151:144];
    assign pixs[19]  =  pix[159:152];
    assign pixs[20]  =  pix[167:160];
    assign pixs[21]  =  pix[175:168];
    assign pixs[22]  =  pix[183:176];
    assign pixs[23]  =  pix[191:184];
    assign pixs[24]  =  pix[199:192];
    assign pixs[25]  =  pix[207:200];
    assign pixs[26]  =  pix[215:208];
    assign pixs[27]  =  pix[223:216];
    assign pixs[28]  =  pix[231:224];
    assign pixs[29]  =  pix[239:232];
    assign pixs[30]  =  pix[247:240];

    reg startS2   = 0;
    reg startS3   = 0;
    reg startS4   = 0;
    reg startS5   = 0;
    reg startS6   = 0;
    reg startS7   = 0;
    reg startS8   = 0;
    reg finishReg = 0;

    reg [3:0] index2 = 0;
    reg [3:0] index3 = 0;
    reg [3:0] index4 = 0;
    reg [3:0] index5 = 0;
    reg [3:0] index6 = 0;

    assign finish = finishReg;

    reg [15:0] sum2  [0:15] ;
    reg [15:0] sum4  [0:7]  ;
    reg [15:0] sum8  [0:3]  ;
    reg [15:0] sum16 [0:1]  ;
    reg [15:0] sum31        = 0;
    reg [15:0] sum31_2      = 0;
    reg [15:0] sum31_3      = 0;
    reg [15:0] sum31_4      = 0;
    assign sum = sum31_4;

    always @(posedge clk)
    begin
        /* s1
         */
        startS2 <= start;
        if(start)
        begin
            index2 <= index;

            sum2[0]  <= pixs[0]  +  pixs[1];
            sum2[1]  <= pixs[2]  +  pixs[3];
            sum2[2]  <= pixs[4]  +  pixs[5];
            sum2[3]  <= pixs[6]  +  pixs[7];
            sum2[4]  <= pixs[8]  +  pixs[9];
            sum2[5]  <= pixs[10] +  pixs[11];
            sum2[6]  <= pixs[12] +  pixs[13];
            sum2[7]  <= pixs[14] +  pixs[15];
            sum2[8]  <= pixs[16] +  pixs[17];
            sum2[9]  <= pixs[18] +  pixs[19];
            sum2[10] <= pixs[20] +  pixs[21];
            sum2[11] <= pixs[22] +  pixs[23];
            sum2[12] <= pixs[24] +  pixs[25];
            sum2[13] <= pixs[26] +  pixs[27];
            sum2[14] <= pixs[28] +  pixs[29];
            sum2[15] <= pixs[30];
        end

        /* s2
         */
		startS3 <= startS2;
        if(startS2)
        begin
            index3 <= index2;
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
            index4 <= index3;

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
            index5 <= index4;

            sum16[0]  <= sum8[0]  +  sum8[1];
            sum16[1]  <= sum8[2]  +  sum8[3];
        end

        /* s5
         */
        startS6 <= startS5;
        if(startS5)
        begin
            index6 <= index5;

            sum31 <= sum16[0] + sum16[1];
        end

        /* s6
         */
        startS7 <= startS6;
        if(startS6)
        begin
            sum31_2 <= sum31;
        end

        /* s7
         */
        startS8 <= startS7;
        if(startS7)
        begin
            sum31_3 <= sum31_2;
        end

        /* s8
         */
        finishReg <= startS8;
        if(startS8)
        begin
            sum31_4 <= sum31_3;
        end


    end


    mult_gen_0 mult_gen_0
    (
        .CLK(clk),
        .A(sum31),
        .B(index6),
        .P(mult)
    );

endmodule
