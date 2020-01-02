`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/07 11:20:04
// Design Name: 
// Module Name: detect_and_compute_sim
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


module detect_and_compute_sim(

    );


    reg wr_burst_data_req = 0;
    reg wr_burst_finish = 0;
    reg rd_burst_finish = 0;
    wire rd_burst_req;
    wire wr_burst_req;
    wire[9:0] rd_burst_len;
    wire[9:0] wr_burst_len;
	wire[9:0] addrout;
    wire[31:0] rd_burst_addr;
    wire[31:0] wr_burst_addr;
    reg rd_burst_data_valid = 0;
    reg[63 : 0] rd_burst_data = 0;
    wire[63 : 0] wr_burst_data;
    wire error;

	wire [383:0] heap_din;
	wire [383:0] heap_dout;
	wire ct;
	wire insert_en;
	reg output_start = 0;
	wire heap_rst;
	wire heap_outvalid;
	wire heap_outfinish;


	reg [31:0] rdAddr = 0;
	reg [31:0] wrAddr = 32'h39000000;
	reg [31:0] ctrl = 0;
	reg rst = 0;
    wire finish;
    reg clk = 1;
    always #1 clk = ~clk;

    initial
    begin
        #2
        rst = 1;
        #4
        rst = 0;
        #4
        ctrl = 1;
        #8
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he502b2ad1f290000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hc0d7ea4f03230000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hf7e8c9145abe0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2b39ccf27d840000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h782c534409e10000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8153bf40386c0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h87cb676625d60000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h44c9d6d01fae0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h0e12bf6b5d520000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5f1e14c4d4900000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5033d630cb490000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h00747eb7fcf10000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hd49e2d3296f10000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h610cdc3bf5bb0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8df48ea145e90000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hbed566223beb0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h7bd483f613b30000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h059fef220da60000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h15d4579189db0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h07a4499d0a3c0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h3b5961e11c870000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h337eff8bdb0c0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8235691fae3e0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h1fcf8fda32990000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h183261b020240000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h7022cdca9a5e0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h92f4d199500d0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hdacc1e02ee1c0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h64cf9db940060000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h54d39c7278b70000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hce90169d36470000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb12d7249fdde0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8548722c12b30000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h3ed3e68049120000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h698f1d7e324d0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h1575f0c5f6c80000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hf8e684999e430000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h46d94fd57dbb0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h6a1d4ae9498b0000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h042a7780dca60000;



		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb4caff6d9f15c596;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h31bea00ee21d6073;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h0e7dd0e3a59a590e;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'haa9f3b6ce2953dd9;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'had8975280cc19716;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hcf8a06a19b9b272f;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hd5418c1eb4e18a67;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb01b7e2047c05968;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hcafd871d657e76d4;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h27b878cb38e92df7;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hff4f73c22aa8d04a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hd8684d03469ac24a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9df6d03f89a7c9d0;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h1472be41a986cd57;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h4d7b820782c26868;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hf414be8479b5d476;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h7999db0f7a5449fa;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h27cdc21476bf6a16;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h59d34605789a79bb;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h420d4165c2e72511;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h7cf02b1b63d908ad;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9c448c28b12361ae;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hc13afa6126d14024;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hf8b430c9df551488;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hcda67fc5da90b179;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8c6670e729383bfe;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8753f02c6d286a52;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2033a78e3ed1a5db;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h230b544662d91125;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h64cb8636e06c2843;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb8a1320896a1c1e5;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha61095dc12668c3c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h875eaaf3345ed6f4;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h954c5ba8bf4ea945;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h4cec688d39e10bd3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb00313fea63087d8;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5a4c0bbe3f9c9728;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8d73e6f289fe8cce;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h4ee6fceb5ed92f0b;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2d05f571f171f1f5;
        #2
        rd_burst_data_valid = 0;
        #2
        rd_burst_finish = 1;
        #2
        rd_burst_finish = 0;



        #20
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h92b88c848d88ca99;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h742f98c674816fe7;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'haf7310c3d938d53d;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8de2ffb18b61cfb1;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb5519aa7436bd360;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha47e43306568a1de;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h907dcd4a111295b1;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hd51dcf100862ce80;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5ed857eea5f95aad;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h6a84c775f654be08;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h40d3506f79d06541;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hfc1f5903bde727e9;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8001bf2ff7712a67;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h76bebd9eeb17f641;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h02501c6a154807a5;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h4b6b27efb878add5;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h17160310e00da19f;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h6bd62850e192bee4;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h36437f9b60296518;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb1215dc88f1da69f;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h218389816e86b415;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hdb195f433c29c942;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h7d15b9297b99c000;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5a184928f4726926;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hea98348a5bdb32fe;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h722b4ef66274344c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h1e2c60e98a1c09d1;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h822e3c9e8afa2c21;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8d8be5478f4f4d04;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h71f9dea127370193;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha80e02815cb88f2f;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8cdc9848f7b517b3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb8bc4231e5b0568f;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5ef0b26c8795c673;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hd9ca0dcd4a57db53;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h4e0e2ba43bf59d40;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'haf3db69e32dfc843;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hfa6d14de9b80a68a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hbf94ec81616cd8af;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb031bba3406d0b7e;
        #2
        rd_burst_data_valid = 0;
        #2
        rd_burst_finish = 1;
        #2
        rd_burst_finish = 0;



        #650
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hbf0e97322bc3ad94;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hc96a12b9f88fe174;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h190acaf437d62a1d;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h14425704b82ad575;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hd1c40202ed21b2e5;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h3f71b62dd51432dc;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hf8be6c2c7aa95d10;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hf20f08e0a0d40a58;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h08e36e1e5c04e546;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h68c33f014e115ada;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5101b074fa01dcf2;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'haddbe0f89f18e95b;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hc0ff3a43218d7781;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hc5301c90fcae5da0;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hecb29b0b3cbbeb7f;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h021adfa23673b55c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h94893a37851c69cb;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h12f85f168e60c51d;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hec65409281ca3a36;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9422dd08b0206ce9;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h6951ba537dcf9349;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h303cb91cbf5d9874;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hf605e4b5eed60d02;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h833d1b37b12f5755;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'haf4ac03ee445ebd2;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h63b3a637855387ac;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h95be610ee9299a1a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h41fd1d7212d7df0b;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he38d92fb07a804f7;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hbd9ee5f28b5968a9;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hdd19c846c6ccb226;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha1d0bcccec0da223;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h58a1782666ead540;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hdafe2b09e226e65b;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h4f694a7ea3eda4a3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h31d477f6f355c633;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h38fac37ab94ebcb9;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hce0418d8f4807735;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hfd6759ed90845f88;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hcaed0a5506d98d68;
        #2
        rd_burst_data_valid = 0;
        #2
        rd_burst_finish = 1;
        #2
        rd_burst_finish = 0;



        #650
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h7c0c62b7b804b1c5;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h70af4f26ae87f45c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8c833db6fdb698ef;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h80fd84a2a9308f65;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h3f23ee78492274e5;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he0a2a0d82bdd1869;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h4d44a80231e422c4;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h473169d151564f30;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h0a5c0ceecadd58de;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5fb322af80613faf;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h7418d013ec7b749c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2ada24212e6e47e2;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9a307fba453def5e;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h430918591a8c42b6;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h4be13f29395c5436;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h596128de35e72e4b;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h3034c0c6aac4dfbe;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5a75a9a6be67be00;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hbb77cb2a1cbc3956;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2b500165652fb62f;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h949affcfcef2e687;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hdcedd9f477ff0c84;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h6c4abd47bdc9676a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb563e43657cc1c54;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5afb6421b30f1b36;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9d3db8ebd313745f;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2e4933ddc9905c6c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9ce18b4b17a9feda;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h64549aa20a24773c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h87f9d96a4e119dc5;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9802c399161e6b0a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h272c40a832ad6ecb;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha84e8e12f64b9349;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h48b606c00f41483d;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hee0a61e086e5a705;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h98973734109244f3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h33c274911328b3ca;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h48793220d23f3e0e;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h489f836e2d6202d7;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hbd7920c784f5b8f2;
        #2
        rd_burst_data_valid = 0;
        #2
        rd_burst_finish = 1;
        #2
        rd_burst_finish = 0;



        #650
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h08f02c54748d136e;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'haa3f8e4dd7aaeade;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h481ca9496d1760f1;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h0f55c4cd9fb13ec2;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h41ad9d499aae59a1;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hc8514072a70595c3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hd04fc10e7505250e;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h14c432215a29dc49;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha385719d30c6f2b5;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9196afbfcd82afc7;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he858f28b907f6d80;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb35e64bea92880bc;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h50d5d0d3a5c0d23e;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2f88f23987efe5c2;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h601e48044b6a830b;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h908141e1f41257e2;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2b56d6fd8e4245b9;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h858c4640afe9e9ce;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he3bb5fa4703fa0b7;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb7e9091dee8bc4b1;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he39f9637a331ec11;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h1d6dff0aa64f67b3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2025841f2ab10f76;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2fc8e665258afa64;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2deb5f740a770269;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h6209c5508bf73ba3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h280d17956b908f08;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hd319c568d8aecacd;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h501d3e7dd904e415;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h104afc47b09fe128;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h170733ba8bedf91c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5d31631d08d6b9eb;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he701c336d612d1e9;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he85884d24e262d5a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hf7ec9234327f22b8;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hc497ab9ed1ec56bf;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he2d5082381aeeeb7;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha80da3f677fc3c55;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he17caa44774503da;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hc8153f39fb01cb5c;
        #2
        rd_burst_data_valid = 0;
        #2
        rd_burst_finish = 1;
        #2
        rd_burst_finish = 0;



        #650
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha3fc35489f9d15cf;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hb5590f6eb137023a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8e174eeec63ac065;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h038959c3d9ef20ca;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h16a250b51d06a258;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h35bed63a8acce82c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hbf20f890864ba52d;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9a07a312fc8cf2e2;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h139dde6bccfff20c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h3dab277273b6ea60;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hed02551c244c07dc;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h88a7e00f5086d72c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h202d6cd181576162;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hcaedeb6e83198705;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h6aa7f7dcb225b73c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he7b96bedb4367062;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hc62fbb1a71d7dbfa;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hd27d7425a32587c5;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha5703d3fbd93b199;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h762f36728c72d7b0;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h949fc1ca3bcbe527;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h35fb6c9e8b8ee940;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h51d4777b75ce4468;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h32ae61055ba731c3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h675bf17529bfe1ab;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hf2570ba8ed3c1dba;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hc34b4c760d69732d;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h26e50b0995288224;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he829bccab2878dc1;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h96d28dcbef437310;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9c6a59e765799c9b;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h831e6869aec6c6c4;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h55fc58d14482ce61;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hfb25e47edf15d4f1;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha94f1bb8e7f957fc;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hf312137477a13dd8;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8573c071411facbf;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2effaa9a22f7b04a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h073f0fb0af6da1d3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h2b02a6ecaa3e06e6;
        #2
        rd_burst_data_valid = 0;
        #2
        rd_burst_finish = 1;
        #2
        rd_burst_finish = 0;

		#20
		wr_burst_data_req = 1;
		#40
		wr_burst_data_req = 0;
		#2
		wr_burst_finish = 1;
		#2
		wr_burst_finish = 0;

        #650

		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8d6fbed37a74f526;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hd33d13ca7e6e7db1;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9db46de4485dfa8b;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9bd983c7972977bf;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hfe4245fd14698e4a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h692aa270137051e3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5cf68bc6a4f6e260;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h173afde475bfcf3b;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9be49198e0c69b22;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha333c807b43d2ebc;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hc3553907ea2282f2;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'heaf3d95464c9896f;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h4d7893f11740da08;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5278423a4c4a67bd;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'ha9be8af2aecd300b;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h9f49e541b392ba0a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h40ffaf5f93c4dfc3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h81897594d95cd627;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h40d6a33b43f9ab3c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'haa61c7a37e262e6b;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'he9dabfc8d6011207;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h64d75ff166fbd06c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h3f99d89ddc60467f;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hfc5493553a65ffb3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h48895a664e26f73c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h8b68cc32392358e3;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h404112c1f15b491a;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hd5859d6e8e57661f;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h6ab956cbd8edb280;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5bcfcd354d3e93bf;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h666a7462e50294c7;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hda338cce64bfd295;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h337e8b2382d8caef;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hbf5c6605034f7d42;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h44733eafe5958511;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h674ab0f741f3377c;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h5adddaba95ba2d22;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h1b90874d1470d92e;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'hfa27f1f0131b1c01;
		#2
		rd_burst_data_valid = 1;
		rd_burst_data = 64'h267f961fd1eaa9d1;
        #2
        rd_burst_data_valid = 0;
        #2
        rd_burst_finish = 1;
        #2
        rd_burst_finish = 0;



		#20
		wr_burst_data_req = 1;
		#80
		wr_burst_data_req = 0;
		#2
		wr_burst_finish = 1;
		#2
		wr_burst_finish = 0;



		#600
		wr_burst_data_req = 1;
		#80
		wr_burst_data_req = 0;
		#2
		wr_burst_finish = 1;
		#2
		wr_burst_finish = 0;



		#200
		wr_burst_data_req = 1;
		#80
		wr_burst_data_req = 0;
		#2
		wr_burst_finish = 1;
		#2
		wr_burst_finish = 0;

		#100
		output_start = 1;
		#4
		output_start = 0;
    end

    detect_and_compute
	#(
		.MEM_DATA_BITS(64),
		.ADDR_BITS(32)
	)
	t
	(
		.ctrl(ctrl),
		.rdAddr(rdAddr),
		.wrAddr(wrAddr),
		.rstIn(rst),
		.finish(finish),
		.batch(1),
        .imgSize(32'h00400028),
                          
		.rst(rst),      
		.clk(clk),                             
		.rd_burst_req(rd_burst_req),               
		.wr_burst_req(wr_burst_req),               
		.rd_burst_len(rd_burst_len),               
		.wr_burst_len(wr_burst_len),               
		.rd_burst_addr(rd_burst_addr),        
		.wr_burst_addr(wr_burst_addr),        
		.rd_burst_data_valid(rd_burst_data_valid),  
		.wr_burst_data_req(wr_burst_data_req),  
		.rd_burst_data(rd_burst_data),  
		.wr_burst_data(wr_burst_data),    
		.rd_burst_finish(rd_burst_finish),   
		.wr_burst_finish(wr_burst_finish),

		.error(error),

		.heap_din(heap_din),
		.heap_ct(ct),
		.heap_valid(insert_en)

	); 
	heap h0(
		.clk(clk),
		.rst(rst),
		.ct(ct),
		.insert_en(insert_en),
		.d_in(heap_din),
		.out(heap_dout),
		.output_start(output_start),
		.outValid(heap_outvalid),
		.outFinish(heap_outfinish),
		.addrout(addrout)
	);
endmodule
