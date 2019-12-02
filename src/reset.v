/*���ϵ縴λģ��
����������0xffffʱ��λ�ź�Ϊ1
*/
module Reset(
	input clk,
	output rst_n
);
reg[15:0] cnt = 16'd0;
reg rst_n_reg;
assign rst_n = rst_n_reg;
always@(posedge clk)
	if(cnt != 16'hffff)
		cnt <= cnt + 16'd1;
	else
		cnt <= cnt;
always@(posedge clk)
	rst_n_reg <= (cnt == 16'hffff);
endmodule 