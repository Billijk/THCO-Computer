`timescale 1ns / 1ps
module VirtualSram(
    input wire[15:0] ramInputData,
    input wire[17:0] ramAddr,
    input wire ramOE,
    input wire ramWE,
    input wire ramEN,
	 output reg[15:0] ramOutputData
);
    reg [15:0] rom[65535:0];
    always @(*) begin
        if(ramEN==1'b0) begin
            if(ramOE == 1'b1 && ramWE == 1'b0) begin
                rom[ramAddr[17:0]] = ramInputData;
            end
            else if (ramOE == 1'b0 && ramWE == 1'b1) begin
                ramOutputData = rom[ramAddr[17:0]];
            end
        end
        else begin
            
        end
    end
endmodule

