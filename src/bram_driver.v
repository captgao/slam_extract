`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/13 22:48:10
// Design Name: 
// Module Name: bram_driver
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

/* out: 3 periods
 */
module bram_driver(
    input [63:0] inputData,
    output [63:0] outputData,
    input [9:0] addr,
    input wr,
    input clk,
    input start,
    output valid
    );

    reg [9:0] addrA=0;
    reg [63:0] dinA=0;
    reg ena=1;
    reg wea=0;
    reg [63:0] outputDataReg;
    wire [63:0] douta;
    assign outputData = outputDataReg;
    
    always @(posedge clk)
        outputDataReg <= douta;

    always @(negedge clk)
    begin
        addrA <= addr;
        dinA <= inputData;
        if(wr==1)
        begin
            wea <= 1;
        end
        else
        begin
            wea <= 0;
        end
    end


    blk_mem_gen_0 bram
    (
        .addra(addrA),
        .clka(clk),
        .dina(dinA),
        .douta(douta),
        .ena(ena),
        .wea(wea)
    );

    reg startReg[0:1];
    reg validReg = 0;

    assign valid = validReg;

    always @(posedge clk)
    begin
        startReg[0] <= start;
        startReg[1] <= startReg[0];
        validReg    <= startReg[1];
    end

endmodule
