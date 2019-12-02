`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/09/12 12:19:08
// Design Name: 
// Module Name: heap
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


module heap(
    input [343:0] d_in,
    input clk,
    input ct,
    input insert_en,
    input output_start,
    input rst,
    output [343:0] out,
    output reg outFinish,
    output outValid
    );

    reg [9:0] addrInL[1:10];
    reg [9:0] addrInR[1:10];
    reg [9:0] addrOutL[1:10];
    reg [9:0] addrOutR[1:10];

    reg [343:0] dIn[1:10];
    reg we[1:10];
    reg weL[1:10];
    reg weR[1:10];
    reg [10:0] inCount;
    wire [343:0] dOutL[1:10];
    wire [343:0] dOutR[1:10];

    reg [343:0] outRegNeg;
    reg [343:0] outReg;
    assign out = outReg;

    reg outValidReg;
    assign outValid = outValidReg;

    /* gen out
     */
    always @(negedge clk)
    begin
        if(outKeepDelay)
        begin
            case (outLevelDelay)
                1  : outRegNeg <= dOutL[1];
                2  : outRegNeg <= outCountDelay<=1   ? dOutL[2 ] : dOutR[2 ];
                3  : outRegNeg <= outCountDelay<=2   ? dOutL[3 ] : dOutR[3 ];
                4  : outRegNeg <= outCountDelay<=4   ? dOutL[4 ] : dOutR[4 ];
                5  : outRegNeg <= outCountDelay<=8   ? dOutL[5 ] : dOutR[5 ];
                6  : outRegNeg <= outCountDelay<=16  ? dOutL[6 ] : dOutR[6 ];
                7  : outRegNeg <= outCountDelay<=32  ? dOutL[7 ] : dOutR[7 ];
                8  : outRegNeg <= outCountDelay<=64  ? dOutL[8 ] : dOutR[8 ];
                9  : outRegNeg <= outCountDelay<=128 ? dOutL[9 ] : dOutR[9 ];
                10 : outRegNeg <= outCountDelay<=256 ? dOutL[10] : dOutR[10];
                default: ;
            endcase
        end
    end
    always @(posedge clk)
    begin
        outReg <= outRegNeg;
        outValidReg <= outKeepDelay;
    end

    /* output paras
     */
    reg [7:0] outLevel = 0;
    reg [15:0] outCount = 0;
    reg outKeep = 0;
    reg [7:0] outLevelDelay = 0;
    reg [15:0] outCountDelay = 0;
    reg outKeepDelay = 0;
    always @(posedge clk)
    begin
        if(rst) begin
            outFinish <= 0;
            outCount <= 0;
            outKeep <= 0;
            inCount <= 0;
        end
        else if(output_start || outKeep)
        begin
            // output_start only keeps 1 period, init
            if(output_start && outKeep == 0)
            begin
                outKeep <= 1;
                outCount <= 1;
                outLevel <= 1;
                outFinish <= 0;
            end
            else    // outKeep 1
            begin
                if( outLevel == 1 && outCount >= 1      ||
                    outLevel == 2 && outCount >= 2      ||
                    outLevel == 3 && outCount >= 4      ||
                    outLevel == 4 && outCount >= 8      ||
                    outLevel == 5 && outCount >= 16     ||
                    outLevel == 6 && outCount >= 32     ||
                    outLevel == 7 && outCount >= 64     ||
                    outLevel == 8 && outCount >= 128    ||
                    outLevel == 9 && outCount >= 256    ||
                    outLevel == 10 && outCount >= 512   )
                begin
                    if(outLevel == 10)  // out finish
                    begin
                        outKeep <= 0;
                        inCount <= 0;
                        outFinish <= 1;
                    end
                    else    // next level
                    begin
                        outLevel <= outLevel + 1;
                        outCount <= 1;
                    end
                end
                else
                begin
                    outCount <= outCount + 1;
                end
            end
        end
        else begin
            if(ct == 0 && insert_en && d_in > dOutL[1]) begin
                inCount <= inCount + 1;
            end
        end
        outLevelDelay <= outLevel;
        outCountDelay <= outCount;
        outKeepDelay <= outKeep;
    end

    /* drams
     */
    dram_w8_d16 layer1
    (
        .a(addrInL[1]),
        .d(dIn[1]),
        .dpra(addrOutL[1]),
        .clk(~clk),
        .we(we[1]),
        .dpo(dOutL[1])
    );

    genvar i;
    generate
        for ( i=2 ; i<7 ; i=i+1 ) 
        begin
            dram_w8_d16 layerL
            (
                .a(addrInL[i]),
                .d(dIn[i]),
                .dpra(addrOutL[i]),
                .clk(~clk),
                .we(weL[i]),
                .dpo(dOutL[i])
            );
            dram_w8_d16 layerR
            (
                .a(addrInR[i]),
                .d(dIn[i]),
                .dpra(addrOutR[i]),
                .clk(~clk),
                .we(weR[i]),
                .dpo(dOutR[i])
            );
        end
    endgenerate
    
    dram_w8_d32 layer7L
    (
        .a(addrInL[7]),
        .d(dIn[7]),
        .dpra(addrOutL[7]),
        .clk(~clk),
        .we(weL[7]),
        .dpo(dOutL[7])
    );
    dram_w8_d32 layer7R
    (
        .a(addrInR[7]),
        .d(dIn[7]),
        .dpra(addrOutR[7]),
        .clk(~clk),
        .we(weR[7]),
        .dpo(dOutR[7])
    );

    dram_w8_d64 layer8L
    (
        .a(addrInL[8]),
        .d(dIn[8]),
        .dpra(addrOutL[8]),
        .clk(~clk),
        .we(weL[8]),
        .dpo(dOutL[8])
    );
    dram_w8_d64 layer8R
    (
        .a(addrInR[8]),
        .d(dIn[8]),
        .dpra(addrOutR[8]),
        .clk(~clk),
        .we(weR[8]),
        .dpo(dOutR[8])
    );

    dram_w8_d128 layer9L
    (
        .a(addrInL[9]),
        .d(dIn[9]),
        .dpra(addrOutL[9]),
        .clk(~clk),
        .we(weL[9]),
        .dpo(dOutL[9])
    );
    dram_w8_d128 layer9R
    (
        .a(addrInR[9]),
        .d(dIn[9]),
        .dpra(addrOutR[9]),
        .clk(~clk),
        .we(weR[9]),
        .dpo(dOutR[9])
    );

    
    dram_w8_d256 layer10L
    (
        .a(addrInL[10]),
        .d(dIn[10]),
        .dpra(addrOutL[10]),
        .clk(~clk),
        .we(weL[10]),
        .dpo(dOutL[10])
    );
    dram_w8_d256 layer10R
    (
        .a(addrInR[10]),
        .d(dIn[10]),
        .dpra(addrOutR[10]),
        .clk(~clk),
        .we(weR[10]),
        .dpo(dOutR[10])
    );

    /* init
     */
    generate
        for ( i=1 ; i<11 ; i=i+1 ) 
        begin
            initial
            begin
                addrInL[i]  <= 0;
                addrInR[i]  <= 0;
                addrOutL[i] <= 0;
                addrOutR[i] <= 0;
                dIn[i]  <= 0;
                we[i]   <= 0;
                weL[i]  <= 0;
                weR[i]  <= 0;
            end  
        end
    endgenerate

    /* level 1
     */
    always @(posedge clk)
    begin
        /* output */
        if(outKeep)
        begin
            if(outLevel == 1)
            begin
                // output
                addrOutL[1] <= outCount - 1;

                // reset
                we[1] <= 1;
                dIn[1] <= 0;
                addrInL[1] <= 0;
            end
            else
            begin
                addrOutL[1] <= 0;
                we[1] <= 0;
                addrInL[1] <= 0;
            end

            if(outLevel == 2)
            begin
                /* left */
                if(outCount <= 1)
                begin
                    // output addr
                    addrOutL[2] <= outCount - 1;
                end
                /* right */
                else
                begin
                    // output addr
                    addrOutR[2] <= outCount - 2;
                end
            end
            else
            begin
                addrOutL[2] <= 0;
                addrOutR[2] <= 0;
            end
        end
        /* input */
        else
        begin
            addrOutL[1] <= 0;
            addrInL[1]  <= 0;

            addrOutL[2] <= 0;
            addrOutR[2] <= 0;
            // cmp with d_in
            if(ct == 0)
            begin
                if(insert_en && d_in > dOutL[1] )   // input
                begin
                    we[1] <= 1;
                    dIn[1] <= d_in;
                end
                else
                begin
                    // no change for layer1
                    we[1] <= 0;
                end
            end
            // cmp with lower layer
            else    // ct == 1
            begin
                if(we[1])   // this layer is inputting (parent changing)
                begin
                    if(dOutL[2] < dIn[1] && dOutL[2] <= dOutR[2])       // left child min
                    begin
                        // parent <= left child
                        // we & addrIn don't need to change
                        dIn[1] <= dOutL[2];
                    end
                    else if(dOutR[2] < dIn[1] && dOutR[2] < dOutL[2])   // right child min
                    begin
                        // parent <= right child
                        dIn[1] <= dOutR[2];
                    end
                    else
                    begin
                        we[1] <= 0;
                    end
                end
                else
                begin
                    we[1] <= 0;
                end
            end
        end
    end


    /* level 2~9
     */
    generate
        for(i=2; i<10; i=i+1)
        begin
            always @(posedge clk)
            begin
                /* output */
                if(outKeep)
                begin
                    if(outLevel == i)
                    begin
                        /* left */
                        if(outCount <= 2**(i-2))
                        begin
                            // reset
                            addrInL[i] <= outCount - 1;
                            weL[i] <= 1;
                            dIn[i] <= 0;
                        end
                        /* right */
                        else
                        begin
                            // reset
                            addrInR[i] <= outCount - 2**(i-2) - 1;
                            weR[i] <= 1;
                            dIn[i] <= 0;
                        end
                    end
                    else
                    begin
                        weL[i] <= 0;
                        weR[i] <= 0;
                        addrInL[i] <= 0;
                        addrInR[i] <= 0;
                    end

                    if(outLevel == i + 1)
                    begin
                        /* left */
                        if(outCount <= 2**(i-1))
                        begin
                            // output addr
                            addrOutL[i+1] <= outCount - 1;
                        end
                        /* right */
                        else
                        begin
                            // output addr
                            addrOutR[i+1] <= outCount - 2**(i-1) - 1;
                        end
                    end
                    else
                    begin
                        addrOutL[i+1] <= 0;
                        addrOutR[i+1] <= 0;
                    end
                end

                /* input */
                else
                begin
                    // cmp with upper layer
                    if(ct == (i+1)%2)
                    begin
                        if(we[i-1])   // upper layer is writting
                        begin
                            if(dOutL[i] < dIn[i-1] && dOutL[i] <= dOutR[i])       // left child min
                            begin
                                // left child <= parent
                                we[i] <= 1;
                                weL[i] <= 1;
                                weR[i] <= 0;

                                addrInL[i] <= addrOutL[i];
                                dIn[i] <= dIn[i-1];   // dIn[i-1] hasn't been loaded to layer[i-1] yet

                                // decide layer[i+1]'s out addr
                                addrOutL[i+1] <= addrOutL[i] * 2;
                                addrOutR[i+1] <= addrOutL[i] * 2;
                            end
                            else if(dOutR[i] < dIn[i-1] && dOutR[i] < dOutL[i])   // right child min
                            begin
                                // right child <= parent
                                we[i] <= 1;
                                weL[i] <= 0;
                                weR[i] <= 1;

                                addrInR[i] <= addrOutR[i];
                                dIn[i] <= dIn[i-1];

                                // decide layer[i+1]'s out addr
                                addrOutL[i+1] <= addrOutR[i] * 2 + 1;
                                addrOutR[i+1] <= addrOutR[i] * 2 + 1;
                            end
                            else    // parent min
                            begin
                                // no change for layer[i]
                                we[i] <= 0;
                                weL[i] <= 0;
                                weR[i] <= 0;
                            end
                        end
                        else    // upper layer did not change
                        begin
                            // no change for layer[i]
                            we[i] <= 0;
                            weL[i] <= 0;
                            weR[i] <= 0;
                        end
                    end
                    // cmp with lower layer
                    else    // ct == 0
                    begin
                        if(we[i])   // this layer is inputting (parent changing)
                        begin
                            if(dOutL[i+1] < dIn[i] && dOutL[i+1] <= dOutR[i+1])       // left child min
                            begin
                                // parent <= left child
                                // we & addrIn don't need to change
                                dIn[i] <= dOutL[i+1];
                            end
                            else if(dOutR[i+1] < dIn[i] && dOutR[i+1] < dOutL[i+1])   // right child min
                            begin
                                // parent <= right child
                                dIn[i] <= dOutR[i+1];
                            end
                            else
                            begin
                                we[i] <= 0;
                                weL[i] <= 0;
                                weR[i] <= 0;
                            end
                        end
                        else
                        begin
                            we[i] <= 0;
                            weL[i] <= 0;
                            weR[i] <= 0;
                        end
                    end
                end
            end
        end
    endgenerate


    /* level 10
     */
    always @(posedge clk)
    begin
        /* output */
        if(outKeep)
        begin
            if(outLevel == 10)
            begin
                /* left */
                if(outCount <= 2**8)
                begin
                    // reset
                    addrInL[10] <= outCount - 1;
                    weL[10] <= 1;
                    dIn[10] <= 0;
                end
                /* right */
                else
                begin
                    // reset
                    addrInR[10] <= outCount - 2**8 - 1;
                    weR[10] <= 1;
                    dIn[10] <= 0;
                end
            end
            else
            begin
                weL[10] <= 0;
                weR[10] <= 0;
                addrInL[10] <= 0;
                addrInR[10] <= 0;
            end
        end

        /* input */
        else
        begin
            // cmp with upper layer
            if(ct == 1)
            begin
                if(we[9])   // upper layer is writting
                begin
                    if(dOutL[10] < dIn[9] && dOutL[10] <= dOutR[10])       // left child min
                    begin
                        // left child <= parent
                        we[10] <= 1;
                        weL[10] <= 1;
                        weR[10] <= 0;

                        addrInL[10] <= addrOutL[10];
                        dIn[10] <= dIn[9];   // dIn[1] hasn't been loaded to layer1 yet
                    end
                    else if(dOutR[10] < dIn[9] && dOutR[10] < dOutL[10])   // right child min
                    begin
                        // right child <= parent
                        we[10] <= 1;
                        weL[10] <= 0;
                        weR[10] <= 1;

                        addrInR[10] <= addrOutR[10];
                        dIn[10] <= dIn[9];
                    end
                    else    // parent min
                    begin
                        // no change for layer2
                        we[10] <= 0;
                        weL[10] <= 0;
                        weR[10] <= 0;
                    end
                end
                else    // upper layer did not change
                begin
                    // no change for layer2
                    we[10] <= 0;
                    weL[10] <= 0;
                    weR[10] <= 0;
                end
            end
        end
    end

endmodule
