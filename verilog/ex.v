`include "defines.v"

module ex(

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
	//MEM-WB
	output reg[15:0] writeData_o,
	
	//MEM
    output reg[1:0] memOp_o,
    output reg[15:0] memAddr_o,
	
	//WB
	output reg[3:0] writeRegAddr_o,
	output reg writeReg_o,

	//visit mem pause
	output reg pc_vmem_pause,
	output reg ifid_vmem_pause
    );


	reg[15:0]		logicout;
	reg[15:0] 		shiftout;
	reg[15:0]		mathout;
	
	//wire 			overflow_sum;
	wire 			op1_lt_op2;
	wire 			op1_eq_op2;
	wire[15:0]		op2_i_mux;
	//wire[15:0]		op1_i_not;
	wire[15:0]		result_sum;

	//visit mem pause
	always @(*) begin
		pc_vmem_pause = `Disable;
		ifid_vmem_pause = `Disable;
		case(memOp_i)
			`MEM_WRITE_OP, `MEM_READ_OP: begin
				pc_vmem_pause = `Enable;
				ifid_vmem_pause = `Enable;
			end
			default: begin
				
			end
		endcase
	end


    // Control
	always @(*) begin
        //MEM
        memOp_o = memOp_i;
        memAddr_o = operand1_i; // Memory offset
    
        //WB
        writeReg_o = writeReg_i;
        writeRegAddr_o = writeRegAddr_i;

        case (aluOp_i) 
        	`ALU_AND_OP, `ALU_OR_OP: begin
        		writeData_o = logicout;
        	end
        	`ALU_SLL_OP, `ALU_SRA_OP: begin
        		writeData_o = shiftout;
        	end
        	`ALU_ADDU_OP, `ALU_ADDIU_OP, `ALU_ADDIU3_OP, `ALU_ADDSP_OP, `ALU_SUBU_OP, `ALU_SLTU_OP, `ALU_CMP_OP: begin
        		writeData_o = mathout;
        	end
			`ALU_LI_OP, `ALU_MFIH_OP, `ALU_MTIH_OP, `ALU_MTSP_OP, `ALU_MFPC_OP, `ALU_JALR_OP: begin
				writeData_o = operand1_i;
			end
			`ALU_LW_OP, `ALU_LWSP_OP: begin
				memAddr_o = operand1_i + operand2_i;
				writeData_o = `ZERO;
			end
			`ALU_SW_OP, `ALU_SWRS_OP, `ALU_SWSP_OP: begin
				writeData_o = operand2_i;
			end
        	default: begin
        		writeData_o = `ZERO;
        	end
        endcase
	end


	// Logic
	always @(*) begin
			case (aluOp_i)
				`ALU_AND_OP: begin
					logicout = operand1_i & operand2_i;
				end
				`ALU_OR_OP: begin
					logicout = operand1_i | operand2_i;
				end
				default: begin
					logicout = `ZERO;
				end
			endcase
	end

	// Shift
	always @(*) begin
			case (aluOp_i) 
				`ALU_SLL_OP: begin
					if (operand2_i[2:0] == 3'b000) begin
						shiftout = operand1_i << 4'd8;
					end else begin
						shiftout = operand1_i << operand2_i[2:0];
					end
				end
				`ALU_SRA_OP: begin
					if (operand2_i[2:0] == 3'b000) begin
						shiftout = (operand1_i >> 4'd8) | ({16{operand1_i[15]}}) << 4'd8;
					end else begin
						shiftout = (operand1_i >> operand2_i[2:0]) | ({16{operand1_i[15]}} << (5'd16 - {2'b00, operand2_i[2:0]}));
					end
				end
				default: begin
					shiftout = `ZERO;
				end
			endcase
	end

	// Math
	assign op2_i_mux = ((aluOp_i == `ALU_SUBU_OP) ||
						 (aluOp_i == `ALU_SLTU_OP)) ?
						 (~operand2_i) + 1 : operand2_i;

	assign result_sum = operand1_i + op2_i_mux;

	//assign overflow_sum = ((!operand1_i[15] && !op2_i_mux[15]) && result_sum[15]) ||
	//					  ((operand1_i[15] && op2_i_mux[15]) && !result_sum[15]);

	assign op1_lt_op2 = (aluOp_i == `ALU_SLTU_OP) ?
						  ((operand1_i[15] && ~operand2_i[15]) || 
						  	(~operand1_i[15] && ~operand2_i[15] && result_sum[15])|| 
						  	(operand1_i[15] && operand2_i[15] && result_sum[15])) : (operand1_i < operand2_i);

	assign op1_neq_op2 = ~(operand1_i == operand2_i);

	//assign op1_i_not = ~operand1_i;

	always @(*) begin
			case (aluOp_i)
				`ALU_ADDU_OP, `ALU_ADDIU_OP, `ALU_ADDIU3_OP, `ALU_ADDSP_OP: begin
					mathout = result_sum;
				end
				`ALU_SUBU_OP: begin
					mathout = result_sum;
				end
				`ALU_SLTU_OP: begin
					mathout = op1_lt_op2;
				end
				`ALU_CMP_OP: begin
					mathout = op1_neq_op2;
				end
				default: begin
					mathout = `ZERO;
				end
			endcase
	end

endmodule
