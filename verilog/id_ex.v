`include "defines.v"

module id_ex(
    input wire clk,
    input wire rst,
    input wire pause,

    //input
    
    //EX
    input wire[15:0] operand1_i,
    input wire[15:0] operand2_i,
    input wire[4:0] aluOp_i,

    //MEM
    input wire[1:0] memOp_i,

    //WB
    input wire writeReg_i,
    input wire[3:0] writeRegAddr_i,
   
    //output
    
    //EX
    output reg[15:0] operand1_o,
    output reg[15:0] operand2_o,
    output reg[4:0] aluOp_o,

    //MEM
    output reg[1:0] memOp_o,

    //WB
    output reg writeReg_o,
    output reg[3:0] writeRegAddr_o
    );

    always @(posedge clk) begin
        if (rst == `RstEnable || pause == `Enable) begin
        
            //EX
                operand1_o <= `ZERO;
                operand2_o <= `ZERO;
                aluOp_o <= `ALU_NOP_OP;
                
            //MEM
                memOp_o <= `MEM_NOP_OP;

            //WB
                writeReg_o <= `Disable;
                writeRegAddr_o <= 5'h0;
        end else begin
                
            //EX
                operand1_o <= operand1_i;
                operand2_o <= operand2_i;
                aluOp_o <= aluOp_i;
                
            //MEM
                memOp_o <= memOp_i;

            //WB
                writeReg_o <= writeReg_i;
                writeRegAddr_o <= writeRegAddr_i;
        end
    end

endmodule
