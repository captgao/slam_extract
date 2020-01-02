
`timescale 1 ns / 1 ps

	module WriteTest_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 6
	)
	(
		// Users to add ports here

		input wire M_AXI_ACLK,

		// Master Write Address
		output [0:0]  M_AXI_AWID,
		output [31:0] M_AXI_AWADDR,
		output [7:0]  M_AXI_AWLEN,    // Burst Length: 0-255
		output [2:0]  M_AXI_AWSIZE,   // Burst Size: Fixed 2'b011
		output [1:0]  M_AXI_AWBURST,  // Burst Type: Fixed 2'b01(Incremental Burst)
		output        M_AXI_AWLOCK,   // Lock: Fixed 2'b00
		output [3:0]  M_AXI_AWCACHE,  // Cache: Fiex 2'b0011
		output [2:0]  M_AXI_AWPROT,   // Protect: Fixed 2'b000
		output [3:0]  M_AXI_AWQOS,    // QoS: Fixed 2'b0000
		output [0:0]  M_AXI_AWUSER,   // User: Fixed 32'd0
		output        M_AXI_AWVALID,
		input         M_AXI_AWREADY,

		// Master Write Data
		output [63:0] M_AXI_WDATA,
		output [7:0]  M_AXI_WSTRB,
		output        M_AXI_WLAST,
		output [0:0]  M_AXI_WUSER,
		output        M_AXI_WVALID,
		input         M_AXI_WREADY,

		// Master Write Response
		input [0:0]   M_AXI_BID,
		input [1:0]   M_AXI_BRESP,
		input [0:0]   M_AXI_BUSER,
		input         M_AXI_BVALID,
		output        M_AXI_BREADY,
			
		// Master Read Address
		output [0:0]  M_AXI_ARID,
		output [31:0] M_AXI_ARADDR,
		output [7:0]  M_AXI_ARLEN,
		output [2:0]  M_AXI_ARSIZE,
		output [1:0]  M_AXI_ARBURST,
		output [1:0]  M_AXI_ARLOCK,
		output [3:0]  M_AXI_ARCACHE,
		output [2:0]  M_AXI_ARPROT,
		output [3:0]  M_AXI_ARQOS,
		output [0:0]  M_AXI_ARUSER,
		output        M_AXI_ARVALID,
		input         M_AXI_ARREADY,
			
		// Master Read Data 
		input [0:0]   M_AXI_RID,
		input [63:0]  M_AXI_RDATA,
		input [1:0]   M_AXI_RRESP,
		input         M_AXI_RLAST,
		input [0:0]   M_AXI_RUSER,
		input         M_AXI_RVALID,
		output        M_AXI_RREADY,

/*
		output heap_outfinish,
        output [383:0] heap_out_data,
        output heap_out_valid,
*/
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,


		output [31:0] addrx16,
		output [31:0] addrx32,
		output clkb,
		output [255:0] dout_desc,
		output [127:0] dout_128,
		output reg enb,
		output reg rstb,
		output [15:0] we16,
		output [31:0] we32
	);
// Instantiation of Axi Bus Interface S00_AXI
wire heap_outstart;
genvar i;

assign clkb = M_AXI_ACLK;
wire[383:0] heap_out_data;
assign dout_desc = heap_out_data[344:88];
assign dout_128 = {heap_out_data[383:344],heap_out_data[87:0]};
reg[9:0] addrb;
assign addrx16 = {18'b0,addrb,4'b0};
assign addrx32 = {17'b0,addrb,5'b0};
generate
	for(i = 0; i < 16; i = i + 1) begin
		assign we16[i] = heap_out_valid;
	end
	for(i = 0; i < 32; i = i + 1) begin
		assign we32[i] = heap_out_valid;
	end
endgenerate
reg heap_prevfinish;
	always @(posedge M_AXI_ACLK) begin
		if(~rst_n || rst) begin
			addrb <= 0;
			rstb <= 0;
			enb <=0;
		end
		else begin
			heap_prevfinish <= heap_outfinish;
			if(heap_outfinish == 1 && heap_prevfinish == 0) begin
				addrb <= 0;
				enb <= 0;
			end
			else if(heap_outstart) begin
				enb <= 1;
			end
			if(heap_out_valid) begin
				addrb <= addrb + 1;
			end
		end
	end
	wire [31:0] rdAddr;

	(*mark_debug="true"*)wire [31:0] wrAddr;
	(*mark_debug="true"*)wire [31:0] ctrl;
	wire [31:0] imgsize;
	wire [31:0] batch;
	wire rst;
	wire finish;
	WriteTest_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) WriteTest_v1_0_S00_AXI_inst (

		.rdAddr(rdAddr),
		.wrAddr(wrAddr),

		.ctrl(ctrl),
		.rst(rst),
		.finish(finish),
		.debug(debug_state),
		.heap_outstart(heap_outstart),
		.heap_outfinish(heap_outfinish),
		.imgsize(imgsize),
		.batch(batch),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here
	
	wire rst_n;

	Reset reset_m0(
		.clk(M_AXI_ACLK),
		.rst_n(rst_n)
	);

	(*mark_debug="true"*)wire wr_burst_data_req;
	(*mark_debug="true"*)wire wr_burst_finish;
	(*mark_debug="true"*)wire rd_burst_finish;
	(*mark_debug="true"*)wire rd_burst_req;
	(*mark_debug="true"*)wire wr_burst_req;
	(*mark_debug="true"*)wire[28:0] rd_burst_len;
	(*mark_debug="true"*)wire[28:0] wr_burst_len;
	(*mark_debug="true"*)wire[31:0] rd_burst_addr;
	(*mark_debug="true"*)wire[31:0] wr_burst_addr;
	(*mark_debug="true"*)wire rd_burst_data_valid;
	(*mark_debug="true"*)wire[63 : 0] rd_burst_data;
	(*mark_debug="true"*)wire[63 : 0] wr_burst_data;
	(*mark_debug="true"*)wire error;

    
        wire [383:0] heap_din;
        wire heap_valid;
        wire heap_ct;
        wire [7:0] debug_state;
	detect_and_compute
	#(
		.MEM_DATA_BITS(64),
		.ADDR_BITS(32)
	)
	mem_test_m0
	(
		.ctrl(ctrl),
		.rdAddr(rdAddr),
		.wrAddr(wrAddr),
		.rstIn(rst),
		.finish(finish),

		.imgSize(imgsize),
		.batch(batch),
		.rst(~rst_n),      
		.clk(M_AXI_ACLK),                             
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

            /* heap fifo */
        .heap_din(heap_din),
        .heap_valid(heap_valid),
        .heap_ct(heap_ct),
        .debug(debug_state),
		.error(error)
	); 

    heap h0
    (
        .d_in(heap_din),
        .clk(M_AXI_ACLK),
        .ct(heap_ct),
        .insert_en(heap_valid),
        .output_start(heap_outstart),
        .out(heap_out_data),
        .outValid(heap_out_valid),
		.outFinish(heap_outfinish),
		.rst(~rst_n)
    );


	aq_axi_master u_aq_axi_master
    (
      .ARESETN(rst_n),
      .ACLK(M_AXI_ACLK),
      
      .M_AXI_AWID(M_AXI_AWID),
      .M_AXI_AWADDR(M_AXI_AWADDR),
	  .M_AXI_AWLEN(M_AXI_AWLEN),
      .M_AXI_AWSIZE(M_AXI_AWSIZE),
      .M_AXI_AWBURST(M_AXI_AWBURST),
      .M_AXI_AWLOCK(M_AXI_AWLOCK),
      .M_AXI_AWCACHE(M_AXI_AWCACHE),
      .M_AXI_AWPROT(M_AXI_AWPROT),
      .M_AXI_AWQOS(M_AXI_AWQOS),
      .M_AXI_AWUSER(M_AXI_AWUSER),
      .M_AXI_AWVALID(M_AXI_AWVALID),
      .M_AXI_AWREADY(M_AXI_AWREADY),
      
      .M_AXI_WDATA(M_AXI_WDATA),
      .M_AXI_WSTRB(M_AXI_WSTRB),
      .M_AXI_WLAST(M_AXI_WLAST),
      .M_AXI_WUSER(M_AXI_WUSER),
      .M_AXI_WVALID(M_AXI_WVALID),
      .M_AXI_WREADY(M_AXI_WREADY),
      
      .M_AXI_BID(M_AXI_BID),
      .M_AXI_BRESP(M_AXI_BRESP),
      .M_AXI_BUSER(M_AXI_BUSER),
      .M_AXI_BVALID(M_AXI_BVALID),
      .M_AXI_BREADY(M_AXI_BREADY),
      
      .M_AXI_ARID(M_AXI_ARID),
      .M_AXI_ARADDR(M_AXI_ARADDR),
      .M_AXI_ARLEN(M_AXI_ARLEN),
      .M_AXI_ARSIZE(M_AXI_ARSIZE),
      .M_AXI_ARBURST(M_AXI_ARBURST),
      .M_AXI_ARLOCK(M_AXI_ARLOCK),
      .M_AXI_ARCACHE(M_AXI_ARCACHE),
      .M_AXI_ARPROT(M_AXI_ARPROT),
      .M_AXI_ARQOS(M_AXI_ARQOS),
      .M_AXI_ARUSER(M_AXI_ARUSER),
      .M_AXI_ARVALID(M_AXI_ARVALID),
      .M_AXI_ARREADY(M_AXI_ARREADY),
      
      .M_AXI_RID(M_AXI_RID),
      .M_AXI_RDATA(M_AXI_RDATA),
      .M_AXI_RRESP(M_AXI_RRESP),
      .M_AXI_RLAST(M_AXI_RLAST),
      .M_AXI_RUSER(M_AXI_RUSER),
      .M_AXI_RVALID(M_AXI_RVALID),
      .M_AXI_RREADY(M_AXI_RREADY),
      
      .MASTER_RST(1'b0),
      
      .WR_START(wr_burst_req),
    //   .WR_ADRS({1'b1,wr_burst_addr[24:0],3'd0}),
      .WR_ADRS(wr_burst_addr),
      .WR_LEN({wr_burst_len,3'd0}), 
      .WR_READY(),
      .WR_FIFO_RE(wr_burst_data_req),
      .WR_FIFO_EMPTY(1'b0),
      .WR_FIFO_AEMPTY(1'b0),
      .WR_FIFO_DATA(wr_burst_data),
	  .WR_DONE(wr_burst_finish),
      
      .RD_START(rd_burst_req),
    //   .RD_ADRS({1'b1,rd_burst_addr[24:0],3'd0}),
      .RD_ADRS(rd_burst_addr),
      .RD_LEN({rd_burst_len,3'd0}), 
      .RD_READY(),
      .RD_FIFO_WE(rd_burst_data_valid),
      .RD_FIFO_FULL(1'b0),
      .RD_FIFO_AFULL(1'b0),
      .RD_FIFO_DATA(rd_burst_data),
      .RD_DONE(rd_burst_finish),
      .DEBUG()                                         
    );




	// User logic ends

	endmodule
