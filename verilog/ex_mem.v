`include "defines.v"

module ex_mem(
    input wire clk,
    input wire rst,

    //input
    //MEM-WB
    input wire[15:0] writeData_i,

    //MEM
    input wire[1:0] memOp_i,
    input wire[15:0] memAddr_i,

    //WB
    input wire writeReg_i,
    input wire[3:0] writeRegAddr_i,

    //output
    //MEM-WB
    output reg[15:0] writeData_o,

    //MEM
    output reg[1:0] memOp_o,
    output reg[15:0] memAddr_o,

    //WB
    output reg writeReg_o,
    output reg[3:0] writeRegAddr_o
    );

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            //MEM-WB
                writeData_o <= `ZERO;

            //MEM
                memOp_o <= `MEM_NOP_OP;
                memAddr_o <= `ZERO;

            //WB
                writeReg_o <= `Disable;
                writeRegAddr_o <= `ZERO;
        end else begin
            //MEM-WB
                writeData_o <= writeData_i;

            //MEM
                memOp_o <= memOp_i;
                memAddr_o <= memAddr_i;

            //WB
                writeReg_o <= writeReg_i;
                writeRegAddr_o <= writeRegAddr_i;
        end
    end

endmodule
