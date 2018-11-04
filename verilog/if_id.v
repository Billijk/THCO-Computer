`include "defines.v"

module if_id(
    input wire clk,
    input wire rst,
    input wire pause,

    //input
    //Instruction
    input wire[15:0] if_pc,
    input wire[15:0] if_ins,

    //visit mem pause
    input wire vmem_pause_i,

    //output
    //Instruction
    output reg[15:0] id_pc,
    output reg[15:0] id_ins
    );

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc <= `ZERO;
            id_ins <= 16'b0000100000000000;   //nop
        end/* else if (vmem_pause_i == `Enable) begin
            id_pc <= `ZERO;
            id_ins <= `ZERO;
        end*/ else if (pause == `Enable) begin
            // stay unchanged
            id_pc <= id_pc;
            id_ins <= id_ins;
        end else begin
            id_pc <= if_pc;
            id_ins <= if_ins;
        end
    end

endmodule
