module KeyboardAdapter(
	input wire clk, rst,
	input wire ps2data, ps2clk,

	output wire [6:0] data,
	output wire status
	//output wire[3:0] status_debug
);

wire e0;
wire f0;
wire[7:0] raw_data;
wire[6:0] addr;
//reg[127:0] one_hot_key_down = 128'h0;
reg query_res;
wire data_ready;

assign data = addr;
assign status = query_res;

always @(posedge clk) begin
	if (data_ready == 1) begin
		if (f0 == 1)
			query_res <= 0;
		else
			query_res <= 1;
	end
	else query_res <= query_res;
end

keyboard keyboard0(
	.clk(clk), .rst(rst),
	.ps2data(ps2data), .ps2clk(ps2clk),
	.data_ready(data_ready),
	.e0_flag(e0),
	.break_flag(f0), 
	.out(raw_data)
);

keyboard2ascii keyboard2ascii0(
	.e0_flag(e0),
	.key(raw_data),
	.ascii(addr)
);

endmodule