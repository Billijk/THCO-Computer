module keyboard2ascii(
	input wire e0_flag,
	input wire[7:0] key,
	output wire[6:0] ascii
);

	reg[6:0] char;
	assign ascii=char;

	`define UNDEF 7'h00

	always @(*) begin
		char = 8'b0;
		case (key)
			// A ~ Z
			8'h1C: char=7'h41; // A
			8'h32: char=7'h42; // B
			8'h21: char=7'h43; // C
			8'h23: char=7'h44; // D
			8'h24: char=7'h45; // E
			8'h2B: char=7'h46; // F
			8'h34: char=7'h47; // G
			8'h33: char=7'h48; // H
			8'h43: char=7'h49; // I
			8'h3B: char=7'h4A; // J
			8'h42: char=7'h4B; // K
			8'h4B: char=7'h4C; // L
			8'h3A: char=7'h4D; // M
			8'h31: char=7'h4E; // N
			8'h44: char=7'h4F; // O
			8'h4D: char=7'h50; // P
			8'h15: char=7'h51; // Q 
			8'h2D: char=7'h52; // R
			8'h1B: char=7'h53; // S
			8'h2C: char=7'h54; // T
			8'h3C: char=7'h55; // U
			8'h2A: char=7'h56; // V
			8'h1D: char=7'h57; // W
			8'h22: char=7'h58; // X
			8'h35: char=7'h59; // Y 
			8'h1A: char=7'h5A; // Z

			// 0 ~ 9
			8'h45: char=7'h30; // 0
			8'h16: char=7'h31; // 1
			8'h1E: char=7'h32; // 2
			8'h26: char=7'h33; // 3
			8'h25: char=7'h34; // 4
			8'h2E: char=7'h35; // 5
			8'h36: char=7'h36; // 6
			8'h3D: char=7'h37; // 7
			8'h3E: char=7'h38; // 8
			8'h46: char=7'h39; // 9

			// Commands
			8'h66: char=7'h08; // Backspace
			8'h29: char=7'h20; // Space
			8'h0D: char=7'h09; // Tab
			8'h58: char=7'h25; // CapsLock
			8'h12: begin 
				if (e0_flag == 0) char=7'h01; // Left Shift
				else char=`UNDEF;
			end
			8'h59: char=7'h02; // Right Shift
			8'h14: begin 
				if (e0_flag == 0) char=7'h03; // Left Control
				else char=7'h04; // Right Control
			end
			8'h11: begin 
				if (e0_flag == 0) char=7'h05; // Left Alt
				else char=7'h06;
			end
			
			8'h5A: begin
				if (e0_flag == 0) char=7'h0D; // ENTER
				else char=7'h0D; // KP ENTER
			end
			8'h76: char=7'h1B; // Esc

			// Symbols
			8'h4E: char=7'h2D; // -
			8'h55: char=7'h3D; // =
			8'h5D: char=7'h5C; // \
			8'h54: char=7'h5B; // [
			8'h5B: char=7'h5D; // ]
			8'h4C: char=7'h3B; // ;
			8'h52: char=7'h27; // '
			8'h41: char=7'h2C; // ,
			8'h49: char=7'h2E; // .
			8'h4A: begin
				if (e0_flag == 0) char=7'h2F; // /
				else char=7'h2F; // KP /
			end
			8'h7C: begin
				if (e0_flag == 0) char=7'h2A; // KP_*
				else char=`UNDEF;
			end
			8'h7B: char=7'h2D; // KP_-
			8'h79: char=7'h2B; // KP_+

			// Arrows and KPs
			8'h75: begin
				if (e0_flag == 0) char=7'h38; // KP_8
				else char=7'h21; // U Arrow
			end
			8'h6B: begin
				if (e0_flag == 0) char=7'h34; // KP_4
				else char=7'h22; // L Arrow
			end
			8'h72: begin
				if (e0_flag == 0) char=7'h32; // KP_2
				else char=7'h23; // D Arrow
			end
			8'h74: begin
				if (e0_flag == 0) char=7'h36; // KP_6
				else char=7'h24; // R Arrow
			end
			8'h70: begin
				if (e0_flag == 0) char=7'h30; // KP_0
				else char=7'h10; // INSERT
			end
			8'h73: char=7'h35; // KP_5
			8'h6C: begin
				if (e0_flag == 0) char=7'h37; // KP_7
				else char=7'h11; // HOME
			end
			8'h7D: begin 
				if (e0_flag == 0) char=7'h39; // KP_9
				else char=7'h12; // PG UP
			end
			8'h71: begin
				if (e0_flag == 0) char=7'h7F; // KP .
				else char=7'h13; // Delete
			end
			8'h69: begin
				if (e0_flag == 0) char=7'h31; // KP_1
				else char=7'h14; // END
			end
			8'h7A: begin
				if (e0_flag == 0) char=7'h33; // KP_3
				else char=7'h15; // PG DN
			end
			default: char=`UNDEF;
		endcase
	end

endmodule