`include "defines.v"

module pc(
    input wire clk,
    input wire rst,
    input wire pause,
    input wire branchFlag_i,
    input wire[15:0] branchPC_i,

    //visit mem pause
    input wire vmem_pause_i,
    
    output reg[15:0] pc,
	 output reg[6:0] disp0,
	 output reg[6:0] disp1,
	 
	 //give to MMU
	 output reg MMU_pause
    );

	reg[2:0] pause_state;
	reg[2:0] next_pause_state;
	reg[15:0] branchPC;
	reg[15:0] nextPC;

	`define NORMAL 3'b000
	`define PAUSE 3'b001
	`define BRANCH 3'b010
	`define D_BRANCH 3'b011
	`define DELAY 3'b100

	always @(posedge clk) begin
		if (rst == `RstEnable) begin
			pc <= 16'h0000;
			pause_state <= `NORMAL;
			MMU_pause <= `Disable;
		end else begin
			pause_state <= next_pause_state;
			pc <= nextPC;
			if (pause == `Enable) MMU_pause <= `Enable;
			else MMU_pause <= `Disable;
			if (branchFlag_i == `Enable) branchPC <= branchPC_i;
			else branchPC <= branchPC;
		end
	end

	always @(*) begin
		nextPC = pc + 1;
		if (vmem_pause_i == `Enable || pause == `Enable) nextPC = pc;
		case (pause_state)
			`NORMAL: begin
				if (branchFlag_i == `Enable) begin
					if (vmem_pause_i == `Enable || pause == `Enable) begin
						next_pause_state = `BRANCH;
					end else begin
						nextPC = branchPC_i;
						next_pause_state = `NORMAL;
					end
				end
				else if (vmem_pause_i == `Enable || pause == `Enable)
					next_pause_state = `PAUSE;
				else next_pause_state = `NORMAL;
			end
			`BRANCH: begin
				if (vmem_pause_i == `Enable || pause == `Enable)
					next_pause_state = `BRANCH;
				else begin
					nextPC = branchPC;
					next_pause_state = `NORMAL;
				end
			end
			`PAUSE: begin
				if (branchFlag_i == `Enable) begin
					if (vmem_pause_i == `Enable || pause == `Enable)
						next_pause_state = `D_BRANCH;
					else next_pause_state = `DELAY;
				end else if (vmem_pause_i == `Enable || pause == `Enable)
					next_pause_state = `PAUSE;
				else
					next_pause_state = `NORMAL;
			end
			`D_BRANCH: begin
				next_pause_state = `DELAY;
			end
			`DELAY: begin
				nextPC = branchPC;
				next_pause_state = `NORMAL;
			end
			default: next_pause_state = `NORMAL;
		endcase
	end

	// display pc	
	`define D0 7'b0111111
	`define D1 7'b0000110
	`define D2 7'b1011011
	`define D3 7'b1001111
	`define D4 7'b1100110
	`define D5 7'b1101101
	`define D6 7'b1111101
	`define D7 7'b0000111
	`define D8 7'b1111111
	`define D9 7'b1101111
	`define DA 7'b0000001
	`define DB 7'b0000010
	`define DC 7'b0000100
	`define DD 7'b0001000
	`define DE 7'b0010000
	`define DF 7'b0100000
	`define DNull 7'b0000000
	 
	 always @(*) begin
		case (nextPC[3:0])
			4'd0: disp0 = `D0;
			4'd1: disp0 = `D1;
			4'd2: disp0 = `D2;
			4'd3: disp0 = `D3;
			4'd4: disp0 = `D4;
			4'd5: disp0 = `D5;
			4'd6: disp0 = `D6;
			4'd7: disp0 = `D7;
			4'd8: disp0 = `D8;
			4'd9: disp0 = `D9;
			4'd10: disp0 = `DA;
			4'd11: disp0 = `DB;
			4'd12: disp0 = `DC;
			4'd13: disp0 = `DD;
			4'd14: disp0 = `DE;
			4'd15: disp0 = `DF;
			default: disp0 = `DNull;
		endcase
		case (nextPC[7:4])
			4'd0: disp1 = `D0;
			4'd1: disp1 = `D1;
			4'd2: disp1 = `D2;
			4'd3: disp1 = `D3;
			4'd4: disp1 = `D4;
			4'd5: disp1 = `D5;
			4'd6: disp1 = `D6;
			4'd7: disp1 = `D7;
			4'd8: disp1 = `D8;
			4'd9: disp1 = `D9;
			4'd10: disp1 = `DA;
			4'd11: disp1 = `DB;
			4'd12: disp1 = `DC;
			4'd13: disp1 = `DD;
			4'd14: disp1 = `DE;
			4'd15: disp1 = `DF;
			default: disp1 = `DNull;
		endcase
	 end

endmodule
