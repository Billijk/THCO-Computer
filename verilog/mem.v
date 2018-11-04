`include "defines.v"

module mem (
    // inputs
    // from EXE
    input wire[1:0] memOp_i,       // mem operation
    input wire[15:0] data_i,       //write to reg or write to ram
    input wire[15:0] memAddr_i,

    input wire[3:0] regAddr_wb_i,
    input wire we_i,               // write back enable

    //get form MMU
    input wire[15:0] data_MMU_i,

    // outputs
    // to MEM/WB
    output reg[15:0] data_wb_o,
    output reg[3:0] regAddr_wb_o,
    output reg we_o,

    // to MMU
    output reg[1:0] memOp_o,
    output wire[15:0] ramData_o,
    output wire[15:0] ramAddr_o
);

//data to MMU
assign ramData_o = data_i;
assign ramAddr_o = memAddr_i;

//data to WB
always @(*) begin
    regAddr_wb_o = regAddr_wb_i;
    we_o = we_i;
end

//data should from EXE or MMU
always @(*) begin
    memOp_o = memOp_i;
	 data_wb_o = data_i;
    case (memOp_i)
      `MEM_READ_OP: begin
          data_wb_o = data_MMU_i;
      end
      default: begin
      	
      end
    endcase
end

endmodule