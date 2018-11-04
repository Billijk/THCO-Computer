`include "defines.v"

module mem_wb (
    // inputs
    // clock
    input wire clk,

    // reset
    input wire rst,

    // from MEM
    input wire re,
    input wire[15:0] data,
    input wire[3:0] regAddr,

    // outputs
    output reg reO,
    output reg[15:0] dataO,
    output reg[3:0] regAddrO
);

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        reO <= 1'b0;
        dataO <= 16'b0;
        regAddrO <= 4'b0;
    end else begin
        reO <= re;
        dataO <= data;
        regAddrO <= regAddr;
    end
end

endmodule