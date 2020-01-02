`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/05 11:17:21
// Design Name: 
// Module Name: detect_and_compute
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


module detect_and_compute
#(
	parameter MEM_DATA_BITS = 64,
	parameter ADDR_BITS = 32
)
(
    input [31:0] rdAddr,
	input [31:0] wrAddr,
	input [31:0] ctrl,
	input rstIn,
	output reg finish,

	input [31:0] imgSize,
    input [31:0] batch,
	input rst,                                 /*复位*/
	input clk,                               /*接口时钟*/
	output reg rd_burst_req,                          /*读请�?*/
	output reg wr_burst_req,                          /*写请�?*/
	output reg[28:0] rd_burst_len,                     /*读数据长�?*/
	output reg[28:0] wr_burst_len,                     /*写数据长�?*/
	output reg[ADDR_BITS - 1:0] rd_burst_addr,        /*读首地址*/
	output reg[ADDR_BITS - 1:0] wr_burst_addr,        /*写首地址*/
	input rd_burst_data_valid,                  /*读出数据有效*/
	input wr_burst_data_req,                    /*写数据信�?*/
	input[MEM_DATA_BITS - 1:0] rd_burst_data,   /*读出的数�?*/
	output[MEM_DATA_BITS - 1:0] wr_burst_data,    /*写入的数�?*/
	input rd_burst_finish,                      /*读完�?*/
	input wr_burst_finish,                      /*写完�?*/

    /* heap fifo */
    output [383:0] heap_din,
    output heap_valid,
    output heap_ct,
    /* DEBUG */
    output [7:0] debug,
	output reg error
);
assign debug = {computeState,detectState};
/** 
 *  args:
 *      width
 *      height
 * 
 *  detect_stage:
 *      [idle]
 *          if(start) =>[init]
 *      [init]
 *          input 2 cols -> bram[1][1,2]
 *          countBram2 = 0
 *          rowCount = 2
 *      [exe]
 *          loop: 
 *              bram[1][1,2] detect -> bram[2][countBram2%4+1]
 *              input 1 col -> bram[1][3]
 *              countBram2++
 *              rowCount++
 *              if(rowCount>height) =>[finish]
 *
 *              bram[1][2,3] detect -> bram[2][countBram2%4+1]
 *              input 1 col -> bram[1][1]
 *              countBram2++
 *              rowCount++
 *              if(rowCount>height) =>[finish]
 *
 *              bram[1][3,1] detect -> bram[2][countBram2%4+1]
 *              input 1 col -> bram[1][2]
 *              countBram2++
 *              rowCount++
 
 *              if(rowCount>height) =>[finish]
 *      [finish]
 *          =>[idle]
 * 
 *  compute_stage:
 *      [idle]
 *          if(countBram2>=4) =>[init]
 *      [init]
 *          bram[2][1,2,3,4] compute
 *          =>[exe]
 *      [exe]
 *          loop:
 *              bram[2][1,2,3,4,5] compute
 *              bram[2][2,3,4,5,6] compute
 *              bram[2][3,4,5,6,1] compute
 *              bram[2][4,5,6,1,2] compute
 *              bram[2][5,6,1,2,3] compute
 *              bram[2][6,1,2,3,4] compute
 *              >height? =>[finish]
 *      [finish]
 *          =>[idle]
 *
 *      
 */

/* detect */

/////////////////
////* bram1 *////
/////////////////

(*mark_debug="true"*)reg [63:0] bramIn1_1;
wire [63:0] bramOut1_1;
(*mark_debug="true"*)reg [9:0] bramAddr1_1 = 0;
(*mark_debug="true"*)reg bramWr1_1 = 0;
reg bramStart1_1 = 0;
wire bramValid1_1;
bram_driver bram1_1
(
    .inputData(bramIn1_1),
    .outputData(bramOut1_1),
    .addr(bramAddr1_1),
    .wr(bramWr1_1),
    .start(bramStart1_1),
    .valid(bramValid1_1),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramIn1_2;
wire [63:0] bramOut1_2;
(*mark_debug="true"*)reg [9:0] bramAddr1_2 = 0;
(*mark_debug="true"*)reg bramWr1_2 = 0;
reg bramStart1_2 = 0;
wire bramValid1_2;
bram_driver bram1_2
(
    .inputData(bramIn1_2),
    .outputData(bramOut1_2),
    .addr(bramAddr1_2),
    .wr(bramWr1_2),
    .start(bramStart1_2),
    .valid(bramValid1_2),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramIn1_3;
wire [63:0] bramOut1_3;
(*mark_debug="true"*)reg [9:0] bramAddr1_3 = 0;
(*mark_debug="true"*)reg bramWr1_3 = 0;
reg bramStart1_3 = 0;
wire bramValid1_3;
bram_driver bram1_3
(
    .inputData(bramIn1_3),
    .outputData(bramOut1_3),
    .addr(bramAddr1_3),
    .wr(bramWr1_3),
    .start(bramStart1_3),
    .valid(bramValid1_3),
    .clk(clk)
);


/* bram1 data in
 */
always@(posedge clk)
begin
	bramIn1_1 <= rd_burst_data;
	bramIn1_2 <= rd_burst_data;
	bramIn1_3 <= rd_burst_data;
end

reg [3:0] detectExeAddrDelay = 0;

/*  bram1 addr gen
    bram1 wr ctrl
 */
always@(posedge clk)
begin
	if(rst || rstIn)
	begin
		bramWr1_1 <= 0; 
		bramWr1_2 <= 0; 
		bramWr1_3 <= 0; 
		bramAddr1_1 <= 0;
		bramAddr1_2 <= 0;
		bramAddr1_3 <= 0;
        bramStart1_1 <= 0;
        bramStart1_2 <= 0;
        bramStart1_3 <= 0;
        detectExeAddrDelay <= 0;
	end
	
	else if(detectState == DETECT_INIT)
	begin
    /*  compute init, input 2 cols -> bram1[1,2]
     */
		if(rd_burst_data_valid)
		begin
			// bram1[1] input
			if(bramAddr1_1 < imgWidth)
			begin
			    bramAddr1_1 <= bramAddr1_1 + 1;
				bramWr1_1 <= 1; 
				bramWr1_2 <= 0; 
				bramWr1_3 <= 0; 
			end
			// bram1[2] input
			else if(bramAddr1_2 < imgWidth)
			begin
			    bramAddr1_2 <= bramAddr1_2 + 1;
				bramWr1_1 <= 0; 
				bramWr1_2 <= 1; 
				bramWr1_3 <= 0; 
			end
		end
		else if(rd_burst_finish)
		begin
			bramWr1_1 <= 0; 
			bramWr1_2 <= 0; 
			bramWr1_3 <= 0; 
			bramAddr1_1 <= 0;
			bramAddr1_2 <= 0;
			bramAddr1_3 <= 0;
		end
		else
		begin
        /*  between bursts
            rd_burst_data_valid: ----____----
         */
			bramWr1_1 <= 0; 
			bramWr1_2 <= 0; 
			bramWr1_3 <= 0; 
		end
	end

	else if(detectState == DETECT_EXE)
	begin
    /* compute, input 1 col
     */
        /* bram1 output
         */
        case (bram1Switch)
            1: 
            begin
                if(bramAddr1_2 < imgWidth)
                begin
                    if(bramAddr1_2 <= 6)
                    begin
                    /* fill the buffer, no delay
                     */
                        bramAddr1_2 <= bramAddr1_2 + 1;
                        bramAddr1_3 <= bramAddr1_3 + 1;
                        detectExeAddrDelay <= 0;
                    end
                    else
                    begin
                    /* gen delay, every 8 periods addr ++
                     */
                        if(detectExeAddrDelay == 7)
                        begin
                            detectExeAddrDelay <= 0;
                            bramAddr1_2 <= bramAddr1_2 + 1;
                            bramAddr1_3 <= bramAddr1_3 + 1;
                        end
                        else
                            detectExeAddrDelay <= detectExeAddrDelay + 1;
                    end
                    bramStart1_2 <= 1;
                    bramStart1_3 <= 1;
                end
                else if(bramAddr1_2 == imgWidth && detectExeAddrDelay != 7)
                begin
                    bramStart1_2 <= 1;
                    bramStart1_3 <= 1;
                    detectExeAddrDelay <= detectExeAddrDelay + 1;
                end
                else
                begin
                    bramStart1_1 <= 0;
                    bramStart1_2 <= 0;
                    bramStart1_3 <= 0;
                end
            end
            2: 
            begin
                if(bramAddr1_3 < imgWidth)
                begin
                    if(bramAddr1_3 <= 6)
                    begin
                    /* fill the buffer, no delay
                     */
                        bramAddr1_3 <= bramAddr1_3 + 1;
                        bramAddr1_1 <= bramAddr1_1 + 1;
                        detectExeAddrDelay <= 0;
                    end
                    else
                    begin
                    /* gen delay, every 8 periods addr ++
                     */
                        if(detectExeAddrDelay == 7)
                        begin
                            detectExeAddrDelay <= 0;
                            bramAddr1_3 <= bramAddr1_3 + 1;
                            bramAddr1_1 <= bramAddr1_1 + 1;
                        end
                        else
                            detectExeAddrDelay <= detectExeAddrDelay + 1;
                    end
                    bramStart1_3 <= 1;
                    bramStart1_1 <= 1;
                end
                else if(bramAddr1_3 == imgWidth && detectExeAddrDelay != 7)
                begin
                    bramStart1_3 <= 1;
                    bramStart1_1 <= 1;
                    detectExeAddrDelay <= detectExeAddrDelay + 1;
                end
                else
                begin
                    bramStart1_1 <= 0;
                    bramStart1_2 <= 0;
                    bramStart1_3 <= 0;
                end
            end
            3: 
            begin
                if(bramAddr1_1 < imgWidth)
                begin
                    if(bramAddr1_1 <= 6)
                    begin
                    /* fill the buffer, no delay
                     */
                        bramAddr1_1 <= bramAddr1_1 + 1;
                        bramAddr1_2 <= bramAddr1_2 + 1;
                        detectExeAddrDelay <= 0;
                    end
                    else
                    begin
                    /* gen delay, every 8 periods addr ++
                     */
                        if(detectExeAddrDelay == 7)
                        begin
                            detectExeAddrDelay <= 0;
                            bramAddr1_1 <= bramAddr1_1 + 1;
                            bramAddr1_2 <= bramAddr1_2 + 1;
                        end
                        else
                            detectExeAddrDelay <= detectExeAddrDelay + 1;
                    end
                    bramStart1_1 <= 1;
                    bramStart1_2 <= 1;
                end
                else if(bramAddr1_1 == imgWidth && detectExeAddrDelay != 7)
                begin
                    bramStart1_1 <= 1;
                    bramStart1_2 <= 1;
                    detectExeAddrDelay <= detectExeAddrDelay + 1;
                end
                else
                begin
                    bramStart1_1 <= 0;
                    bramStart1_2 <= 0;
                    bramStart1_3 <= 0;
                end
            end

            default: 
            begin
            end
        endcase

        /* bram1 input
         */
        if(rd_burst_data_valid)
		begin
            case (bram1Switch)
                1: 
                begin
			        // bram1[1] input
                    if(bramAddr1_1 < imgWidth)
                    begin
                        bramAddr1_1 <= bramAddr1_1 + 1;
                        bramWr1_1 <= 1; 
                        bramWr1_2 <= 0; 
                        bramWr1_3 <= 0; 
                    end
                end
                2: 
                begin
			        // bram1[2] input
                    if(bramAddr1_2 < imgWidth)
                    begin
                        bramAddr1_2 <= bramAddr1_2 + 1;
                        bramWr1_1 <= 0; 
                        bramWr1_2 <= 1; 
                        bramWr1_3 <= 0; 
                    end
                end
                3: 
                begin
			        // bram1[3] input
                    if(bramAddr1_3 < imgWidth)
                    begin
                        bramAddr1_3 <= bramAddr1_3 + 1;
                        bramWr1_1 <= 0; 
                        bramWr1_2 <= 0; 
                        bramWr1_3 <= 1; 
                    end
                end
                default: 
                begin
                    bramWr1_1 <= 0; 
                    bramWr1_2 <= 0; 
                    bramWr1_3 <= 0; 
                end
            endcase
		end
        else if(rd_burst_finish)
		begin
			bramWr1_1 <= 0; 
			bramWr1_2 <= 0; 
			bramWr1_3 <= 0; 
			// bramAddr1_1 <= 0;
			// bramAddr1_2 <= 0;
			// bramAddr1_3 <= 0;
		end
		else
		begin
        /*  between bursts
            rd_burst_data_valid: ----____----
         */
			bramWr1_1 <= 0; 
			bramWr1_2 <= 0; 
			bramWr1_3 <= 0; 
		end
	end

    else if(detectState == DETECT_LAST_EXE)
	begin
    /* compute
     */
        /* bram1 output
         */
        // case (bram1Switch)
        //     1: 
        //     begin
        //         if(bramAddr1_2 < imgWidth)
        //         begin
        //             bramAddr1_2 <= bramAddr1_2 + 1;
        //             bramAddr1_3 <= bramAddr1_3 + 1;
        //             bramStart1_2 <= 1;
        //             bramStart1_3 <= 1;
        //         end
        //         else
        //         begin
        //             bramStart1_1 <= 0;
        //             bramStart1_2 <= 0;
        //             bramStart1_3 <= 0;
        //         end
        //     end
        //     2: 
        //     begin
        //         if(bramAddr1_3 < imgWidth)
        //         begin
        //             bramAddr1_3 <= bramAddr1_3 + 1;
        //             bramAddr1_1 <= bramAddr1_1 + 1;
        //             bramStart1_3 <= 1;
        //             bramStart1_1 <= 1;
        //         end
        //         else
        //         begin
        //             bramStart1_1 <= 0;
        //             bramStart1_2 <= 0;
        //             bramStart1_3 <= 0;
        //         end
        //     end
        //     3: 
        //     begin
        //         if(bramAddr1_1 < imgWidth)
        //         begin
        //             bramAddr1_1 <= bramAddr1_1 + 1;
        //             bramAddr1_2 <= bramAddr1_2 + 1;
        //             bramStart1_1 <= 1;
        //             bramStart1_2 <= 1;
        //         end
        //         else
        //         begin
        //             bramStart1_1 <= 0;
        //             bramStart1_2 <= 0;
        //             bramStart1_3 <= 0;
        //         end
        //     end

        //     default: 
        //     begin
        //     end
        // endcase

        case (bram1Switch)
            1: 
            begin
                if(bramAddr1_2 < imgWidth)
                begin
                    if(bramAddr1_2 <= 6)
                    begin
                    /* fill the buffer, no delay
                     */
                        bramAddr1_2 <= bramAddr1_2 + 1;
                        bramAddr1_3 <= bramAddr1_3 + 1;
                        detectExeAddrDelay <= 0;
                    end
                    else
                    begin
                    /* gen delay, every 8 periods addr ++
                     */
                        if(detectExeAddrDelay == 7)
                        begin
                            detectExeAddrDelay <= 0;
                            bramAddr1_2 <= bramAddr1_2 + 1;
                            bramAddr1_3 <= bramAddr1_3 + 1;
                        end
                        else
                            detectExeAddrDelay <= detectExeAddrDelay + 1;
                    end
                    bramStart1_2 <= 1;
                    bramStart1_3 <= 1;
                end
                else if(bramAddr1_2 == imgWidth && detectExeAddrDelay != 7)
                begin
                    bramStart1_2 <= 1;
                    bramStart1_3 <= 1;
                    detectExeAddrDelay <= detectExeAddrDelay + 1;
                end
                else
                begin
                    bramStart1_1 <= 0;
                    bramStart1_2 <= 0;
                    bramStart1_3 <= 0;
                end
            end
            2: 
            begin
                if(bramAddr1_3 < imgWidth)
                begin
                    if(bramAddr1_3 <= 6)
                    begin
                    /* fill the buffer, no delay
                     */
                        bramAddr1_3 <= bramAddr1_3 + 1;
                        bramAddr1_1 <= bramAddr1_1 + 1;
                        detectExeAddrDelay <= 0;
                    end
                    else
                    begin
                    /* gen delay, every 8 periods addr ++
                     */
                        if(detectExeAddrDelay == 7)
                        begin
                            detectExeAddrDelay <= 0;
                            bramAddr1_3 <= bramAddr1_3 + 1;
                            bramAddr1_1 <= bramAddr1_1 + 1;
                        end
                        else
                            detectExeAddrDelay <= detectExeAddrDelay + 1;
                    end
                    bramStart1_3 <= 1;
                    bramStart1_1 <= 1;
                end
                else if(bramAddr1_3 == imgWidth && detectExeAddrDelay != 7)
                begin
                    bramStart1_3 <= 1;
                    bramStart1_1 <= 1;
                    detectExeAddrDelay <= detectExeAddrDelay + 1;
                end
                else
                begin
                    bramStart1_1 <= 0;
                    bramStart1_2 <= 0;
                    bramStart1_3 <= 0;
                end
            end
            3: 
            begin
                if(bramAddr1_1 < imgWidth)
                begin
                    if(bramAddr1_1 <= 6)
                    begin
                    /* fill the buffer, no delay
                     */
                        bramAddr1_1 <= bramAddr1_1 + 1;
                        bramAddr1_2 <= bramAddr1_2 + 1;
                        detectExeAddrDelay <= 0;
                    end
                    else
                    begin
                    /* gen delay, every 8 periods addr ++
                     */
                        if(detectExeAddrDelay == 7)
                        begin
                            detectExeAddrDelay <= 0;
                            bramAddr1_1 <= bramAddr1_1 + 1;
                            bramAddr1_2 <= bramAddr1_2 + 1;
                        end
                        else
                            detectExeAddrDelay <= detectExeAddrDelay + 1;
                    end
                    bramStart1_1 <= 1;
                    bramStart1_2 <= 1;
                end
                else if(bramAddr1_1 == imgWidth && detectExeAddrDelay != 7)
                begin
                    bramStart1_1 <= 1;
                    bramStart1_2 <= 1;
                    detectExeAddrDelay <= detectExeAddrDelay + 1;
                end
                else
                begin
                    bramStart1_1 <= 0;
                    bramStart1_2 <= 0;
                    bramStart1_3 <= 0;
                end
            end

            default: 
            begin
            end
        endcase
	end

	else
	begin
		bramWr1_1 <= 0; 
		bramWr1_2 <= 0; 
		bramWr1_3 <= 0; 
		bramAddr1_1 <= 0;
		bramAddr1_2 <= 0;
		bramAddr1_3 <= 0;
        bramStart1_1 <= 0;
        bramStart1_2 <= 0;
        bramStart1_3 <= 0;
	end
end

//////////////////
////* detect *////
//////////////////

// buffer
reg [55:0] detectExeBuffer1 = 0;
reg [55:0] detectExeBuffer2 = 0;
reg [55:0] detectExeBuffer3 = 0;
reg [55:0] detectExeBuffer4 = 0;
reg [55:0] detectExeBuffer5 = 0;
reg [55:0] detectExeBuffer6 = 0;
reg [55:0] detectExeBuffer7 = 0;
reg [55:0] detectExeBuffer8 = 0;

reg [55:0] detectExeBuffer9  = 0;
reg [55:0] detectExeBuffer10 = 0;
reg [55:0] detectExeBuffer11 = 0;
reg [55:0] detectExeBuffer12 = 0;
reg [55:0] detectExeBuffer13 = 0;
reg [55:0] detectExeBuffer14 = 0;
reg [55:0] detectExeBuffer15 = 0;
reg [55:0] detectExeBuffer16 = 0;

reg detectExeBufferValid    = 0;
reg [15:0] detectValidCount = 0;
reg [3:0] detectExeBufferDelay = 0;

/* buffer ctrl
 */
always @(posedge clk)
begin
    if(rst || rstIn)
    begin
		detectExeBuffer1 <= 0;
		detectExeBuffer2 <= 0;
		detectExeBuffer3 <= 0;
		detectExeBuffer4 <= 0;
		detectExeBuffer5 <= 0;
		detectExeBuffer6 <= 0;
		detectExeBuffer7 <= 0;
		detectExeBuffer8 <= 0;
		
		detectExeBuffer9  <= 0;
		detectExeBuffer10 <= 0;
		detectExeBuffer11 <= 0;
		detectExeBuffer12 <= 0;
		detectExeBuffer13 <= 0;
		detectExeBuffer14 <= 0;
		detectExeBuffer15 <= 0;
		detectExeBuffer16 <= 0;
		
        detectExeBufferValid <= 0;
        detectValidCount <= 0;
        detectExeBufferDelay <= 0;
    end

    else if(detectState == DETECT_EXE || detectState == DETECT_LAST_EXE)
    begin
        /*  valid gen
         */
        case (bram1Switch)
            1: 
            begin
                if(bramValid1_2)
                    detectValidCount <= detectValidCount + 1;
                detectExeBufferValid <= bramValid1_2 & detectValidCount >= 6;
            end
            2: 
            begin
                if(bramValid1_3)
                    detectValidCount <= detectValidCount + 1;
                detectExeBufferValid <= bramValid1_3 & detectValidCount >= 6;
            end
            3: 
            begin
                if(bramValid1_1)
                    detectValidCount <= detectValidCount + 1;
                detectExeBufferValid <= bramValid1_1 & detectValidCount >= 6;
            end

            default: 
            begin
                detectExeBufferValid <= 0;
            end
        endcase
        /*  buffer shift
         */
        if(detectValidCount <= 6)
        begin
        /* fill buffer, every 1 period shift 1
         */
            detectExeBuffer1[55:8] <= detectExeBuffer1[47:0];
            detectExeBuffer2[55:8] <= detectExeBuffer2[47:0];
            detectExeBuffer3[55:8] <= detectExeBuffer3[47:0];
            detectExeBuffer4[55:8] <= detectExeBuffer4[47:0];
            detectExeBuffer5[55:8] <= detectExeBuffer5[47:0];
            detectExeBuffer6[55:8] <= detectExeBuffer6[47:0];
            detectExeBuffer7[55:8] <= detectExeBuffer7[47:0];
            detectExeBuffer8[55:8] <= detectExeBuffer8[47:0];
			
            detectExeBuffer9[55:8]  <= detectExeBuffer9[47:0];
            detectExeBuffer10[55:8] <= detectExeBuffer10[47:0];
            detectExeBuffer11[55:8] <= detectExeBuffer11[47:0];
            detectExeBuffer12[55:8] <= detectExeBuffer12[47:0];
            detectExeBuffer13[55:8] <= detectExeBuffer13[47:0];
            detectExeBuffer14[55:8] <= detectExeBuffer14[47:0];
            detectExeBuffer15[55:8] <= detectExeBuffer15[47:0];
            detectExeBuffer16[55:8] <= detectExeBuffer16[47:0];
            case (bram1Switch)
                1: 
                begin
                    detectExeBuffer1[7:0] <= bramOut1_2[7 :0 ];
                    detectExeBuffer2[7:0] <= bramOut1_2[15:8 ];
                    detectExeBuffer3[7:0] <= bramOut1_2[23:16];
                    detectExeBuffer4[7:0] <= bramOut1_2[31:24];
                    detectExeBuffer5[7:0] <= bramOut1_2[39:32];
                    detectExeBuffer6[7:0] <= bramOut1_2[47:40];
                    detectExeBuffer7[7:0] <= bramOut1_2[55:48];
                    detectExeBuffer8[7:0] <= bramOut1_2[63:56];
			
					detectExeBuffer9[7:0]  <= bramOut1_3[7 :0 ];
					detectExeBuffer10[7:0] <= bramOut1_3[15:8 ];
					detectExeBuffer11[7:0] <= bramOut1_3[23:16];
					detectExeBuffer12[7:0] <= bramOut1_3[31:24];
					detectExeBuffer13[7:0] <= bramOut1_3[39:32];
					detectExeBuffer14[7:0] <= bramOut1_3[47:40];
					detectExeBuffer15[7:0] <= bramOut1_3[55:48];
					detectExeBuffer16[7:0] <= bramOut1_3[63:56];
                end
                2: 
                begin
                    detectExeBuffer1[7:0] <= bramOut1_3[7 :0 ];
                    detectExeBuffer2[7:0] <= bramOut1_3[15:8 ];
                    detectExeBuffer3[7:0] <= bramOut1_3[23:16];
                    detectExeBuffer4[7:0] <= bramOut1_3[31:24];
                    detectExeBuffer5[7:0] <= bramOut1_3[39:32];
                    detectExeBuffer6[7:0] <= bramOut1_3[47:40];
                    detectExeBuffer7[7:0] <= bramOut1_3[55:48];
                    detectExeBuffer8[7:0] <= bramOut1_3[63:56];
			
					detectExeBuffer9[7:0]  <= bramOut1_1[7 :0 ];
					detectExeBuffer10[7:0] <= bramOut1_1[15:8 ];
					detectExeBuffer11[7:0] <= bramOut1_1[23:16];
					detectExeBuffer12[7:0] <= bramOut1_1[31:24];
					detectExeBuffer13[7:0] <= bramOut1_1[39:32];
					detectExeBuffer14[7:0] <= bramOut1_1[47:40];
					detectExeBuffer15[7:0] <= bramOut1_1[55:48];
					detectExeBuffer16[7:0] <= bramOut1_1[63:56];
                end
                3: 
                begin
                    detectExeBuffer1[7:0] <= bramOut1_1[7 :0 ];
                    detectExeBuffer2[7:0] <= bramOut1_1[15:8 ];
                    detectExeBuffer3[7:0] <= bramOut1_1[23:16];
                    detectExeBuffer4[7:0] <= bramOut1_1[31:24];
                    detectExeBuffer5[7:0] <= bramOut1_1[39:32];
                    detectExeBuffer6[7:0] <= bramOut1_1[47:40];
                    detectExeBuffer7[7:0] <= bramOut1_1[55:48];
                    detectExeBuffer8[7:0] <= bramOut1_1[63:56];
			
					detectExeBuffer9[7:0]  <= bramOut1_2[7 :0 ];
					detectExeBuffer10[7:0] <= bramOut1_2[15:8 ];
					detectExeBuffer11[7:0] <= bramOut1_2[23:16];
					detectExeBuffer12[7:0] <= bramOut1_2[31:24];
					detectExeBuffer13[7:0] <= bramOut1_2[39:32];
					detectExeBuffer14[7:0] <= bramOut1_2[47:40];
					detectExeBuffer15[7:0] <= bramOut1_2[55:48];
					detectExeBuffer16[7:0] <= bramOut1_2[63:56];
                end

                default: 
                begin
                end
            endcase
            detectExeBufferDelay <= 0;
        end
        else
        begin
        /* every 8 periods shift 1
         */
            if(detectExeBufferDelay == 7)
            begin
                detectExeBufferDelay <= 0;

                detectExeBuffer1[55:8] <= detectExeBuffer1[47:0];
				detectExeBuffer2[55:8] <= detectExeBuffer2[47:0];
				detectExeBuffer3[55:8] <= detectExeBuffer3[47:0];
				detectExeBuffer4[55:8] <= detectExeBuffer4[47:0];
				detectExeBuffer5[55:8] <= detectExeBuffer5[47:0];
				detectExeBuffer6[55:8] <= detectExeBuffer6[47:0];
				detectExeBuffer7[55:8] <= detectExeBuffer7[47:0];
				detectExeBuffer8[55:8] <= detectExeBuffer8[47:0];
				
				detectExeBuffer9[55:8]  <= detectExeBuffer9[47:0];
				detectExeBuffer10[55:8] <= detectExeBuffer10[47:0];
				detectExeBuffer11[55:8] <= detectExeBuffer11[47:0];
				detectExeBuffer12[55:8] <= detectExeBuffer12[47:0];
				detectExeBuffer13[55:8] <= detectExeBuffer13[47:0];
				detectExeBuffer14[55:8] <= detectExeBuffer14[47:0];
				detectExeBuffer15[55:8] <= detectExeBuffer15[47:0];
				detectExeBuffer16[55:8] <= detectExeBuffer16[47:0];
				case (bram1Switch)
					1: 
					begin
						detectExeBuffer1[7:0] <= bramOut1_2[7 :0 ];
						detectExeBuffer2[7:0] <= bramOut1_2[15:8 ];
						detectExeBuffer3[7:0] <= bramOut1_2[23:16];
						detectExeBuffer4[7:0] <= bramOut1_2[31:24];
						detectExeBuffer5[7:0] <= bramOut1_2[39:32];
						detectExeBuffer6[7:0] <= bramOut1_2[47:40];
						detectExeBuffer7[7:0] <= bramOut1_2[55:48];
						detectExeBuffer8[7:0] <= bramOut1_2[63:56];
				
						detectExeBuffer9[7:0]  <= bramOut1_3[7 :0 ];
						detectExeBuffer10[7:0] <= bramOut1_3[15:8 ];
						detectExeBuffer11[7:0] <= bramOut1_3[23:16];
						detectExeBuffer12[7:0] <= bramOut1_3[31:24];
						detectExeBuffer13[7:0] <= bramOut1_3[39:32];
						detectExeBuffer14[7:0] <= bramOut1_3[47:40];
						detectExeBuffer15[7:0] <= bramOut1_3[55:48];
						detectExeBuffer16[7:0] <= bramOut1_3[63:56];
					end
					2: 
					begin
						detectExeBuffer1[7:0] <= bramOut1_3[7 :0 ];
						detectExeBuffer2[7:0] <= bramOut1_3[15:8 ];
						detectExeBuffer3[7:0] <= bramOut1_3[23:16];
						detectExeBuffer4[7:0] <= bramOut1_3[31:24];
						detectExeBuffer5[7:0] <= bramOut1_3[39:32];
						detectExeBuffer6[7:0] <= bramOut1_3[47:40];
						detectExeBuffer7[7:0] <= bramOut1_3[55:48];
						detectExeBuffer8[7:0] <= bramOut1_3[63:56];
				
						detectExeBuffer9[7:0]  <= bramOut1_1[7 :0 ];
						detectExeBuffer10[7:0] <= bramOut1_1[15:8 ];
						detectExeBuffer11[7:0] <= bramOut1_1[23:16];
						detectExeBuffer12[7:0] <= bramOut1_1[31:24];
						detectExeBuffer13[7:0] <= bramOut1_1[39:32];
						detectExeBuffer14[7:0] <= bramOut1_1[47:40];
						detectExeBuffer15[7:0] <= bramOut1_1[55:48];
						detectExeBuffer16[7:0] <= bramOut1_1[63:56];
					end
					3: 
					begin
						detectExeBuffer1[7:0] <= bramOut1_1[7 :0 ];
						detectExeBuffer2[7:0] <= bramOut1_1[15:8 ];
						detectExeBuffer3[7:0] <= bramOut1_1[23:16];
						detectExeBuffer4[7:0] <= bramOut1_1[31:24];
						detectExeBuffer5[7:0] <= bramOut1_1[39:32];
						detectExeBuffer6[7:0] <= bramOut1_1[47:40];
						detectExeBuffer7[7:0] <= bramOut1_1[55:48];
						detectExeBuffer8[7:0] <= bramOut1_1[63:56];
				
						detectExeBuffer9[7:0]  <= bramOut1_2[7 :0 ];
						detectExeBuffer10[7:0] <= bramOut1_2[15:8 ];
						detectExeBuffer11[7:0] <= bramOut1_2[23:16];
						detectExeBuffer12[7:0] <= bramOut1_2[31:24];
						detectExeBuffer13[7:0] <= bramOut1_2[39:32];
						detectExeBuffer14[7:0] <= bramOut1_2[47:40];
						detectExeBuffer15[7:0] <= bramOut1_2[55:48];
						detectExeBuffer16[7:0] <= bramOut1_2[63:56];
					end

					default: 
					begin
					end
				endcase
            end
            else
                detectExeBufferDelay <= detectExeBufferDelay + 1;
        end
        
    end

    else
    begin
        detectExeBufferValid <= 0;
        detectValidCount <= 0;
    end
end

// fast detect unit
wire isFast;
wire [7:0] fastScore;
wire [7:0] fastResult;
wire fastDetectValid;

reg [55:0] fastDetectCol1 = 0;
reg [55:0] fastDetectCol2 = 0;
reg [55:0] fastDetectCol3 = 0;
reg [55:0] fastDetectCol4 = 0;
reg [55:0] fastDetectCol5 = 0;
reg [55:0] fastDetectCol6 = 0;
reg [55:0] fastDetectCol7 = 0;
reg [55:0] fastDetectCol8 = 0;

reg fastDetectStart = 0;

fast_detect fast_detect_u
(
    .clk(clk),
    .rst(0),
    .start(fastDetectStart),


    .col1(fastDetectCol1),
    .col2(fastDetectCol2),
    .col3(fastDetectCol3),
    .col4(fastDetectCol4),
    .col5(fastDetectCol5),
    .col6(fastDetectCol6),
    .col7(fastDetectCol7),

    .isFast(isFast),
    .score(fastScore),
    .fastResult(fastResult),
    .val(fastDetectValid)
);

// gaussian unit
wire [7:0] gausConvResult;
wire gausConvValid;

gaus_conv gc_u
(
    .clk(clk),
    .rst(0),
    .start(fastDetectStart),


    .col1(fastDetectCol1),
    .col2(fastDetectCol2),
    .col3(fastDetectCol3),
    .col4(fastDetectCol4),
    .col5(fastDetectCol5),
    .col6(fastDetectCol6),
    .col7(fastDetectCol7),

    .result(gausConvResult),
    .val(gausConvValid)

);

reg [3:0] detectExeBufferSelect  = 0;
reg [15:0] detectFinishCount     = 0;
reg [3:0] detectFinishCountDelay = 0;

/*  fast_detect ctrl
    detectFinish gen
 */
always @(posedge clk)
begin
    if(rst || rstIn)
    begin
        fastDetectStart <= 0;
		
		fastDetectCol1 <= 0;
		fastDetectCol2 <= 0;
		fastDetectCol3 <= 0;
		fastDetectCol4 <= 0;
		fastDetectCol5 <= 0;
		fastDetectCol6 <= 0;
		fastDetectCol7 <= 0;

        detectExeBufferSelect <= 0;
		
        /*  padding: 3, 3*2=6
            0000000000000
            0000000000000
            0000000000000
            0001111111000
            0000000000000
            0000000000000
            0000000000000
         */
        detectFinishCount <= 6;
        detectFinishCountDelay <= 0;
        detectFinish <= 0;
    end

    else if(detectState == DETECT_EXE || detectState == DETECT_LAST_EXE)
    begin
        /*  buffer ready
            gen start
            select buffer
         */
        // start
        fastDetectStart <= detectExeBufferValid;
        if(detectExeBufferValid)
        begin
            /* buffer -> cols
             */
            case (detectExeBufferSelect)
                0:
                begin
                    // select change
                    detectExeBufferSelect <= 1;

                    fastDetectCol1 <= detectExeBuffer3;
                    fastDetectCol2 <= detectExeBuffer4;
                    fastDetectCol3 <= detectExeBuffer5;
                    fastDetectCol4 <= detectExeBuffer6;
                    fastDetectCol5 <= detectExeBuffer7;
                    fastDetectCol6 <= detectExeBuffer8;
                    fastDetectCol7 <= detectExeBuffer9;
                end 
                1:
                begin
                    // select change
                    detectExeBufferSelect <= 2;

                    fastDetectCol1 <= detectExeBuffer4;
                    fastDetectCol2 <= detectExeBuffer5;
                    fastDetectCol3 <= detectExeBuffer6;
                    fastDetectCol4 <= detectExeBuffer7;
                    fastDetectCol5 <= detectExeBuffer8;
                    fastDetectCol6 <= detectExeBuffer9;
                    fastDetectCol7 <= detectExeBuffer10;
                end 
                2:
                begin
                    // select change
                    detectExeBufferSelect <= 3;

                    fastDetectCol1 <= detectExeBuffer5;
                    fastDetectCol2 <= detectExeBuffer6;
                    fastDetectCol3 <= detectExeBuffer7;
                    fastDetectCol4 <= detectExeBuffer8;
                    fastDetectCol5 <= detectExeBuffer9;
                    fastDetectCol6 <= detectExeBuffer10;
                    fastDetectCol7 <= detectExeBuffer11;
                end 
                3:
                begin
                    // select change
                    detectExeBufferSelect <= 4;

                    fastDetectCol1 <= detectExeBuffer6;
                    fastDetectCol2 <= detectExeBuffer7;
                    fastDetectCol3 <= detectExeBuffer8;
                    fastDetectCol4 <= detectExeBuffer9;
                    fastDetectCol5 <= detectExeBuffer10;
                    fastDetectCol6 <= detectExeBuffer11;
                    fastDetectCol7 <= detectExeBuffer12;
                end 
                4:
                begin
                    // select change
                    detectExeBufferSelect <= 5;

                    fastDetectCol1 <= detectExeBuffer7;
                    fastDetectCol2 <= detectExeBuffer8;
                    fastDetectCol3 <= detectExeBuffer9;
                    fastDetectCol4 <= detectExeBuffer10;
                    fastDetectCol5 <= detectExeBuffer11;
                    fastDetectCol6 <= detectExeBuffer12;
                    fastDetectCol7 <= detectExeBuffer13;
                end
                5:
                begin
                    // select change
                    detectExeBufferSelect <= 6;

                    fastDetectCol1 <= detectExeBuffer8;
                    fastDetectCol2 <= detectExeBuffer9;
                    fastDetectCol3 <= detectExeBuffer10;
                    fastDetectCol4 <= detectExeBuffer11;
                    fastDetectCol5 <= detectExeBuffer12;
                    fastDetectCol6 <= detectExeBuffer13;
                    fastDetectCol7 <= detectExeBuffer14;
                end 
                6:
                begin
                    // select change
                    detectExeBufferSelect <= 7;

                    fastDetectCol1 <= detectExeBuffer9;
                    fastDetectCol2 <= detectExeBuffer10;
                    fastDetectCol3 <= detectExeBuffer11;
                    fastDetectCol4 <= detectExeBuffer12;
                    fastDetectCol5 <= detectExeBuffer13;
                    fastDetectCol6 <= detectExeBuffer14;
                    fastDetectCol7 <= detectExeBuffer15;
                end 
                7:
                begin
                    // select change
                    detectExeBufferSelect <= 0;

                    fastDetectCol1 <= detectExeBuffer10;
                    fastDetectCol2 <= detectExeBuffer11;
                    fastDetectCol3 <= detectExeBuffer12;
                    fastDetectCol4 <= detectExeBuffer13;
                    fastDetectCol5 <= detectExeBuffer14;
                    fastDetectCol6 <= detectExeBuffer15;
                    fastDetectCol7 <= detectExeBuffer16;
                end 
                default: 
                begin
                end
            endcase
        end

        /* gen detectFinish
         */
        if(fastDetectValid)
        begin
            if(detectFinishCountDelay == 7)
            begin
                detectFinishCountDelay <= 0;
                detectFinishCount <= detectFinishCount + 1;
            end
            else
                detectFinishCountDelay <= detectFinishCountDelay + 1;
        end
        if(detectFinishCount >= imgWidth)
            detectFinish <= 1;
    end

    else
    begin
        detectFinish <= 0;
        detectFinishCount <= 6;
        detectFinishCountDelay <= 0;

        fastDetectStart <= 0;
        detectExeBufferSelect <= 0;
    end
end


//////////////////////
////* detect fsm *////
//////////////////////

/* states */
parameter DETECT_IDLE      = 0;    // idle
parameter DETECT_INIT      = 1;    // input 2 cols
parameter DETECT_EXE       = 2;    // detect, input 1 col
parameter DETECT_LAST_EXE  = 3;    // detect last col
parameter DETECT_EXE_INVL  = 4;    // exe -> invl -> exe
reg [3:0] detectState      = 0;
/* args */
reg [15:0] imgWidth     = 0;
reg [15:0] imgHeight    = 0;
reg [15:0] rdLenExe     = 0;
reg [31:0] rdAddrReg    = 0;
/* counters */
reg [15:0] rowCount     = 0;
reg [15:0] bram2Count   = 0;
/* ctrl */
reg [3:0] bram1Switch   = 0;    // decide which bram is the input buffer
reg [3:0] inputSwitch   = 0;    // 1: init input; 2: exe input
reg detectFinish        = 0;    // one col finish
reg detectEXERdFin      = 0;
reg detectFinishAll     = 0;    // all finish

always@(posedge clk)
begin
    // reset
	if(rst || rstIn)
	begin
        // state change
		detectState <= DETECT_IDLE;
		// axi
		rd_burst_req <= 0;
		rd_burst_len <= 0;
		rd_burst_addr <= 0;
        // counter
        rowCount <= 0;
        detectFinishAll <= 0;
	end

	else
	begin
		case(detectState)
			DETECT_IDLE:
			begin
                if(ctrl == 1 && !detectFinishAll)
                begin
                /*  ->DETECT_INIT
                    get args
                    start axi transfer, input 2 cols -> bram[1][1,2]
                 */
                    // state change
                    detectState <= DETECT_INIT;
                    // args
                    imgWidth <= imgSize[15:0];
                    imgHeight <= imgSize[31:16];
                    rdLenExe <= imgSize[15:0];
                    rdAddrReg <= rdAddr+{12'b0,imgSize[15:0],4'b0};
                    // axi
					rd_burst_req <= 1;
                    rd_burst_len <= {12'b0,imgSize[15:0],1'b0};
					rd_burst_addr <= rdAddr;
                    // ctrl
                    inputSwitch <= 1;
                    bram1Switch <= 2;
                    // counter
                    rowCount <= 0;
                end
			end

			DETECT_INIT:
			begin
				if(rd_burst_finish)
				begin
                /*  -> COMPUTE_EXE_INVL -> COMPUTE_EXE
                    col += 2
                    stop axi req
                 */
                    // state change
                    detectState <= DETECT_EXE_INVL;
                    // counter
                    rowCount <= rowCount + 16;
                    // axi
					rd_burst_req <= 0;
				end
			end
            
            DETECT_EXE_INVL:
			begin
                if(computeState == COMPUTE_EXE_INVL || computeState == COMPUTE_IN_INVL) // sync to compute
                begin
                    if(rowCount<imgHeight)
                    begin
                    /*  -> DETECT_EXE
                        start axi transfer
                    */
                        // state change
                        detectState <= DETECT_EXE;
                        // axi
                        rd_burst_req <= 1;
                        rd_burst_len <= rdLenExe;
                        rd_burst_addr <= rdAddrReg;
                        // ctrl
                        inputSwitch <= 2;
                        detectEXERdFin <= 0;
                        case (bram1Switch)
                            1: bram1Switch <= 2;
                            2: bram1Switch <= 3;
                            3: bram1Switch <= 1;
                            default: 
                            begin
                            end
                        endcase
                    end
                    else
                    begin
                    /*  -> DETECT_LAST_EXE
                    */
                        // state change
                        detectState <= DETECT_LAST_EXE;
                        // ctrl
                        inputSwitch <= 2;
                        case (bram1Switch)
                            1: bram1Switch <= 2;
                            2: bram1Switch <= 3;
                            3: bram1Switch <= 1;
                            default: 
                            begin
                            end
                        endcase
                    end
                end
			end

            DETECT_EXE:
            begin
                if(rd_burst_finish)
                    detectEXERdFin <= 1;
				if(detectEXERdFin)
				begin
                /*  col += 1
                    stop axi req
                 */
                    // axi
					rd_burst_req <= 0;

                    if(detectFinish)
                    begin
                    /*  finish, -> DETECT_EXE_INVL
                        rdAddr++
                     */
                        // state change
                        detectState <= DETECT_EXE_INVL;
                        // args
                        rdAddrReg <= rdAddrReg + {13'b0,rdLenExe,3'b0};
                        // counter
                        rowCount <= rowCount + 8;
                    end
				end
            end
            
            DETECT_LAST_EXE:
			begin
            /*  -> DETECT_IDLE
                rst
             */
                if(detectFinish)
                begin
                    // state change
                    detectState <= DETECT_IDLE;
                    // axi
                    rd_burst_req <= 0;
                    rd_burst_len <= 0;
                    rd_burst_addr <= 0;
                    // counter
                    rowCount <= 0;
                    // ctrl
                    detectFinishAll <= 1;
                end
			end

		endcase
	end
end


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* compute */

/////////////////
////* bram2 *////
/////////////////

(*mark_debug="true"*)reg [63:0] bramIn2_1;
wire [63:0] bramOut2_1;
(*mark_debug="true"*)reg [9:0] bramAddr2_1 = 0;
(*mark_debug="true"*)reg bramWr2_1 = 0;
reg bramStart2_1 = 0;
wire bramValid2_1;
bram_driver bram2_1
(
    .inputData(bramIn2_1),
    .outputData(bramOut2_1),
    .addr(bramAddr2_1),
    .wr(bramWr2_1),
    .start(bramStart2_1),
    .valid(bramValid2_1),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramIn2_2;
wire [63:0] bramOut2_2;
(*mark_debug="true"*)reg [9:0] bramAddr2_2 = 0;
(*mark_debug="true"*)reg bramWr2_2 = 0;
reg bramStart2_2 = 0;
wire bramValid2_2;
bram_driver bram2_2
(
    .inputData(bramIn2_2),
    .outputData(bramOut2_2),
    .addr(bramAddr2_2),
    .wr(bramWr2_2),
    .start(bramStart2_2),
    .valid(bramValid2_2),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramIn2_3;
wire [63:0] bramOut2_3;
(*mark_debug="true"*)reg [9:0] bramAddr2_3 = 0;
(*mark_debug="true"*)reg bramWr2_3 = 0;
reg bramStart2_3 = 0;
wire bramValid2_3;
bram_driver bram2_3
(
    .inputData(bramIn2_3),
    .outputData(bramOut2_3),
    .addr(bramAddr2_3),
    .wr(bramWr2_3),
    .start(bramStart2_3),
    .valid(bramValid2_3),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramIn2_4;
wire [63:0] bramOut2_4;
(*mark_debug="true"*)reg [9:0] bramAddr2_4 = 0;
(*mark_debug="true"*)reg bramWr2_4 = 0;
reg bramStart2_4 = 0;
wire bramValid2_4;
bram_driver bram2_4
(
    .inputData(bramIn2_4),
    .outputData(bramOut2_4),
    .addr(bramAddr2_4),
    .wr(bramWr2_4),
    .start(bramStart2_4),
    .valid(bramValid2_4),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramIn2_5;
wire [63:0] bramOut2_5;
(*mark_debug="true"*)reg [9:0] bramAddr2_5 = 0;
(*mark_debug="true"*)reg bramWr2_5 = 0;
reg bramStart2_5 = 0;
wire bramValid2_5;
bram_driver bram2_5
(
    .inputData(bramIn2_5),
    .outputData(bramOut2_5),
    .addr(bramAddr2_5),
    .wr(bramWr2_5),
    .start(bramStart2_5),
    .valid(bramValid2_5),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramIn2_6;
wire [63:0] bramOut2_6;
(*mark_debug="true"*)reg [9:0] bramAddr2_6 = 0;
(*mark_debug="true"*)reg bramWr2_6 = 0;
reg bramStart2_6 = 0;
wire bramValid2_6;
bram_driver bram2_6
(
    .inputData(bramIn2_6),
    .outputData(bramOut2_6),
    .addr(bramAddr2_6),
    .wr(bramWr2_6),
    .start(bramStart2_6),
    .valid(bramValid2_6),
    .clk(clk)
);

(*mark_debug="true"*)reg [63:0] bramInFast2_1;
wire [63:0] bramOutFast2_1;
bram_driver bramFast2_1
(
    .inputData(bramInFast2_1),
    .outputData(bramOutFast2_1),
    .addr(bramAddr2_1),
    .wr(bramWr2_1),
    .start(bramStart2_1),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramInFast2_2;
wire [63:0] bramOutFast2_2;
bram_driver bramFast2_2
(
    .inputData(bramInFast2_2),
    .outputData(bramOutFast2_2),
    .addr(bramAddr2_2),
    .wr(bramWr2_2),
    .start(bramStart2_2),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramInFast2_3;
wire [63:0] bramOutFast2_3;
bram_driver bramFast2_3
(
    .inputData(bramInFast2_3),
    .outputData(bramOutFast2_3),
    .addr(bramAddr2_3),
    .wr(bramWr2_3),
    .start(bramStart2_3),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramInFast2_4;
wire [63:0] bramOutFast2_4;
bram_driver bramFast2_4
(
    .inputData(bramInFast2_4),
    .outputData(bramOutFast2_4),
    .addr(bramAddr2_4),
    .wr(bramWr2_4),
    .start(bramStart2_4),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramInFast2_5;
wire [63:0] bramOutFast2_5;
bram_driver bramFast2_5
(
    .inputData(bramInFast2_5),
    .outputData(bramOutFast2_5),
    .addr(bramAddr2_5),
    .wr(bramWr2_5),
    .start(bramStart2_5),
    .clk(clk)
);
(*mark_debug="true"*)reg [63:0] bramInFast2_6;
wire [63:0] bramOutFast2_6;
bram_driver bramFast2_6
(
    .inputData(bramInFast2_6),
    .outputData(bramOutFast2_6),
    .addr(bramAddr2_6),
    .wr(bramWr2_6),
    .start(bramStart2_6),
    .clk(clk)
);

reg [15:0] bram2InCount = 0;
reg [63:0] bram2InBuff = 0;
reg [63:0] bramFast2InBuff = 0;
/*  5-1-2-3 - 0-1-2-3 - 0-1-2-3 - ...
    if(0): buffer -> bram2
 */
reg [3:0] bram2InBuffByteSwitch = 0;
reg [3:0] computeExeAddrDelay = 0;

/*  bram2 addr gen
    bram2 wr ctrl
 */
always @(posedge clk)
begin
    if(rst || rstIn)
	begin
        bram2InBuff <= 0;
        bramFast2InBuff <= 0;
        bram2InBuffByteSwitch <= 8;
        bram2InCount <= 6;  // pad 6 000111000

		bramWr2_1 <= 0; 
		bramWr2_2 <= 0; 
		bramWr2_3 <= 0; 
		bramWr2_4 <= 0; 
		bramWr2_5 <= 0; 
		bramWr2_6 <= 0;
		
		bramAddr2_1 <= 0; 
		bramAddr2_2 <= 0; 
		bramAddr2_3 <= 0; 
		bramAddr2_4 <= 0; 
		bramAddr2_5 <= 0; 
		bramAddr2_6 <= 0;
		
		bramStart2_1 <= 0; 
		bramStart2_2 <= 0; 
		bramStart2_3 <= 0; 
		bramStart2_4 <= 0; 
		bramStart2_5 <= 0; 
		bramStart2_6 <= 0;

        /* ctrl
         */
        computeInFinish <= 0;
	end
    
    else
    begin

        /*  bram2 in
            gaus -> buffer -> bram2
        */
        if(computeState == COMPUTE_IN || computeState == COMPUTE_EXE || computeState == COMPUTE_FIRST_EXE)
        begin
            /* finish
            */
            if(bram2InCount >= imgWidth)
            begin
                computeInFinish <= 1;
            end

            /* gaus -> buffer
            */
            if(gausConvValid)
            begin
                case (bram2InBuffByteSwitch)
                    0:
                    begin
                        bram2InBuff[7:0]        <= gausConvResult;
                        bramFast2InBuff[7:0]    <= fastResult;
                        bram2InBuffByteSwitch   <= 1;
                    end
                    1:
                    begin
                        bram2InBuff[15:8]       <= gausConvResult;
                        bramFast2InBuff[15:8]   <= fastResult;
                        bram2InBuffByteSwitch   <= 2;
                    end
                    2:
                    begin
                        bram2InBuff[23:16]      <= gausConvResult;
                        bramFast2InBuff[23:16]  <= fastResult;
                        bram2InBuffByteSwitch   <= 3;
                    end
                    3:
                    begin
                        bram2InBuff[31:24]      <= gausConvResult;
                        bramFast2InBuff[31:24]  <= fastResult;
                        bram2InBuffByteSwitch   <= 4;
                    end
                    4:
                    begin
                        bram2InBuff[39:32]      <= gausConvResult;
                        bramFast2InBuff[39:32]  <= fastResult;
                        bram2InBuffByteSwitch   <= 5;
                    end
                    5:
                    begin
                        bram2InBuff[47:40]      <= gausConvResult;
                        bramFast2InBuff[47:40]  <= fastResult;
                        bram2InBuffByteSwitch   <= 6;
                    end
                    6:
                    begin
                        bram2InBuff[55:48]      <= gausConvResult;
                        bramFast2InBuff[55:48]  <= fastResult;
                        bram2InBuffByteSwitch   <= 7;
                    end
                    7:
                    begin
                        bram2InBuff[63:56]      <= gausConvResult;
                        bramFast2InBuff[63:56]  <= fastResult;
                        bram2InBuffByteSwitch   <= 0;
                    end
                    8:  //init, 5-1-2-3 - 0-1-2-3 - 0-1-2-3 - ...
                    begin
                        bram2InBuff[7:0]        <= gausConvResult;
                        bramFast2InBuff[7:0]    <= fastResult;
                        bram2InBuffByteSwitch   <= 1;
                    end
                    default:
                    begin
                    end 
                endcase
            end
            
            /* buffer -> bram2
            */
            if(bram2InBuffByteSwitch == 0 && bram2InCount < imgWidth)
            begin
                bram2InCount <= bram2InCount + 1;
                case(bram2Switch)
                    1:
                    begin
                        bramWr2_1 <= 1; 
                        bramWr2_2 <= 0; 
                        bramWr2_3 <= 0; 
                        bramWr2_4 <= 0; 
                        bramWr2_5 <= 0; 
                        bramWr2_6 <= 0;
                        bramIn2_1 <= bram2InBuff;
                        bramInFast2_1 <= bramFast2InBuff;
                        bramAddr2_1 <= bramAddr2_1 + 1;
                    end
                    2:
                    begin
                        bramWr2_1 <= 0; 
                        bramWr2_2 <= 1; 
                        bramWr2_3 <= 0; 
                        bramWr2_4 <= 0; 
                        bramWr2_5 <= 0; 
                        bramWr2_6 <= 0;
                        bramIn2_2 <= bram2InBuff;
                        bramInFast2_2 <= bramFast2InBuff;
                        bramAddr2_2 <= bramAddr2_2 + 1;
                    end
                    3:
                    begin
                        bramWr2_1 <= 0; 
                        bramWr2_2 <= 0; 
                        bramWr2_3 <= 1; 
                        bramWr2_4 <= 0; 
                        bramWr2_5 <= 0; 
                        bramWr2_6 <= 0;
                        bramIn2_3 <= bram2InBuff;
                        bramInFast2_3 <= bramFast2InBuff;
                        bramAddr2_3 <= bramAddr2_3 + 1;
                    end
                    4:
                    begin
                        bramWr2_1 <= 0; 
                        bramWr2_2 <= 0; 
                        bramWr2_3 <= 0; 
                        bramWr2_4 <= 1; 
                        bramWr2_5 <= 0; 
                        bramWr2_6 <= 0;
                        bramIn2_4 <= bram2InBuff;
                        bramInFast2_4 <= bramFast2InBuff;
                        bramAddr2_4 <= bramAddr2_4 + 1;
                    end
                    5:
                    begin
                        bramWr2_1 <= 0; 
                        bramWr2_2 <= 0; 
                        bramWr2_3 <= 0; 
                        bramWr2_4 <= 0; 
                        bramWr2_5 <= 1; 
                        bramWr2_6 <= 0;
                        bramIn2_5 <= bram2InBuff;
                        bramInFast2_5 <= bramFast2InBuff;
                        bramAddr2_5 <= bramAddr2_5 + 1;
                    end
                    6:
                    begin
                        bramWr2_1 <= 0; 
                        bramWr2_2 <= 0; 
                        bramWr2_3 <= 0; 
                        bramWr2_4 <= 0; 
                        bramWr2_5 <= 0; 
                        bramWr2_6 <= 1;
                        bramIn2_6 <= bram2InBuff;
                        bramInFast2_6 <= bramFast2InBuff;
                        bramAddr2_6 <= bramAddr2_6 + 1;
                    end
                    
                    default:
                    begin
                    end
                endcase
            end
            else
            begin
                bramWr2_1 <= 0; 
                bramWr2_2 <= 0; 
                bramWr2_3 <= 0; 
                bramWr2_4 <= 0; 
                bramWr2_5 <= 0; 
                bramWr2_6 <= 0;
            end

        end

        /*  bram2 out
            first bram2 -> compute
        */
        if(computeState == COMPUTE_FIRST_EXE)
        begin
            if(bramAddr2_1 < bram2Size)
            begin
                if(bramAddr2_1 <= 30)
                begin
                /* fill the buffer, no delay
                */
                    bramAddr2_1 <= bramAddr2_1 + 1;
                    bramAddr2_2 <= bramAddr2_2 + 1;
                    bramAddr2_3 <= bramAddr2_3 + 1;
                    bramAddr2_4 <= bramAddr2_4 + 1;
                    computeExeAddrDelay <= 0;
                end
                else
                begin
                /* gen delay, every 2 periods addr ++
                */
                    if(computeExeAddrDelay == 1)
                    begin
                        computeExeAddrDelay <= 0;
                        bramAddr2_1 <= bramAddr2_1 + 1;
                        bramAddr2_2 <= bramAddr2_2 + 1;
                        bramAddr2_3 <= bramAddr2_3 + 1;
                        bramAddr2_4 <= bramAddr2_4 + 1;
                    end
                    else
                        computeExeAddrDelay <= computeExeAddrDelay + 1;
                end
                bramStart2_1 <= 1;
                bramStart2_2 <= 1;
                bramStart2_3 <= 1;
                bramStart2_4 <= 1;
            end
            else if(bramAddr2_1 == bram2Size && computeExeAddrDelay != 1)
            begin
                bramStart2_1 <= 1;
                bramStart2_2 <= 1;
                bramStart2_3 <= 1;
                bramStart2_4 <= 1;
                computeExeAddrDelay <= computeExeAddrDelay + 1;
            end
            else
            begin
                bramStart2_1 <= 0;
                bramStart2_2 <= 0;
                bramStart2_3 <= 0;
                bramStart2_4 <= 0;
                bramStart2_5 <= 0;
                bramStart2_6 <= 0;
            end
        end

        /*  bram2 out
            bram2 -> compute
        */
        if(computeState == COMPUTE_EXE || computeState == COMPUTE_LAST_EXE)
        begin
            case (bram2Switch)
                1: 
                begin
                    if(bramAddr2_2 < bram2Size)
                    begin
                        if(bramAddr2_2 <= 30)
                        begin
                        /* fill the buffer, no delay
                        */
                            bramAddr2_2 <= bramAddr2_2 + 1;
                            bramAddr2_3 <= bramAddr2_3 + 1;
                            bramAddr2_4 <= bramAddr2_4 + 1;
                            bramAddr2_5 <= bramAddr2_5 + 1;
                            bramAddr2_6 <= bramAddr2_6 + 1;
                            computeExeAddrDelay <= 0;
                        end
                        else
                        begin
                        /* gen delay, every 8 periods addr ++
                        */
                            if(computeExeAddrDelay == 7)
                            begin
                                computeExeAddrDelay <= 0;
                                bramAddr2_2 <= bramAddr2_2 + 1;
                                bramAddr2_3 <= bramAddr2_3 + 1;
                                bramAddr2_4 <= bramAddr2_4 + 1;
                                bramAddr2_5 <= bramAddr2_5 + 1;
                                bramAddr2_6 <= bramAddr2_6 + 1;
                            end
                            else
                                computeExeAddrDelay <= computeExeAddrDelay + 1;
                        end
                        bramStart2_2 <= 1;
                        bramStart2_3 <= 1;
                        bramStart2_4 <= 1;
                        bramStart2_5 <= 1;
                        bramStart2_6 <= 1;
                    end
                    else if(bramAddr2_2 == bram2Size && computeExeAddrDelay != 7)
                    begin
                        bramStart2_2 <= 1;
                        bramStart2_3 <= 1;
                        bramStart2_4 <= 1;
                        bramStart2_5 <= 1;
                        bramStart2_6 <= 1;
                        computeExeAddrDelay <= computeExeAddrDelay + 1;
                    end
                    else
                    begin
                        bramStart2_1 <= 0;
                        bramStart2_2 <= 0;
                        bramStart2_3 <= 0;
                        bramStart2_4 <= 0;
                        bramStart2_5 <= 0;
                        bramStart2_6 <= 0;
                    end
                end

                2: 
                begin
                    if(bramAddr2_3 < bram2Size)
                    begin
                        if(bramAddr2_3 <= 30)
                        begin
                        /* fill the buffer, no delay
                        */
                            bramAddr2_3 <= bramAddr2_3 + 1;
                            bramAddr2_4 <= bramAddr2_4 + 1;
                            bramAddr2_5 <= bramAddr2_5 + 1;
                            bramAddr2_6 <= bramAddr2_6 + 1;
                            bramAddr2_1 <= bramAddr2_1 + 1;
                            computeExeAddrDelay <= 0;
                        end
                        else
                        begin
                        /* gen delay, every 8 periods addr ++
                        */
                            if(computeExeAddrDelay == 7)
                            begin
                                computeExeAddrDelay <= 0;
                                bramAddr2_3 <= bramAddr2_3 + 1;
                                bramAddr2_4 <= bramAddr2_4 + 1;
                                bramAddr2_5 <= bramAddr2_5 + 1;
                                bramAddr2_6 <= bramAddr2_6 + 1;
                                bramAddr2_1 <= bramAddr2_1 + 1;
                            end
                            else
                                computeExeAddrDelay <= computeExeAddrDelay + 1;
                        end
                        bramStart2_3 <= 1;
                        bramStart2_4 <= 1;
                        bramStart2_5 <= 1;
                        bramStart2_6 <= 1;
                        bramStart2_1 <= 1;
                    end
                    else if(bramAddr2_3 == bram2Size && computeExeAddrDelay != 7)
                    begin
                        bramStart2_3 <= 1;
                        bramStart2_4 <= 1;
                        bramStart2_5 <= 1;
                        bramStart2_6 <= 1;
                        bramStart2_1 <= 1;
                        computeExeAddrDelay <= computeExeAddrDelay + 1;
                    end
                    else
                    begin
                        bramStart2_1 <= 0;
                        bramStart2_2 <= 0;
                        bramStart2_3 <= 0;
                        bramStart2_4 <= 0;
                        bramStart2_5 <= 0;
                        bramStart2_6 <= 0;
                    end
                end

                3: 
                begin
                    if(bramAddr2_4 < bram2Size)
                    begin
                        if(bramAddr2_4 <= 30)
                        begin
                        /* fill the buffer, no delay
                        */
                            bramAddr2_4 <= bramAddr2_4 + 1;
                            bramAddr2_5 <= bramAddr2_5 + 1;
                            bramAddr2_6 <= bramAddr2_6 + 1;
                            bramAddr2_1 <= bramAddr2_1 + 1;
                            bramAddr2_2 <= bramAddr2_2 + 1;
                            computeExeAddrDelay <= 0;
                        end
                        else
                        begin
                        /* gen delay, every 8 periods addr ++
                        */
                            if(computeExeAddrDelay == 7)
                            begin
                                computeExeAddrDelay <= 0;
                                bramAddr2_4 <= bramAddr2_4 + 1;
                                bramAddr2_5 <= bramAddr2_5 + 1;
                                bramAddr2_6 <= bramAddr2_6 + 1;
                                bramAddr2_1 <= bramAddr2_1 + 1;
                                bramAddr2_2 <= bramAddr2_2 + 1;
                            end
                            else
                                computeExeAddrDelay <= computeExeAddrDelay + 1;
                        end
                        bramStart2_4 <= 1;
                        bramStart2_5 <= 1;
                        bramStart2_6 <= 1;
                        bramStart2_1 <= 1;
                        bramStart2_2 <= 1;
                    end
                    else if(bramAddr2_4 == bram2Size && computeExeAddrDelay != 7)
                    begin
                        bramStart2_4 <= 1;
                        bramStart2_5 <= 1;
                        bramStart2_6 <= 1;
                        bramStart2_1 <= 1;
                        bramStart2_2 <= 1;
                        computeExeAddrDelay <= computeExeAddrDelay + 1;
                    end
                    else
                    begin
                        bramStart2_1 <= 0;
                        bramStart2_2 <= 0;
                        bramStart2_3 <= 0;
                        bramStart2_4 <= 0;
                        bramStart2_5 <= 0;
                        bramStart2_6 <= 0;
                    end
                end

                4: 
                begin
                    if(bramAddr2_5 < bram2Size)
                    begin
                        if(bramAddr2_5 <= 30)
                        begin
                        /* fill the buffer, no delay
                        */
                            bramAddr2_5 <= bramAddr2_5 + 1;
                            bramAddr2_6 <= bramAddr2_6 + 1;
                            bramAddr2_1 <= bramAddr2_1 + 1;
                            bramAddr2_2 <= bramAddr2_2 + 1;
                            bramAddr2_3 <= bramAddr2_3 + 1;
                            computeExeAddrDelay <= 0;
                        end
                        else
                        begin
                        /* gen delay, every 8 periods addr ++
                        */
                            if(computeExeAddrDelay == 7)
                            begin
                                computeExeAddrDelay <= 0;
                                bramAddr2_5 <= bramAddr2_5 + 1;
                                bramAddr2_6 <= bramAddr2_6 + 1;
                                bramAddr2_1 <= bramAddr2_1 + 1;
                                bramAddr2_2 <= bramAddr2_2 + 1;
                                bramAddr2_3 <= bramAddr2_3 + 1;
                            end
                            else
                                computeExeAddrDelay <= computeExeAddrDelay + 1;
                        end
                        bramStart2_5 <= 1;
                        bramStart2_6 <= 1;
                        bramStart2_1 <= 1;
                        bramStart2_2 <= 1;
                        bramStart2_3 <= 1;
                    end
                    else if(bramAddr2_5 == bram2Size && computeExeAddrDelay != 7)
                    begin
                        bramStart2_5 <= 1;
                        bramStart2_6 <= 1;
                        bramStart2_1 <= 1;
                        bramStart2_2 <= 1;
                        bramStart2_3 <= 1;
                        computeExeAddrDelay <= computeExeAddrDelay + 1;
                    end
                    else
                    begin
                        bramStart2_1 <= 0;
                        bramStart2_2 <= 0;
                        bramStart2_3 <= 0;
                        bramStart2_4 <= 0;
                        bramStart2_5 <= 0;
                        bramStart2_6 <= 0;
                    end
                end

                5: 
                begin
                    if(bramAddr2_6 < bram2Size)
                    begin
                        if(bramAddr2_6 <= 30)
                        begin
                        /* fill the buffer, no delay
                        */
                            bramAddr2_6 <= bramAddr2_6 + 1;
                            bramAddr2_1 <= bramAddr2_1 + 1;
                            bramAddr2_2 <= bramAddr2_2 + 1;
                            bramAddr2_3 <= bramAddr2_3 + 1;
                            bramAddr2_4 <= bramAddr2_4 + 1;
                            computeExeAddrDelay <= 0;
                        end
                        else
                        begin
                        /* gen delay, every 8 periods addr ++
                        */
                            if(computeExeAddrDelay == 7)
                            begin
                                computeExeAddrDelay <= 0;
                                bramAddr2_6 <= bramAddr2_6 + 1;
                                bramAddr2_1 <= bramAddr2_1 + 1;
                                bramAddr2_2 <= bramAddr2_2 + 1;
                                bramAddr2_3 <= bramAddr2_3 + 1;
                                bramAddr2_4 <= bramAddr2_4 + 1;
                            end
                            else
                                computeExeAddrDelay <= computeExeAddrDelay + 1;
                        end
                        bramStart2_6 <= 1;
                        bramStart2_1 <= 1;
                        bramStart2_2 <= 1;
                        bramStart2_3 <= 1;
                        bramStart2_4 <= 1;
                    end
                    else if(bramAddr2_6 == bram2Size && computeExeAddrDelay != 7)
                    begin
                        bramStart2_6 <= 1;
                        bramStart2_1 <= 1;
                        bramStart2_2 <= 1;
                        bramStart2_3 <= 1;
                        bramStart2_4 <= 1;
                        computeExeAddrDelay <= computeExeAddrDelay + 1;
                    end
                    else
                    begin
                        bramStart2_1 <= 0;
                        bramStart2_2 <= 0;
                        bramStart2_3 <= 0;
                        bramStart2_4 <= 0;
                        bramStart2_5 <= 0;
                        bramStart2_6 <= 0;
                    end
                end

                6: 
                begin
                    if(bramAddr2_1 < bram2Size)
                    begin
                        if(bramAddr2_1 <= 30)
                        begin
                        /* fill the buffer, no delay
                        */
                            bramAddr2_1 <= bramAddr2_1 + 1;
                            bramAddr2_2 <= bramAddr2_2 + 1;
                            bramAddr2_3 <= bramAddr2_3 + 1;
                            bramAddr2_4 <= bramAddr2_4 + 1;
                            bramAddr2_5 <= bramAddr2_5 + 1;
                            computeExeAddrDelay <= 0;
                        end
                        else
                        begin
                        /* gen delay, every 8 periods addr ++
                        */
                            if(computeExeAddrDelay == 7)
                            begin
                                computeExeAddrDelay <= 0;
                                bramAddr2_1 <= bramAddr2_1 + 1;
                                bramAddr2_2 <= bramAddr2_2 + 1;
                                bramAddr2_3 <= bramAddr2_3 + 1;
                                bramAddr2_4 <= bramAddr2_4 + 1;
                                bramAddr2_5 <= bramAddr2_5 + 1;
                            end
                            else
                                computeExeAddrDelay <= computeExeAddrDelay + 1;
                        end
                        bramStart2_1 <= 1;
                        bramStart2_2 <= 1;
                        bramStart2_3 <= 1;
                        bramStart2_4 <= 1;
                        bramStart2_5 <= 1;
                    end
                    else if(bramAddr2_1 == bram2Size && computeExeAddrDelay != 7)
                    begin
                        bramStart2_1 <= 1;
                        bramStart2_2 <= 1;
                        bramStart2_3 <= 1;
                        bramStart2_4 <= 1;
                        bramStart2_5 <= 1;
                        computeExeAddrDelay <= computeExeAddrDelay + 1;
                    end
                    else
                    begin
                        bramStart2_1 <= 0;
                        bramStart2_2 <= 0;
                        bramStart2_3 <= 0;
                        bramStart2_4 <= 0;
                        bramStart2_5 <= 0;
                        bramStart2_6 <= 0;
                    end
                end

                default:
                begin
                end 
            endcase

        end

        /*  rst
        */
        if(computeState == COMPUTE_IN_INVL || computeState == COMPUTE_EXE_INVL)
        begin
            bramWr2_1 <= 0; 
            bramWr2_2 <= 0; 
            bramWr2_3 <= 0; 
            bramWr2_4 <= 0; 
            bramWr2_5 <= 0; 
            bramWr2_6 <= 0;
            
            bramAddr2_1 <= 0; 
            bramAddr2_2 <= 0; 
            bramAddr2_3 <= 0; 
            bramAddr2_4 <= 0; 
            bramAddr2_5 <= 0; 
            bramAddr2_6 <= 0;
            
            bramStart2_1 <= 0; 
            bramStart2_2 <= 0; 
            bramStart2_3 <= 0; 
            bramStart2_4 <= 0; 
            bramStart2_5 <= 0; 
            bramStart2_6 <= 0;

            bram2InBuff <= 0;
            bramFast2InBuff <= 0;
            bram2InBuffByteSwitch <= 8;
            bram2InCount <= 6;

            /* ctrl
            */
            computeInFinish <= 0;
        end

    end

end

///////////////////
////* compute *////
///////////////////

// buffer
reg [247:0] computeExeBuffer1 = 0;
reg [247:0] computeExeBuffer2 = 0;
reg [247:0] computeExeBuffer3 = 0;
reg [247:0] computeExeBuffer4 = 0;
reg [247:0] computeExeBuffer5 = 0;
reg [247:0] computeExeBuffer6 = 0;
reg [247:0] computeExeBuffer7 = 0;
reg [247:0] computeExeBuffer8 = 0;

reg [247:0] computeExeBuffer9  = 0;
reg [247:0] computeExeBuffer10 = 0;
reg [247:0] computeExeBuffer11 = 0;
reg [247:0] computeExeBuffer12 = 0;
reg [247:0] computeExeBuffer13 = 0;
reg [247:0] computeExeBuffer14 = 0;
reg [247:0] computeExeBuffer15 = 0;
reg [247:0] computeExeBuffer16 = 0;

reg [247:0] computeExeBuffer17 = 0;
reg [247:0] computeExeBuffer18 = 0;
reg [247:0] computeExeBuffer19 = 0;
reg [247:0] computeExeBuffer20 = 0;
reg [247:0] computeExeBuffer21 = 0;
reg [247:0] computeExeBuffer22 = 0;
reg [247:0] computeExeBuffer23 = 0;
reg [247:0] computeExeBuffer24 = 0;

reg [247:0] computeExeBuffer25 = 0;
reg [247:0] computeExeBuffer26 = 0;
reg [247:0] computeExeBuffer27 = 0;
reg [247:0] computeExeBuffer28 = 0;
reg [247:0] computeExeBuffer29 = 0;
reg [247:0] computeExeBuffer30 = 0;
reg [247:0] computeExeBuffer31 = 0;
reg [247:0] computeExeBuffer32 = 0;

reg [247:0] computeExeBuffer33 = 0;
reg [247:0] computeExeBuffer34 = 0;
reg [247:0] computeExeBuffer35 = 0;
reg [247:0] computeExeBuffer36 = 0;
reg [247:0] computeExeBuffer37 = 0;
reg [247:0] computeExeBuffer38 = 0;
reg [247:0] computeExeBuffer39 = 0;
reg [247:0] computeExeBuffer40 = 0;

reg [127:0] fastResultBuff0 = 0;
reg [127:0] fastResultBuff1 = 0;
reg [127:0] fastResultBuff2 = 0;
reg [127:0] fastResultBuff3 = 0;
reg [127:0] fastResultBuff4 = 0;
reg [127:0] fastResultBuff5 = 0;
reg [127:0] fastResultBuff6 = 0;
reg [127:0] fastResultBuff7 = 0;
reg [127:0] fastResultBuff8 = 0;
reg [127:0] fastResultBuff9 = 0;

/* non-maximum suppression
 */
reg [7:0] nmsLineMax[0:9];

reg computeExeBufferValid       = 0;
reg [15:0] computeValidCount    = 0;
reg [3:0] computeExeBufferDelay = 0;

/* buffer ctrl
 */
always @(posedge clk)
begin
    if(rst || rstIn)
    begin
		computeExeBuffer1 <= 0;
		computeExeBuffer2 <= 0;
		computeExeBuffer3 <= 0;
		computeExeBuffer4 <= 0;
		computeExeBuffer5 <= 0;
		computeExeBuffer6 <= 0;
		computeExeBuffer7 <= 0;
		computeExeBuffer8 <= 0;
		
		computeExeBuffer9  <= 0;
		computeExeBuffer10 <= 0;
		computeExeBuffer11 <= 0;
		computeExeBuffer12 <= 0;
		computeExeBuffer13 <= 0;
		computeExeBuffer14 <= 0;
		computeExeBuffer15 <= 0;
		computeExeBuffer16 <= 0;
		
		computeExeBuffer17 <= 0;
		computeExeBuffer18 <= 0;
		computeExeBuffer19 <= 0;
		computeExeBuffer20 <= 0;
		computeExeBuffer21 <= 0;
		computeExeBuffer22 <= 0;
		computeExeBuffer23 <= 0;
		computeExeBuffer24 <= 0;
		
		computeExeBuffer25 <= 0;
		computeExeBuffer26 <= 0;
		computeExeBuffer27 <= 0;
		computeExeBuffer28 <= 0;
		computeExeBuffer29 <= 0;
		computeExeBuffer30 <= 0;
		computeExeBuffer31 <= 0;
		computeExeBuffer32 <= 0;
		
		computeExeBuffer33 <= 0;
		computeExeBuffer34 <= 0;
		computeExeBuffer35 <= 0;
		computeExeBuffer36 <= 0;
		computeExeBuffer37 <= 0;
		computeExeBuffer38 <= 0;
		computeExeBuffer39 <= 0;
		computeExeBuffer40 <= 0;

        fastResultBuff0 <= 0;
        fastResultBuff1 <= 0;
        fastResultBuff2 <= 0;
        fastResultBuff3 <= 0;
        fastResultBuff4 <= 0;
        fastResultBuff5 <= 0;
        fastResultBuff6 <= 0;
        fastResultBuff7 <= 0;
        fastResultBuff8 <= 0;
        fastResultBuff9 <= 0;
		
		
        computeExeBufferValid <= 0;
        computeValidCount <= 0;
        computeExeBufferDelay <= 0;

        nmsLineMax[0] <= 0;
        nmsLineMax[1] <= 0;
        nmsLineMax[2] <= 0;
        nmsLineMax[3] <= 0;
        nmsLineMax[4] <= 0;
        nmsLineMax[5] <= 0;
        nmsLineMax[6] <= 0;
        nmsLineMax[7] <= 0;
        nmsLineMax[8] <= 0;
        nmsLineMax[9] <= 0;
    end

    else if(computeState == COMPUTE_EXE || computeState == COMPUTE_LAST_EXE)
    begin
        /*  valid gen
         */
        case (bram2Switch)
            1:
			begin
				if (bramValid2_2)
					computeValidCount <= computeValidCount + 1;
				computeExeBufferValid <= bramValid2_2 & computeValidCount >= 30;
			end
			2:
			begin
				if (bramValid2_3)
					computeValidCount <= computeValidCount + 1;
				computeExeBufferValid <= bramValid2_3 & computeValidCount >= 30;
			end
			3:
			begin
				if (bramValid2_4)
					computeValidCount <= computeValidCount + 1;
				computeExeBufferValid <= bramValid2_4 & computeValidCount >= 30;
			end
			4:
			begin
				if (bramValid2_5)
					computeValidCount <= computeValidCount + 1;
				computeExeBufferValid <= bramValid2_5 & computeValidCount >= 30;
			end
			5:
			begin
				if (bramValid2_6)
					computeValidCount <= computeValidCount + 1;
				computeExeBufferValid <= bramValid2_6 & computeValidCount >= 30;
			end
			6:
			begin
				if (bramValid2_1)
					computeValidCount <= computeValidCount + 1;
				computeExeBufferValid <= bramValid2_1 & computeValidCount >= 30;
			end
			
            default: 
            begin
                computeExeBufferValid <= 0;
            end
        endcase
		
        /*  buffer shift
         */
        if(computeValidCount <= 30 || computeExeBufferDelay == 7)
        begin
        /* fill buffer, every 1 period shift 1
         */
            computeExeBuffer1[247:8] <= computeExeBuffer1[239:0];
			computeExeBuffer2[247:8] <= computeExeBuffer2[239:0];
			computeExeBuffer3[247:8] <= computeExeBuffer3[239:0];
			computeExeBuffer4[247:8] <= computeExeBuffer4[239:0];
			computeExeBuffer5[247:8] <= computeExeBuffer5[239:0];
			computeExeBuffer6[247:8] <= computeExeBuffer6[239:0];
			computeExeBuffer7[247:8] <= computeExeBuffer7[239:0];
			computeExeBuffer8[247:8] <= computeExeBuffer8[239:0];
			
			computeExeBuffer9[247:8]  <= computeExeBuffer9[239:0];
			computeExeBuffer10[247:8] <= computeExeBuffer10[239:0];
			computeExeBuffer11[247:8] <= computeExeBuffer11[239:0];
			computeExeBuffer12[247:8] <= computeExeBuffer12[239:0];
			computeExeBuffer13[247:8] <= computeExeBuffer13[239:0];
			computeExeBuffer14[247:8] <= computeExeBuffer14[239:0];
			computeExeBuffer15[247:8] <= computeExeBuffer15[239:0];
			computeExeBuffer16[247:8] <= computeExeBuffer16[239:0];
			
			computeExeBuffer17[247:8] <= computeExeBuffer17[239:0]; 
			computeExeBuffer18[247:8] <= computeExeBuffer18[239:0]; 
			computeExeBuffer19[247:8] <= computeExeBuffer19[239:0]; 
			computeExeBuffer20[247:8] <= computeExeBuffer20[239:0]; 
			computeExeBuffer21[247:8] <= computeExeBuffer21[239:0]; 
			computeExeBuffer22[247:8] <= computeExeBuffer22[239:0]; 
			computeExeBuffer23[247:8] <= computeExeBuffer23[239:0]; 
			computeExeBuffer24[247:8] <= computeExeBuffer24[239:0]; 
			
			computeExeBuffer25[247:8] <= computeExeBuffer25[239:0]; 
			computeExeBuffer26[247:8] <= computeExeBuffer26[239:0]; 
			computeExeBuffer27[247:8] <= computeExeBuffer27[239:0]; 
			computeExeBuffer28[247:8] <= computeExeBuffer28[239:0]; 
			computeExeBuffer29[247:8] <= computeExeBuffer29[239:0]; 
			computeExeBuffer30[247:8] <= computeExeBuffer30[239:0]; 
			computeExeBuffer31[247:8] <= computeExeBuffer31[239:0]; 
			computeExeBuffer32[247:8] <= computeExeBuffer32[239:0]; 
			
			computeExeBuffer33[247:8] <= computeExeBuffer33[239:0]; 
			computeExeBuffer34[247:8] <= computeExeBuffer34[239:0]; 
			computeExeBuffer35[247:8] <= computeExeBuffer35[239:0]; 
			computeExeBuffer36[247:8] <= computeExeBuffer36[239:0]; 
			computeExeBuffer37[247:8] <= computeExeBuffer37[239:0]; 
			computeExeBuffer38[247:8] <= computeExeBuffer38[239:0]; 
			computeExeBuffer39[247:8] <= computeExeBuffer39[239:0]; 
			computeExeBuffer40[247:8] <= computeExeBuffer40[239:0]; 

            fastResultBuff0[127:32] <= fastResultBuff0[119:24];
            fastResultBuff1[127:32] <= fastResultBuff1[119:24];
            fastResultBuff2[127:32] <= fastResultBuff2[119:24];
            fastResultBuff3[127:32] <= fastResultBuff3[119:24];
            fastResultBuff4[127:32] <= fastResultBuff4[119:24];
            fastResultBuff5[127:32] <= fastResultBuff5[119:24];
            fastResultBuff6[127:32] <= fastResultBuff6[119:24];
            fastResultBuff7[127:32] <= fastResultBuff7[119:24];
            fastResultBuff8[127:32] <= fastResultBuff8[119:24];
            fastResultBuff9[127:32] <= fastResultBuff9[119:24];
            
            fastResultBuff0[31:8] <= fastResultBuff0[23:0];
            fastResultBuff1[23:8] <= fastResultBuff1[15:0];
            fastResultBuff2[23:8] <= fastResultBuff2[15:0];
            fastResultBuff3[23:8] <= fastResultBuff3[15:0];
            fastResultBuff4[23:8] <= fastResultBuff4[15:0];
            fastResultBuff5[23:8] <= fastResultBuff5[15:0];
            fastResultBuff6[23:8] <= fastResultBuff6[15:0];
            fastResultBuff7[23:8] <= fastResultBuff7[15:0];
            fastResultBuff8[23:8] <= fastResultBuff8[15:0];
            fastResultBuff9[31:8] <= fastResultBuff9[23:0];

            /* non maximum suppression
             */
            nmsLineMax[0] <= (fastResultBuff0[7:0] >= fastResultBuff0[15:8] && fastResultBuff0[7:0] >= fastResultBuff0[23:16]) ? fastResultBuff0[7:0] :
                                (fastResultBuff0[15:8] >= fastResultBuff0[7:0] && fastResultBuff0[15:8] >= fastResultBuff0[23:16]) ? fastResultBuff0[15:8] :
                                fastResultBuff0[23:16];
            nmsLineMax[1] <= (fastResultBuff1[7:0] >= fastResultBuff1[15:8] && fastResultBuff1[7:0] >= fastResultBuff1[23:16]) ? fastResultBuff1[7:0] :
                                (fastResultBuff1[15:8] >= fastResultBuff1[7:0] && fastResultBuff1[15:8] >= fastResultBuff1[23:16]) ? fastResultBuff1[15:8] :
                                fastResultBuff1[23:16];
            nmsLineMax[2] <= (fastResultBuff2[7:0] >= fastResultBuff2[15:8] && fastResultBuff2[7:0] >= fastResultBuff2[23:16]) ? fastResultBuff2[7:0] :
                                (fastResultBuff2[15:8] >= fastResultBuff2[7:0] && fastResultBuff2[15:8] >= fastResultBuff2[23:16]) ? fastResultBuff2[15:8] :
                                fastResultBuff2[23:16];
            nmsLineMax[3] <= (fastResultBuff3[7:0] >= fastResultBuff3[15:8] && fastResultBuff3[7:0] >= fastResultBuff3[23:16]) ? fastResultBuff3[7:0] :
                                (fastResultBuff3[15:8] >= fastResultBuff3[7:0] && fastResultBuff3[15:8] >= fastResultBuff3[23:16]) ? fastResultBuff3[15:8] :
                                fastResultBuff3[23:16];
            nmsLineMax[4] <= (fastResultBuff4[7:0] >= fastResultBuff4[15:8] && fastResultBuff4[7:0] >= fastResultBuff4[23:16]) ? fastResultBuff4[7:0] :
                                (fastResultBuff4[15:8] >= fastResultBuff4[7:0] && fastResultBuff4[15:8] >= fastResultBuff4[23:16]) ? fastResultBuff4[15:8] :
                                fastResultBuff4[23:16];
            nmsLineMax[5] <= (fastResultBuff5[7:0] >= fastResultBuff5[15:8] && fastResultBuff5[7:0] >= fastResultBuff5[23:16]) ? fastResultBuff5[7:0] :
                                (fastResultBuff5[15:8] >= fastResultBuff5[7:0] && fastResultBuff5[15:8] >= fastResultBuff5[23:16]) ? fastResultBuff5[15:8] :
                                fastResultBuff5[23:16];
            nmsLineMax[6] <= (fastResultBuff6[7:0] >= fastResultBuff6[15:8] && fastResultBuff6[7:0] >= fastResultBuff6[23:16]) ? fastResultBuff6[7:0] :
                                (fastResultBuff6[15:8] >= fastResultBuff6[7:0] && fastResultBuff6[15:8] >= fastResultBuff6[23:16]) ? fastResultBuff6[15:8] :
                                fastResultBuff6[23:16];
            nmsLineMax[7] <= (fastResultBuff7[7:0] >= fastResultBuff7[15:8] && fastResultBuff7[7:0] >= fastResultBuff7[23:16]) ? fastResultBuff7[7:0] :
                                (fastResultBuff7[15:8] >= fastResultBuff7[7:0] && fastResultBuff7[15:8] >= fastResultBuff7[23:16]) ? fastResultBuff7[15:8] :
                                fastResultBuff7[23:16];
            nmsLineMax[8] <= (fastResultBuff8[7:0] >= fastResultBuff8[15:8] && fastResultBuff8[7:0] >= fastResultBuff8[23:16]) ? fastResultBuff8[7:0] :
                                (fastResultBuff8[15:8] >= fastResultBuff8[7:0] && fastResultBuff8[15:8] >= fastResultBuff8[23:16]) ? fastResultBuff8[15:8] :
                                fastResultBuff8[23:16];
            nmsLineMax[9] <= (fastResultBuff9[7:0] >= fastResultBuff9[15:8] && fastResultBuff9[7:0] >= fastResultBuff9[23:16]) ? fastResultBuff9[7:0] :
                                (fastResultBuff9[15:8] >= fastResultBuff9[7:0] && fastResultBuff9[15:8] >= fastResultBuff9[23:16]) ? fastResultBuff9[15:8] :
                                fastResultBuff9[23:16];
            if(fastResultBuff1[23:16] >= nmsLineMax[0] && fastResultBuff1[23:16] >= nmsLineMax[1] && fastResultBuff1[23:16] >= nmsLineMax[2])
                fastResultBuff1[31:24] <= fastResultBuff1[23:16];
            else fastResultBuff1[31:24] <= 0;
            if(fastResultBuff2[23:16] >= nmsLineMax[1] && fastResultBuff2[23:16] >= nmsLineMax[2] && fastResultBuff2[23:16] >= nmsLineMax[3])
                fastResultBuff2[31:24] <= fastResultBuff2[23:16];
            else fastResultBuff2[31:24] <= 0;
            if(fastResultBuff3[23:16] >= nmsLineMax[2] && fastResultBuff3[23:16] >= nmsLineMax[3] && fastResultBuff3[23:16] >= nmsLineMax[4])
                fastResultBuff3[31:24] <= fastResultBuff3[23:16];
            else fastResultBuff3[31:24] <= 0;
            if(fastResultBuff4[23:16] >= nmsLineMax[3] && fastResultBuff4[23:16] >= nmsLineMax[4] && fastResultBuff4[23:16] >= nmsLineMax[5])
                fastResultBuff4[31:24] <= fastResultBuff4[23:16];
            else fastResultBuff4[31:24] <= 0;
            if(fastResultBuff5[23:16] >= nmsLineMax[4] && fastResultBuff5[23:16] >= nmsLineMax[5] && fastResultBuff5[23:16] >= nmsLineMax[6])
                fastResultBuff5[31:24] <= fastResultBuff5[23:16];
            else fastResultBuff5[31:24] <= 0;
            if(fastResultBuff6[23:16] >= nmsLineMax[5] && fastResultBuff6[23:16] >= nmsLineMax[6] && fastResultBuff6[23:16] >= nmsLineMax[7])
                fastResultBuff6[31:24] <= fastResultBuff6[23:16];
            else fastResultBuff6[31:24] <= 0;
            if(fastResultBuff7[23:16] >= nmsLineMax[6] && fastResultBuff7[23:16] >= nmsLineMax[7] && fastResultBuff7[23:16] >= nmsLineMax[8])
                fastResultBuff7[31:24] <= fastResultBuff7[23:16];
            else fastResultBuff7[31:24] <= 0;
            if(fastResultBuff8[23:16] >= nmsLineMax[7] && fastResultBuff8[23:16] >= nmsLineMax[8] && fastResultBuff8[23:16] >= nmsLineMax[9])
                fastResultBuff8[31:24] <= fastResultBuff8[23:16];
            else fastResultBuff8[31:24] <= 0;

            case (bram2Switch)
                1: 
                begin
                    computeExeBuffer1[7:0] <= bramOut2_2[7 :0 ];
                    computeExeBuffer2[7:0] <= bramOut2_2[15:8 ];
                    computeExeBuffer3[7:0] <= bramOut2_2[23:16];
                    computeExeBuffer4[7:0] <= bramOut2_2[31:24];
                    computeExeBuffer5[7:0] <= bramOut2_2[39:32];
                    computeExeBuffer6[7:0] <= bramOut2_2[47:40];
                    computeExeBuffer7[7:0] <= bramOut2_2[55:48];
                    computeExeBuffer8[7:0] <= bramOut2_2[63:56];
			
					computeExeBuffer9[7:0]  <= bramOut2_3[7 :0 ];
					computeExeBuffer10[7:0] <= bramOut2_3[15:8 ];
					computeExeBuffer11[7:0] <= bramOut2_3[23:16];
					computeExeBuffer12[7:0] <= bramOut2_3[31:24];
					computeExeBuffer13[7:0] <= bramOut2_3[39:32];
					computeExeBuffer14[7:0] <= bramOut2_3[47:40];
					computeExeBuffer15[7:0] <= bramOut2_3[55:48];
					computeExeBuffer16[7:0] <= bramOut2_3[63:56];
					
                    computeExeBuffer17[7:0] <= bramOut2_4[7 :0 ];
                    computeExeBuffer18[7:0] <= bramOut2_4[15:8 ];
                    computeExeBuffer19[7:0] <= bramOut2_4[23:16];
                    computeExeBuffer20[7:0] <= bramOut2_4[31:24];
                    computeExeBuffer21[7:0] <= bramOut2_4[39:32];
                    computeExeBuffer22[7:0] <= bramOut2_4[47:40];
                    computeExeBuffer23[7:0] <= bramOut2_4[55:48];
                    computeExeBuffer24[7:0] <= bramOut2_4[63:56];
					
                    computeExeBuffer25[7:0] <= bramOut2_5[7 :0 ];
                    computeExeBuffer26[7:0] <= bramOut2_5[15:8 ];
                    computeExeBuffer27[7:0] <= bramOut2_5[23:16];
                    computeExeBuffer28[7:0] <= bramOut2_5[31:24];
                    computeExeBuffer29[7:0] <= bramOut2_5[39:32];
                    computeExeBuffer30[7:0] <= bramOut2_5[47:40];
                    computeExeBuffer31[7:0] <= bramOut2_5[55:48];
                    computeExeBuffer32[7:0] <= bramOut2_5[63:56];
					
                    computeExeBuffer33[7:0] <= bramOut2_6[7 :0 ];
                    computeExeBuffer34[7:0] <= bramOut2_6[15:8 ];
                    computeExeBuffer35[7:0] <= bramOut2_6[23:16];
                    computeExeBuffer36[7:0] <= bramOut2_6[31:24];
                    computeExeBuffer37[7:0] <= bramOut2_6[39:32];
                    computeExeBuffer38[7:0] <= bramOut2_6[47:40];
                    computeExeBuffer39[7:0] <= bramOut2_6[55:48];
                    computeExeBuffer40[7:0] <= bramOut2_6[63:56];

                    fastResultBuff0[7:0] <= bramOutFast2_4[7 :0 ];
                    fastResultBuff1[7:0] <= bramOutFast2_4[15:8 ];
                    fastResultBuff2[7:0] <= bramOutFast2_4[23:16];
                    fastResultBuff3[7:0] <= bramOutFast2_4[31:24];
                    fastResultBuff4[7:0] <= bramOutFast2_4[39:32];
                    fastResultBuff5[7:0] <= bramOutFast2_4[47:40];
                    fastResultBuff6[7:0] <= bramOutFast2_4[55:48];
                    fastResultBuff7[7:0] <= bramOutFast2_4[63:56];
                    fastResultBuff8[7:0] <= bramOutFast2_5[7 :0 ];
                    fastResultBuff9[7:0] <= bramOutFast2_5[15:8 ];
                end
                2: 
                begin
                    computeExeBuffer1[7:0] <= bramOut2_3[7 :0 ];
                    computeExeBuffer2[7:0] <= bramOut2_3[15:8 ];
                    computeExeBuffer3[7:0] <= bramOut2_3[23:16];
                    computeExeBuffer4[7:0] <= bramOut2_3[31:24];
                    computeExeBuffer5[7:0] <= bramOut2_3[39:32];
                    computeExeBuffer6[7:0] <= bramOut2_3[47:40];
                    computeExeBuffer7[7:0] <= bramOut2_3[55:48];
                    computeExeBuffer8[7:0] <= bramOut2_3[63:56];
			
					computeExeBuffer9[7:0]  <= bramOut2_4[7 :0 ];
					computeExeBuffer10[7:0] <= bramOut2_4[15:8 ];
					computeExeBuffer11[7:0] <= bramOut2_4[23:16];
					computeExeBuffer12[7:0] <= bramOut2_4[31:24];
					computeExeBuffer13[7:0] <= bramOut2_4[39:32];
					computeExeBuffer14[7:0] <= bramOut2_4[47:40];
					computeExeBuffer15[7:0] <= bramOut2_4[55:48];
					computeExeBuffer16[7:0] <= bramOut2_4[63:56];
					
                    computeExeBuffer17[7:0] <= bramOut2_5[7 :0 ];
                    computeExeBuffer18[7:0] <= bramOut2_5[15:8 ];
                    computeExeBuffer19[7:0] <= bramOut2_5[23:16];
                    computeExeBuffer20[7:0] <= bramOut2_5[31:24];
                    computeExeBuffer21[7:0] <= bramOut2_5[39:32];
                    computeExeBuffer22[7:0] <= bramOut2_5[47:40];
                    computeExeBuffer23[7:0] <= bramOut2_5[55:48];
                    computeExeBuffer24[7:0] <= bramOut2_5[63:56];
					
                    computeExeBuffer25[7:0] <= bramOut2_6[7 :0 ];
                    computeExeBuffer26[7:0] <= bramOut2_6[15:8 ];
                    computeExeBuffer27[7:0] <= bramOut2_6[23:16];
                    computeExeBuffer28[7:0] <= bramOut2_6[31:24];
                    computeExeBuffer29[7:0] <= bramOut2_6[39:32];
                    computeExeBuffer30[7:0] <= bramOut2_6[47:40];
                    computeExeBuffer31[7:0] <= bramOut2_6[55:48];
                    computeExeBuffer32[7:0] <= bramOut2_6[63:56];
					
                    computeExeBuffer33[7:0] <= bramOut2_1[7 :0 ];
                    computeExeBuffer34[7:0] <= bramOut2_1[15:8 ];
                    computeExeBuffer35[7:0] <= bramOut2_1[23:16];
                    computeExeBuffer36[7:0] <= bramOut2_1[31:24];
                    computeExeBuffer37[7:0] <= bramOut2_1[39:32];
                    computeExeBuffer38[7:0] <= bramOut2_1[47:40];
                    computeExeBuffer39[7:0] <= bramOut2_1[55:48];
                    computeExeBuffer40[7:0] <= bramOut2_1[63:56];

                    fastResultBuff0[7:0] <= bramOutFast2_5[7 :0 ];
                    fastResultBuff1[7:0] <= bramOutFast2_5[15:8 ];
                    fastResultBuff2[7:0] <= bramOutFast2_5[23:16];
                    fastResultBuff3[7:0] <= bramOutFast2_5[31:24];
                    fastResultBuff4[7:0] <= bramOutFast2_5[39:32];
                    fastResultBuff5[7:0] <= bramOutFast2_5[47:40];
                    fastResultBuff6[7:0] <= bramOutFast2_5[55:48];
                    fastResultBuff7[7:0] <= bramOutFast2_5[63:56];
                    fastResultBuff8[7:0] <= bramOutFast2_6[7 :0 ];
                    fastResultBuff9[7:0] <= bramOutFast2_6[15:8 ];
                end
                3: 
                begin
                    computeExeBuffer1[7:0] <= bramOut2_4[7 :0 ];
                    computeExeBuffer2[7:0] <= bramOut2_4[15:8 ];
                    computeExeBuffer3[7:0] <= bramOut2_4[23:16];
                    computeExeBuffer4[7:0] <= bramOut2_4[31:24];
                    computeExeBuffer5[7:0] <= bramOut2_4[39:32];
                    computeExeBuffer6[7:0] <= bramOut2_4[47:40];
                    computeExeBuffer7[7:0] <= bramOut2_4[55:48];
                    computeExeBuffer8[7:0] <= bramOut2_4[63:56];
			
					computeExeBuffer9[7:0]  <= bramOut2_5[7 :0 ];
					computeExeBuffer10[7:0] <= bramOut2_5[15:8 ];
					computeExeBuffer11[7:0] <= bramOut2_5[23:16];
					computeExeBuffer12[7:0] <= bramOut2_5[31:24];
					computeExeBuffer13[7:0] <= bramOut2_5[39:32];
					computeExeBuffer14[7:0] <= bramOut2_5[47:40];
					computeExeBuffer15[7:0] <= bramOut2_5[55:48];
					computeExeBuffer16[7:0] <= bramOut2_5[63:56];
					
                    computeExeBuffer17[7:0] <= bramOut2_6[7 :0 ];
                    computeExeBuffer18[7:0] <= bramOut2_6[15:8 ];
                    computeExeBuffer19[7:0] <= bramOut2_6[23:16];
                    computeExeBuffer20[7:0] <= bramOut2_6[31:24];
                    computeExeBuffer21[7:0] <= bramOut2_6[39:32];
                    computeExeBuffer22[7:0] <= bramOut2_6[47:40];
                    computeExeBuffer23[7:0] <= bramOut2_6[55:48];
                    computeExeBuffer24[7:0] <= bramOut2_6[63:56];
					
                    computeExeBuffer25[7:0] <= bramOut2_1[7 :0 ];
                    computeExeBuffer26[7:0] <= bramOut2_1[15:8 ];
                    computeExeBuffer27[7:0] <= bramOut2_1[23:16];
                    computeExeBuffer28[7:0] <= bramOut2_1[31:24];
                    computeExeBuffer29[7:0] <= bramOut2_1[39:32];
                    computeExeBuffer30[7:0] <= bramOut2_1[47:40];
                    computeExeBuffer31[7:0] <= bramOut2_1[55:48];
                    computeExeBuffer32[7:0] <= bramOut2_1[63:56];
					
                    computeExeBuffer33[7:0] <= bramOut2_2[7 :0 ];
                    computeExeBuffer34[7:0] <= bramOut2_2[15:8 ];
                    computeExeBuffer35[7:0] <= bramOut2_2[23:16];
                    computeExeBuffer36[7:0] <= bramOut2_2[31:24];
                    computeExeBuffer37[7:0] <= bramOut2_2[39:32];
                    computeExeBuffer38[7:0] <= bramOut2_2[47:40];
                    computeExeBuffer39[7:0] <= bramOut2_2[55:48];
                    computeExeBuffer40[7:0] <= bramOut2_2[63:56];

                    fastResultBuff0[7:0] <= bramOutFast2_6[7 :0 ];
                    fastResultBuff1[7:0] <= bramOutFast2_6[15:8 ];
                    fastResultBuff2[7:0] <= bramOutFast2_6[23:16];
                    fastResultBuff3[7:0] <= bramOutFast2_6[31:24];
                    fastResultBuff4[7:0] <= bramOutFast2_6[39:32];
                    fastResultBuff5[7:0] <= bramOutFast2_6[47:40];
                    fastResultBuff6[7:0] <= bramOutFast2_6[55:48];
                    fastResultBuff7[7:0] <= bramOutFast2_6[63:56];
                    fastResultBuff8[7:0] <= bramOutFast2_1[7 :0 ];
                    fastResultBuff9[7:0] <= bramOutFast2_1[15:8 ];
                end
                4: 
                begin
                    computeExeBuffer1[7:0] <= bramOut2_5[7 :0 ];
                    computeExeBuffer2[7:0] <= bramOut2_5[15:8 ];
                    computeExeBuffer3[7:0] <= bramOut2_5[23:16];
                    computeExeBuffer4[7:0] <= bramOut2_5[31:24];
                    computeExeBuffer5[7:0] <= bramOut2_5[39:32];
                    computeExeBuffer6[7:0] <= bramOut2_5[47:40];
                    computeExeBuffer7[7:0] <= bramOut2_5[55:48];
                    computeExeBuffer8[7:0] <= bramOut2_5[63:56];
			
					computeExeBuffer9[7:0]  <= bramOut2_6[7 :0 ];
					computeExeBuffer10[7:0] <= bramOut2_6[15:8 ];
					computeExeBuffer11[7:0] <= bramOut2_6[23:16];
					computeExeBuffer12[7:0] <= bramOut2_6[31:24];
					computeExeBuffer13[7:0] <= bramOut2_6[39:32];
					computeExeBuffer14[7:0] <= bramOut2_6[47:40];
					computeExeBuffer15[7:0] <= bramOut2_6[55:48];
					computeExeBuffer16[7:0] <= bramOut2_6[63:56];
					
                    computeExeBuffer17[7:0] <= bramOut2_1[7 :0 ];
                    computeExeBuffer18[7:0] <= bramOut2_1[15:8 ];
                    computeExeBuffer19[7:0] <= bramOut2_1[23:16];
                    computeExeBuffer20[7:0] <= bramOut2_1[31:24];
                    computeExeBuffer21[7:0] <= bramOut2_1[39:32];
                    computeExeBuffer22[7:0] <= bramOut2_1[47:40];
                    computeExeBuffer23[7:0] <= bramOut2_1[55:48];
                    computeExeBuffer24[7:0] <= bramOut2_1[63:56];
					
                    computeExeBuffer25[7:0] <= bramOut2_2[7 :0 ];
                    computeExeBuffer26[7:0] <= bramOut2_2[15:8 ];
                    computeExeBuffer27[7:0] <= bramOut2_2[23:16];
                    computeExeBuffer28[7:0] <= bramOut2_2[31:24];
                    computeExeBuffer29[7:0] <= bramOut2_2[39:32];
                    computeExeBuffer30[7:0] <= bramOut2_2[47:40];
                    computeExeBuffer31[7:0] <= bramOut2_2[55:48];
                    computeExeBuffer32[7:0] <= bramOut2_2[63:56];
					
                    computeExeBuffer33[7:0] <= bramOut2_3[7 :0 ];
                    computeExeBuffer34[7:0] <= bramOut2_3[15:8 ];
                    computeExeBuffer35[7:0] <= bramOut2_3[23:16];
                    computeExeBuffer36[7:0] <= bramOut2_3[31:24];
                    computeExeBuffer37[7:0] <= bramOut2_3[39:32];
                    computeExeBuffer38[7:0] <= bramOut2_3[47:40];
                    computeExeBuffer39[7:0] <= bramOut2_3[55:48];
                    computeExeBuffer40[7:0] <= bramOut2_3[63:56];

                    fastResultBuff0[7:0] <= bramOutFast2_1[7 :0 ];
                    fastResultBuff1[7:0] <= bramOutFast2_1[15:8 ];
                    fastResultBuff2[7:0] <= bramOutFast2_1[23:16];
                    fastResultBuff3[7:0] <= bramOutFast2_1[31:24];
                    fastResultBuff4[7:0] <= bramOutFast2_1[39:32];
                    fastResultBuff5[7:0] <= bramOutFast2_1[47:40];
                    fastResultBuff6[7:0] <= bramOutFast2_1[55:48];
                    fastResultBuff7[7:0] <= bramOutFast2_1[63:56];
                    fastResultBuff8[7:0] <= bramOutFast2_2[7 :0 ];
                    fastResultBuff9[7:0] <= bramOutFast2_2[15:8 ];
                end
                5: 
                begin
                    computeExeBuffer1[7:0] <= bramOut2_6[7 :0 ];
                    computeExeBuffer2[7:0] <= bramOut2_6[15:8 ];
                    computeExeBuffer3[7:0] <= bramOut2_6[23:16];
                    computeExeBuffer4[7:0] <= bramOut2_6[31:24];
                    computeExeBuffer5[7:0] <= bramOut2_6[39:32];
                    computeExeBuffer6[7:0] <= bramOut2_6[47:40];
                    computeExeBuffer7[7:0] <= bramOut2_6[55:48];
                    computeExeBuffer8[7:0] <= bramOut2_6[63:56];
			
					computeExeBuffer9[7:0]  <= bramOut2_1[7 :0 ];
					computeExeBuffer10[7:0] <= bramOut2_1[15:8 ];
					computeExeBuffer11[7:0] <= bramOut2_1[23:16];
					computeExeBuffer12[7:0] <= bramOut2_1[31:24];
					computeExeBuffer13[7:0] <= bramOut2_1[39:32];
					computeExeBuffer14[7:0] <= bramOut2_1[47:40];
					computeExeBuffer15[7:0] <= bramOut2_1[55:48];
					computeExeBuffer16[7:0] <= bramOut2_1[63:56];
					
                    computeExeBuffer17[7:0] <= bramOut2_2[7 :0 ];
                    computeExeBuffer18[7:0] <= bramOut2_2[15:8 ];
                    computeExeBuffer19[7:0] <= bramOut2_2[23:16];
                    computeExeBuffer20[7:0] <= bramOut2_2[31:24];
                    computeExeBuffer21[7:0] <= bramOut2_2[39:32];
                    computeExeBuffer22[7:0] <= bramOut2_2[47:40];
                    computeExeBuffer23[7:0] <= bramOut2_2[55:48];
                    computeExeBuffer24[7:0] <= bramOut2_2[63:56];
					
                    computeExeBuffer25[7:0] <= bramOut2_3[7 :0 ];
                    computeExeBuffer26[7:0] <= bramOut2_3[15:8 ];
                    computeExeBuffer27[7:0] <= bramOut2_3[23:16];
                    computeExeBuffer28[7:0] <= bramOut2_3[31:24];
                    computeExeBuffer29[7:0] <= bramOut2_3[39:32];
                    computeExeBuffer30[7:0] <= bramOut2_3[47:40];
                    computeExeBuffer31[7:0] <= bramOut2_3[55:48];
                    computeExeBuffer32[7:0] <= bramOut2_3[63:56];
					
                    computeExeBuffer33[7:0] <= bramOut2_4[7 :0 ];
                    computeExeBuffer34[7:0] <= bramOut2_4[15:8 ];
                    computeExeBuffer35[7:0] <= bramOut2_4[23:16];
                    computeExeBuffer36[7:0] <= bramOut2_4[31:24];
                    computeExeBuffer37[7:0] <= bramOut2_4[39:32];
                    computeExeBuffer38[7:0] <= bramOut2_4[47:40];
                    computeExeBuffer39[7:0] <= bramOut2_4[55:48];
                    computeExeBuffer40[7:0] <= bramOut2_4[63:56];

                    fastResultBuff0[7:0] <= bramOutFast2_2[7 :0 ];
                    fastResultBuff1[7:0] <= bramOutFast2_2[15:8 ];
                    fastResultBuff2[7:0] <= bramOutFast2_2[23:16];
                    fastResultBuff3[7:0] <= bramOutFast2_2[31:24];
                    fastResultBuff4[7:0] <= bramOutFast2_2[39:32];
                    fastResultBuff5[7:0] <= bramOutFast2_2[47:40];
                    fastResultBuff6[7:0] <= bramOutFast2_2[55:48];
                    fastResultBuff7[7:0] <= bramOutFast2_2[63:56];
                    fastResultBuff8[7:0] <= bramOutFast2_3[7 :0 ];
                    fastResultBuff9[7:0] <= bramOutFast2_3[15:8 ];
                end
                6: 
                begin
                    computeExeBuffer1[7:0] <= bramOut2_1[7 :0 ];
                    computeExeBuffer2[7:0] <= bramOut2_1[15:8 ];
                    computeExeBuffer3[7:0] <= bramOut2_1[23:16];
                    computeExeBuffer4[7:0] <= bramOut2_1[31:24];
                    computeExeBuffer5[7:0] <= bramOut2_1[39:32];
                    computeExeBuffer6[7:0] <= bramOut2_1[47:40];
                    computeExeBuffer7[7:0] <= bramOut2_1[55:48];
                    computeExeBuffer8[7:0] <= bramOut2_1[63:56];
			
					computeExeBuffer9[7:0]  <= bramOut2_2[7 :0 ];
					computeExeBuffer10[7:0] <= bramOut2_2[15:8 ];
					computeExeBuffer11[7:0] <= bramOut2_2[23:16];
					computeExeBuffer12[7:0] <= bramOut2_2[31:24];
					computeExeBuffer13[7:0] <= bramOut2_2[39:32];
					computeExeBuffer14[7:0] <= bramOut2_2[47:40];
					computeExeBuffer15[7:0] <= bramOut2_2[55:48];
					computeExeBuffer16[7:0] <= bramOut2_2[63:56];
					
                    computeExeBuffer17[7:0] <= bramOut2_3[7 :0 ];
                    computeExeBuffer18[7:0] <= bramOut2_3[15:8 ];
                    computeExeBuffer19[7:0] <= bramOut2_3[23:16];
                    computeExeBuffer20[7:0] <= bramOut2_3[31:24];
                    computeExeBuffer21[7:0] <= bramOut2_3[39:32];
                    computeExeBuffer22[7:0] <= bramOut2_3[47:40];
                    computeExeBuffer23[7:0] <= bramOut2_3[55:48];
                    computeExeBuffer24[7:0] <= bramOut2_3[63:56];
					
                    computeExeBuffer25[7:0] <= bramOut2_4[7 :0 ];
                    computeExeBuffer26[7:0] <= bramOut2_4[15:8 ];
                    computeExeBuffer27[7:0] <= bramOut2_4[23:16];
                    computeExeBuffer28[7:0] <= bramOut2_4[31:24];
                    computeExeBuffer29[7:0] <= bramOut2_4[39:32];
                    computeExeBuffer30[7:0] <= bramOut2_4[47:40];
                    computeExeBuffer31[7:0] <= bramOut2_4[55:48];
                    computeExeBuffer32[7:0] <= bramOut2_4[63:56];
					
                    computeExeBuffer33[7:0] <= bramOut2_5[7 :0 ];
                    computeExeBuffer34[7:0] <= bramOut2_5[15:8 ];
                    computeExeBuffer35[7:0] <= bramOut2_5[23:16];
                    computeExeBuffer36[7:0] <= bramOut2_5[31:24];
                    computeExeBuffer37[7:0] <= bramOut2_5[39:32];
                    computeExeBuffer38[7:0] <= bramOut2_5[47:40];
                    computeExeBuffer39[7:0] <= bramOut2_5[55:48];
                    computeExeBuffer40[7:0] <= bramOut2_5[63:56];

                    fastResultBuff0[7:0] <= bramOutFast2_3[7 :0 ];
                    fastResultBuff1[7:0] <= bramOutFast2_3[15:8 ];
                    fastResultBuff2[7:0] <= bramOutFast2_3[23:16];
                    fastResultBuff3[7:0] <= bramOutFast2_3[31:24];
                    fastResultBuff4[7:0] <= bramOutFast2_3[39:32];
                    fastResultBuff5[7:0] <= bramOutFast2_3[47:40];
                    fastResultBuff6[7:0] <= bramOutFast2_3[55:48];
                    fastResultBuff7[7:0] <= bramOutFast2_3[63:56];
                    fastResultBuff8[7:0] <= bramOutFast2_4[7 :0 ];
                    fastResultBuff9[7:0] <= bramOutFast2_4[15:8 ];
                end

                default: 
                begin
                end
            endcase
        end
		
        /* gen computeExeBufferDelay
         */
		if(computeValidCount <= 30)
            computeExeBufferDelay <= 0;
		else
		begin
			if(computeExeBufferDelay == 7)
            begin
                computeExeBufferDelay <= 0;
			end
			else
			begin
                computeExeBufferDelay <= computeExeBufferDelay + 1;
			end
		end
        
    end

    else if(computeState == COMPUTE_FIRST_EXE)
    begin
        /*  valid gen
         */
        if (bramValid2_1)
			computeValidCount <= computeValidCount + 1;
		computeExeBufferValid <= bramValid2_1 & computeValidCount >= 30;
		
        /*  buffer shift
         */
        if(computeValidCount <= 30 || computeExeBufferDelay == 1)
        begin
        /* fill buffer, every 1 period shift 1
         */
            computeExeBuffer1[247:8] <= computeExeBuffer1[239:0];
			computeExeBuffer2[247:8] <= computeExeBuffer2[239:0];
			computeExeBuffer3[247:8] <= computeExeBuffer3[239:0];
			computeExeBuffer4[247:8] <= computeExeBuffer4[239:0];
			computeExeBuffer5[247:8] <= computeExeBuffer5[239:0];
			computeExeBuffer6[247:8] <= computeExeBuffer6[239:0];
			computeExeBuffer7[247:8] <= computeExeBuffer7[239:0];
			computeExeBuffer8[247:8] <= computeExeBuffer8[239:0];
			
			computeExeBuffer9[247:8]  <= computeExeBuffer9[239:0];
			computeExeBuffer10[247:8] <= computeExeBuffer10[239:0];
			computeExeBuffer11[247:8] <= computeExeBuffer11[239:0];
			computeExeBuffer12[247:8] <= computeExeBuffer12[239:0];
			computeExeBuffer13[247:8] <= computeExeBuffer13[239:0];
			computeExeBuffer14[247:8] <= computeExeBuffer14[239:0];
			computeExeBuffer15[247:8] <= computeExeBuffer15[239:0];
			computeExeBuffer16[247:8] <= computeExeBuffer16[239:0];
			
			computeExeBuffer17[247:8] <= computeExeBuffer17[239:0]; 
			computeExeBuffer18[247:8] <= computeExeBuffer18[239:0]; 
			computeExeBuffer19[247:8] <= computeExeBuffer19[239:0]; 
			computeExeBuffer20[247:8] <= computeExeBuffer20[239:0]; 
			computeExeBuffer21[247:8] <= computeExeBuffer21[239:0]; 
			computeExeBuffer22[247:8] <= computeExeBuffer22[239:0]; 
			computeExeBuffer23[247:8] <= computeExeBuffer23[239:0]; 
			computeExeBuffer24[247:8] <= computeExeBuffer24[239:0]; 
			
			computeExeBuffer25[247:8] <= computeExeBuffer25[239:0]; 
			computeExeBuffer26[247:8] <= computeExeBuffer26[239:0]; 
			computeExeBuffer27[247:8] <= computeExeBuffer27[239:0]; 
			computeExeBuffer28[247:8] <= computeExeBuffer28[239:0]; 
			computeExeBuffer29[247:8] <= computeExeBuffer29[239:0]; 
			computeExeBuffer30[247:8] <= computeExeBuffer30[239:0]; 
			computeExeBuffer31[247:8] <= computeExeBuffer31[239:0]; 
			computeExeBuffer32[247:8] <= computeExeBuffer32[239:0]; 
			
			computeExeBuffer33[247:8] <= computeExeBuffer33[239:0]; 
			computeExeBuffer34[247:8] <= computeExeBuffer34[239:0]; 
			computeExeBuffer35[247:8] <= computeExeBuffer35[239:0]; 
			computeExeBuffer36[247:8] <= computeExeBuffer36[239:0]; 
			computeExeBuffer37[247:8] <= computeExeBuffer37[239:0]; 
			computeExeBuffer38[247:8] <= computeExeBuffer38[239:0]; 
			computeExeBuffer39[247:8] <= computeExeBuffer39[239:0]; 
			computeExeBuffer40[247:8] <= computeExeBuffer40[239:0]; 


            fastResultBuff0[127:32] <= fastResultBuff0[119:24];
            fastResultBuff1[127:32] <= fastResultBuff1[119:24];
            fastResultBuff2[127:32] <= fastResultBuff2[119:24];
            fastResultBuff3[127:32] <= fastResultBuff3[119:24];
            fastResultBuff4[127:32] <= fastResultBuff4[119:24];
            fastResultBuff5[127:32] <= fastResultBuff5[119:24];
            fastResultBuff6[127:32] <= fastResultBuff6[119:24];
            fastResultBuff7[127:32] <= fastResultBuff7[119:24];
            fastResultBuff8[127:32] <= fastResultBuff8[119:24];
            fastResultBuff9[127:32] <= fastResultBuff9[119:24];
            
            fastResultBuff0[31:8] <= fastResultBuff0[23:0];
            fastResultBuff1[23:8] <= fastResultBuff1[15:0];
            fastResultBuff2[23:8] <= fastResultBuff2[15:0];
            fastResultBuff3[23:8] <= fastResultBuff3[15:0];
            fastResultBuff4[23:8] <= fastResultBuff4[15:0];
            fastResultBuff5[23:8] <= fastResultBuff5[15:0];
            fastResultBuff6[23:8] <= fastResultBuff6[15:0];
            fastResultBuff7[23:8] <= fastResultBuff7[15:0];
            fastResultBuff8[23:8] <= fastResultBuff8[15:0];
            fastResultBuff9[31:8] <= fastResultBuff9[23:0];


            

            /* non maximum suppression
             */
            nmsLineMax[0] <= (fastResultBuff0[7:0] >= fastResultBuff0[15:8] && fastResultBuff0[7:0] >= fastResultBuff0[23:16]) ? fastResultBuff0[7:0] :
                                (fastResultBuff0[15:8] >= fastResultBuff0[7:0] && fastResultBuff0[15:8] >= fastResultBuff0[23:16]) ? fastResultBuff0[15:8] :
                                fastResultBuff0[23:16];
            nmsLineMax[1] <= (fastResultBuff1[7:0] >= fastResultBuff1[15:8] && fastResultBuff1[7:0] >= fastResultBuff1[23:16]) ? fastResultBuff1[7:0] :
                                (fastResultBuff1[15:8] >= fastResultBuff1[7:0] && fastResultBuff1[15:8] >= fastResultBuff1[23:16]) ? fastResultBuff1[15:8] :
                                fastResultBuff1[23:16];
            nmsLineMax[2] <= (fastResultBuff2[7:0] >= fastResultBuff2[15:8] && fastResultBuff2[7:0] >= fastResultBuff2[23:16]) ? fastResultBuff2[7:0] :
                                (fastResultBuff2[15:8] >= fastResultBuff2[7:0] && fastResultBuff2[15:8] >= fastResultBuff2[23:16]) ? fastResultBuff2[15:8] :
                                fastResultBuff2[23:16];
            // nmsLineMax[3] <= (fastResultBuff3[7:0] >= fastResultBuff3[15:8] && fastResultBuff3[7:0] >= fastResultBuff3[23:16]) ? fastResultBuff3[7:0] :
            //                     (fastResultBuff3[15:8] >= fastResultBuff3[7:0] && fastResultBuff3[15:8] >= fastResultBuff3[23:16]) ? fastResultBuff3[15:8] :
            //                     fastResultBuff3[23:16];
            // nmsLineMax[4] <= (fastResultBuff4[7:0] >= fastResultBuff4[15:8] && fastResultBuff4[7:0] >= fastResultBuff4[23:16]) ? fastResultBuff4[7:0] :
            //                     (fastResultBuff4[15:8] >= fastResultBuff4[7:0] && fastResultBuff4[15:8] >= fastResultBuff4[23:16]) ? fastResultBuff4[15:8] :
            //                     fastResultBuff4[23:16];
            // nmsLineMax[5] <= (fastResultBuff5[7:0] >= fastResultBuff5[15:8] && fastResultBuff5[7:0] >= fastResultBuff5[23:16]) ? fastResultBuff5[7:0] :
            //                     (fastResultBuff5[15:8] >= fastResultBuff5[7:0] && fastResultBuff5[15:8] >= fastResultBuff5[23:16]) ? fastResultBuff5[15:8] :
            //                     fastResultBuff5[23:16];
            // nmsLineMax[6] <= (fastResultBuff6[7:0] >= fastResultBuff6[15:8] && fastResultBuff6[7:0] >= fastResultBuff6[23:16]) ? fastResultBuff6[7:0] :
            //                     (fastResultBuff6[15:8] >= fastResultBuff6[7:0] && fastResultBuff6[15:8] >= fastResultBuff6[23:16]) ? fastResultBuff6[15:8] :
            //                     fastResultBuff6[23:16];
            // nmsLineMax[7] <= (fastResultBuff7[7:0] >= fastResultBuff7[15:8] && fastResultBuff7[7:0] >= fastResultBuff7[23:16]) ? fastResultBuff7[7:0] :
            //                     (fastResultBuff7[15:8] >= fastResultBuff7[7:0] && fastResultBuff7[15:8] >= fastResultBuff7[23:16]) ? fastResultBuff7[15:8] :
            //                     fastResultBuff7[23:16];
            // nmsLineMax[8] <= (fastResultBuff8[7:0] >= fastResultBuff8[15:8] && fastResultBuff8[7:0] >= fastResultBuff8[23:16]) ? fastResultBuff8[7:0] :
            //                     (fastResultBuff8[15:8] >= fastResultBuff8[7:0] && fastResultBuff8[15:8] >= fastResultBuff8[23:16]) ? fastResultBuff8[15:8] :
            //                     fastResultBuff8[23:16];
            nmsLineMax[9] <= (fastResultBuff9[7:0] >= fastResultBuff9[15:8] && fastResultBuff9[7:0] >= fastResultBuff9[23:16]) ? fastResultBuff9[7:0] :
                                (fastResultBuff9[15:8] >= fastResultBuff9[7:0] && fastResultBuff9[15:8] >= fastResultBuff9[23:16]) ? fastResultBuff9[15:8] :
                                fastResultBuff9[23:16];
            if(fastResultBuff1[23:16] >= nmsLineMax[0] && fastResultBuff1[23:16] >= nmsLineMax[1] && fastResultBuff1[23:16] >= nmsLineMax[2])
                fastResultBuff1[31:24] <= fastResultBuff1[23:16];
            else fastResultBuff1[31:24] <= 0;
            if(fastResultBuff2[23:16] >= nmsLineMax[1] && fastResultBuff2[23:16] >= nmsLineMax[2] && fastResultBuff2[23:16] >= nmsLineMax[3])
                fastResultBuff2[31:24] <= fastResultBuff2[23:16];
            else fastResultBuff2[31:24] <= 0;
            // if(fastResultBuff3[23:16] >= nmsLineMax[2] && fastResultBuff3[23:16] >= nmsLineMax[3] && fastResultBuff3[23:16] >= nmsLineMax[4])
            //     fastResultBuff3[31:24] <= fastResultBuff3[23:16];
            // else fastResultBuff3[31:24] <= 0;
            // if(fastResultBuff4[23:16] >= nmsLineMax[3] && fastResultBuff4[23:16] >= nmsLineMax[4] && fastResultBuff4[23:16] >= nmsLineMax[5])
            //     fastResultBuff4[31:24] <= fastResultBuff4[23:16];
            // else fastResultBuff4[31:24] <= 0;
            // if(fastResultBuff5[23:16] >= nmsLineMax[4] && fastResultBuff5[23:16] >= nmsLineMax[5] && fastResultBuff5[23:16] >= nmsLineMax[6])
            //     fastResultBuff5[31:24] <= fastResultBuff5[23:16];
            // else fastResultBuff5[31:24] <= 0;
            // if(fastResultBuff6[23:16] >= nmsLineMax[5] && fastResultBuff6[23:16] >= nmsLineMax[6] && fastResultBuff6[23:16] >= nmsLineMax[7])
            //     fastResultBuff6[31:24] <= fastResultBuff6[23:16];
            // else fastResultBuff6[31:24] <= 0;
            // if(fastResultBuff7[23:16] >= nmsLineMax[6] && fastResultBuff7[23:16] >= nmsLineMax[7] && fastResultBuff7[23:16] >= nmsLineMax[8])
            //     fastResultBuff7[31:24] <= fastResultBuff7[23:16];
            // else fastResultBuff7[31:24] <= 0;
            // if(fastResultBuff8[23:16] >= nmsLineMax[7] && fastResultBuff8[23:16] >= nmsLineMax[8] && fastResultBuff8[23:16] >= nmsLineMax[9])
            //     fastResultBuff8[31:24] <= fastResultBuff8[23:16];
            // else fastResultBuff8[31:24] <= 0;


            computeExeBuffer1[7:0] <= bramOut2_1[7 :0 ];
            computeExeBuffer2[7:0] <= bramOut2_1[15:8 ];
            computeExeBuffer3[7:0] <= bramOut2_1[23:16];
            computeExeBuffer4[7:0] <= bramOut2_1[31:24];
            computeExeBuffer5[7:0] <= bramOut2_1[39:32];
            computeExeBuffer6[7:0] <= bramOut2_1[47:40];
            computeExeBuffer7[7:0] <= bramOut2_1[55:48];
            computeExeBuffer8[7:0] <= bramOut2_1[63:56];
			
			computeExeBuffer9[7:0]  <= bramOut2_2[7 :0 ];
			computeExeBuffer10[7:0] <= bramOut2_2[15:8 ];
			computeExeBuffer11[7:0] <= bramOut2_2[23:16];
			computeExeBuffer12[7:0] <= bramOut2_2[31:24];
			computeExeBuffer13[7:0] <= bramOut2_2[39:32];
			computeExeBuffer14[7:0] <= bramOut2_2[47:40];
			computeExeBuffer15[7:0] <= bramOut2_2[55:48];
			computeExeBuffer16[7:0] <= bramOut2_2[63:56];
			
            computeExeBuffer17[7:0] <= bramOut2_3[7 :0 ];
            computeExeBuffer18[7:0] <= bramOut2_3[15:8 ];
            computeExeBuffer19[7:0] <= bramOut2_3[23:16];
            computeExeBuffer20[7:0] <= bramOut2_3[31:24];
            computeExeBuffer21[7:0] <= bramOut2_3[39:32];
            computeExeBuffer22[7:0] <= bramOut2_3[47:40];
            computeExeBuffer23[7:0] <= bramOut2_3[55:48];
            computeExeBuffer24[7:0] <= bramOut2_3[63:56];
			
            computeExeBuffer25[7:0] <= bramOut2_4[7 :0 ];
            computeExeBuffer26[7:0] <= bramOut2_4[15:8 ];
            computeExeBuffer27[7:0] <= bramOut2_4[23:16];
            computeExeBuffer28[7:0] <= bramOut2_4[31:24];
            computeExeBuffer29[7:0] <= bramOut2_4[39:32];
            computeExeBuffer30[7:0] <= bramOut2_4[47:40];
            computeExeBuffer31[7:0] <= bramOut2_4[55:48];
            computeExeBuffer32[7:0] <= bramOut2_4[63:56];

            fastResultBuff0[7:0] <= bramOutFast2_2[55:48];
            fastResultBuff1[7:0] <= bramOutFast2_2[63:56];
            fastResultBuff2[7:0] <= bramOutFast2_3[7 :0 ];
            fastResultBuff9[7:0] <= bramOutFast2_3[15:8 ];
        end
		
        /* gen computeExeBufferDelay
         */
		if(computeValidCount <= 30)
            computeExeBufferDelay <= 0;
		else
		begin
			if(computeExeBufferDelay == 1)
            begin
                computeExeBufferDelay <= 0;
			end
			else
			begin
                computeExeBufferDelay <= computeExeBufferDelay + 1;
			end
		end
        
    end

    else
    begin
        computeExeBufferValid <= 0;
        computeValidCount <= 0;
    end
end

////////////////////////
////* compute unit *////
////////////////////////
reg [247:0] computeCol1  = 0;
reg [247:0] computeCol2  = 0;
reg [247:0] computeCol3  = 0;
reg [247:0] computeCol4  = 0;
reg [247:0] computeCol5  = 0;
reg [247:0] computeCol6  = 0;
reg [247:0] computeCol7  = 0;
reg [247:0] computeCol8  = 0;
reg [247:0] computeCol9  = 0;
reg [247:0] computeCol10 = 0;
reg [247:0] computeCol11 = 0;
reg [247:0] computeCol12 = 0;
reg [247:0] computeCol13 = 0;
reg [247:0] computeCol14 = 0;
reg [247:0] computeCol15 = 0;
reg [247:0] computeCol16 = 0;
reg [247:0] computeCol17 = 0;
reg [247:0] computeCol18 = 0;
reg [247:0] computeCol19 = 0;
reg [247:0] computeCol20 = 0;
reg [247:0] computeCol21 = 0;
reg [247:0] computeCol22 = 0;
reg [247:0] computeCol23 = 0;
reg [247:0] computeCol24 = 0;
reg [247:0] computeCol25 = 0;
reg [247:0] computeCol26 = 0;
reg [247:0] computeCol27 = 0;
reg [247:0] computeCol28 = 0;
reg [247:0] computeCol29 = 0;
reg [247:0] computeCol30 = 0;
reg [247:0] computeCol31 = 0;

reg computeUnitStart = 0;
wire computeUnitFinish;
wire [23:0] sumColProduct;
wire [23:0] sumRowProduct;
wire ctMask;
reg fastResultMask = 0;

centroid ct_u
(
    .clk(clk),
    .start(computeUnitStart),
    .maskIn(fastResultMask),

    .col1 (computeCol1 ),
    .col2 (computeCol2 ),
    .col3 (computeCol3 ),
    .col4 (computeCol4 ),
    .col5 (computeCol5 ),
    .col6 (computeCol6 ),
    .col7 (computeCol7 ),
    .col8 (computeCol8 ),
    .col9 (computeCol9 ),
    .col10(computeCol10),
    .col11(computeCol11),
    .col12(computeCol12),
    .col13(computeCol13),
    .col14(computeCol14),
    .col15(computeCol15),
    .col16(computeCol16),
    .col17(computeCol17),
    .col18(computeCol18),
    .col19(computeCol19),
    .col20(computeCol20),
    .col21(computeCol21),
    .col22(computeCol22),
    .col23(computeCol23),
    .col24(computeCol24),
    .col25(computeCol25),
    .col26(computeCol26),
    .col27(computeCol27),
    .col28(computeCol28),
    .col29(computeCol29),
    .col30(computeCol30),
    .col31(computeCol31),

    .finish(computeUnitFinish),
    .sumColProduct(sumColProduct),
    .sumRowProduct(sumRowProduct),
    .maskOut(ctMask)

);


wire descUnitFinish;
wire descMask;
wire [255:0] desc;

desc_compute dc_u
(
    .clk(clk),
    .start(computeUnitStart),
    .maskIn(fastResultMask),

    .col1 (computeCol1 ),
    .col2 (computeCol2 ),
    .col3 (computeCol3 ),
    .col4 (computeCol4 ),
    .col5 (computeCol5 ),
    .col6 (computeCol6 ),
    .col7 (computeCol7 ),
    .col8 (computeCol8 ),
    .col9 (computeCol9 ),
    .col10(computeCol10),
    .col11(computeCol11),
    .col12(computeCol12),
    .col13(computeCol13),
    .col14(computeCol14),
    .col15(computeCol15),
    .col16(computeCol16),
    .col17(computeCol17),
    .col18(computeCol18),
    .col19(computeCol19),
    .col20(computeCol20),
    .col21(computeCol21),
    .col22(computeCol22),
    .col23(computeCol23),
    .col24(computeCol24),
    .col25(computeCol25),
    .col26(computeCol26),
    .col27(computeCol27),
    .col28(computeCol28),
    .col29(computeCol29),
    .col30(computeCol30),
    .col31(computeCol31),

    .val(descUnitFinish),
    .desc(desc),
    .maskOut(descMask)

);

reg [3:0] computeExeBufferSelect  = 0;
reg [15:0] computeFinishCount     = 0;
reg [3:0] computeFinishCountDelay = 0;

/*  compute unit ctrl
    computeFinish gen
 */
always @(posedge clk)
begin
    if(rst || rstIn)
    begin
        computeUnitStart <= 0;
		
		computeCol1  <= 0;
		computeCol2  <= 0;
		computeCol3  <= 0;
		computeCol4  <= 0;
		computeCol5  <= 0;
		computeCol6  <= 0;
		computeCol7  <= 0;
		computeCol8  <= 0;
		computeCol9  <= 0;
		computeCol10 <= 0;
		computeCol11 <= 0;
		computeCol12 <= 0;
		computeCol13 <= 0;
		computeCol14 <= 0;
		computeCol15 <= 0;
		computeCol16 <= 0;
		computeCol17 <= 0;
		computeCol18 <= 0;
		computeCol19 <= 0;
		computeCol20 <= 0;
		computeCol21 <= 0;
		computeCol22 <= 0;
		computeCol23 <= 0;
		computeCol24 <= 0;
		computeCol25 <= 0;
		computeCol26 <= 0;
		computeCol27 <= 0;
		computeCol28 <= 0;
		computeCol29 <= 0;
		computeCol30 <= 0;
		computeCol31 <= 0;

        computeExeBufferSelect <= 0;
		
        /*  padding: 15, 15*2=30
			rows: imgWidth - 6, 30+6=36 
         */
        computeFinishCount <= 36;
        computeFinishCountDelay <= 0;
        computeExeFinish <= 0;
        fastResultMask <= 0;
    end

    else if(computeState == COMPUTE_EXE || computeState == COMPUTE_LAST_EXE)
    begin
        /*  buffer ready
            gen start
            select buffer
         */
        // start
        computeUnitStart <= computeExeBufferValid;
        if(computeExeBufferValid)
        begin
            /* buffer -> cols
             */
            case (computeExeBufferSelect)
                0:
                begin
                    // select change
                    computeExeBufferSelect <= 1;
					
					computeCol1  <= computeExeBuffer3 ;
					computeCol2  <= computeExeBuffer4 ;
					computeCol3  <= computeExeBuffer5 ;
					computeCol4  <= computeExeBuffer6 ;
					computeCol5  <= computeExeBuffer7 ;
					computeCol6  <= computeExeBuffer8 ;
					computeCol7  <= computeExeBuffer9 ;
					computeCol8  <= computeExeBuffer10;
					computeCol9  <= computeExeBuffer11;
					computeCol10 <= computeExeBuffer12;
					computeCol11 <= computeExeBuffer13;
					computeCol12 <= computeExeBuffer14;
					computeCol13 <= computeExeBuffer15;
					computeCol14 <= computeExeBuffer16;
					computeCol15 <= computeExeBuffer17;
					computeCol16 <= computeExeBuffer18;
					computeCol17 <= computeExeBuffer19;
					computeCol18 <= computeExeBuffer20;
					computeCol19 <= computeExeBuffer21;
					computeCol20 <= computeExeBuffer22;
					computeCol21 <= computeExeBuffer23;
					computeCol22 <= computeExeBuffer24;
					computeCol23 <= computeExeBuffer25;
					computeCol24 <= computeExeBuffer26;
					computeCol25 <= computeExeBuffer27;
					computeCol26 <= computeExeBuffer28;
					computeCol27 <= computeExeBuffer29;
					computeCol28 <= computeExeBuffer30;
					computeCol29 <= computeExeBuffer31;
					computeCol30 <= computeExeBuffer32;
					computeCol31 <= computeExeBuffer33;

                    fastResultMask <= fastResultBuff1[127:120]==0;
                end 
                1:
                begin
                    // select change
                    computeExeBufferSelect <= 2;
					
					computeCol1  <= computeExeBuffer4 ;
					computeCol2  <= computeExeBuffer5 ;
					computeCol3  <= computeExeBuffer6 ;
					computeCol4  <= computeExeBuffer7 ;
					computeCol5  <= computeExeBuffer8 ;
					computeCol6  <= computeExeBuffer9 ;
					computeCol7  <= computeExeBuffer10;
					computeCol8  <= computeExeBuffer11;
					computeCol9  <= computeExeBuffer12;
					computeCol10 <= computeExeBuffer13;
					computeCol11 <= computeExeBuffer14;
					computeCol12 <= computeExeBuffer15;
					computeCol13 <= computeExeBuffer16;
					computeCol14 <= computeExeBuffer17;
					computeCol15 <= computeExeBuffer18;
					computeCol16 <= computeExeBuffer19;
					computeCol17 <= computeExeBuffer20;
					computeCol18 <= computeExeBuffer21;
					computeCol19 <= computeExeBuffer22;
					computeCol20 <= computeExeBuffer23;
					computeCol21 <= computeExeBuffer24;
					computeCol22 <= computeExeBuffer25;
					computeCol23 <= computeExeBuffer26;
					computeCol24 <= computeExeBuffer27;
					computeCol25 <= computeExeBuffer28;
					computeCol26 <= computeExeBuffer29;
					computeCol27 <= computeExeBuffer30;
					computeCol28 <= computeExeBuffer31;
					computeCol29 <= computeExeBuffer32;
					computeCol30 <= computeExeBuffer33;
					computeCol31 <= computeExeBuffer34;

                    fastResultMask <= fastResultBuff2[127:120]==0;
                end 
                2:
                begin
                    // select change
                    computeExeBufferSelect <= 3;
					
					computeCol1  <= computeExeBuffer5 ;
					computeCol2  <= computeExeBuffer6 ;
					computeCol3  <= computeExeBuffer7 ;
					computeCol4  <= computeExeBuffer8 ;
					computeCol5  <= computeExeBuffer9 ;
					computeCol6  <= computeExeBuffer10;
					computeCol7  <= computeExeBuffer11;
					computeCol8  <= computeExeBuffer12;
					computeCol9  <= computeExeBuffer13;
					computeCol10 <= computeExeBuffer14;
					computeCol11 <= computeExeBuffer15;
					computeCol12 <= computeExeBuffer16;
					computeCol13 <= computeExeBuffer17;
					computeCol14 <= computeExeBuffer18;
					computeCol15 <= computeExeBuffer19;
					computeCol16 <= computeExeBuffer20;
					computeCol17 <= computeExeBuffer21;
					computeCol18 <= computeExeBuffer22;
					computeCol19 <= computeExeBuffer23;
					computeCol20 <= computeExeBuffer24;
					computeCol21 <= computeExeBuffer25;
					computeCol22 <= computeExeBuffer26;
					computeCol23 <= computeExeBuffer27;
					computeCol24 <= computeExeBuffer28;
					computeCol25 <= computeExeBuffer29;
					computeCol26 <= computeExeBuffer30;
					computeCol27 <= computeExeBuffer31;
					computeCol28 <= computeExeBuffer32;
					computeCol29 <= computeExeBuffer33;
					computeCol30 <= computeExeBuffer34;
					computeCol31 <= computeExeBuffer35;

                    fastResultMask <= fastResultBuff3[127:120]==0;
                end 
                3:
                begin
                    // select change
                    computeExeBufferSelect <= 4;
					
					computeCol1  <= computeExeBuffer6 ;
					computeCol2  <= computeExeBuffer7 ;
					computeCol3  <= computeExeBuffer8 ;
					computeCol4  <= computeExeBuffer9 ;
					computeCol5  <= computeExeBuffer10;
					computeCol6  <= computeExeBuffer11;
					computeCol7  <= computeExeBuffer12;
					computeCol8  <= computeExeBuffer13;
					computeCol9  <= computeExeBuffer14;
					computeCol10 <= computeExeBuffer15;
					computeCol11 <= computeExeBuffer16;
					computeCol12 <= computeExeBuffer17;
					computeCol13 <= computeExeBuffer18;
					computeCol14 <= computeExeBuffer19;
					computeCol15 <= computeExeBuffer20;
					computeCol16 <= computeExeBuffer21;
					computeCol17 <= computeExeBuffer22;
					computeCol18 <= computeExeBuffer23;
					computeCol19 <= computeExeBuffer24;
					computeCol20 <= computeExeBuffer25;
					computeCol21 <= computeExeBuffer26;
					computeCol22 <= computeExeBuffer27;
					computeCol23 <= computeExeBuffer28;
					computeCol24 <= computeExeBuffer29;
					computeCol25 <= computeExeBuffer30;
					computeCol26 <= computeExeBuffer31;
					computeCol27 <= computeExeBuffer32;
					computeCol28 <= computeExeBuffer33;
					computeCol29 <= computeExeBuffer34;
					computeCol30 <= computeExeBuffer35;
					computeCol31 <= computeExeBuffer36;

                    fastResultMask <= fastResultBuff4[127:120]==0;
                end 
                4:
                begin
                    // select change
                    computeExeBufferSelect <= 5;
					
					computeCol1  <= computeExeBuffer7 ;
					computeCol2  <= computeExeBuffer8 ;
					computeCol3  <= computeExeBuffer9 ;
					computeCol4  <= computeExeBuffer10;
					computeCol5  <= computeExeBuffer11;
					computeCol6  <= computeExeBuffer12;
					computeCol7  <= computeExeBuffer13;
					computeCol8  <= computeExeBuffer14;
					computeCol9  <= computeExeBuffer15;
					computeCol10 <= computeExeBuffer16;
					computeCol11 <= computeExeBuffer17;
					computeCol12 <= computeExeBuffer18;
					computeCol13 <= computeExeBuffer19;
					computeCol14 <= computeExeBuffer20;
					computeCol15 <= computeExeBuffer21;
					computeCol16 <= computeExeBuffer22;
					computeCol17 <= computeExeBuffer23;
					computeCol18 <= computeExeBuffer24;
					computeCol19 <= computeExeBuffer25;
					computeCol20 <= computeExeBuffer26;
					computeCol21 <= computeExeBuffer27;
					computeCol22 <= computeExeBuffer28;
					computeCol23 <= computeExeBuffer29;
					computeCol24 <= computeExeBuffer30;
					computeCol25 <= computeExeBuffer31;
					computeCol26 <= computeExeBuffer32;
					computeCol27 <= computeExeBuffer33;
					computeCol28 <= computeExeBuffer34;
					computeCol29 <= computeExeBuffer35;
					computeCol30 <= computeExeBuffer36;
					computeCol31 <= computeExeBuffer37;

                    fastResultMask <= fastResultBuff5[127:120]==0;
                end 
                5:
                begin
                    // select change
                    computeExeBufferSelect <= 6;
					
					computeCol1  <= computeExeBuffer8 ;
					computeCol2  <= computeExeBuffer9 ;
					computeCol3  <= computeExeBuffer10;
					computeCol4  <= computeExeBuffer11;
					computeCol5  <= computeExeBuffer12;
					computeCol6  <= computeExeBuffer13;
					computeCol7  <= computeExeBuffer14;
					computeCol8  <= computeExeBuffer15;
					computeCol9  <= computeExeBuffer16;
					computeCol10 <= computeExeBuffer17;
					computeCol11 <= computeExeBuffer18;
					computeCol12 <= computeExeBuffer19;
					computeCol13 <= computeExeBuffer20;
					computeCol14 <= computeExeBuffer21;
					computeCol15 <= computeExeBuffer22;
					computeCol16 <= computeExeBuffer23;
					computeCol17 <= computeExeBuffer24;
					computeCol18 <= computeExeBuffer25;
					computeCol19 <= computeExeBuffer26;
					computeCol20 <= computeExeBuffer27;
					computeCol21 <= computeExeBuffer28;
					computeCol22 <= computeExeBuffer29;
					computeCol23 <= computeExeBuffer30;
					computeCol24 <= computeExeBuffer31;
					computeCol25 <= computeExeBuffer32;
					computeCol26 <= computeExeBuffer33;
					computeCol27 <= computeExeBuffer34;
					computeCol28 <= computeExeBuffer35;
					computeCol29 <= computeExeBuffer36;
					computeCol30 <= computeExeBuffer37;
					computeCol31 <= computeExeBuffer38;

                    fastResultMask <= fastResultBuff6[127:120]==0;
                end 
                6:
                begin
                    // select change
                    computeExeBufferSelect <= 7;
					
					computeCol1  <= computeExeBuffer9 ;
					computeCol2  <= computeExeBuffer10;
					computeCol3  <= computeExeBuffer11;
					computeCol4  <= computeExeBuffer12;
					computeCol5  <= computeExeBuffer13;
					computeCol6  <= computeExeBuffer14;
					computeCol7  <= computeExeBuffer15;
					computeCol8  <= computeExeBuffer16;
					computeCol9  <= computeExeBuffer17;
					computeCol10 <= computeExeBuffer18;
					computeCol11 <= computeExeBuffer19;
					computeCol12 <= computeExeBuffer20;
					computeCol13 <= computeExeBuffer21;
					computeCol14 <= computeExeBuffer22;
					computeCol15 <= computeExeBuffer23;
					computeCol16 <= computeExeBuffer24;
					computeCol17 <= computeExeBuffer25;
					computeCol18 <= computeExeBuffer26;
					computeCol19 <= computeExeBuffer27;
					computeCol20 <= computeExeBuffer28;
					computeCol21 <= computeExeBuffer29;
					computeCol22 <= computeExeBuffer30;
					computeCol23 <= computeExeBuffer31;
					computeCol24 <= computeExeBuffer32;
					computeCol25 <= computeExeBuffer33;
					computeCol26 <= computeExeBuffer34;
					computeCol27 <= computeExeBuffer35;
					computeCol28 <= computeExeBuffer36;
					computeCol29 <= computeExeBuffer37;
					computeCol30 <= computeExeBuffer38;
					computeCol31 <= computeExeBuffer39;

                    fastResultMask <= fastResultBuff7[127:120]==0;
                end 
                7:
                begin
                    // select change
                    computeExeBufferSelect <= 0;
					
					computeCol1  <= computeExeBuffer10;
					computeCol2  <= computeExeBuffer11;
					computeCol3  <= computeExeBuffer12;
					computeCol4  <= computeExeBuffer13;
					computeCol5  <= computeExeBuffer14;
					computeCol6  <= computeExeBuffer15;
					computeCol7  <= computeExeBuffer16;
					computeCol8  <= computeExeBuffer17;
					computeCol9  <= computeExeBuffer18;
					computeCol10 <= computeExeBuffer19;
					computeCol11 <= computeExeBuffer20;
					computeCol12 <= computeExeBuffer21;
					computeCol13 <= computeExeBuffer22;
					computeCol14 <= computeExeBuffer23;
					computeCol15 <= computeExeBuffer24;
					computeCol16 <= computeExeBuffer25;
					computeCol17 <= computeExeBuffer26;
					computeCol18 <= computeExeBuffer27;
					computeCol19 <= computeExeBuffer28;
					computeCol20 <= computeExeBuffer29;
					computeCol21 <= computeExeBuffer30;
					computeCol22 <= computeExeBuffer31;
					computeCol23 <= computeExeBuffer32;
					computeCol24 <= computeExeBuffer33;
					computeCol25 <= computeExeBuffer34;
					computeCol26 <= computeExeBuffer35;
					computeCol27 <= computeExeBuffer36;
					computeCol28 <= computeExeBuffer37;
					computeCol29 <= computeExeBuffer38;
					computeCol30 <= computeExeBuffer39;
					computeCol31 <= computeExeBuffer40;

                    fastResultMask <= fastResultBuff8[127:120]==0;
                end 
                default: 
                begin
                end
            endcase
        end

        /* gen computeFinish
         */
        if(computeUnitFinish)
        begin
            if(computeFinishCountDelay == 7)
            begin
                computeFinishCountDelay <= 0;
                computeFinishCount <= computeFinishCount + 1;
            end
            else
                computeFinishCountDelay <= computeFinishCountDelay + 1;
        end
        if(computeFinishCount >= imgWidth)
            computeExeFinish <= 1;
    end

    else if(computeState == COMPUTE_FIRST_EXE)
    begin
        /*  buffer ready
            gen start
            select buffer
         */
        // start
        computeUnitStart <= computeExeBufferValid;
        if(computeExeBufferValid)
        begin
            /* buffer -> cols
             */
            case (computeExeBufferSelect)
                0:
                begin
                    // select change
                    computeExeBufferSelect <= 1;
					
					computeCol1  <= computeExeBuffer1 ;
					computeCol2  <= computeExeBuffer2 ;
					computeCol3  <= computeExeBuffer3 ;
					computeCol4  <= computeExeBuffer4 ;
					computeCol5  <= computeExeBuffer5 ;
					computeCol6  <= computeExeBuffer6 ;
					computeCol7  <= computeExeBuffer7 ;
					computeCol8  <= computeExeBuffer8 ;
					computeCol9  <= computeExeBuffer9 ;
					computeCol10 <= computeExeBuffer10;
					computeCol11 <= computeExeBuffer11;
					computeCol12 <= computeExeBuffer12;
					computeCol13 <= computeExeBuffer13;
					computeCol14 <= computeExeBuffer14;
					computeCol15 <= computeExeBuffer15;
					computeCol16 <= computeExeBuffer16;
					computeCol17 <= computeExeBuffer17;
					computeCol18 <= computeExeBuffer18;
					computeCol19 <= computeExeBuffer19;
					computeCol20 <= computeExeBuffer20;
					computeCol21 <= computeExeBuffer21;
					computeCol22 <= computeExeBuffer22;
					computeCol23 <= computeExeBuffer23;
					computeCol24 <= computeExeBuffer24;
					computeCol25 <= computeExeBuffer25;
					computeCol26 <= computeExeBuffer26;
					computeCol27 <= computeExeBuffer27;
					computeCol28 <= computeExeBuffer28;
					computeCol29 <= computeExeBuffer29;
					computeCol30 <= computeExeBuffer30;
					computeCol31 <= computeExeBuffer31;

                    fastResultMask <= fastResultBuff1[127:120]==0;
                end 
                1:
                begin
                    // select change
                    computeExeBufferSelect <= 0;
					
					computeCol1  <= computeExeBuffer2 ;
					computeCol2  <= computeExeBuffer3 ;
					computeCol3  <= computeExeBuffer4 ;
					computeCol4  <= computeExeBuffer5 ;
					computeCol5  <= computeExeBuffer6 ;
					computeCol6  <= computeExeBuffer7 ;
					computeCol7  <= computeExeBuffer8 ;
					computeCol8  <= computeExeBuffer9 ;
					computeCol9  <= computeExeBuffer10;
					computeCol10 <= computeExeBuffer11;
					computeCol11 <= computeExeBuffer12;
					computeCol12 <= computeExeBuffer13;
					computeCol13 <= computeExeBuffer14;
					computeCol14 <= computeExeBuffer15;
					computeCol15 <= computeExeBuffer16;
					computeCol16 <= computeExeBuffer17;
					computeCol17 <= computeExeBuffer18;
					computeCol18 <= computeExeBuffer19;
					computeCol19 <= computeExeBuffer20;
					computeCol20 <= computeExeBuffer21;
					computeCol21 <= computeExeBuffer22;
					computeCol22 <= computeExeBuffer23;
					computeCol23 <= computeExeBuffer24;
					computeCol24 <= computeExeBuffer25;
					computeCol25 <= computeExeBuffer26;
					computeCol26 <= computeExeBuffer27;
					computeCol27 <= computeExeBuffer28;
					computeCol28 <= computeExeBuffer29;
					computeCol29 <= computeExeBuffer30;
					computeCol30 <= computeExeBuffer31;
					computeCol31 <= computeExeBuffer32;

                    fastResultMask <= fastResultBuff2[127:120]==0;
                end 
                
                default: 
                begin
                end
            endcase
        end

        /* gen computeFinish
         */
        if(computeUnitFinish)
        begin
            if(computeFinishCountDelay == 1)
            begin
                computeFinishCountDelay <= 0;
                computeFinishCount <= computeFinishCount + 1;
            end
            else
                computeFinishCountDelay <= computeFinishCountDelay + 1;
        end
        if(computeFinishCount >= imgWidth)
            computeExeFinish <= 1;
    end

    else
    begin
        computeExeFinish <= 0;
        computeFinishCount <= 36;
        computeFinishCountDelay <= 0;

        computeUnitStart <= 0;
        computeExeBufferSelect <= 0;
    end
end

/////////////////
////* bram3 *////
/////////////////

reg [9:0] bramFaAddr1   = 0;
reg bramFaWe1           = 0;
reg [63:0] bramFaDIn1   = 0;
reg bramFaStart1        = 0;
wire [63:0] bramFaDOut1;         
fake_dram bram3_fa_1
(
    .addr(bramFaAddr1),
    .clk(clk),
    .we(bramFaWe1),
    .dIn(bramFaDIn1),
    .start(bramFaStart1),

    .dOut(bramFaDOut1)
);
reg [9:0] bramFaAddr2   = 0;
reg bramFaWe2           = 0;
reg [63:0] bramFaDIn2   = 0;
reg bramFaStart2        = 0;
wire [63:0] bramFaDOut2;         
fake_dram bram3_fa_2
(
    .addr(bramFaAddr2),
    .clk(clk),
    .we(bramFaWe2),
    .dIn(bramFaDIn2),
    .start(bramFaStart2),

    .dOut(bramFaDOut2)
);

reg [9:0] bramCtAddr1   = 0;
reg bramCtWe1           = 0;
reg [63:0] bramCtDIn1   = 0;
reg bramCtStart1        = 0;
wire [63:0] bramCtDOut1;         
fake_dram bram3_ct_1
(
    .addr(bramCtAddr1),
    .clk(clk),
    .we(bramCtWe1),
    .dIn(bramCtDIn1),
    .start(bramCtStart1),

    .dOut(bramCtDOut1)
);
reg [9:0] bramCtAddr2   = 0;
reg bramCtWe2           = 0;
reg [63:0] bramCtDIn2   = 0;
reg bramCtStart2        = 0;
wire [63:0] bramCtDOut2;         
fake_dram bram3_ct_2
(
    .addr(bramCtAddr2),
    .clk(clk),
    .we(bramCtWe2),
    .dIn(bramCtDIn2),
    .start(bramCtStart2),

    .dOut(bramCtDOut2)
);


reg [9:0] bramDescAddr11   = 0;
reg bramDescWe11           = 0;
reg [63:0] bramDescDIn11   = 0;
reg bramDescStart11        = 0;
wire [63:0] bramDescDOut11;         
fake_dram bram3_desc_1_1
(
    .addr(bramDescAddr11),
    .clk(clk),
    .we(bramDescWe11),
    .dIn(bramDescDIn11),
    .start(bramDescStart11),

    .dOut(bramDescDOut11)
);
reg [9:0] bramDescAddr12   = 0;
reg bramDescWe12           = 0;
reg [63:0] bramDescDIn12   = 0;
reg bramDescStart12        = 0;
wire [63:0] bramDescDOut12;         
fake_dram bram3_desc_1_2
(
    .addr(bramDescAddr12),
    .clk(clk),
    .we(bramDescWe12),
    .dIn(bramDescDIn12),
    .start(bramDescStart12),

    .dOut(bramDescDOut12)
);
reg [9:0] bramDescAddr13   = 0;
reg bramDescWe13           = 0;
reg [63:0] bramDescDIn13   = 0;
reg bramDescStart13        = 0;
wire [63:0] bramDescDOut13;         
fake_dram bram3_desc_1_3
(
    .addr(bramDescAddr13),
    .clk(clk),
    .we(bramDescWe13),
    .dIn(bramDescDIn13),
    .start(bramDescStart13),

    .dOut(bramDescDOut13)
);
reg [9:0] bramDescAddr14   = 0;
reg bramDescWe14           = 0;
reg [63:0] bramDescDIn14   = 0;
reg bramDescStart14        = 0;
wire [63:0] bramDescDOut14;         
fake_dram bram3_desc_1_4
(
    .addr(bramDescAddr14),
    .clk(clk),
    .we(bramDescWe14),
    .dIn(bramDescDIn14),
    .start(bramDescStart14),

    .dOut(bramDescDOut14)
);

reg [9:0] bramDescAddr21   = 0;
reg bramDescWe21           = 0;
reg [63:0] bramDescDIn21   = 0;
reg bramDescStart21        = 0;
wire [63:0] bramDescDOut21;         
fake_dram bram3_desc_2_1
(
    .addr(bramDescAddr21),
    .clk(clk),
    .we(bramDescWe21),
    .dIn(bramDescDIn21),
    .start(bramDescStart21),

    .dOut(bramDescDOut21)
);
reg [9:0] bramDescAddr22   = 0;
reg bramDescWe22           = 0;
reg [63:0] bramDescDIn22   = 0;
reg bramDescStart22        = 0;
wire [63:0] bramDescDOut22;         
fake_dram bram3_desc_2_2
(
    .addr(bramDescAddr22),
    .clk(clk),
    .we(bramDescWe22),
    .dIn(bramDescDIn22),
    .start(bramDescStart22),

    .dOut(bramDescDOut22)
);
reg [9:0] bramDescAddr23   = 0;
reg bramDescWe23           = 0;
reg [63:0] bramDescDIn23   = 0;
reg bramDescStart23        = 0;
wire [63:0] bramDescDOut23;         
fake_dram bram3_desc_2_3
(
    .addr(bramDescAddr23),
    .clk(clk),
    .we(bramDescWe23),
    .dIn(bramDescDIn23),
    .start(bramDescStart23),

    .dOut(bramDescDOut23)
);
reg [9:0] bramDescAddr24   = 0;
reg bramDescWe24           = 0;
reg [63:0] bramDescDIn24   = 0;
reg bramDescStart24        = 0;
wire [63:0] bramDescDOut24;         
fake_dram bram3_desc_2_4
(
    .addr(bramDescAddr24),
    .clk(clk),
    .we(bramDescWe24),
    .dIn(bramDescDIn24),
    .start(bramDescStart24),

    .dOut(bramDescDOut24)
);

/* bram3 ctrl
 */
reg [63:0] bramFaInDelay = 0;
reg [9:0] bramFaSize1 = 0;
reg [9:0] bramCtSize1 = 0;
reg [9:0] bramDescSize1 = 0;
reg [9:0] bramFaSize2 = 0;
reg [9:0] bramCtSize2 = 0;
reg [9:0] bramDescSize2 = 0;
reg [28:0] bram3Len1 = 0;
reg [28:0] bram3Len2 = 0;
reg [3:0] bram3LenGenDelay = 0;
reg bram3InFinish = 0;
reg bram3OutFinish = 0;
reg [3:0] descOutSwitch = 1;

reg [3:0] wrBurstDataSwitch = 0;

/* heap
 */
reg [7:0] heapFaDIn = 0;
reg heapFaWe = 0;
reg [27:0] pixId = 0;
reg [255:0] heapDescIn = 0;
reg [31:0] heapIdIn = 0;
reg [23:0] heapColIn = 0;
reg [23:0] heapRowIn = 0;
reg heapCtWe = 0;
reg heapDescWe = 0;

reg [39:0] heapFaIdShift[0:13];
reg [255:0] heapDescShift[0:11];
genvar i;
generate
    for (i=1; i<14; i=i+1) 
    begin
        always @(posedge clk)
        begin
            heapFaIdShift[i] <= heapFaIdShift[i-1];
        end
    end
    
    for (i=1; i<12; i=i+1) 
    begin
        always @(posedge clk)
        begin
            heapDescShift[i] <= heapDescShift[i-1];
        end
    end
endgenerate
always @(posedge clk)
begin
    heapFaIdShift[0] <= {heapIdIn,heapFaDIn};
    heapDescShift[0] <= heapDescIn;
end

/* heap fifo
 */
heap_fifo u_heap_fifo
(
    .dIn({heapFaIdShift[13], heapDescShift[11], heapColIn, 8'haa, heapRowIn, batch}),
    .we(heapCtWe),
    .clk(clk),
    .dOut(heap_din),
    .valid(heap_valid),
    .ct(heap_ct)
);

always @(posedge clk)
begin
    if(rst || rstIn)
    begin
        bramFaInDelay <= 0;

        bramFaWe1 <= 0;
        bramFaWe2 <= 0;
        bramCtWe1 <= 0;
        bramCtWe2 <= 0;
        bramDescWe11 <= 0;
        bramDescWe12 <= 0;
        bramDescWe13 <= 0;
        bramDescWe14 <= 0;
        bramDescWe21 <= 0;
        bramDescWe22 <= 0;
        bramDescWe23 <= 0;
        bramDescWe24 <= 0;

        bramFaAddr1 <= 0;
        bramFaAddr2 <= 0;
        bramCtAddr1 <= 0;
        bramCtAddr2 <= 0;
        bramDescAddr11 <= 0;
        bramDescAddr12 <= 0;
        bramDescAddr13 <= 0;
        bramDescAddr14 <= 0;
        bramDescAddr21 <= 0;
        bramDescAddr22 <= 0;
        bramDescAddr23 <= 0;
        bramDescAddr24 <= 0;

        bramFaStart1 <= 0;
        bramFaStart2 <= 0;
        bramCtStart1 <= 0;
        bramCtStart2 <= 0;
        bramDescStart11 <= 0;
        bramDescStart12 <= 0;
        bramDescStart13 <= 0;
        bramDescStart14 <= 0;
        bramDescStart21 <= 0;
        bramDescStart22 <= 0;
        bramDescStart23 <= 0;
        bramDescStart24 <= 0;

        bramFaSize1 <= 0;
        bramCtSize1 <= 0;
        bramDescSize1 <= 0;
        bramFaSize2 <= 0;
        bramCtSize2 <= 0;
        bramDescSize2 <= 0;

        bram3Len1 <= 0;
        bram3Len2 <= 0;
        bram3InFinish <= 0;
        bram3OutFinish <= 0;
        bram3LenGenDelay <= 0;
        descOutSwitch <= 1;
        
        wrBurstDataSwitch <= 0;

        pixId <= 0;

    end
    else
    begin
        /* bram3 in
         */
        if( computeState == COMPUTE_FIRST_EXE ||
            computeState == COMPUTE_EXE ||
            computeState == COMPUTE_LAST_EXE )
        begin
            /* gen finish
             */
            if(computeExeFinish)
            begin
                if(bram3Switch == 1)
                begin
                    if(bram3LenGenDelay == 0)
                    begin
                        bram3LenGenDelay <= 1;
                        bram3Len1 <= {17'b0,bramDescSize1,2'b0};
                    end
                    else if(bram3LenGenDelay == 1)
                    begin
                        bram3LenGenDelay <= 2;
                        bram3Len1 <= bram3Len1 + bramFaSize1;
                    end
                    else if(bram3LenGenDelay == 2)
                    begin
                        bram3LenGenDelay <= 3;
                        bram3InFinish <= 1;
                        bram3Len1 <= bram3Len1 + bramCtSize1;
                    end
                end
                else
                begin
                    if(bram3LenGenDelay == 0)
                    begin
                        bram3LenGenDelay <= 1;
                        bram3Len2 <= {17'b0,bramDescSize2,2'b0};
                    end
                    else if(bram3LenGenDelay == 1)
                    begin
                        bram3LenGenDelay <= 2;
                        bram3Len2 <= bram3Len2 + bramFaSize2;
                    end
                    else if(bram3LenGenDelay == 2)
                    begin
                        bram3LenGenDelay <= 3;
                        bram3InFinish <= 1;
                        bram3Len2 <= bram3Len2 + bramCtSize2;
                    end
                end
            end


            // fa
            if(computeState == COMPUTE_FIRST_EXE)
            begin
            /*  first exe
                delay 2
             */ 
                if(computeExeBufferValid)
                begin
                    case (bramFaInDelay)
                        0:
                        begin
                            bramFaInDelay <= 1;
                            bramFaDIn1 <= {48'b0,fastResultBuff2[127:120],fastResultBuff1[127:120]};
                            bramFaAddr1 <= bramFaAddr1 + 1;
                            bramFaWe1 <= 1;
                            bramFaSize1 <= bramFaSize1 + 1;
                            /* heap */
                            heapFaDIn <= fastResultBuff1[127:120];
                            heapFaWe <= 1;
                            pixId <= pixId + 1;
                            heapIdIn <= pixId + 1;
                        end 
                        1:
                        begin
                            bramFaInDelay <= 0;
                            bramFaWe1 <= 0;
                            /* heap */
                            heapFaDIn <= bramFaDIn1[15:8];
                            heapFaWe <= 1;
                            pixId <= pixId + 1;
                            heapIdIn <= pixId + 1;
                        end

                        default: 
                        begin
                        end
                    endcase
                end
                else
                begin
                    /* heap */
                    heapFaDIn <= 0;
                    heapFaWe <= 0;
                end
            end
            else
            begin
            /*  exe | last exe
                delay 8
             */
                if(computeExeBufferValid)
                begin
                    if(bram3Switch == 1)
                    begin
                        case (bramFaInDelay)
                            0:
                            begin
                                bramFaInDelay <= 1;
                                bramFaDIn1 <= { fastResultBuff8[127:120],fastResultBuff7[127:120],
                                                fastResultBuff6[127:120],fastResultBuff5[127:120],
                                                fastResultBuff4[127:120],fastResultBuff3[127:120],
                                                fastResultBuff2[127:120],fastResultBuff1[127:120]};
                                bramFaAddr1 <= bramFaAddr1 + 1;
                                bramFaWe1 <= 1;
                                bramFaSize1 <= bramFaSize1 + 1;
                                /* heap */
                                heapFaDIn <= fastResultBuff1[127:120];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end 
                            1:
                            begin
                                bramFaInDelay <= 2;
                                bramFaWe1 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn1[15:8];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            2:
                            begin
                                bramFaInDelay <= 3;
                                bramFaWe1 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn1[23:16];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            3:
                            begin
                                bramFaInDelay <= 4;
                                bramFaWe1 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn1[31:24];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            4:
                            begin
                                bramFaInDelay <= 5;
                                bramFaWe1 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn1[39:32];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            5:
                            begin
                                bramFaInDelay <= 6;
                                bramFaWe1 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn1[47:40];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            6:
                            begin
                                bramFaInDelay <= 7;
                                bramFaWe1 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn1[55:48];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            7:
                            begin
                                bramFaInDelay <= 0;
                                bramFaWe1 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn1[63:56];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end

                            default: 
                            begin
                            end
                        endcase
                    end
                    else
                    begin
                        case (bramFaInDelay)
                            0:
                            begin
                                bramFaInDelay <= 1;
                                bramFaDIn2 <= { fastResultBuff8[127:120],fastResultBuff7[127:120],
                                                fastResultBuff6[127:120],fastResultBuff5[127:120],
                                                fastResultBuff4[127:120],fastResultBuff3[127:120],
                                                fastResultBuff2[127:120],fastResultBuff1[127:120]};
                                bramFaAddr2 <= bramFaAddr2 + 1;
                                bramFaWe2 <= 1;
                                bramFaSize2 <= bramFaSize2 + 1;
                                /* heap */
                                heapFaDIn <= fastResultBuff1[127:120];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end 
                            1:
                            begin
                                bramFaInDelay <= 2;
                                bramFaWe2 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn2[15:8];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            2:
                            begin
                                bramFaInDelay <= 3;
                                bramFaWe2 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn2[23:16];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            3:
                            begin
                                bramFaInDelay <= 4;
                                bramFaWe2 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn2[31:24];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            4:
                            begin
                                bramFaInDelay <= 5;
                                bramFaWe2 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn2[39:32];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            5:
                            begin
                                bramFaInDelay <= 6;
                                bramFaWe2 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn2[47:40];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            6:
                            begin
                                bramFaInDelay <= 7;
                                bramFaWe2 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn2[55:48];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end
                            7:
                            begin
                                bramFaInDelay <= 0;
                                bramFaWe2 <= 0;
                                /* heap */
                                heapFaDIn <= bramFaDIn2[63:56];
                                heapFaWe <= 1;
                                pixId <= pixId + 1;
                                heapIdIn <= pixId + 1;
                            end

                            default: 
                            begin
                            end
                        endcase
                    end
                    
                end
                else
                begin
                    /* heap */
                    heapFaDIn <= 0;
                    heapFaWe <= 0;
                end
            end

            //ct
            if(computeUnitFinish && !ctMask)
            begin
                if(bram3Switch == 1)
                begin
                    bramCtSize1 <= bramCtSize1 + 1;
                    bramCtAddr1 <= bramCtAddr1 + 1;
                    bramCtDIn1 <= {8'b0,sumColProduct,8'b0,sumRowProduct};
                    bramCtWe1 <= 1;
                    /* heap */
                    heapCtWe <= 1;
                    heapColIn <= sumColProduct;
                    heapRowIn <= sumRowProduct;
                end
                else
                begin
                    bramCtSize2 <= bramCtSize2 + 1;
                    bramCtAddr2 <= bramCtAddr2 + 1;
                    bramCtDIn2 <= {8'b0,sumColProduct,8'b0,sumRowProduct};
                    bramCtWe2 <= 1;
                    /* heap */
                    heapCtWe <= 1;
                    heapColIn <= sumColProduct;
                    heapRowIn <= sumRowProduct;
                end
            end
            else
            begin
                bramCtWe1 <= 0;
                bramCtWe2 <= 0;
                /* heap */
                heapCtWe <= 0;
            end

            //desc
            if(descUnitFinish && !descMask)
            begin
                if(bram3Switch == 1)
                begin
                    bramDescSize1 <= bramDescSize1 + 1;
                    
                    bramDescAddr11 <= bramDescAddr11 + 1;
                    bramDescAddr12 <= bramDescAddr12 + 1;
                    bramDescAddr13 <= bramDescAddr13 + 1;
                    bramDescAddr14 <= bramDescAddr14 + 1;

                    bramDescDIn11 <= desc[63:0];
                    bramDescDIn12 <= desc[127:64];
                    bramDescDIn13 <= desc[191:128];
                    bramDescDIn14 <= desc[255:192];

                    bramDescWe11 <= 1;
                    bramDescWe12 <= 1;
                    bramDescWe13 <= 1;
                    bramDescWe14 <= 1;

                    /* heap */
                    heapDescIn <= desc;
                    heapDescWe <= 1;
                end
                else
                begin
                    bramDescSize2 <= bramDescSize2 + 1;
                    
                    bramDescAddr21 <= bramDescAddr21 + 1;
                    bramDescAddr22 <= bramDescAddr22 + 1;
                    bramDescAddr23 <= bramDescAddr23 + 1;
                    bramDescAddr24 <= bramDescAddr24 + 1;

                    bramDescDIn21 <= desc[63:0];
                    bramDescDIn22 <= desc[127:64];
                    bramDescDIn23 <= desc[191:128];
                    bramDescDIn24 <= desc[255:192];

                    bramDescWe21 <= 1;
                    bramDescWe22 <= 1;
                    bramDescWe23 <= 1;
                    bramDescWe24 <= 1;

                    /* heap */
                    heapDescIn <= desc;
                    heapDescWe <= 1;
                end
            end
            else
            begin
                bramDescWe11 <= 0;
                bramDescWe12 <= 0;
                bramDescWe13 <= 0;
                bramDescWe14 <= 0;
                bramDescWe21 <= 0;
                bramDescWe22 <= 0;
                bramDescWe23 <= 0;
                bramDescWe24 <= 0;

                /* heap */
                heapDescIn <= 0;
                heapDescWe <= 0;
            end
            
        end

        /*  bram3 out
         */
        if(computeState == COMPUTE_EXE || computeState == COMPUTE_LAST_EXE || computeState == COMPUTE_LAST_OUT || computeState == COMPUTE_IDLE)
        begin
            if(wr_burst_data_req )
            begin
                if(bram3Switch == 1)
                begin
                /* bram3_2 out
                 */
                    // fa out
                    if(bramFaAddr2 < bramFaSize2)
                    begin
                        wrBurstDataSwitch <= 1;
                        bramFaAddr2 <= bramFaAddr2 + 1;
                        bramFaStart2 <= 1;
                        bramCtStart2 <= 0;
                        bramDescStart21 <= 0;
                        bramDescStart22 <= 0;
                        bramDescStart23 <= 0;
                        bramDescStart24 <= 0;
                    end
                    // ct out
                    else if(bramCtAddr2 < bramCtSize2)
                    begin
                        wrBurstDataSwitch <= 2;
                        bramCtAddr2 <= bramCtAddr2 + 1;
                        bramFaStart2 <= 0;
                        bramCtStart2 <= 1;
                        bramDescStart21 <= 0;
                        bramDescStart22 <= 0;
                        bramDescStart23 <= 0;
                        bramDescStart24 <= 0;
                    end
                    // desc out
                    else if(bramDescAddr24 < bramDescSize2)
                    begin
                        bramFaStart2 <= 0;
                        bramCtStart2 <= 0;
                        case (descOutSwitch)
                            1:
                            begin
                                wrBurstDataSwitch <= 3;
                                bramDescAddr21 <= bramDescAddr21 + 1;
                                bramDescStart21 <= 1;
                                bramDescStart22 <= 0;
                                bramDescStart23 <= 0;
                                bramDescStart24 <= 0;
                                descOutSwitch <= 2;
                            end
                            2:
                            begin
                                wrBurstDataSwitch <= 4;
                                bramDescAddr22 <= bramDescAddr22 + 1;
                                bramDescStart21 <= 0;
                                bramDescStart22 <= 1;
                                bramDescStart23 <= 0;
                                bramDescStart24 <= 0;
                                descOutSwitch <= 3;
                            end
                            3:
                            begin
                                wrBurstDataSwitch <= 5;
                                bramDescAddr23 <= bramDescAddr23 + 1;
                                bramDescStart21 <= 0;
                                bramDescStart22 <= 0;
                                bramDescStart23 <= 1;
                                bramDescStart24 <= 0;
                                descOutSwitch <= 4;
                            end
                            4:
                            begin
                                wrBurstDataSwitch <= 6;
                                bramDescAddr24 <= bramDescAddr24 + 1;
                                bramDescStart21 <= 0;
                                bramDescStart22 <= 0;
                                bramDescStart23 <= 0;
                                bramDescStart24 <= 1;
                                descOutSwitch <= 1;
                            end
                            default: 
                            begin
                            end
                        endcase
                    end
                    else
                    begin
                        bramFaStart2 <= 0;
                        bramCtStart2 <= 0;
                        bramDescStart21 <= 0;
                        bramDescStart22 <= 0;
                        bramDescStart23 <= 0;
                        bramDescStart24 <= 0;
                    end
                end
                else if(bram3Switch == 2)
                begin
                /* bram3_1 out
                 */
                    // fa out
                    if(bramFaAddr1 < bramFaSize1)
                    begin
                        wrBurstDataSwitch <= 7;
                        bramFaAddr1 <= bramFaAddr1 + 1;
                        bramFaStart1 <= 1;
                        bramCtStart1 <= 0;
                        bramDescStart11 <= 0;
                        bramDescStart12 <= 0;
                        bramDescStart13 <= 0;
                        bramDescStart14 <= 0;
                    end
                    // ct out
                    else if(bramCtAddr1 < bramCtSize1)
                    begin
                        wrBurstDataSwitch <= 8;
                        bramCtAddr1 <= bramCtAddr1 + 1;
                        bramFaStart1 <= 0;
                        bramCtStart1 <= 1;
                        bramDescStart11 <= 0;
                        bramDescStart12 <= 0;
                        bramDescStart13 <= 0;
                        bramDescStart14 <= 0;
                    end
                    // desc out
                    else if(bramDescAddr14 < bramDescSize1)
                    begin
                        bramFaStart1 <= 0;
                        bramCtStart1 <= 0;
                        case (descOutSwitch)
                            1:
                            begin
                                wrBurstDataSwitch <= 9;
                                bramDescAddr11 <= bramDescAddr11 + 1;
                                bramDescStart11 <= 1;
                                bramDescStart12 <= 0;
                                bramDescStart13 <= 0;
                                bramDescStart14 <= 0;
                                descOutSwitch <= 2;
                            end
                            2:
                            begin
                                wrBurstDataSwitch <= 10;
                                bramDescAddr12 <= bramDescAddr12 + 1;
                                bramDescStart11 <= 0;
                                bramDescStart12 <= 1;
                                bramDescStart13 <= 0;
                                bramDescStart14 <= 0;
                                descOutSwitch <= 3;
                            end
                            3:
                            begin
                                wrBurstDataSwitch <= 11;
                                bramDescAddr13 <= bramDescAddr13 + 1;
                                bramDescStart11 <= 0;
                                bramDescStart12 <= 0;
                                bramDescStart13 <= 1;
                                bramDescStart14 <= 0;
                                descOutSwitch <= 4;
                            end
                            4:
                            begin
                                wrBurstDataSwitch <= 12;
                                bramDescAddr14 <= bramDescAddr14 + 1;
                                bramDescStart11 <= 0;
                                bramDescStart12 <= 0;
                                bramDescStart13 <= 0;
                                bramDescStart14 <= 1;
                                descOutSwitch <= 1;
                            end
                            default: 
                            begin
                            end
                        endcase
                    end
                    else
                    begin
                        bramFaStart1 <= 0;
                        bramCtStart1 <= 0;
                        bramDescStart11 <= 0;
                        bramDescStart12 <= 0;
                        bramDescStart13 <= 0;
                        bramDescStart14 <= 0;
                    end
                end
            end
            else if(wr_burst_finish)
            begin
                wrBurstDataSwitch <= 0;
                bramFaStart1 <= 0;
                bramCtStart1 <= 0;
                bramDescStart11 <= 0;
                bramDescStart12 <= 0;
                bramDescStart13 <= 0;
                bramDescStart14 <= 0;
                bram3OutFinish <= 1;
            end
            else
            begin
                wrBurstDataSwitch <= 0;
                bramFaStart1 <= 0;
                bramCtStart1 <= 0;
                bramDescStart11 <= 0;
                bramDescStart12 <= 0;
                bramDescStart13 <= 0;
                bramDescStart14 <= 0;
            end
        end


        /*  rst
        */
        if(computeState == COMPUTE_EXE_INVL || computeState == COMPUTE_LAST_INVL)
        begin
            wrBurstDataSwitch <= 0;

            bramFaInDelay <= 0;

            bramFaWe1 <= 0;
            bramFaWe2 <= 0;
            bramCtWe1 <= 0;
            bramCtWe2 <= 0;
            bramDescWe11 <= 0;
            bramDescWe12 <= 0;
            bramDescWe13 <= 0;
            bramDescWe14 <= 0;
            bramDescWe21 <= 0;
            bramDescWe22 <= 0;
            bramDescWe23 <= 0;
            bramDescWe24 <= 0;

            bramFaAddr1 <= 0;
            bramFaAddr2 <= 0;
            bramCtAddr1 <= 0;
            bramCtAddr2 <= 0;
            bramDescAddr11 <= 0;
            bramDescAddr12 <= 0;
            bramDescAddr13 <= 0;
            bramDescAddr14 <= 0;
            bramDescAddr21 <= 0;
            bramDescAddr22 <= 0;
            bramDescAddr23 <= 0;
            bramDescAddr24 <= 0;

            bramFaStart1 <= 0;
            bramFaStart2 <= 0;
            bramCtStart1 <= 0;
            bramCtStart2 <= 0;
            bramDescStart11 <= 0;
            bramDescStart12 <= 0;
            bramDescStart13 <= 0;
            bramDescStart14 <= 0;
            bramDescStart21 <= 0;
            bramDescStart22 <= 0;
            bramDescStart23 <= 0;
            bramDescStart24 <= 0;

            bram3LenGenDelay <= 0;
            bram3InFinish <= 0;
            bram3OutFinish <= 0;
            descOutSwitch <= 1;

            if(bram3Switch == 1)
            begin
                bramFaSize2 <= 0;
                bramCtSize2 <= 0;
                bramDescSize2 <= 0;
                bram3Len2 <= 0;
            end
            else
            begin
                bramFaSize1 <= 0;
                bramCtSize1 <= 0;
                bramDescSize1 <= 0;
                bram3Len1 <= 0;
            end

        end

    end
end

assign wr_burst_data =  wrBurstDataSwitch == 1  ?   bramFaDOut2     :
                        wrBurstDataSwitch == 2  ?   bramCtDOut2     :
                        wrBurstDataSwitch == 3  ?   bramDescDOut21  :
                        wrBurstDataSwitch == 4  ?   bramDescDOut22  :
                        wrBurstDataSwitch == 5  ?   bramDescDOut23  :
                        wrBurstDataSwitch == 6  ?   bramDescDOut24  :
                        wrBurstDataSwitch == 7  ?   bramFaDOut1     :
                        wrBurstDataSwitch == 8  ?   bramCtDOut1     :
                        wrBurstDataSwitch == 9  ?   bramDescDOut11  :
                        wrBurstDataSwitch == 10 ?   bramDescDOut12  :
                        wrBurstDataSwitch == 11 ?   bramDescDOut13  :
                        wrBurstDataSwitch == 12 ?   bramDescDOut14  :   0;

/*
assign wr_burst_data =  {wrBurstDataSwitch,wrBurstDataSwitch,wrBurstDataSwitch,wrBurstDataSwitch,
                           wrBurstDataSwitch,wrBurstDataSwitch,wrBurstDataSwitch,wrBurstDataSwitch,
                          wrBurstDataSwitch,wrBurstDataSwitch,wrBurstDataSwitch,wrBurstDataSwitch,
                          wrBurstDataSwitch,wrBurstDataSwitch,wrBurstDataSwitch,wrBurstDataSwitch} ;
                          */
///////////////////////
////* compute fsm *////
///////////////////////

/* states */
parameter COMPUTE_IDLE      = 0;    // idle
parameter COMPUTE_INIT      = 1;    // input 2 cols
parameter COMPUTE_EXE       = 2;    // compute, input 1 col
parameter COMPUTE_LAST_EXE  = 3;    // compute last col
parameter COMPUTE_EXE_INVL  = 4;    // exe -> invl -> exe
parameter COMPUTE_IN		= 5;	// input 1 col
parameter COMPUTE_IN_INVL	= 6;	// in -> invl -> in
parameter COMPUTE_FIRST_EXE = 7;    // compute 2
parameter COMPUTE_LAST_OUT  = 8;
parameter COMPUTE_LAST_INVL = 9;
reg [3:0] computeState      = 0;

/* counter */
reg [15:0] computeRowCount  = 0;

/* arg */
/* arg */
reg [15:0] imgHeight2       = 0;
reg [15:0] bram2Size        = 0;
reg [31:0] wrAddrReg        = 0;

/* ctrl */
reg computeInFinish         = 0;
reg computeExeFinish        = 0;
reg [3:0] bram2Switch       = 0;
reg computeFinishAll        = 0;
reg [3:0] bram3Switch       = 0;

always@(posedge clk)
begin
    // reset
	if(rst || rstIn)
	begin
        // state change
		computeState <= COMPUTE_IDLE;
        computeRowCount <= 0;
        // computeInFinish <= 0;
        // computeExeFinish <= 0;
        imgHeight2 <= 0;
        bram2Size <= 0;
        finish <= 0;
        computeFinishAll <= 0;
        wr_burst_req <= 0;
	end

	else
	begin
		case(computeState)
			COMPUTE_IDLE:
			begin
                if(ctrl == 1 && !computeFinishAll)
                begin
                // /*  start
                //     -> COMPUTE_IN
                //     in 1 col
                //  */
                //     // state change
                //     computeState <= COMPUTE_IN;
                //     // ctrl
                //     bram2Switch <= 1;
                //     computeInFinish <= 0;
                //     computeExeFinish <= 0;
                //     // counter
                //     computeRowCount <= 0;
                //     // arg
                //     imgHeight2 <= imgSize[31:16] - 8;

                /*  -> COMPUTE_IN_INVL
                    sync to DETECT
                 */
                    // state change
                    computeState <= COMPUTE_IN_INVL;
                    // ctrl
                    bram2Switch <= 6;   // 6 -> 1
                    bram3Switch <= 1;
                    // counter
                    computeRowCount <= 0;
                    // arg
                    imgHeight2 <= imgSize[31:16] - 8;
                    bram2Size <= imgSize[15:0] - 6;
                    wrAddrReg <= wrAddr;
                    finish <= 0;

                end
			end

            COMPUTE_IN:
            begin
                if(computeInFinish)
                begin
                /*  -> COMPUTE_IN_INVL
                    row ++
                 */
                    // state change
                    computeState <= COMPUTE_IN_INVL;
                    // counter
                    computeRowCount <= computeRowCount + 8;
                end
            end

            COMPUTE_IN_INVL:
            begin
            /*  -> COMPUTE_IN or COMPUTE_EXE
                bram2 buffer switch
             */
                if(detectState == DETECT_EXE_INVL)  // sync to detect
                begin
                    if(computeRowCount == 32)
                    begin
                        // state change
                        computeState <= COMPUTE_FIRST_EXE;
                    end
                    else if(computeRowCount > 32)
                    begin
                        // state change
                        computeState <= COMPUTE_EXE;
                        // axi
						wr_burst_req <= 1'b1;
						wr_burst_addr <= wrAddrReg;
                        wr_burst_len <= bram3Len1 + 1;
                    end
                    else
                    begin
                        // state change
                        computeState <= COMPUTE_IN;
                    end

                    // buffer switch
                    case (bram2Switch)
                        1: bram2Switch <= 2;
                        2: bram2Switch <= 3;
                        3: bram2Switch <= 4;
                        4: bram2Switch <= 5;
                        5: bram2Switch <= 6;
                        6: bram2Switch <= 1;
                        default:
                        begin
                        end
                    endcase
                end
            end

			COMPUTE_FIRST_EXE:
            begin
                if(computeExeFinish && computeInFinish && bram3InFinish)
                begin
                /*  -> COMPUTE_EXE_INVL
                    row ++
                 */
                    // state change
                    computeState <= COMPUTE_EXE_INVL;
                    // counter
                    computeRowCount <= computeRowCount + 8;
                end
            end

			COMPUTE_EXE:
            begin
                if(wr_burst_finish)
                begin
                /*  stop burst req
                 */
                    wr_burst_req <= 0;
                end
                if(computeExeFinish && computeInFinish && bram3InFinish && bram3OutFinish)
                begin
                /*  -> COMPUTE_EXE_INVL
                    row ++
                 */
                    // state change
                    computeState <= COMPUTE_EXE_INVL;
                    // counter
                    computeRowCount <= computeRowCount + 8;
                    // arg
                    case (bram3Switch)
                        1: wrAddrReg <= wrAddrReg + {bram3Len2 + 1,3'b0};
                        2: wrAddrReg <= wrAddrReg + {bram3Len1 + 1,3'b0};
                        default:
                        begin
                        end
                    endcase
                    
                end
            end

			COMPUTE_LAST_EXE:
            begin
                if(wr_burst_finish)
                begin
                /*  stop burst req
                 */
                    wr_burst_req <= 0;
                end
                if(computeExeFinish && bram3InFinish && bram3OutFinish)
                begin
                /*  -> last invl
                    row = 0
                 */
                    // state change
                    computeState <= COMPUTE_LAST_INVL;
                    // arg
                    case (bram3Switch)
                        1: wrAddrReg <= wrAddrReg + {bram3Len2 + 1,3'b0};
                        2: wrAddrReg <= wrAddrReg + {bram3Len1 + 1,3'b0};
                        default:
                        begin
                        end
                    endcase
                end
            end

            COMPUTE_LAST_OUT:
            begin
                if(wr_burst_finish)
                begin
                /*  -> COMPUTE_IDLE
                    row = 0
                 */
                    // state change
                    computeState <= COMPUTE_IDLE;
                    finish <= 1;
                    // counter
                    computeRowCount <= 0;
                    // ctrl
                    computeFinishAll <= 1;
                    //wr_burst
                    wr_burst_req <= 0;
                end
            end

            COMPUTE_EXE_INVL:
            begin
            /*  -> COMPUTE_EXE or COMPUTE_LAST_EXE
                bram2 buffer switch
             */
                if(detectState == DETECT_EXE_INVL || computeRowCount >= imgHeight2)  // sync to detect
                begin
                    if(computeRowCount >= imgHeight2)
                    begin
                        // state change
                        computeState <= COMPUTE_LAST_EXE;
                    end
                    else
                    begin
                        // state change
                        computeState <= COMPUTE_EXE;
                    end

                    // axi
					wr_burst_req <= 1'b1;
					wr_burst_addr <= wrAddrReg;
                    case (bram3Switch)
                        1: wr_burst_len <= bram3Len1 + 1;
                        2: wr_burst_len <= bram3Len2 + 1;
                        default:
                        begin
                        end
                    endcase

                    // buffer switch
                    case (bram2Switch)
                        1: bram2Switch <= 2;
                        2: bram2Switch <= 3;
                        3: bram2Switch <= 4;
                        4: bram2Switch <= 5;
                        5: bram2Switch <= 6;
                        6: bram2Switch <= 1;
                        default:
                        begin
                        end
                    endcase
                    case (bram3Switch)
                        1: bram3Switch <= 2;
                        2: bram3Switch <= 1; 
                        default:
                        begin
                        end
                    endcase

                end
            end

            COMPUTE_LAST_INVL:
            begin
            /*  -> last out
             */
                computeState <= COMPUTE_LAST_OUT;
                
                // axi
				wr_burst_req <= 1'b1;
				wr_burst_addr <= wrAddrReg;
                case (bram3Switch)
                    1: wr_burst_len <= bram3Len1 + 1;
                    2: wr_burst_len <= bram3Len2 + 1;
                    default:
                    begin
                    end
                endcase

                // buffer switch
                case (bram3Switch)
                    1: bram3Switch <= 2;
                    2: bram3Switch <= 1; 
                    default:
                    begin
                    end
                endcase
            end
		endcase
	end
end

endmodule