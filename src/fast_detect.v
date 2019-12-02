`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/26 12:50:14
// Design Name: 
// Module Name: fast_detect
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


module fast_detect(
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

    output isFast,
    output [7:0] score,
    output [7:0] fastResult,
    output val

    );

    wire [7:0] pixCenter;
    wire [7:0] pix1;
    wire [7:0] pix2;
    wire [7:0] pix3;
    wire [7:0] pix4;
    wire [7:0] pix5;
    wire [7:0] pix6;
    wire [7:0] pix7;
    wire [7:0] pix8;
    wire [7:0] pix9;
    wire [7:0] pix10;
    wire [7:0] pix11;
    wire [7:0] pix12;
    wire [7:0] pix13;
    wire [7:0] pix14;
    wire [7:0] pix15;
    wire [7:0] pix16;

    reg [7:0] pixReg1;
    reg [7:0] pixReg2;
    reg [7:0] pixReg3;
    reg [7:0] pixReg4;
    reg [7:0] pixReg5;
    reg [7:0] pixReg6;
    reg [7:0] pixReg7;
    reg [7:0] pixReg8;
    reg [7:0] pixReg9;
    reg [7:0] pixReg10;
    reg [7:0] pixReg11;
    reg [7:0] pixReg12;
    reg [7:0] pixReg13;
    reg [7:0] pixReg14;
    reg [7:0] pixReg15;
    reg [7:0] pixReg16;

    /* 
    0022200
    0200020
    2000002
    2001002
    2000002
    0200020
    0022200
    */

    assign pixCenter    =   col4[31:24];

    assign pix1     =   col1[31:24];
    assign pix2     =   col1[23:16];
    assign pix3     =   col2[15:8];
    assign pix4     =   col3[7:0];
    assign pix5     =   col4[7:0];
    assign pix6     =   col5[7:0];
    assign pix7     =   col6[15:8];
    assign pix8     =   col7[23:16];
    assign pix9     =   col7[31:24];
    assign pix10    =   col7[39:32];
    assign pix11    =   col6[47:40];
    assign pix12    =   col5[55:48];
    assign pix13    =   col4[55:48];
    assign pix14    =   col3[55:48];
    assign pix15    =   col2[47:40];
    assign pix16    =   col1[39:32];

    reg [7:0] thresUp   =   0;
    reg [7:0] thresDown =   0;
    
    reg startS2  =   0;
    reg startS3  =   0;
    reg startS4  =   0;
    reg startS5  =   0;
    reg startS6  =   0;
    reg startS7  =   0;
    reg startS8  =   0;
    reg startS9  =   0;
    reg startS10 =   0;
    reg startS11 =   0;
    reg validReg =   0;

    // assign val   =   validReg;

    // 1
    reg boU1    =   0;
    reg boU2    =   0;
    reg boU3    =   0;
    reg boU4    =   0;
    reg boU5    =   0;
    reg boU6    =   0;
    reg boU7    =   0;
    reg boU8    =   0;
    reg boU9    =   0;
    reg boU10   =   0;
    reg boU11   =   0;
    reg boU12   =   0;
    reg boU13   =   0;
    reg boU14   =   0;
    reg boU15   =   0;
    reg boU16   =   0;

    reg boD1    =   0;
    reg boD2    =   0;
    reg boD3    =   0;
    reg boD4    =   0;
    reg boD5    =   0;
    reg boD6    =   0;
    reg boD7    =   0;
    reg boD8    =   0;
    reg boD9    =   0;
    reg boD10   =   0;
    reg boD11   =   0;
    reg boD12   =   0;
    reg boD13   =   0;
    reg boD14   =   0;
    reg boD15   =   0;
    reg boD16   =   0;


    // 2
    reg boU1_2     =   0;
    reg boU2_3     =   0;
    reg boU3_4     =   0;
    reg boU4_5     =   0;
    reg boU5_6     =   0;
    reg boU6_7     =   0;
    reg boU7_8     =   0;
    reg boU8_9     =   0;
    reg boU9_10    =   0;
    reg boU10_11   =   0;
    reg boU11_12   =   0;
    reg boU12_13   =   0;
    reg boU13_14   =   0;
    reg boU14_15   =   0;
    reg boU15_16   =   0;
    reg boU16_1    =   0;

    reg boD1_2     =   0;
    reg boD2_3     =   0;
    reg boD3_4     =   0;
    reg boD4_5     =   0;
    reg boD5_6     =   0;
    reg boD6_7     =   0;
    reg boD7_8     =   0;
    reg boD8_9     =   0;
    reg boD9_10    =   0;
    reg boD10_11   =   0;
    reg boD11_12   =   0;
    reg boD12_13   =   0;
    reg boD13_14   =   0;
    reg boD14_15   =   0;
    reg boD15_16   =   0;
    reg boD16_1    =   0;

    // 4
    reg boU1_2_3_4      =   0;
    reg boU2_3_4_5      =   0;
    reg boU3_4_5_6      =   0;
    reg boU4_5_6_7      =   0;
    reg boU5_6_7_8      =   0;
    reg boU6_7_8_9      =   0;
    reg boU7_8_9_10     =   0;
    reg boU8_9_10_11    =   0;
    reg boU9_10_11_12   =   0;
    reg boU10_11_12_13  =   0;
    reg boU11_12_13_14  =   0;
    reg boU12_13_14_15  =   0;
    reg boU13_14_15_16  =   0;
    reg boU14_15_16_1   =   0;
    reg boU15_16_1_2    =   0;
    reg boU16_1_2_3     =   0;

    reg boD1_2_3_4      =   0;
    reg boD2_3_4_5      =   0;
    reg boD3_4_5_6      =   0;
    reg boD4_5_6_7      =   0;
    reg boD5_6_7_8      =   0;
    reg boD6_7_8_9      =   0;
    reg boD7_8_9_10     =   0;
    reg boD8_9_10_11    =   0;
    reg boD9_10_11_12   =   0;
    reg boD10_11_12_13  =   0;
    reg boD11_12_13_14  =   0;
    reg boD12_13_14_15  =   0;
    reg boD13_14_15_16  =   0;
    reg boD14_15_16_1   =   0;
    reg boD15_16_1_2    =   0;
    reg boD16_1_2_3     =   0;

    // 8
    reg boU8_1_8   =   0;
    reg boU8_2_9   =   0;
    reg boU8_3_10  =   0;
    reg boU8_4_11  =   0;
    reg boU8_5_12  =   0;
    reg boU8_6_13  =   0;
    reg boU8_7_14  =   0;
    reg boU8_8_15  =   0;
    reg boU8_9_16  =   0;
    reg boU8_10_1  =   0;
    reg boU8_11_2  =   0;
    reg boU8_12_3  =   0;
    reg boU8_13_4  =   0;
    reg boU8_14_5  =   0;
    reg boU8_15_6  =   0;
    reg boU8_16_7  =   0;
    
    reg boD8_1_8   =   0;
    reg boD8_2_9   =   0;
    reg boD8_3_10  =   0;
    reg boD8_4_11  =   0;
    reg boD8_5_12  =   0;
    reg boD8_6_13  =   0;
    reg boD8_7_14  =   0;
    reg boD8_8_15  =   0;
    reg boD8_9_16  =   0;
    reg boD8_10_1  =   0;
    reg boD8_11_2  =   0;
    reg boD8_12_3  =   0;
    reg boD8_13_4  =   0;
    reg boD8_14_5  =   0;
    reg boD8_15_6  =   0;
    reg boD8_16_7  =   0;
    
    reg boU_1_2_3_4      =   0;
    reg boU_2_3_4_5      =   0;
    reg boU_3_4_5_6      =   0;
    reg boU_4_5_6_7      =   0;
    reg boU_5_6_7_8      =   0;
    reg boU_6_7_8_9      =   0;
    reg boU_7_8_9_10     =   0;
    reg boU_8_9_10_11    =   0;
    reg boU_9_10_11_12   =   0;
    reg boU_10_11_12_13  =   0;
    reg boU_11_12_13_14  =   0;
    reg boU_12_13_14_15  =   0;
    reg boU_13_14_15_16  =   0;
    reg boU_14_15_16_1   =   0;
    reg boU_15_16_1_2    =   0;
    reg boU_16_1_2_3     =   0;

    reg boD_1_2_3_4      =   0;
    reg boD_2_3_4_5      =   0;
    reg boD_3_4_5_6      =   0;
    reg boD_4_5_6_7      =   0;
    reg boD_5_6_7_8      =   0;
    reg boD_6_7_8_9      =   0;
    reg boD_7_8_9_10     =   0;
    reg boD_8_9_10_11    =   0;
    reg boD_9_10_11_12   =   0;
    reg boD_10_11_12_13  =   0;
    reg boD_11_12_13_14  =   0;
    reg boD_12_13_14_15  =   0;
    reg boD_13_14_15_16  =   0;
    reg boD_14_15_16_1   =   0;
    reg boD_15_16_1_2    =   0;
    reg boD_16_1_2_3     =   0;

    // 12
    reg boU12_1_12   =   0;
    reg boU12_2_13   =   0;
    reg boU12_3_14   =   0;
    reg boU12_4_15   =   0;
    reg boU12_5_16   =   0;
    reg boU12_6_1    =   0;
    reg boU12_7_2    =   0;
    reg boU12_8_3    =   0;
    reg boU12_9_4    =   0;
    reg boU12_10_5   =   0;
    reg boU12_11_6   =   0;
    reg boU12_12_7   =   0;
    reg boU12_13_8   =   0;
    reg boU12_14_9   =   0;
    reg boU12_15_10  =   0;
    reg boU12_16_11  =   0;
	
    reg boD12_1_12   =   0;
    reg boD12_2_13   =   0;
    reg boD12_3_14   =   0;
    reg boD12_4_15   =   0;
    reg boD12_5_16   =   0;
    reg boD12_6_1    =   0;
    reg boD12_7_2    =   0;
    reg boD12_8_3    =   0;
    reg boD12_9_4    =   0;
    reg boD12_10_5   =   0;
    reg boD12_11_6   =   0;
    reg boD12_12_7   =   0;
    reg boD12_13_8   =   0;
    reg boD12_14_9   =   0;
    reg boD12_15_10  =   0;
    reg boD12_16_11  =   0;

    reg bo16_1  = 0;
    reg bo16_2  = 0;
    reg bo16_3  = 0;
    reg bo16_4  = 0;
    reg bo16_5  = 0;
    reg bo16_6  = 0;
    reg bo16_7  = 0;
    reg bo16_8  = 0;
    reg bo16_9  = 0;
    reg bo16_10 = 0;
    reg bo16_11 = 0;
    reg bo16_12 = 0;
    reg bo16_13 = 0;
    reg bo16_14 = 0;
    reg bo16_15 = 0;
    reg bo16_16 = 0;

    reg bo8_1  = 0;
    reg bo8_2  = 0;
    reg bo8_3  = 0;
    reg bo8_4  = 0;
    reg bo8_5  = 0;
    reg bo8_6  = 0;
    reg bo8_7  = 0;
    reg bo8_8  = 0;

    reg bo4_1  = 0;
    reg bo4_2  = 0;
    reg bo4_3  = 0;
    reg bo4_4  = 0;

    reg bo2_1  = 0;
    reg bo2_2  = 0;

    reg isFastReg = 0;
    assign isFast = isFastReg;

    //////////////////
    ////* detect *////
    //////////////////

    always @(posedge clk)
    begin
        /* s1
         */
        startS2 <= start;
        if(start)
        begin
            thresUp     <=  pixCenter>=235  ?   255 :   pixCenter+20;
            thresDown   <=  pixCenter<=20   ?   0   :   pixCenter-20;

            pixReg1    <=  pix1;
            pixReg2    <=  pix2;
            pixReg3    <=  pix3;
            pixReg4    <=  pix4;
            pixReg5    <=  pix5;
            pixReg6    <=  pix6;
            pixReg7    <=  pix7;
            pixReg8    <=  pix8;
            pixReg9    <=  pix9;
            pixReg10   <=  pix10;
            pixReg11   <=  pix11;
            pixReg12   <=  pix12;
            pixReg13   <=  pix13;
            pixReg14   <=  pix14;
            pixReg15   <=  pix15;
            pixReg16   <=  pix16;  
        end

        /* s2
         */
        // 1
        startS3 <= startS2;
        if(startS2)
        begin
            boU1    <=  pixReg1>thresUp      ?   1   :   0;
            boU2    <=  pixReg2>thresUp      ?   1   :   0;
            boU3    <=  pixReg3>thresUp      ?   1   :   0;
            boU4    <=  pixReg4>thresUp      ?   1   :   0;
            boU5    <=  pixReg5>thresUp      ?   1   :   0;
            boU6    <=  pixReg6>thresUp      ?   1   :   0;
            boU7    <=  pixReg7>thresUp      ?   1   :   0;
            boU8    <=  pixReg8>thresUp      ?   1   :   0;
            boU9    <=  pixReg9>thresUp      ?   1   :   0;
            boU10   <=  pixReg10>thresUp     ?   1   :   0;
            boU11   <=  pixReg11>thresUp     ?   1   :   0;
            boU12   <=  pixReg12>thresUp     ?   1   :   0;
            boU13   <=  pixReg13>thresUp     ?   1   :   0;
            boU14   <=  pixReg14>thresUp     ?   1   :   0;
            boU15   <=  pixReg15>thresUp     ?   1   :   0;
            boU16   <=  pixReg16>thresUp     ?   1   :   0;

            boD1    <=  pixReg1<thresDown    ?   1   :   0;
            boD2    <=  pixReg2<thresDown    ?   1   :   0;
            boD3    <=  pixReg3<thresDown    ?   1   :   0;
            boD4    <=  pixReg4<thresDown    ?   1   :   0;
            boD5    <=  pixReg5<thresDown    ?   1   :   0;
            boD6    <=  pixReg6<thresDown    ?   1   :   0;
            boD7    <=  pixReg7<thresDown    ?   1   :   0;
            boD8    <=  pixReg8<thresDown    ?   1   :   0;
            boD9    <=  pixReg9<thresDown    ?   1   :   0;
            boD10   <=  pixReg10<thresDown   ?   1   :   0;
            boD11   <=  pixReg11<thresDown   ?   1   :   0;
            boD12   <=  pixReg12<thresDown   ?   1   :   0;
            boD13   <=  pixReg13<thresDown   ?   1   :   0;
            boD14   <=  pixReg14<thresDown   ?   1   :   0;
            boD15   <=  pixReg15<thresDown   ?   1   :   0;
            boD16   <=  pixReg16<thresDown   ?   1   :   0;
        end

        /* s3
         */
        // 2
        startS4 <= startS3;
        if(startS3)
        begin
            boU1_2      <=  boU1    &   boU2;    
            boU2_3      <=  boU2    &   boU3;  
            boU3_4      <=  boU3    &   boU4;
            boU4_5      <=  boU4    &   boU5;
            boU5_6      <=  boU5    &   boU6;
            boU6_7      <=  boU6    &   boU7;
            boU7_8      <=  boU7    &   boU8;
            boU8_9      <=  boU8    &   boU9;
            boU9_10 	<=  boU9    &   boU10;
            boU10_11  	<=  boU10   &   boU11;
            boU11_12    <=  boU11   &   boU12;
            boU12_13    <=  boU12   &   boU13;
            boU13_14    <=  boU13   &   boU14;
            boU14_15    <=  boU14   &   boU15;
            boU15_16    <=  boU15   &   boU16;
            boU16_1     <=  boU16   &	boU1;

            boD1_2      <=  boD1    &   boD2;    
            boD2_3      <=  boD2    &   boD3;  
            boD3_4      <=  boD3    &   boD4;
            boD4_5      <=  boD4    &   boD5;
            boD5_6      <=  boD5    &   boD6;
            boD6_7      <=  boD6    &   boD7;
            boD7_8      <=  boD7    &   boD8;
            boD8_9      <=  boD8    &   boD9;
            boD9_10 	<=  boD9    &   boD10;
            boD10_11  	<=  boD10   &   boD11;
            boD11_12    <=  boD11   &   boD12;
            boD12_13    <=  boD12   &   boD13;
            boD13_14    <=  boD13   &   boD14;
            boD14_15    <=  boD14   &   boD15;
            boD15_16    <=  boD15   &   boD16;
            boD16_1     <=  boD16   &	boD1;
        end

        /* s4
         */
        // 4
        startS5 <= startS4;
        if(startS4)
        begin
            boU1_2_3_4        <=  boU1_2     &   boU3_4;      
            boU2_3_4_5        <=  boU2_3     &   boU4_5;    
            boU3_4_5_6        <=  boU3_4     &   boU5_6;  
            boU4_5_6_7        <=  boU4_5     &   boU6_7;  
            boU5_6_7_8        <=  boU5_6     &   boU7_8;  
            boU6_7_8_9        <=  boU6_7     &   boU8_9;  
            boU7_8_9_10       <=  boU7_8     &   boU9_10; 
            boU8_9_10_11      <=  boU8_9     &   boU10_11;
            boU9_10_11_12     <=  boU9_10    &   boU11_12;
            boU10_11_12_13    <=  boU10_11   &   boU12_13;
            boU11_12_13_14    <=  boU11_12   &   boU13_14;
            boU12_13_14_15    <=  boU12_13   &   boU14_15;
            boU13_14_15_16    <=  boU13_14   &   boU15_16;
            boU14_15_16_1     <=  boU14_15   &   boU16_1;
            boU15_16_1_2      <=  boU15_16   &   boU1_2;
            boU16_1_2_3       <=  boU16_1    &   boU2_3;

            boD1_2_3_4        <=  boD1_2     &   boD3_4;      
            boD2_3_4_5        <=  boD2_3     &   boD4_5;    
            boD3_4_5_6        <=  boD3_4     &   boD5_6;  
            boD4_5_6_7        <=  boD4_5     &   boD6_7;  
            boD5_6_7_8        <=  boD5_6     &   boD7_8;  
            boD6_7_8_9        <=  boD6_7     &   boD8_9;  
            boD7_8_9_10       <=  boD7_8     &   boD9_10; 
            boD8_9_10_11      <=  boD8_9     &   boD10_11;
            boD9_10_11_12     <=  boD9_10    &   boD11_12;
            boD10_11_12_13    <=  boD10_11   &   boD12_13;
            boD11_12_13_14    <=  boD11_12   &   boD13_14;
            boD12_13_14_15    <=  boD12_13   &   boD14_15;
            boD13_14_15_16    <=  boD13_14   &   boD15_16;
            boD14_15_16_1     <=  boD14_15   &   boD16_1;
            boD15_16_1_2      <=  boD15_16   &   boD1_2;
            boD16_1_2_3       <=  boD16_1    &   boD2_3;
        end

        /* s5
         */
        // 8
        startS6 <= startS5;
        if(startS5)
        begin
            boU8_1_8     <=  boU1_2_3_4       &   boU5_6_7_8;        
            boU8_2_9     <=  boU2_3_4_5       &   boU6_7_8_9;      
            boU8_3_10    <=  boU3_4_5_6       &   boU7_8_9_10;   
            boU8_4_11    <=  boU4_5_6_7       &   boU8_9_10_11;  
            boU8_5_12    <=  boU5_6_7_8       &   boU9_10_11_12; 
            boU8_6_13    <=  boU6_7_8_9       &   boU10_11_12_13;
            boU8_7_14    <=  boU7_8_9_10      &   boU11_12_13_14;
            boU8_8_15    <=  boU8_9_10_11     &   boU12_13_14_15;
            boU8_9_16    <=  boU9_10_11_12    &   boU13_14_15_16;
            boU8_10_1    <=  boU10_11_12_13   &   boU14_15_16_1; 
            boU8_11_2    <=  boU11_12_13_14   &   boU15_16_1_2;  
            boU8_12_3    <=  boU12_13_14_15   &   boU16_1_2_3;   
            boU8_13_4    <=  boU13_14_15_16   &   boU1_2_3_4;
            boU8_14_5    <=  boU14_15_16_1    &   boU2_3_4_5;
            boU8_15_6    <=  boU15_16_1_2     &   boU3_4_5_6;
            boU8_16_7    <=  boU16_1_2_3      &   boU4_5_6_7;

            boD8_1_8     <=  boD1_2_3_4       &   boD5_6_7_8;        
            boD8_2_9     <=  boD2_3_4_5       &   boD6_7_8_9;      
            boD8_3_10    <=  boD3_4_5_6       &   boD7_8_9_10;   
            boD8_4_11    <=  boD4_5_6_7       &   boD8_9_10_11;  
            boD8_5_12    <=  boD5_6_7_8       &   boD9_10_11_12; 
            boD8_6_13    <=  boD6_7_8_9       &   boD10_11_12_13;
            boD8_7_14    <=  boD7_8_9_10      &   boD11_12_13_14;
            boD8_8_15    <=  boD8_9_10_11     &   boD12_13_14_15;
            boD8_9_16    <=  boD9_10_11_12    &   boD13_14_15_16;
            boD8_10_1    <=  boD10_11_12_13   &   boD14_15_16_1; 
            boD8_11_2    <=  boD11_12_13_14   &   boD15_16_1_2;  
            boD8_12_3    <=  boD12_13_14_15   &   boD16_1_2_3;   
            boD8_13_4    <=  boD13_14_15_16   &   boD1_2_3_4;
            boD8_14_5    <=  boD14_15_16_1    &   boD2_3_4_5;
            boD8_15_6    <=  boD15_16_1_2     &   boD3_4_5_6;
            boD8_16_7    <=  boD16_1_2_3      &   boD4_5_6_7;

            boU_1_2_3_4      <=  boU1_2_3_4;    
            boU_2_3_4_5      <=  boU2_3_4_5;   
            boU_3_4_5_6      <=  boU3_4_5_6;    
            boU_4_5_6_7      <=  boU4_5_6_7;    
            boU_5_6_7_8      <=  boU5_6_7_8;    
            boU_6_7_8_9      <=  boU6_7_8_9;    
            boU_7_8_9_10     <=  boU7_8_9_10;   
            boU_8_9_10_11    <=  boU8_9_10_11;  
            boU_9_10_11_12   <=  boU9_10_11_12; 
            boU_10_11_12_13  <=  boU10_11_12_13;
            boU_11_12_13_14  <=  boU11_12_13_14;
            boU_12_13_14_15  <=  boU12_13_14_15;
            boU_13_14_15_16  <=  boU13_14_15_16;
            boU_14_15_16_1   <=  boU14_15_16_1; 
            boU_15_16_1_2    <=  boU15_16_1_2;  
            boU_16_1_2_3     <=  boU16_1_2_3;   

            boD_1_2_3_4      <=  boD1_2_3_4;    
            boD_2_3_4_5      <=  boD2_3_4_5;    
            boD_3_4_5_6      <=  boD3_4_5_6;    
            boD_4_5_6_7      <=  boD4_5_6_7;    
            boD_5_6_7_8      <=  boD5_6_7_8;    
            boD_6_7_8_9      <=  boD6_7_8_9;    
            boD_7_8_9_10     <=  boD7_8_9_10;   
            boD_8_9_10_11    <=  boD8_9_10_11;  
            boD_9_10_11_12   <=  boD9_10_11_12; 
            boD_10_11_12_13  <=  boD10_11_12_13;
            boD_11_12_13_14  <=  boD11_12_13_14;
            boD_12_13_14_15  <=  boD12_13_14_15;
            boD_13_14_15_16  <=  boD13_14_15_16;
            boD_14_15_16_1   <=  boD14_15_16_1; 
            boD_15_16_1_2    <=  boD15_16_1_2;  
            boD_16_1_2_3     <=  boD16_1_2_3;   

        end

        /* s6
         */
        // 12
        startS7 <= startS6;
        if(startS6)
        begin
            boU12_1_12   <=   boU8_1_8   &  boU_9_10_11_12;
            boU12_2_13   <=   boU8_2_9   &  boU_10_11_12_13;
            boU12_3_14   <=   boU8_3_10  &  boU_11_12_13_14;
            boU12_4_15   <=   boU8_4_11  &  boU_12_13_14_15;
            boU12_5_16   <=   boU8_5_12  &  boU_13_14_15_16;
            boU12_6_1    <=   boU8_6_13  &  boU_14_15_16_1; 
            boU12_7_2    <=   boU8_7_14  &  boU_15_16_1_2;  
            boU12_8_3    <=   boU8_8_15  &  boU_16_1_2_3;   
            boU12_9_4    <=   boU8_9_16  &  boU_1_2_3_4;  
            boU12_10_5   <=   boU8_10_1  &  boU_2_3_4_5;  
            boU12_11_6   <=   boU8_11_2  &  boU_3_4_5_6;  
            boU12_12_7   <=   boU8_12_3  &  boU_4_5_6_7;  
            boU12_13_8   <=   boU8_13_4  &  boU_5_6_7_8;  
            boU12_14_9   <=   boU8_14_5  &  boU_6_7_8_9;  
            boU12_15_10  <=   boU8_15_6  &  boU_7_8_9_10; 
            boU12_16_11  <=   boU8_16_7  &  boU_8_9_10_11;
            
            boD12_1_12   <=   boD8_1_8   &  boD_9_10_11_12;
            boD12_2_13   <=   boD8_2_9   &  boD_10_11_12_13;
            boD12_3_14   <=   boD8_3_10  &  boD_11_12_13_14;
            boD12_4_15   <=   boD8_4_11  &  boD_12_13_14_15;
            boD12_5_16   <=   boD8_5_12  &  boD_13_14_15_16;
            boD12_6_1    <=   boD8_6_13  &  boD_14_15_16_1; 
            boD12_7_2    <=   boD8_7_14  &  boD_15_16_1_2;  
            boD12_8_3    <=   boD8_8_15  &  boD_16_1_2_3;   
            boD12_9_4    <=   boD8_9_16  &  boD_1_2_3_4;  
            boD12_10_5   <=   boD8_10_1  &  boD_2_3_4_5;  
            boD12_11_6   <=   boD8_11_2  &  boD_3_4_5_6;  
            boD12_12_7   <=   boD8_12_3  &  boD_4_5_6_7;  
            boD12_13_8   <=   boD8_13_4  &  boD_5_6_7_8;  
            boD12_14_9   <=   boD8_14_5  &  boD_6_7_8_9;  
            boD12_15_10  <=   boD8_15_6  &  boD_7_8_9_10; 
            boD12_16_11  <=   boD8_16_7  &  boD_8_9_10_11;
        end


        /* s7
         */
        startS8 <= startS7;
        if(startS7)
        begin
            bo16_1   <=  boD12_1_12  |   boU12_1_12;
            bo16_2   <=  boD12_2_13  |   boU12_2_13;
            bo16_3   <=  boD12_3_14  |   boU12_3_14;
            bo16_4   <=  boD12_4_15  |   boU12_4_15;
            bo16_5   <=  boD12_5_16  |   boU12_5_16;
            bo16_6   <=  boD12_6_1   |   boU12_6_1;  
            bo16_7   <=  boD12_7_2   |   boU12_7_2;  
            bo16_8   <=  boD12_8_3   |   boU12_8_3;  
            bo16_9   <=  boD12_9_4   |   boU12_9_4;  
            bo16_10  <=  boD12_10_5  |   boU12_10_5; 
            bo16_11  <=  boD12_11_6  |   boU12_11_6; 
            bo16_12  <=  boD12_12_7  |   boU12_12_7; 
            bo16_13  <=  boD12_13_8  |   boU12_13_8; 
            bo16_14  <=  boD12_14_9  |   boU12_14_9; 
            bo16_15  <=  boD12_15_10 |   boU12_15_10;
            bo16_16  <=  boD12_16_11 |   boU12_16_11;
        end

        /* s8
         */
        startS9 <= startS8;
        if(startS8)
        begin
            bo8_1    <=  bo16_1  |   bo16_9; 
			bo8_2    <=  bo16_2  |   bo16_10;
			bo8_3    <=  bo16_3  |   bo16_11;
			bo8_4    <=  bo16_4  |   bo16_12;
			bo8_5    <=  bo16_5  |   bo16_13;
			bo8_6    <=  bo16_6  |   bo16_14;
			bo8_7    <=  bo16_7  |   bo16_15;
			bo8_8    <=  bo16_8  |   bo16_16;
        end

        /* s9
         */
        startS10 <= startS9;
        if(startS9)
        begin
            bo4_1    <=  bo8_1  |   bo8_5; 
			bo4_2    <=  bo8_2  |   bo8_6;
			bo4_3    <=  bo8_3  |   bo8_7;
			bo4_4    <=  bo8_4  |   bo8_8;
        end

        /* s10
         */
        startS11 <= startS10;
        if(startS10)
        begin
            bo2_1    <=  bo4_1  |   bo4_3; 
			bo2_2    <=  bo4_2  |   bo4_4;
        end

        /* s11
         */
        validReg <= startS11;
        if(startS11)
        begin
            isFastReg   <=  bo2_1  |   bo2_2;
        end


    end

    /////////////////
    ////* score *////
    /////////////////

    reg [7:0] absDiff[0:15]     ;
    reg [7:0] minScore2[0:15]   ;
    reg [7:0] minScore4[0:15]   ;
    reg [7:0] minScore4_2[0:15] ;
    reg [7:0] minScore8[0:15]   ;
    reg [7:0] minScore8_2[0:15] ;
    reg [7:0] minScore10[0:15]  ;
    reg [7:0] maxScore2[0:7]    ;
    reg [7:0] maxScore4[0:3]    ;
    reg [7:0] maxScore8[0:1]    ;
    reg [7:0] cornerScoreReg_1  ;
    reg [7:0] cornerScoreReg_2  ;
    reg [7:0] cornerScoreReg    ;

    assign score = cornerScoreReg;
    
    always @(posedge clk)
    begin
        /* s1
         */
        if(start)
        begin
            absDiff[0]  <=  pix1>pixCenter   ?  pix1-pixCenter   :   pixCenter-pix1;
            absDiff[1]  <=  pix2>pixCenter   ?  pix2-pixCenter   :   pixCenter-pix2;
            absDiff[2]  <=  pix3>pixCenter   ?  pix3-pixCenter   :   pixCenter-pix3;
            absDiff[3]  <=  pix4>pixCenter   ?  pix4-pixCenter   :   pixCenter-pix4;
            absDiff[4]  <=  pix5>pixCenter   ?  pix5-pixCenter   :   pixCenter-pix5;
            absDiff[5]  <=  pix6>pixCenter   ?  pix6-pixCenter   :   pixCenter-pix6;
            absDiff[6]  <=  pix7>pixCenter   ?  pix7-pixCenter   :   pixCenter-pix7;
            absDiff[7]  <=  pix8>pixCenter   ?  pix8-pixCenter   :   pixCenter-pix8;
            absDiff[8]  <=  pix9>pixCenter   ?  pix9-pixCenter   :   pixCenter-pix9;
            absDiff[9]  <=  pix10>pixCenter  ?  pix10-pixCenter  :   pixCenter-pix10;
            absDiff[10] <=  pix11>pixCenter  ?  pix11-pixCenter  :   pixCenter-pix11;
            absDiff[11] <=  pix12>pixCenter  ?  pix12-pixCenter  :   pixCenter-pix12;
            absDiff[12] <=  pix13>pixCenter  ?  pix13-pixCenter  :   pixCenter-pix13;
            absDiff[13] <=  pix14>pixCenter  ?  pix14-pixCenter  :   pixCenter-pix14;
            absDiff[14] <=  pix15>pixCenter  ?  pix15-pixCenter  :   pixCenter-pix15;
            absDiff[15] <=  pix16>pixCenter  ?  pix16-pixCenter  :   pixCenter-pix16;
        end

        /* s2
         */
        if(startS2)
        begin
            minScore2[0]    <=  absDiff[0]<absDiff[1]    ?   absDiff[0]  :   absDiff[1];
            minScore2[1]    <=  absDiff[1]<absDiff[2]    ?   absDiff[1]  :   absDiff[2];
            minScore2[2]    <=  absDiff[2]<absDiff[3]    ?   absDiff[2]  :   absDiff[3];
            minScore2[3]    <=  absDiff[3]<absDiff[4]    ?   absDiff[3]  :   absDiff[4];
            minScore2[4]    <=  absDiff[4]<absDiff[5]    ?   absDiff[4]  :   absDiff[5];
            minScore2[5]    <=  absDiff[5]<absDiff[6]    ?   absDiff[5]  :   absDiff[6];
            minScore2[6]    <=  absDiff[6]<absDiff[7]    ?   absDiff[6]  :   absDiff[7];
            minScore2[7]    <=  absDiff[7]<absDiff[8]    ?   absDiff[7]  :   absDiff[8];
            minScore2[8]    <=  absDiff[8]<absDiff[9]    ?   absDiff[8]  :   absDiff[9];
            minScore2[9]    <=  absDiff[9]<absDiff[10]   ?   absDiff[9]  :   absDiff[10];
            minScore2[10]   <=  absDiff[10]<absDiff[11]  ?   absDiff[10] :   absDiff[11];
            minScore2[11]   <=  absDiff[11]<absDiff[12]  ?   absDiff[11] :   absDiff[12];
            minScore2[12]   <=  absDiff[12]<absDiff[13]  ?   absDiff[12] :   absDiff[13];
            minScore2[13]   <=  absDiff[13]<absDiff[14]  ?   absDiff[13] :   absDiff[14];
            minScore2[14]   <=  absDiff[14]<absDiff[15]  ?   absDiff[14] :   absDiff[15];
            minScore2[15]   <=  absDiff[15]<absDiff[0]   ?   absDiff[15] :   absDiff[0];
        end

        /* s3
         */
        if(startS3)
        begin
            minScore4[0]    <=  minScore2[0]<minScore2[2]    ?   minScore2[0]  :   minScore2[2]; 
            minScore4[1]    <=  minScore2[1]<minScore2[3]    ?   minScore2[1]  :   minScore2[3]; 
            minScore4[2]    <=  minScore2[2]<minScore2[4]    ?   minScore2[2]  :   minScore2[4]; 
            minScore4[3]    <=  minScore2[3]<minScore2[5]    ?   minScore2[3]  :   minScore2[5]; 
            minScore4[4]    <=  minScore2[4]<minScore2[6]    ?   minScore2[4]  :   minScore2[6]; 
            minScore4[5]    <=  minScore2[5]<minScore2[7]    ?   minScore2[5]  :   minScore2[7]; 
            minScore4[6]    <=  minScore2[6]<minScore2[8]    ?   minScore2[6]  :   minScore2[8]; 
            minScore4[7]    <=  minScore2[7]<minScore2[9]    ?   minScore2[7]  :   minScore2[9]; 
            minScore4[8]    <=  minScore2[8]<minScore2[10]   ?   minScore2[8]  :   minScore2[10];
            minScore4[9]    <=  minScore2[9]<minScore2[11]   ?   minScore2[9]  :   minScore2[11];
            minScore4[10]   <=  minScore2[10]<minScore2[12]  ?   minScore2[10] :   minScore2[12];
            minScore4[11]   <=  minScore2[11]<minScore2[13]  ?   minScore2[11] :   minScore2[13];
            minScore4[12]   <=  minScore2[12]<minScore2[14]  ?   minScore2[12] :   minScore2[14];
            minScore4[13]   <=  minScore2[13]<minScore2[15]  ?   minScore2[13] :   minScore2[15];
            minScore4[14]   <=  minScore2[14]<minScore2[0]   ?   minScore2[14] :   minScore2[0]; 
            minScore4[15]   <=  minScore2[15]<minScore2[1]   ?   minScore2[15] :   minScore2[1]; 

            minScore4_2[0]    <=  minScore2[0];
			minScore4_2[1]    <=  minScore2[1];
			minScore4_2[2]    <=  minScore2[2];
			minScore4_2[3]    <=  minScore2[3];
			minScore4_2[4]    <=  minScore2[4];
			minScore4_2[5]    <=  minScore2[5];
			minScore4_2[6]    <=  minScore2[6];
			minScore4_2[7]    <=  minScore2[7];
			minScore4_2[8]    <=  minScore2[8];
			minScore4_2[9]    <=  minScore2[9];
			minScore4_2[10]   <=  minScore2[10];
			minScore4_2[11]   <=  minScore2[11];
			minScore4_2[12]   <=  minScore2[12];
			minScore4_2[13]   <=  minScore2[13];
			minScore4_2[14]   <=  minScore2[14];
			minScore4_2[15]   <=  minScore2[15];
        end

        /* s4
         */
        if(startS4)
        begin
            minScore8[0]    <=  minScore4[0]<minScore4[4]    ?   minScore4[0]  :   minScore4[4];
            minScore8[1]    <=  minScore4[1]<minScore4[5]    ?   minScore4[1]  :   minScore4[5];
            minScore8[2]    <=  minScore4[2]<minScore4[6]    ?   minScore4[2]  :   minScore4[6];
            minScore8[3]    <=  minScore4[3]<minScore4[7]    ?   minScore4[3]  :   minScore4[7];
            minScore8[4]    <=  minScore4[4]<minScore4[8]    ?   minScore4[4]  :   minScore4[8];
            minScore8[5]    <=  minScore4[5]<minScore4[9]    ?   minScore4[5]  :   minScore4[9];
            minScore8[6]    <=  minScore4[6]<minScore4[10]   ?   minScore4[6]  :   minScore4[10];
            minScore8[7]    <=  minScore4[7]<minScore4[11]   ?   minScore4[7]  :   minScore4[11];
            minScore8[8]    <=  minScore4[8]<minScore4[12]   ?   minScore4[8]  :   minScore4[12];
            minScore8[9]    <=  minScore4[9]<minScore4[13]   ?   minScore4[9]  :   minScore4[13];
            minScore8[10]   <=  minScore4[10]<minScore4[14]  ?   minScore4[10] :   minScore4[14];
            minScore8[11]   <=  minScore4[11]<minScore4[15]  ?   minScore4[11] :   minScore4[15];
            minScore8[12]   <=  minScore4[12]<minScore4[0]   ?   minScore4[12] :   minScore4[0];
            minScore8[13]   <=  minScore4[13]<minScore4[1]   ?   minScore4[13] :   minScore4[1];
            minScore8[14]   <=  minScore4[14]<minScore4[2]   ?   minScore4[14] :   minScore4[2];
            minScore8[15]   <=  minScore4[15]<minScore4[3]   ?   minScore4[15] :   minScore4[3];

            minScore8_2[0]    <=  minScore4_2[0];
			minScore8_2[1]    <=  minScore4_2[1];
			minScore8_2[2]    <=  minScore4_2[2];
			minScore8_2[3]    <=  minScore4_2[3];
			minScore8_2[4]    <=  minScore4_2[4];
			minScore8_2[5]    <=  minScore4_2[5];
			minScore8_2[6]    <=  minScore4_2[6];
			minScore8_2[7]    <=  minScore4_2[7];
			minScore8_2[8]    <=  minScore4_2[8];
			minScore8_2[9]    <=  minScore4_2[9];
			minScore8_2[10]   <=  minScore4_2[10];
			minScore8_2[11]   <=  minScore4_2[11];
			minScore8_2[12]   <=  minScore4_2[12];
			minScore8_2[13]   <=  minScore4_2[13];
			minScore8_2[14]   <=  minScore4_2[14];
			minScore8_2[15]   <=  minScore4_2[15];
        end

        /* s5
         */
        if(startS5)
        begin
            minScore10[0]   <=  minScore8[0]<minScore8_2[8]   ?   minScore8[0]    :   minScore8_2[8];
            minScore10[1]   <=  minScore8[1]<minScore8_2[9]   ?   minScore8[1]    :   minScore8_2[9];
            minScore10[2]   <=  minScore8[2]<minScore8_2[10]  ?   minScore8[2]    :   minScore8_2[10];
            minScore10[3]   <=  minScore8[3]<minScore8_2[11]  ?   minScore8[3]    :   minScore8_2[11];
            minScore10[4]   <=  minScore8[4]<minScore8_2[12]  ?   minScore8[4]    :   minScore8_2[12];
            minScore10[5]   <=  minScore8[5]<minScore8_2[13]  ?   minScore8[5]    :   minScore8_2[13];
            minScore10[6]   <=  minScore8[6]<minScore8_2[14]  ?   minScore8[6]    :   minScore8_2[14];
            minScore10[7]   <=  minScore8[7]<minScore8_2[15]  ?   minScore8[7]    :   minScore8_2[15];
            minScore10[8]   <=  minScore8[8]<minScore8_2[0]   ?   minScore8[8]    :   minScore8_2[0];
            minScore10[9]   <=  minScore8[9]<minScore8_2[1]   ?   minScore8[9]    :   minScore8_2[1];
            minScore10[10]  <=  minScore8[10]<minScore8_2[2]  ?   minScore8[10]   :   minScore8_2[2];
            minScore10[11]  <=  minScore8[11]<minScore8_2[3]  ?   minScore8[11]   :   minScore8_2[3];
            minScore10[12]  <=  minScore8[12]<minScore8_2[4]  ?   minScore8[12]   :   minScore8_2[4];
            minScore10[13]  <=  minScore8[13]<minScore8_2[5]  ?   minScore8[13]   :   minScore8_2[5];
            minScore10[14]  <=  minScore8[14]<minScore8_2[6]  ?   minScore8[14]   :   minScore8_2[6];
            minScore10[15]  <=  minScore8[15]<minScore8_2[7]  ?   minScore8[15]   :   minScore8_2[7];
        end

        /* s6
         */
        if(startS6)
        begin
            maxScore2[0]    <=  minScore10[0]>minScore10[1]     ?   minScore10[0]   :   minScore10[1];
            maxScore2[1]    <=  minScore10[2]>minScore10[3]     ?   minScore10[2]   :   minScore10[3];
            maxScore2[2]    <=  minScore10[4]>minScore10[5]     ?   minScore10[4]   :   minScore10[5];
            maxScore2[3]    <=  minScore10[6]>minScore10[7]     ?   minScore10[6]   :   minScore10[7];
            maxScore2[4]    <=  minScore10[8]>minScore10[9]     ?   minScore10[8]   :   minScore10[9];
            maxScore2[5]    <=  minScore10[10]>minScore10[11]   ?   minScore10[10]  :   minScore10[11];
            maxScore2[6]    <=  minScore10[12]>minScore10[13]   ?   minScore10[12]  :   minScore10[13];
            maxScore2[7]    <=  minScore10[14]>minScore10[15]   ?   minScore10[14]  :   minScore10[15];
        end

        /* s7
         */
        if(startS7)
        begin
            maxScore4[0]    <=  maxScore2[0]>maxScore2[1]     ?   maxScore2[0]   :   maxScore2[1];
            maxScore4[1]    <=  maxScore2[2]>maxScore2[3]     ?   maxScore2[2]   :   maxScore2[3];
            maxScore4[2]    <=  maxScore2[4]>maxScore2[5]     ?   maxScore2[4]   :   maxScore2[5];
            maxScore4[3]    <=  maxScore2[6]>maxScore2[7]     ?   maxScore2[6]   :   maxScore2[7];
        end

        /* s8
         */
        if(startS8)
        begin
            maxScore8[0]    <=  maxScore4[0]>maxScore4[1]     ?   maxScore4[0]   :   maxScore4[1];
            maxScore8[1]    <=  maxScore4[2]>maxScore4[3]     ?   maxScore4[2]   :   maxScore4[3];
        end

        /* s9
         */
        if(startS9)
        begin
            cornerScoreReg_1  <=  maxScore8[0]>maxScore8[1]     ?   maxScore8[0]   :   maxScore8[1];
        end

        /* s10
         */
        if(startS10)
        begin
            cornerScoreReg_2  <=  cornerScoreReg_1;
        end

        /* s11
         */
        if(startS11)
        begin
            cornerScoreReg    <=  cornerScoreReg_2;
        end
    end

    /* result gen
     */
    reg [7:0] resultReg = 0;
    reg resultVal = 0;

    assign val = resultVal;
    assign fastResult = resultReg;

    always @(posedge clk)
    begin
        resultReg <= isFastReg ? cornerScoreReg : 0;
        resultVal <= validReg;
    end

endmodule
