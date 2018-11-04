`timescale 1ns / 10ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:44:07 11/24/2016
// Design Name:   top
// Module Name:   C:/Users/Andy/Desktop/THCO/test.v
// Project Name:  THCO
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire [17:0] ramAddr;
	wire ramOE;
	wire ramWE;
	wire ramEN;
	wire [15:0] led;
	wire [6:0] dispL;
	wire [6:0] dispR;

	// Bidirs
	wire [15:0] ramData;
	wire [15:0] getRamData;
	wire [15:0] giveRamData;
	
	//test
	wire [15:0] debug_pc;
	wire [15:0] debug_ins;
	wire clk100_out;
	
	// Instantiate the Unit Under Test (UUT)
	top uut (
		.clk1(clk), 
		.rst(rst), 
		.ramData(ramData), 
		.ramAddr(ramAddr), 
		.ramOE(ramOE), 
		.ramWE(ramWE), 
		.ramEN(ramEN),
		.led(led), 
		.dispL(dispL), 
		.dispR(dispR),
		.debug_pc(debug_pc),
		.debug_ins(debug_ins),
		.clk100_out(clk100_out)
	);
	
	VirtualSram mySram(
		.ramInputData(giveRamData), 
		.ramOutputData(getRamData),
		.ramAddr(ramAddr), 
		.ramOE(ramOE), 
		.ramWE(ramWE), 
		.ramEN(ramEN)
	);
	wire getRamValid;
	
	assign getRamValid = (ramOE == 1'b0 && ramWE == 1'b1)? 1'b1 : 1'b0;
	assign giveRamData = ramData;
	assign ramData = (getRamValid == 1'b1)? getRamData : 16'hZZ;

	initial begin
		clk = 1'b1;
		forever #10 clk = ~clk;
   end
   initial begin
		rst = 1'b0;
		#50 rst = 1'b1;
   end
      
endmodule

