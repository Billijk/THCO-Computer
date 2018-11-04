`include "defines.v"

module MMU (
    // inputs
    // get from MEM
    input wire[1:0] memOp_i,
    input wire[15:0] mem_ramData_i,
    input wire[15:0] mem_ramAddr_i,

    //get from PC
    input wire[15:0] pc_i,

    //get from rom
    input wire[15:0] rom_ins_i,

    //get from com
    input wire[7:0] comData_i,
    input wire writeable, readable,

	//get from keyboard
	input wire keybStatus_i,
	input wire[6:0] keybKey_i,
	 
	 //get form id
	input wire pc_pause_i,

    //give to if_id
    output reg[15:0] ins_o,

    //give to MEM
    output reg[15:0] mem_data_o,

    // give to RAM part
    inout wire[15:0] ramData,
    output reg[17:0] ramAddr,
    output reg ramOE,
    output reg ramWE,
    output reg ramEN,

    //give to rom part
    output reg[15:0] pc_o,

    //give to com
	 output reg serial_status_o,// r/w 
	 output reg serial_enable_o,// Always 1
    output reg serial_fetch_o, // read
    output reg[7:0] comData_o,

    //give to VGA
    output reg vga_e_o,
    output reg[8:0] vga_addr_o,
    output reg[15:0] vga_data_o
);

//assign ramAddr = mem_ramAddr_i;     //it depends
assign ramData = (memOp_i == `MEM_WRITE_OP) ? mem_ramData_i : `HighZ;

//mem
always @(*) begin
	pc_o = 16'b0;
	//ins_o = 16'b0000100000000000;
	vga_e_o = `Disable;
	vga_addr_o = 9'b0;
	vga_data_o = `ZERO;
	serial_status_o = `COM_READ;
	serial_enable_o = 1'b1;
	serial_fetch_o = 1'b0;
	mem_data_o = `ZERO;
	comData_o = `ZERO;
	ramEN = 1;
	ramOE = 1;
	ramWE = 1;
	if(pc_pause_i == `Enable) begin
		ins_o = ins_o;
	end else begin
		ins_o = 16'b0000100000000000;
	end
	
    case (memOp_i)
      `MEM_READ_OP: begin  //change the ramOE\ramWE first
          if(mem_ramAddr_i == `COM_DATA_REG) begin
          	serial_status_o = `COM_READ;
            serial_fetch_o = 1'b1;
          	mem_data_o = {8'b0, comData_i};
          end else if (mem_ramAddr_i == `COM_SITU_REG) begin
            mem_data_o = {14'b0, readable, writeable};
          end else if(mem_ramAddr_i == `KEYB_DATA_REG) begin
          	//read keyboard
			 mem_data_o = {8'b0, keybKey_i};
          end else if (mem_ramAddr_i == `KEYB_SITU_REG) begin
		  	 mem_data_o = {15'b0, keybStatus_i};
		  end
      	  else begin     //just the simple read
          	ramEN = 0;
          	ramOE = 0;
          	ramWE = 1;
          	ramAddr = {2'b00, mem_ramAddr_i};
          	mem_data_o = ramData;
          end
      end
      `MEM_WRITE_OP: begin   //change the Addr first
      	  if(mem_ramAddr_i == `COM_DATA_REG) begin
          	serial_status_o = `COM_WRITE;
          	comData_o = mem_ramData_i[7:0];
		  end else if(mem_ramAddr_i >= `VGA_SEC_MIN && mem_ramAddr_i <= `VGA_SEC_MAX) begin
          	vga_e_o = `Enable;
          	vga_data_o = mem_ramData_i;
          	vga_addr_o = mem_ramAddr_i[8:0];
          end else if(mem_ramAddr_i >= `ROM_SEC_MIN && mem_ramAddr_i <= `RAM_SEC_MAX) begin
      	  	ramAddr = {2'b00, mem_ramAddr_i};
          	ramEN = 0;
          	ramOE = 1;
          	ramWE = 0;
          end
      end
      default: begin   //change the ramOE\ramWE first
          if(pc_i >= `ROM_SEC_MIN && pc_i <= `ROM_SEC_MAX) begin
				pc_o = pc_i;
				ins_o = rom_ins_i;
    	  end else if(pc_i >= `RAM_SEC_MIN && pc_i <= `RAM_SEC_MAX) begin
				ramEN = 0;
          		ramOE = 0;
          		ramWE = 1;
				ramAddr = {2'b00, pc_i};                  //now I can choose
				ins_o = ramData;
    	  end
	  end
    endcase
end

endmodule