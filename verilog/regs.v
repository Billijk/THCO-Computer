`include "defines.v"

module regs (
    // inputs
    // clock
    input wire clk,

    // reset
    input wire rst,

    // from ID
    input wire re1,     // read enable 1
    input wire re2,     // read enable 2
    input wire[3:0] reg1Addr,
    input wire[3:0] reg2Addr,

    // from MEM/WB
    input wire[15:0] regData,
    input wire[3:0] regAddr,
    input wire we,      // write enable

    // outputs
    output reg[15:0] reg1Data,
    output reg[15:0] reg2Data,
	 output reg[15:0] led
);

reg[15:0] registers[11:0];

always @(posedge clk) begin
    if (rst == `RstEnable) begin
        registers[0] <= 16'd0;
        registers[1] <= 16'd0;
        registers[2] <= 16'd0;
        registers[3] <= 16'd0;
        registers[4] <= 16'd0;
        registers[5] <= 16'd0;
        registers[6] <= 16'd0;
        registers[7] <= 16'd0;
        registers[8] <= 16'hfe00;   // SP
        registers[9] <= 16'd0;      // RA
        registers[10] <= 16'd0;     // T
        registers[11] <= 16'd0;     // IH
    end else begin
        // write to mem
        if (we == `Enable) begin
            registers[regAddr] <= regData;
        end
    end
end

always @(registers[0], registers[1], registers[2],
		registers[3], registers[4], registers[5], registers[6],
		registers[7], registers[8], registers[9], registers[10],
		registers[11], re1, re2, we, reg1Addr, reg2Addr, regAddr, regData) begin
    // read reg1
    if (re1 == `Enable && we == `Enable && reg1Addr == regAddr) begin
        reg1Data = regData;
    end else if (re1 == `Enable) begin
        reg1Data = registers[reg1Addr];
    end else begin
        reg1Data = 16'd0;
    end
    // read reg2
    if (re2 == `Enable && we == `Enable && reg2Addr == regAddr) begin
        reg2Data = regData;
    end else if (re2 == `Enable) begin
        reg2Data = registers[reg2Addr];
    end else begin
        reg2Data = 16'd0;
    end
	 
	 led = registers[2];
end

endmodule