`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/14 18:00:47
// Design Name: 
// Module Name: fake_dram
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


module fake_dram(
    input [9:0] addr,
    input clk,
    input we,
    input [63:0] dIn,
    input start,

    output [63:0] dOut
    );

    /////////////////
    ////* cache *////
    /////////////////
    reg [63:0] cReg0 = 0;
    reg [63:0] cReg1 = 0;
    reg [63:0] cReg2 = 0;
    reg [63:0] cReg3 = 0;
    reg [63:0] cReg4 = 0;
    reg [63:0] cReg5 = 0;
    reg [63:0] cReg6 = 0;
    reg [63:0] cReg7 = 0;

    /* cache select
     */
    assign dOut =   addr[2:0] == 0 ? cReg0 :
                    addr[2:0] == 1 ? cReg1 :
                    addr[2:0] == 2 ? cReg2 :
                    addr[2:0] == 3 ? cReg3 :
                    addr[2:0] == 4 ? cReg4 :
                    addr[2:0] == 5 ? cReg5 :
                    addr[2:0] == 6 ? cReg6 : cReg7;
    
    /* cache ctrl
     */
    always @(posedge clk)
    begin
        if(we)
        begin
            case (addr)
                8:
                begin
                    cReg0 <= dIn;
                end
                1:
                begin
                    cReg1 <= dIn;
                end
                2:
                begin
                    cReg2 <= dIn;
                end
                3:
                begin
                    cReg3 <= dIn;
                end
                4:
                begin
                    cReg4 <= dIn;
                end
                5:
                begin
                    cReg5 <= dIn;
                end
                6:
                begin
                    cReg6 <= dIn;
                end
                7:
                begin
                    cReg7 <= dIn;
                end

                default:
                begin
                end 
            endcase
        end
        else
        begin
            if(bramValid)
            begin
                case (cacheSwitch[3])
                    0:
                    begin
                        cReg0 <= bramDOut;
                    end
                    1:
                    begin
                        cReg1 <= bramDOut;
                    end
                    2:
                    begin
                        cReg2 <= bramDOut;
                    end
                    3:
                    begin
                        cReg3 <= bramDOut;
                    end
                    4:
                    begin
                        cReg4 <= bramDOut;
                    end
                    5:
                    begin
                        cReg5 <= bramDOut;
                    end
                    6:
                    begin
                        cReg6 <= bramDOut;
                    end
                    7:
                    begin
                        cReg7 <= bramDOut;
                    end

                    default:
                    begin
                    end 
                endcase
            end
        end
    end

    ////////////////
    ////* bram *////
    ////////////////
    reg [63:0] bramDIn = 0;
    wire [63:0] bramDOut;
    reg [9:0] bramAddr = 0;
    reg bramWr = 0;
    reg bramStart = 0;
    wire bramValid;

    bram_driver bram
    (
        .inputData(bramDIn),
        .outputData(bramDOut),
        .addr(bramAddr),
        .wr(bramWr),
        .clk(clk),
        .start(bramStart),
        .valid(bramValid)
    );

    reg [2:0] cacheSwitch[0:3];

    /* bram ctrl
     */
    always @(posedge clk)
    begin
        if(we)
        begin
            bramDIn <= dIn;
            bramAddr <= addr;
            bramWr <= 1;
            bramStart <= 0;
        end
        else
        begin
            bramWr <= 0;
            bramAddr <= addr + 8;
            bramStart <= start;
            cacheSwitch[0] <= addr[2:0];
        end

        cacheSwitch[1] <= cacheSwitch[0];
        cacheSwitch[2] <= cacheSwitch[1];
        cacheSwitch[3] <= cacheSwitch[2];
    end

endmodule
