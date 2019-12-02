`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/09 10:56:54
// Design Name: 
// Module Name: heap_fifo
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


module heap_fifo(
    input [343:0] dIn,
    input we,
    input clk,
    output [343:0] dOut,
    output valid,
    output ct
    );
    
    reg [343:0] stack[0:9];
    reg [7:0] pointer = 0;
    reg [343:0] dOutReg = 0;
    assign dOut = dOutReg;

    reg validReg = 0;
    assign valid = validReg;

    reg ctReg = 1;
    assign ct = ctReg;

    /* gen ct
     */
    always @(posedge clk)
    begin
        ctReg <= ~ctReg;
    end

    always @(posedge clk)
    begin
        if(we)
        begin
            if(ct == 1)
            begin
                // input -> output
                dOutReg <= dIn;
                validReg <= 1;
            end
            else
            begin
                // input
                pointer <= pointer + 1;
                case (pointer)
                    0   :   stack[0 ] <= dIn;
                    1   :   stack[1 ] <= dIn; 
                    2   :   stack[2 ] <= dIn; 
                    3   :   stack[3 ] <= dIn; 
                    4   :   stack[4 ] <= dIn; 
                    5   :   stack[5 ] <= dIn; 
                    6   :   stack[6 ] <= dIn; 
                    7   :   stack[7 ] <= dIn; 
                    8   :   stack[8 ] <= dIn; 
                    9   :   stack[9 ] <= dIn; 
                  default: 
                  begin
                  end
                endcase

                validReg <= 0;
            end
        end
        else
        begin
            if(ct == 1 && pointer >= 1)
            begin
                // output
                validReg <= 1;
                pointer <= pointer - 1;
                case (pointer)
                    1   :   dOutReg <= stack[0 ];
                    2   :   dOutReg <= stack[1 ]; 
                    3   :   dOutReg <= stack[2 ]; 
                    4   :   dOutReg <= stack[3 ]; 
                    5   :   dOutReg <= stack[4 ]; 
                    6   :   dOutReg <= stack[5 ]; 
                    7   :   dOutReg <= stack[6 ]; 
                    8   :   dOutReg <= stack[7 ]; 
                    9   :   dOutReg <= stack[8 ]; 
                    10  :   dOutReg <= stack[9 ]; 
                  default: 
                  begin
                  end
                endcase
            end
            else
            begin
                validReg <= 0;
            end
        end
    end

endmodule
