module keyboard(
	input wire clk, rst,

	input wire ps2data, ps2clk, // PS2 data and clk

	output reg data_ready,

	output reg e0_flag,
	output reg break_flag,
	output wire[7:0] out
	//output wire[3:0] status_debug
);	

reg[7:0] data_received;
reg tmpclk1, tmpclk2;

reg[3:0] status;
reg parity;
reg[8:1] record;
reg recv_break;
reg recv_e0;

assign out = data_received;

	always @(posedge clk) begin
		tmpclk1 <= ps2clk;
		tmpclk2 <= tmpclk1;

		if(!rst) begin
			status <= 4'd0;
			parity <= 1'b0;
			record <= 8'd0;
			break_flag <= 0;
			e0_flag <= 0;
			recv_break <= 0;
			recv_e0 <= 0;
			data_ready <= 0;
		end else begin
			if((!tmpclk1) & tmpclk2) begin
				if(status == 0) begin
					if(ps2data == 1'b0) status <= 1;
					parity <= 1'b0;
					break_flag <= break_flag;
					recv_break <= recv_break;
					e0_flag <= e0_flag;
					recv_e0 <= recv_e0;
					data_ready <= 0;
				end 
				if(status < 9) begin
					record[status] <= ps2data;
					status <= status + 1;
					parity <= (parity ^ ps2data);
					break_flag <= break_flag;
					recv_break <= recv_break;
					e0_flag <= e0_flag;
					recv_e0 <= recv_e0;
					data_ready <= 0;
				end 
				if(status == 9) begin	
					if((parity ^ ps2data) == 1'b1) begin
						data_received <= record;
					end
					status <= 10;
					break_flag <= break_flag;
					recv_break <= recv_break;
					e0_flag <= e0_flag;
					recv_e0 <= recv_e0;
					data_ready <= 0;
				end else if(status == 10) begin
					if(data_received == 8'hF0) begin
						// break
						break_flag <= 1;
						recv_break <= 1;
						data_ready <= 0;
					end else if (data_received == 8'hE0) begin
						// e0
						e0_flag <= 1;
						recv_e0 <= 1;
						data_ready <= 0;
					end else begin
						// make
						if (recv_break == 1) break_flag <= break_flag;
						else break_flag <= 0;
						if (recv_e0 == 1) e0_flag <= e0_flag;
						else e0_flag <= 0;
						data_ready <= 1;
						recv_e0 <= 0;
						recv_break <= 0;
					end
					if(ps2data == 1'b1) status <= 0;
				end
			end

			//if(keyboardOp_i == `KB_LOAD_OP) begin
				//head <= head + 1;
			//end
		end
	end

endmodule