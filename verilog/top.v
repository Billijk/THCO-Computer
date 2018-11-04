`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:51:29 11/20/2016 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(
    // input
    input wire clk0,		// 11.0592MHz
	 input wire clk1,		// 50MHz
	 input wire clk_key,
    input wire rst,
	 
	 input wire switch, 	// clock switch
	 
    // SERIAL PART
    input wire data_ready,
    input wire tsre, tbre,

    // KEYBOARD PART
    input wire ps2clk,
    input wire ps2data,

    // inout
    inout wire[15:0] ramData,
    inout wire[7:0] Ram1Data,

    // output
	 // SERIAL PART
	 output wire Ram1OE, Ram1WE, Ram1EN,
	 output wire wrn, rdn,

    // SRAM PART
    output wire[17:0] ramAddr,
    output wire ramOE,
    output wire ramWE,
    output wire ramEN,

    // VGA PART
    output wire hs,
    output wire vs,
    output wire[2:0] r,
    output wire[2:0] g,
    output wire[2:0] b,

	 
    // DEBUG PART
    output wire[15:0] led,
    output wire[6:0] dispL,
    output wire[6:0] dispR,
	 
	 //
	 output wire[15:0] debug_pc,
	 output wire[15:0] debug_ins,
	 output wire clk100_out
);

wire clk100;
assign clk100_out = clk100;

//vmem pause signal
wire vmem_pc_pause;
wire vmem_ifid_pause;

// pause signal
wire pc_pause;
wire id_pause;
wire ex_pause;

// pc branch signals
wire[15:0] branch_pc;
wire branch_flag;

// pc - MMU / if_id
wire[15:0] if_pc;
wire MMU_pause;

// MMU - rom
wire[15:0] rom_pc;
wire[15:0] rom_ins;

// MMU - if_id
wire[15:0] if_ins;

// MMU - mem
wire[15:0] MMU_give_mem_data;

// MMU - VGA
wire MMU_give_VGA_e;
wire[8:0] MMU_give_VGA_addr;
wire[15:0] MMU_give_VGA_data;

// MMU - serial
//wire COM_op;
//wire COM_en;
wire[7:0] MMU_give_COM_data;
wire[7:0] MMU_get_COM_data;
wire com_writeable, com_readable;
//wire serial_command;
wire en1, en2, en3;

// MMU - keyboard
wire keyboard_status;
wire[6:0] keyboard_data;

// if_id - id
wire[15:0] id_pc;
wire[15:0] id_ins;

assign debug_pc = if_pc;
assign debug_ins = if_ins;

// id - regs
wire[15:0] reg1Data;
wire[15:0] reg2Data;
wire[3:0] reg1Addr;
wire[3:0] reg2Addr;
wire re1;
wire re2;

// id - id_ex
wire[15:0] id_operand1;
wire[15:0] id_operand2;
wire[4:0] id_aluOp;
wire[1:0] id_memOp;
wire id_wreg;
wire[3:0] id_wd;

// id_ex - ex
wire[15:0] ex_operand1;
wire[15:0] ex_operand2;
wire[4:0] ex_aluOp;
wire[1:0] ex_memOp;
wire ex_writeReg;
wire[3:0] ex_writeRegAddr;

// ex - ex/mem
wire[15:0] ex_writeData;
wire[1:0] ex_o_memOp;
wire[15:0] ex_o_memAddr;
wire[3:0] ex_o_writeRegAddr;
wire ex_o_writeReg;

// ex/mem - mem
wire[1:0] mem_memOp;
wire[15:0] mem_memAddr;
wire mem_writeReg;
wire[3:0] mem_writeRegAddr;
wire[15:0] mem_writeData;

// mem - mem/wb
wire mem_o_writeReg;
wire[3:0] mem_o_writeRegAddr;
wire[15:0] mem_o_writeData;

// mem - MMU
wire[1:0] MMU_memOp;
wire[15:0] MMU_mem_ramData;
wire[15:0] MMU_mem_ramAddr;

// mem/wb - regs
wire wb_writeReg;
wire[3:0] wb_writeRegAddr;
wire[15:0] wb_writeData;

reg clk25M = 0;
reg clk6M = 0;

wire clk;	// main clock
assign clk = (switch == 1'b1) ? clk6M : clk_key;


always @(posedge clk1) begin
	clk25M = ~clk25M;
end

always @(posedge clk0) begin
	clk6M = ~clk6M;
end

pc pc0(
    .clk(clk), .rst(rst), .pause(pc_pause),
    .branchFlag_i(branch_flag), .branchPC_i(branch_pc),
	 .vmem_pause_i(vmem_pc_pause),
    .pc(if_pc), .disp1(dispL), .disp0(dispR),
	 .MMU_pause(MMU_pause)
);

MMU MMU0(
	 .memOp_i(MMU_memOp), .mem_ramData_i(MMU_mem_ramData), .mem_ramAddr_i(MMU_mem_ramAddr),
	 .pc_i(if_pc), .rom_ins_i(rom_ins), .ins_o(if_ins),
	 .mem_data_o(MMU_give_mem_data), .ramData(ramData), .ramAddr(ramAddr),
	 .ramOE(ramOE), .ramWE(ramWE), .ramEN(ramEN),
	 .pc_o(rom_pc), .vga_e_o(MMU_give_VGA_e), .vga_addr_o(MMU_give_VGA_addr), .vga_data_o(MMU_give_VGA_data),
     .keybStatus_i(keyboard_status), .keybKey_i(keyboard_data),
	 .comData_i(MMU_get_COM_data), 
	 .comData_o(MMU_give_COM_data),
     .writeable(com_writeable), .readable(com_readable),
	 .pc_pause_i(MMU_pause),
     .serial_status_o(en1),
     .serial_enable_o(en2),
     .serial_fetch_o(en3)
);

rom rom0(
    .pc(rom_pc),
    .ins_o(rom_ins)
);

if_id if_id0(
    .clk(clk), .rst(rst), .pause(id_pause),
    .if_pc(if_pc), .if_ins(if_ins),
	 .vmem_pause_i(vmem_ifid_pause),
    .id_pc(id_pc), .id_ins(id_ins)
);

id id0(
    .pc_i(id_pc), .ins_i(id_ins),
    .reg1Data_i(reg1Data), .reg2Data_i(reg2Data),
    .ex_writeReg_i(ex_o_writeReg),
    .ex_writeRegAddr_i(ex_o_writeRegAddr), .ex_writeData_i(ex_writeData),
    .mem_writeReg_i(mem_o_writeReg), 
    .mem_writeRegAddr_i(mem_o_writeRegAddr), .mem_writeData_i(mem_o_writeData),
    .lastMemOp_i(ex_memOp), .lastRegAddr_i(ex_writeRegAddr),
    .branchPC_o(branch_pc), .branchFlag_o(branch_flag),
    .pc_pause_o(pc_pause),
    .reg1Addr_o(reg1Addr), .reg2Addr_o(reg2Addr),
    .re1_o(re1), .re2_o(re2),
    .id_pause_o(id_pause),
    .operand1_o(id_operand1), .operand2_o(id_operand2),
    .aluOp_o(id_aluOp), .ex_pause_o(ex_pause),
    .memOp_o(id_memOp),
    .wreg_o(id_wreg), .wd_o(id_wd)
);

id_ex id_ex0(
    .clk(clk), .rst(rst), .pause(ex_pause),
    .operand1_i(id_operand1), .operand2_i(id_operand2),
    .aluOp_i(id_aluOp), .memOp_i(id_memOp),
    .writeReg_i(id_wreg), .writeRegAddr_i(id_wd),
    .operand1_o(ex_operand1), .operand2_o(ex_operand2),
    .aluOp_o(ex_aluOp), .memOp_o(ex_memOp),
    .writeReg_o(ex_writeReg), .writeRegAddr_o(ex_writeRegAddr)
);

ex ex0(
    .operand1_i(ex_operand1), .operand2_i(ex_operand2),
    .aluOp_i(ex_aluOp), .memOp_i(ex_memOp),
    .writeReg_i(ex_writeReg), .writeRegAddr_i(ex_writeRegAddr),
    .writeData_o(ex_writeData),
    .memOp_o(ex_o_memOp), .memAddr_o(ex_o_memAddr),
    .writeRegAddr_o(ex_o_writeRegAddr), .writeReg_o(ex_o_writeReg),
	 .pc_vmem_pause(vmem_pc_pause), .ifid_vmem_pause(vmem_ifid_pause)
);

ex_mem ex_mem0(
    .clk(clk), .rst(rst),
    .writeData_i(ex_writeData),
    .memOp_i(ex_o_memOp), .memAddr_i(ex_o_memAddr),
    .writeReg_i(ex_o_writeReg), .writeRegAddr_i(ex_o_writeRegAddr),
    .writeData_o(mem_writeData),
    .memOp_o(mem_memOp), .memAddr_o(mem_memAddr),
    .writeReg_o(mem_writeReg), .writeRegAddr_o(mem_writeRegAddr)
);

mem mem0(
    .memOp_i(mem_memOp), .data_i(mem_writeData), .memAddr_i(mem_memAddr),
    .regAddr_wb_i(mem_writeRegAddr), .we_i(mem_writeReg),
	 .data_MMU_i(MMU_give_mem_data),
    .data_wb_o(mem_o_writeData), .regAddr_wb_o(mem_o_writeRegAddr),
    .we_o(mem_o_writeReg),
    .memOp_o(MMU_memOp), .ramData_o(MMU_mem_ramData), .ramAddr_o(MMU_mem_ramAddr)
);

mem_wb mem_wb0(
    .clk(clk), .rst(rst),
    .re(mem_o_writeReg), .data(mem_o_writeData), .regAddr(mem_o_writeRegAddr),
    .reO(wb_writeReg), .dataO(wb_writeData), .regAddrO(wb_writeRegAddr)
);

regs regs0(
    .clk(clk), .rst(rst),
    .re1(re1), .re2(re2),
    .reg1Addr(reg1Addr), .reg2Addr(reg2Addr),
    .regData(wb_writeData), .regAddr(wb_writeRegAddr), .we(wb_writeReg),
    .reg1Data(reg1Data), .reg2Data(reg2Data), .led(led)
);

vga vga0(
    .clk(clk25M), .rst(rst),
	 .we(MMU_give_VGA_e), .mem_addr(MMU_give_VGA_addr), .mem_data(MMU_give_VGA_data),
	 .mainclk(clk),
    .vs(vs), .hs(hs),
    .r(r), .g(g), .b(b)
);


uart serial0(
	  .clk(clk0), .rst(rst), .tsre(tsre), .tbre(tbre),
     .send_data(MMU_give_COM_data), 
     .receive_data(MMU_get_COM_data),
	  .data_ready(data_ready), 
     .send_data_complete(com_writeable),
     .receive_data_complete(com_readable),
     .ram1oe(Ram1OE), .ram1we(Ram1WE), .ram1en(Ram1EN),
     .rdn(rdn), .wrn(wrn),
     .ram1data(Ram1Data),
     .en1(en1),
     .en2(en2),
     .en3(en3)	 
);
/*
serial_port serial0(
    .clk(clk0out), .rst(rst),
    .RxD(RxD), .TxD(TxD),
    .writedata(MMU_give_COM_data),
    .receivedata(MMU_get_COM_data),
    .control(serial_command),
    .readable(com_readable),
    .writeable(com_writeable)
);*/

KeyboardAdapter keyboard0(
    .clk(clk), .rst(rst),
    .ps2data(ps2data), .ps2clk(ps2clk),
    .data(keyboard_data), .status(keyboard_status)
);

endmodule
