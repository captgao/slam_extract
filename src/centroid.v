`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/30 11:58:06
// Design Name: 
// Module Name: centroid
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


module centroid(
    input clk,
    input start,
    input maskIn,

    input [247:0] col1,
    input [247:0] col2,
    input [247:0] col3,
    input [247:0] col4,
    input [247:0] col5,
    input [247:0] col6,
    input [247:0] col7,
    input [247:0] col8,
    input [247:0] col9,
    input [247:0] col10,
    input [247:0] col11,
    input [247:0] col12,
    input [247:0] col13,
    input [247:0] col14,
    input [247:0] col15,
    input [247:0] col16,
    input [247:0] col17,
    input [247:0] col18,
    input [247:0] col19,
    input [247:0] col20,
    input [247:0] col21,
    input [247:0] col22,
    input [247:0] col23,
    input [247:0] col24,
    input [247:0] col25,
    input [247:0] col26,
    input [247:0] col27,
    input [247:0] col28,
    input [247:0] col29,
    input [247:0] col30,
    input [247:0] col31,

    output finish,
    output [23:0] sumColProduct,
    output [23:0] sumRowProduct,
    output maskOut

    );

	wire colFinish;
	wire [19:0] colProduct[0:30];
    wire [15:0] colSum[0:30];
	wire [19:0] rowProduct[0:30];
    wire [15:0] rowSum[0:30];

    // y = 15;
    col_weight col1_
    (
        .clk(clk),
        .pix(col1),
        .start(start),
        .index(15),
        .finish(colFinish),
        .mult(colProduct[0]),
        .sum(colSum[0])
    );
    // y = 14;
    col_weight col2_
    (
        .clk(clk),
        .pix(col2),
        .start(start),
        .index(14),
        .mult(colProduct[1]),
        .sum(colSum[1])
    );
    // y = 13;
    col_weight col3_
    (
        .clk(clk),
        .pix(col3),
        .start(start),
        .index(13),
        .mult(colProduct[2]),
        .sum(colSum[2])
    );
    // y = 12;
    col_weight col4_
    (
        .clk(clk),
        .pix(col4),
        .start(start),
        .index(12),
        .mult(colProduct[3]),
        .sum(colSum[3])
    );
    // y = 11;
    col_weight col5_
    (
        .clk(clk),
        .pix(col5),
        .start(start),
        .index(11),
        .mult(colProduct[4]),
        .sum(colSum[4])
    );
    // y = 10;
    col_weight col6_
    (
        .clk(clk),
        .pix(col6),
        .start(start),
        .index(10),
        .mult(colProduct[5]),
        .sum(colSum[5])
    );
    // y = 9;
    col_weight col7_
    (
        .clk(clk),
        .pix(col7),
        .start(start),
        .index(9),
        .mult(colProduct[6]),
        .sum(colSum[6])
    );
    // y = 8;
    col_weight col8_
    (
        .clk(clk),
        .pix(col8),
        .start(start),
        .index(8),
        .mult(colProduct[7]),
        .sum(colSum[7])
    );
    // y = 7;
    col_weight col9_
    (
        .clk(clk),
        .pix(col9),
        .start(start),
        .index(7),
        .mult(colProduct[8]),
        .sum(colSum[8])
    );
    // y = 6;
    col_weight col10_
    (
        .clk(clk),
        .pix(col10),
        .start(start),
        .index(6),
        .mult(colProduct[9]),
        .sum(colSum[9])
    );
    // y = 5;
    col_weight col11_
    (
        .clk(clk),
        .pix(col11),
        .start(start),
        .index(5),
        .mult(colProduct[10]),
        .sum(colSum[10])
    );
    // y = 4;
    col_weight col12_
    (
        .clk(clk),
        .pix(col12),
        .start(start),
        .index(4),
        .mult(colProduct[11]),
        .sum(colSum[11])
    );
    // y = 3;
    col_weight col13_
    (
        .clk(clk),
        .pix(col13),
        .start(start),
        .index(3),
        .mult(colProduct[12]),
        .sum(colSum[12])
    );
    // y = 2;
    col_weight col14_
    (
        .clk(clk),
        .pix(col14),
        .start(start),
        .index(2),
        .mult(colProduct[13]),
        .sum(colSum[13])
    );
    // y = 1;
    col_weight col15_
    (
        .clk(clk),
        .pix(col15),
        .start(start),
        .index(1),
        .mult(colProduct[14]),
        .sum(colSum[14])
    );
    // y = 0;
    col_weight col16_
    (
        .clk(clk),
        .pix(col16),
        .start(start),
        .index(0),
        .mult(colProduct[15]),
        .sum(colSum[15])
    );
    // y = -1;
    col_weight col17_
    (
        .clk(clk),
        .pix(col17),
        .start(start),
        .index(1),
        .mult(colProduct[16]),
        .sum(colSum[16])
    );
    // y = -2;
    col_weight col18_
    (
        .clk(clk),
        .pix(col18),
        .start(start),
        .index(2),
        .mult(colProduct[17]),
        .sum(colSum[17])
    );
    // y = -3;
    col_weight col19_
    (
        .clk(clk),
        .pix(col19),
        .start(start),
        .index(3),
        .mult(colProduct[18]),
        .sum(colSum[18])
    );
    // y = -4;
    col_weight col20_
    (
        .clk(clk),
        .pix(col20),
        .start(start),
        .index(4),
        .mult(colProduct[19]),
        .sum(colSum[19])
    );
    // y = -5;
    col_weight col21_
    (
        .clk(clk),
        .pix(col21),
        .start(start),
        .index(5),
        .mult(colProduct[20]),
        .sum(colSum[20])
    );
    // y = -6;
    col_weight col22_
    (
        .clk(clk),
        .pix(col22),
        .start(start),
        .index(6),
        .mult(colProduct[21]),
        .sum(colSum[21])
    );
    // y = -7;
    col_weight col23_
    (
        .clk(clk),
        .pix(col23),
        .start(start),
        .index(7),
        .mult(colProduct[22]),
        .sum(colSum[22])
    );
    // y = -8;
    col_weight col24_
    (
        .clk(clk),
        .pix(col24),
        .start(start),
        .index(8),
        .mult(colProduct[23]),
        .sum(colSum[23])
    );
    // y = -9;
    col_weight col25_
    (
        .clk(clk),
        .pix(col25),
        .start(start),
        .index(9),
        .mult(colProduct[24]),
        .sum(colSum[24])
    );
    // y = -10;
    col_weight col26_
    (
        .clk(clk),
        .pix(col26),
        .start(start),
        .index(10),
        .mult(colProduct[25]),
        .sum(colSum[25])
    );
    // y = -11;
    col_weight col27_
    (
        .clk(clk),
        .pix(col27),
        .start(start),
        .index(11),
        .mult(colProduct[26]),
        .sum(colSum[26])
    );
    // y = -12;
    col_weight col28_
    (
        .clk(clk),
        .pix(col28),
        .start(start),
        .index(12),
        .mult(colProduct[27]),
        .sum(colSum[27])
    );
    // y = -13;
    col_weight col29_
    (
        .clk(clk),
        .pix(col29),
        .start(start),
        .index(13),
        .mult(colProduct[28]),
        .sum(colSum[28])
    );
    // y = -14;
    col_weight col30_
    (
        .clk(clk),
        .pix(col30),
        .start(start),
        .index(14),
        .mult(colProduct[29]),
        .sum(colSum[29])
    );
    // y = -15;
    col_weight col31_
    (
        .clk(clk),
        .pix(col31),
        .start(start),
        .index(15),
        .mult(colProduct[30]),
        .sum(colSum[30])
    );

    ////////////////
    ////* rows *////
    ////////////////

    // x = 15;
    col_weight row1_
    (
        .clk(clk),
        .pix({col1[7:0], col2[7:0], col3[7:0], col4[7:0], col5[7:0], col6[7:0], col7[7:0], col8[7:0], col9[7:0], col10[7:0], col11[7:0], col12[7:0], col13[7:0], col14[7:0], col15[7:0], col16[7:0], col17[7:0], col18[7:0], col19[7:0], col20[7:0], col21[7:0], col22[7:0], col23[7:0], col24[7:0], col25[7:0], col26[7:0], col27[7:0], col28[7:0], col29[7:0], col30[7:0], col31[7:0]}),
        .start(start),
        .index(15),
        .mult(rowProduct[0]),
        .sum(rowSum[0])
    );
    // x = 14;
    col_weight row2_
    (
        .clk(clk),
        .pix({col1[15:8], col2[15:8], col3[15:8], col4[15:8], col5[15:8], col6[15:8], col7[15:8], col8[15:8], col9[15:8], col10[15:8], col11[15:8], col12[15:8], col13[15:8], col14[15:8], col15[15:8], col16[15:8], col17[15:8], col18[15:8], col19[15:8], col20[15:8], col21[15:8], col22[15:8], col23[15:8], col24[15:8], col25[15:8], col26[15:8], col27[15:8], col28[15:8], col29[15:8], col30[15:8], col31[15:8]}),
        .start(start),
        .index(14),
        .mult(rowProduct[1]),
        .sum(rowSum[1])
    );
    // x = 13;
    col_weight row3_
    (
        .clk(clk),
        .pix({col1[23:16], col2[23:16], col3[23:16], col4[23:16], col5[23:16], col6[23:16], col7[23:16], col8[23:16], col9[23:16], col10[23:16], col11[23:16], col12[23:16], col13[23:16], col14[23:16], col15[23:16], col16[23:16], col17[23:16], col18[23:16], col19[23:16], col20[23:16], col21[23:16], col22[23:16], col23[23:16], col24[23:16], col25[23:16], col26[23:16], col27[23:16], col28[23:16], col29[23:16], col30[23:16], col31[23:16]}),
        .start(start),
        .index(13),
        .mult(rowProduct[2]),
        .sum(rowSum[2])
    );
    // x = 12;
    col_weight row4_
    (
        .clk(clk),
        .pix({col1[31:24], col2[31:24], col3[31:24], col4[31:24], col5[31:24], col6[31:24], col7[31:24], col8[31:24], col9[31:24], col10[31:24], col11[31:24], col12[31:24], col13[31:24], col14[31:24], col15[31:24], col16[31:24], col17[31:24], col18[31:24], col19[31:24], col20[31:24], col21[31:24], col22[31:24], col23[31:24], col24[31:24], col25[31:24], col26[31:24], col27[31:24], col28[31:24], col29[31:24], col30[31:24], col31[31:24]}),
        .start(start),
        .index(12),
        .mult(rowProduct[3]),
        .sum(rowSum[3])
    );
    // x = 11;
    col_weight row5_
    (
        .clk(clk),
        .pix({col1[39:32], col2[39:32], col3[39:32], col4[39:32], col5[39:32], col6[39:32], col7[39:32], col8[39:32], col9[39:32], col10[39:32], col11[39:32], col12[39:32], col13[39:32], col14[39:32], col15[39:32], col16[39:32], col17[39:32], col18[39:32], col19[39:32], col20[39:32], col21[39:32], col22[39:32], col23[39:32], col24[39:32], col25[39:32], col26[39:32], col27[39:32], col28[39:32], col29[39:32], col30[39:32], col31[39:32]}),
        .start(start),
        .index(11),
        .mult(rowProduct[4]),
        .sum(rowSum[4])
    );
    // x = 10;
    col_weight row6_
    (
        .clk(clk),
        .pix({col1[47:40], col2[47:40], col3[47:40], col4[47:40], col5[47:40], col6[47:40], col7[47:40], col8[47:40], col9[47:40], col10[47:40], col11[47:40], col12[47:40], col13[47:40], col14[47:40], col15[47:40], col16[47:40], col17[47:40], col18[47:40], col19[47:40], col20[47:40], col21[47:40], col22[47:40], col23[47:40], col24[47:40], col25[47:40], col26[47:40], col27[47:40], col28[47:40], col29[47:40], col30[47:40], col31[47:40]}),
        .start(start),
        .index(10),
        .mult(rowProduct[5]),
        .sum(rowSum[5])
    );
    // x = 9;
    col_weight row7_
    (
        .clk(clk),
        .pix({col1[55:48], col2[55:48], col3[55:48], col4[55:48], col5[55:48], col6[55:48], col7[55:48], col8[55:48], col9[55:48], col10[55:48], col11[55:48], col12[55:48], col13[55:48], col14[55:48], col15[55:48], col16[55:48], col17[55:48], col18[55:48], col19[55:48], col20[55:48], col21[55:48], col22[55:48], col23[55:48], col24[55:48], col25[55:48], col26[55:48], col27[55:48], col28[55:48], col29[55:48], col30[55:48], col31[55:48]}),
        .start(start),
        .index(9),
        .mult(rowProduct[6]),
        .sum(rowSum[6])
    );
    // x = 8;
    col_weight row8_
    (
        .clk(clk),
        .pix({col1[63:56], col2[63:56], col3[63:56], col4[63:56], col5[63:56], col6[63:56], col7[63:56], col8[63:56], col9[63:56], col10[63:56], col11[63:56], col12[63:56], col13[63:56], col14[63:56], col15[63:56], col16[63:56], col17[63:56], col18[63:56], col19[63:56], col20[63:56], col21[63:56], col22[63:56], col23[63:56], col24[63:56], col25[63:56], col26[63:56], col27[63:56], col28[63:56], col29[63:56], col30[63:56], col31[63:56]}),
        .start(start),
        .index(8),
        .mult(rowProduct[7]),
        .sum(rowSum[7])
    );
    // x = 7;
    col_weight row9_
    (
        .clk(clk),
        .pix({col1[71:64], col2[71:64], col3[71:64], col4[71:64], col5[71:64], col6[71:64], col7[71:64], col8[71:64], col9[71:64], col10[71:64], col11[71:64], col12[71:64], col13[71:64], col14[71:64], col15[71:64], col16[71:64], col17[71:64], col18[71:64], col19[71:64], col20[71:64], col21[71:64], col22[71:64], col23[71:64], col24[71:64], col25[71:64], col26[71:64], col27[71:64], col28[71:64], col29[71:64], col30[71:64], col31[71:64]}),
        .start(start),
        .index(7),
        .mult(rowProduct[8]),
        .sum(rowSum[8])
    );
    // x = 6;
    col_weight row10_
    (
        .clk(clk),
        .pix({col1[79:72], col2[79:72], col3[79:72], col4[79:72], col5[79:72], col6[79:72], col7[79:72], col8[79:72], col9[79:72], col10[79:72], col11[79:72], col12[79:72], col13[79:72], col14[79:72], col15[79:72], col16[79:72], col17[79:72], col18[79:72], col19[79:72], col20[79:72], col21[79:72], col22[79:72], col23[79:72], col24[79:72], col25[79:72], col26[79:72], col27[79:72], col28[79:72], col29[79:72], col30[79:72], col31[79:72]}),
        .start(start),
        .index(6),
        .mult(rowProduct[9]),
        .sum(rowSum[9])
    );
    // x = 5;
    col_weight row11_
    (
        .clk(clk),
        .pix({col1[87:80], col2[87:80], col3[87:80], col4[87:80], col5[87:80], col6[87:80], col7[87:80], col8[87:80], col9[87:80], col10[87:80], col11[87:80], col12[87:80], col13[87:80], col14[87:80], col15[87:80], col16[87:80], col17[87:80], col18[87:80], col19[87:80], col20[87:80], col21[87:80], col22[87:80], col23[87:80], col24[87:80], col25[87:80], col26[87:80], col27[87:80], col28[87:80], col29[87:80], col30[87:80], col31[87:80]}),
        .start(start),
        .index(5),
        .mult(rowProduct[10]),
        .sum(rowSum[10])
    );
    // x = 4;
    col_weight row12_
    (
        .clk(clk),
        .pix({col1[95:88], col2[95:88], col3[95:88], col4[95:88], col5[95:88], col6[95:88], col7[95:88], col8[95:88], col9[95:88], col10[95:88], col11[95:88], col12[95:88], col13[95:88], col14[95:88], col15[95:88], col16[95:88], col17[95:88], col18[95:88], col19[95:88], col20[95:88], col21[95:88], col22[95:88], col23[95:88], col24[95:88], col25[95:88], col26[95:88], col27[95:88], col28[95:88], col29[95:88], col30[95:88], col31[95:88]}),
        .start(start),
        .index(4),
        .mult(rowProduct[11]),
        .sum(rowSum[11])
    );
    // x = 3;
    col_weight row13_
    (
        .clk(clk),
        .pix({col1[103:96], col2[103:96], col3[103:96], col4[103:96], col5[103:96], col6[103:96], col7[103:96], col8[103:96], col9[103:96], col10[103:96], col11[103:96], col12[103:96], col13[103:96], col14[103:96], col15[103:96], col16[103:96], col17[103:96], col18[103:96], col19[103:96], col20[103:96], col21[103:96], col22[103:96], col23[103:96], col24[103:96], col25[103:96], col26[103:96], col27[103:96], col28[103:96], col29[103:96], col30[103:96], col31[103:96]}),
        .start(start),
        .index(3),
        .mult(rowProduct[12]),
        .sum(rowSum[12])
    );
    // x = 2;
    col_weight row14_
    (
        .clk(clk),
        .pix({col1[111:104], col2[111:104], col3[111:104], col4[111:104], col5[111:104], col6[111:104], col7[111:104], col8[111:104], col9[111:104], col10[111:104], col11[111:104], col12[111:104], col13[111:104], col14[111:104], col15[111:104], col16[111:104], col17[111:104], col18[111:104], col19[111:104], col20[111:104], col21[111:104], col22[111:104], col23[111:104], col24[111:104], col25[111:104], col26[111:104], col27[111:104], col28[111:104], col29[111:104], col30[111:104], col31[111:104]}),
        .start(start),
        .index(2),
        .mult(rowProduct[13]),
        .sum(rowSum[13])
    );
    // x = 1;
    col_weight row15_
    (
        .clk(clk),
        .pix({col1[119:112], col2[119:112], col3[119:112], col4[119:112], col5[119:112], col6[119:112], col7[119:112], col8[119:112], col9[119:112], col10[119:112], col11[119:112], col12[119:112], col13[119:112], col14[119:112], col15[119:112], col16[119:112], col17[119:112], col18[119:112], col19[119:112], col20[119:112], col21[119:112], col22[119:112], col23[119:112], col24[119:112], col25[119:112], col26[119:112], col27[119:112], col28[119:112], col29[119:112], col30[119:112], col31[119:112]}),
        .start(start),
        .index(1),
        .mult(rowProduct[14]),
        .sum(rowSum[14])
    );
    // x = 0;
    col_weight row16_
    (
        .clk(clk),
        .pix({col1[127:120], col2[127:120], col3[127:120], col4[127:120], col5[127:120], col6[127:120], col7[127:120], col8[127:120], col9[127:120], col10[127:120], col11[127:120], col12[127:120], col13[127:120], col14[127:120], col15[127:120], col16[127:120], col17[127:120], col18[127:120], col19[127:120], col20[127:120], col21[127:120], col22[127:120], col23[127:120], col24[127:120], col25[127:120], col26[127:120], col27[127:120], col28[127:120], col29[127:120], col30[127:120], col31[127:120]}),
        .start(start),
        .index(0),
        .mult(rowProduct[15]),
        .sum(rowSum[15])
    );
    // x = -1;
    col_weight row17_
    (
        .clk(clk),
        .pix({col1[135:128], col2[135:128], col3[135:128], col4[135:128], col5[135:128], col6[135:128], col7[135:128], col8[135:128], col9[135:128], col10[135:128], col11[135:128], col12[135:128], col13[135:128], col14[135:128], col15[135:128], col16[135:128], col17[135:128], col18[135:128], col19[135:128], col20[135:128], col21[135:128], col22[135:128], col23[135:128], col24[135:128], col25[135:128], col26[135:128], col27[135:128], col28[135:128], col29[135:128], col30[135:128], col31[135:128]}),
        .start(start),
        .index(1),
        .mult(rowProduct[16]),
        .sum(rowSum[16])
    );
    // x = -2;
    col_weight row18_
    (
        .clk(clk),
        .pix({col1[143:136], col2[143:136], col3[143:136], col4[143:136], col5[143:136], col6[143:136], col7[143:136], col8[143:136], col9[143:136], col10[143:136], col11[143:136], col12[143:136], col13[143:136], col14[143:136], col15[143:136], col16[143:136], col17[143:136], col18[143:136], col19[143:136], col20[143:136], col21[143:136], col22[143:136], col23[143:136], col24[143:136], col25[143:136], col26[143:136], col27[143:136], col28[143:136], col29[143:136], col30[143:136], col31[143:136]}),
        .start(start),
        .index(2),
        .mult(rowProduct[17]),
        .sum(rowSum[17])
    );
    // x = -3;
    col_weight row19_
    (
        .clk(clk),
        .pix({col1[151:144], col2[151:144], col3[151:144], col4[151:144], col5[151:144], col6[151:144], col7[151:144], col8[151:144], col9[151:144], col10[151:144], col11[151:144], col12[151:144], col13[151:144], col14[151:144], col15[151:144], col16[151:144], col17[151:144], col18[151:144], col19[151:144], col20[151:144], col21[151:144], col22[151:144], col23[151:144], col24[151:144], col25[151:144], col26[151:144], col27[151:144], col28[151:144], col29[151:144], col30[151:144], col31[151:144]}),
        .start(start),
        .index(3),
        .mult(rowProduct[18]),
        .sum(rowSum[18])
    );
    // x = -4;
    col_weight row20_
    (
        .clk(clk),
        .pix({col1[159:152], col2[159:152], col3[159:152], col4[159:152], col5[159:152], col6[159:152], col7[159:152], col8[159:152], col9[159:152], col10[159:152], col11[159:152], col12[159:152], col13[159:152], col14[159:152], col15[159:152], col16[159:152], col17[159:152], col18[159:152], col19[159:152], col20[159:152], col21[159:152], col22[159:152], col23[159:152], col24[159:152], col25[159:152], col26[159:152], col27[159:152], col28[159:152], col29[159:152], col30[159:152], col31[159:152]}),
        .start(start),
        .index(4),
        .mult(rowProduct[19]),
        .sum(rowSum[19])
    );
    // x = -5;
    col_weight row21_
    (
        .clk(clk),
        .pix({col1[167:160], col2[167:160], col3[167:160], col4[167:160], col5[167:160], col6[167:160], col7[167:160], col8[167:160], col9[167:160], col10[167:160], col11[167:160], col12[167:160], col13[167:160], col14[167:160], col15[167:160], col16[167:160], col17[167:160], col18[167:160], col19[167:160], col20[167:160], col21[167:160], col22[167:160], col23[167:160], col24[167:160], col25[167:160], col26[167:160], col27[167:160], col28[167:160], col29[167:160], col30[167:160], col31[167:160]}),
        .start(start),
        .index(5),
        .mult(rowProduct[20]),
        .sum(rowSum[20])
    );
    // x = -6;
    col_weight row22_
    (
        .clk(clk),
        .pix({col1[175:168], col2[175:168], col3[175:168], col4[175:168], col5[175:168], col6[175:168], col7[175:168], col8[175:168], col9[175:168], col10[175:168], col11[175:168], col12[175:168], col13[175:168], col14[175:168], col15[175:168], col16[175:168], col17[175:168], col18[175:168], col19[175:168], col20[175:168], col21[175:168], col22[175:168], col23[175:168], col24[175:168], col25[175:168], col26[175:168], col27[175:168], col28[175:168], col29[175:168], col30[175:168], col31[175:168]}),
        .start(start),
        .index(6),
        .mult(rowProduct[21]),
        .sum(rowSum[21])
    );
    // x = -7;
    col_weight row23_
    (
        .clk(clk),
        .pix({col1[183:176], col2[183:176], col3[183:176], col4[183:176], col5[183:176], col6[183:176], col7[183:176], col8[183:176], col9[183:176], col10[183:176], col11[183:176], col12[183:176], col13[183:176], col14[183:176], col15[183:176], col16[183:176], col17[183:176], col18[183:176], col19[183:176], col20[183:176], col21[183:176], col22[183:176], col23[183:176], col24[183:176], col25[183:176], col26[183:176], col27[183:176], col28[183:176], col29[183:176], col30[183:176], col31[183:176]}),
        .start(start),
        .index(7),
        .mult(rowProduct[22]),
        .sum(rowSum[22])
    );
    // x = -8;
    col_weight row24_
    (
        .clk(clk),
        .pix({col1[191:184], col2[191:184], col3[191:184], col4[191:184], col5[191:184], col6[191:184], col7[191:184], col8[191:184], col9[191:184], col10[191:184], col11[191:184], col12[191:184], col13[191:184], col14[191:184], col15[191:184], col16[191:184], col17[191:184], col18[191:184], col19[191:184], col20[191:184], col21[191:184], col22[191:184], col23[191:184], col24[191:184], col25[191:184], col26[191:184], col27[191:184], col28[191:184], col29[191:184], col30[191:184], col31[191:184]}),
        .start(start),
        .index(8),
        .mult(rowProduct[23]),
        .sum(rowSum[23])
    );
    // x = -9;
    col_weight row25_
    (
        .clk(clk),
        .pix({col1[199:192], col2[199:192], col3[199:192], col4[199:192], col5[199:192], col6[199:192], col7[199:192], col8[199:192], col9[199:192], col10[199:192], col11[199:192], col12[199:192], col13[199:192], col14[199:192], col15[199:192], col16[199:192], col17[199:192], col18[199:192], col19[199:192], col20[199:192], col21[199:192], col22[199:192], col23[199:192], col24[199:192], col25[199:192], col26[199:192], col27[199:192], col28[199:192], col29[199:192], col30[199:192], col31[199:192]}),
        .start(start),
        .index(9),
        .mult(rowProduct[24]),
        .sum(rowSum[24])
    );
    // x = -10;
    col_weight row26_
    (
        .clk(clk),
        .pix({col1[207:200], col2[207:200], col3[207:200], col4[207:200], col5[207:200], col6[207:200], col7[207:200], col8[207:200], col9[207:200], col10[207:200], col11[207:200], col12[207:200], col13[207:200], col14[207:200], col15[207:200], col16[207:200], col17[207:200], col18[207:200], col19[207:200], col20[207:200], col21[207:200], col22[207:200], col23[207:200], col24[207:200], col25[207:200], col26[207:200], col27[207:200], col28[207:200], col29[207:200], col30[207:200], col31[207:200]}),
        .start(start),
        .index(10),
        .mult(rowProduct[25]),
        .sum(rowSum[25])
    );
    // x = -11;
    col_weight row27_
    (
        .clk(clk),
        .pix({col1[215:208], col2[215:208], col3[215:208], col4[215:208], col5[215:208], col6[215:208], col7[215:208], col8[215:208], col9[215:208], col10[215:208], col11[215:208], col12[215:208], col13[215:208], col14[215:208], col15[215:208], col16[215:208], col17[215:208], col18[215:208], col19[215:208], col20[215:208], col21[215:208], col22[215:208], col23[215:208], col24[215:208], col25[215:208], col26[215:208], col27[215:208], col28[215:208], col29[215:208], col30[215:208], col31[215:208]}),
        .start(start),
        .index(11),
        .mult(rowProduct[26]),
        .sum(rowSum[26])
    );
    // x = -12;
    col_weight row28_
    (
        .clk(clk),
        .pix({col1[223:216], col2[223:216], col3[223:216], col4[223:216], col5[223:216], col6[223:216], col7[223:216], col8[223:216], col9[223:216], col10[223:216], col11[223:216], col12[223:216], col13[223:216], col14[223:216], col15[223:216], col16[223:216], col17[223:216], col18[223:216], col19[223:216], col20[223:216], col21[223:216], col22[223:216], col23[223:216], col24[223:216], col25[223:216], col26[223:216], col27[223:216], col28[223:216], col29[223:216], col30[223:216], col31[223:216]}),
        .start(start),
        .index(12),
        .mult(rowProduct[27]),
        .sum(rowSum[27])
    );
    // x = -13;
    col_weight row29_
    (
        .clk(clk),
        .pix({col1[231:224], col2[231:224], col3[231:224], col4[231:224], col5[231:224], col6[231:224], col7[231:224], col8[231:224], col9[231:224], col10[231:224], col11[231:224], col12[231:224], col13[231:224], col14[231:224], col15[231:224], col16[231:224], col17[231:224], col18[231:224], col19[231:224], col20[231:224], col21[231:224], col22[231:224], col23[231:224], col24[231:224], col25[231:224], col26[231:224], col27[231:224], col28[231:224], col29[231:224], col30[231:224], col31[231:224]}),
        .start(start),
        .index(13),
        .mult(rowProduct[28]),
        .sum(rowSum[28])
    );
    // x = -14;
    col_weight row30_
    (
        .clk(clk),
        .pix({col1[239:232], col2[239:232], col3[239:232], col4[239:232], col5[239:232], col6[239:232], col7[239:232], col8[239:232], col9[239:232], col10[239:232], col11[239:232], col12[239:232], col13[239:232], col14[239:232], col15[239:232], col16[239:232], col17[239:232], col18[239:232], col19[239:232], col20[239:232], col21[239:232], col22[239:232], col23[239:232], col24[239:232], col25[239:232], col26[239:232], col27[239:232], col28[239:232], col29[239:232], col30[239:232], col31[239:232]}),
        .start(start),
        .index(14),
        .mult(rowProduct[29]),
        .sum(rowSum[29])
    );
    // x = -15;
    col_weight row31_
    (
        .clk(clk),
        .pix({col1[247:240], col2[247:240], col3[247:240], col4[247:240], col5[247:240], col6[247:240], col7[247:240], col8[247:240], col9[247:240], col10[247:240], col11[247:240], col12[247:240], col13[247:240], col14[247:240], col15[247:240], col16[247:240], col17[247:240], col18[247:240], col19[247:240], col20[247:240], col21[247:240], col22[247:240], col23[247:240], col24[247:240], col25[247:240], col26[247:240], col27[247:240], col28[247:240], col29[247:240], col30[247:240], col31[247:240]}),
        .start(start),
        .index(15),
        .mult(rowProduct[30]),
        .sum(rowSum[30])
    );


    // wire [23:0] sumColProduct;
    // wire [23:0] sumRowProduct;
    // wire weightColFinish;

    sum_31 #
	(
		.WIDTH(20)
	)
    weightCol 
    (
        .clk(clk),
        .start(colFinish),

        .i1(colProduct[0]),
        .i2(colProduct[1]),
        .i3(colProduct[2]),
        .i4(colProduct[3]),
        .i5(colProduct[4]),
        .i6(colProduct[5]),
        .i7(colProduct[6]),
        .i8(colProduct[7]),
        .i9(colProduct[8]),
        .i10(colProduct[9]),
        .i11(colProduct[10]),
        .i12(colProduct[11]),
        .i13(colProduct[12]),
        .i14(colProduct[13]),
        .i15(colProduct[14]),
        .i16(colProduct[15]),
        .i17(colProduct[16]),
        .i18(colProduct[17]),
        .i19(colProduct[18]),
        .i20(colProduct[19]),
        .i21(colProduct[20]),
        .i22(colProduct[21]),
        .i23(colProduct[22]),
        .i24(colProduct[23]),
        .i25(colProduct[24]),
        .i26(colProduct[25]),
        .i27(colProduct[26]),
        .i28(colProduct[27]),
        .i29(colProduct[28]),
        .i30(colProduct[29]),
        .i31(colProduct[30]),
		        
        .sum(sumColProduct),
        .finish(finish)

    );

    sum_31 #
	(
		.WIDTH(20)
	)
    weightRow
    (
        .clk(clk),
        .start(colFinish),

        .i1(rowProduct[0]),
        .i2(rowProduct[1]),
        .i3(rowProduct[2]),
        .i4(rowProduct[3]),
        .i5(rowProduct[4]),
        .i6(rowProduct[5]),
        .i7(rowProduct[6]),
        .i8(rowProduct[7]),
        .i9(rowProduct[8]),
        .i10(rowProduct[9]),
        .i11(rowProduct[10]),
        .i12(rowProduct[11]),
        .i13(rowProduct[12]),
        .i14(rowProduct[13]),
        .i15(rowProduct[14]),
        .i16(rowProduct[15]),
        .i17(rowProduct[16]),
        .i18(rowProduct[17]),
        .i19(rowProduct[18]),
        .i20(rowProduct[19]),
        .i21(rowProduct[20]),
        .i22(rowProduct[21]),
        .i23(rowProduct[22]),
        .i24(rowProduct[23]),
        .i25(rowProduct[24]),
        .i26(rowProduct[25]),
        .i27(rowProduct[26]),
        .i28(rowProduct[27]),
        .i29(rowProduct[28]),
        .i30(rowProduct[29]),
        .i31(rowProduct[30]),
		        
        .sum(sumRowProduct)

    );

    reg maskReg[0:12];
    always @(posedge clk)
    begin
        maskReg[0 ] <= maskIn;
        maskReg[1 ] <= maskReg[0 ]; 
        maskReg[2 ] <= maskReg[1 ];  
        maskReg[3 ] <= maskReg[2 ];  
        maskReg[4 ] <= maskReg[3 ];  
        maskReg[5 ] <= maskReg[4 ];  
        maskReg[6 ] <= maskReg[5 ];  
        maskReg[7 ] <= maskReg[6 ];  
        maskReg[8 ] <= maskReg[7 ];  
        maskReg[9 ] <= maskReg[8 ];  
        maskReg[10] <= maskReg[9 ];  
        maskReg[11] <= maskReg[10]; 
        maskReg[12] <= maskReg[11];      
    end
    assign maskOut = maskReg[12];

endmodule
