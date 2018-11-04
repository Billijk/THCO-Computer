`include "defines.v"

module id(
    //Input    
    //PC
    input wire[15:0] pc_i,
    input wire[15:0] ins_i,
    
    //Registers
    input wire[15:0] reg1Data_i,
    input wire[15:0] reg2Data_i,
    
    //EX
    //bypass
    input wire ex_writeReg_i,
    input wire[3:0] ex_writeRegAddr_i,
    input wire[15:0] ex_writeData_i,

    //MEM
    //bypass
    input wire mem_writeReg_i,
    input wire[3:0] mem_writeRegAddr_i,
    input wire[15:0] mem_writeData_i,

    //ID_EX (data conflict: after lw)
    input wire[1:0] lastMemOp_i,
    input wire[3:0] lastRegAddr_i,

    //Output
    //branch
    output reg[15:0] branchPC_o,
    output reg branchFlag_o,

    //PC
    output reg pc_pause_o,

    //Registers
    output reg[3:0] reg1Addr_o,
    output reg[3:0] reg2Addr_o,
    output reg re1_o,
    output reg re2_o,

    //ID_EX
    output reg id_pause_o,

    //EX
    output reg[15:0] operand1_o,
    output reg[15:0] operand2_o,
    output reg[4:0] aluOp_o,
    output reg ex_pause_o,

    //MEM
    output reg[1:0] memOp_o,

    //WB
    output reg wreg_o,
    output reg[3:0] wd_o
    );

	//Instruction Decoding Variables
    wire[4:0] op = ins_i[15:11];
    wire[2:0] sec1 = ins_i[10:8];
    wire[2:0] sec2 = ins_i[7:5];
    wire[2:0] sec3 = ins_i[4:2];
    wire[1:0] sec4 = ins_i[1:0];

    reg[15:0] regData1;
    reg[15:0] regData2;
    
    //regData1 - bypass
    always @(*) begin
        if (re1_o == `Enable && ex_writeReg_i == `Enable && reg1Addr_o == ex_writeRegAddr_i) begin
            regData1 = ex_writeData_i;
        end else if (re1_o == `Enable && mem_writeReg_i == `Enable && reg1Addr_o == mem_writeRegAddr_i) begin
            regData1 = mem_writeData_i;
        end else begin
            regData1 = reg1Data_i;
        end
    end

    //regData2 - bypass
    always @(*) begin
        if (re2_o == `Enable && ex_writeReg_i == `Enable && reg2Addr_o == ex_writeRegAddr_i) begin
            regData2 = ex_writeData_i;
        end else if (re2_o == `Enable && mem_writeReg_i == `Enable && reg2Addr_o == mem_writeRegAddr_i) begin
            regData2 = mem_writeData_i;
        end else begin
            regData2 = reg2Data_i;
        end
    end

    // insert bubble
    always @(*) begin
        if (lastMemOp_i == `MEM_READ_OP && 
            ((lastRegAddr_i == reg1Addr_o && re1_o == `Enable) || 
				(lastRegAddr_i == reg2Addr_o && re2_o == `Enable))) begin
            pc_pause_o = `Enable;
            id_pause_o = `Enable;
            ex_pause_o = `Enable;  
        end else begin
            pc_pause_o = `Disable;
            id_pause_o = `Disable;
            ex_pause_o = `Disable;
        end
    end

    //Decoding
    always @(*) begin
            //reg
            reg1Addr_o = `ZERO;
            reg2Addr_o = `ZERO;
            re1_o = `Disable;
            re2_o = `Disable;
        
            //alu
            operand1_o = `ZERO;
            operand2_o = `ZERO;
            aluOp_o = `ALU_NOP_OP;

            //mem
            memOp_o = `MEM_NOP_OP;

            //wb
            wreg_o = `Disable;
            wd_o = 4'h0;

            //branch
            branchPC_o = `ZERO;
            branchFlag_o = `Disable;

        case (op)
            //00110
            `EXE_SLL_SRA: begin
                case(sec4)
                    //SLL
                    2'b00: begin
                        //reg
                        re1_o = `Enable;
                        reg1Addr_o = {1'b0,sec2};
                        //alu
                        operand1_o = regData1;
                        operand2_o = {13'b0, sec3};
                        aluOp_o = `ALU_SLL_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = {1'b0,sec1};
                    end
                    //SRA
                    2'b11: begin
                        //reg
                        re1_o = `Enable;
                        reg1Addr_o = {1'b0,sec2};
                        //alu
                        operand1_o = regData1;
                        operand2_o = {13'b0, sec3};
                        aluOp_o = `ALU_SRA_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = {1'b0,sec1};
                    end
                    default: begin
                    	
                    end
                endcase
            end    //EXE_SLL_SRA END

            //11100
            `EXE_ADDU_SUBU: begin
                case(sec4)
                    //ADDU
                    2'b01: begin
                        //reg
                        re1_o = `Enable;
                        reg1Addr_o = {1'b0,sec1};
                        re2_o = `Enable;
                        reg2Addr_o = {1'b0,sec2};
                        //alu
                        operand1_o = regData1;
                        operand2_o = regData2;
                        aluOp_o = `ALU_ADDU_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = {1'b0,sec3};
                    end
                    //SUBU
                    2'b11: begin
                        //reg
                        re1_o = `Enable;
                        reg1Addr_o = {1'b0,sec1};
                        re2_o = `Enable;
                        reg2Addr_o = {1'b0,sec2};
                        //alu
                        operand1_o = regData1;
                        operand2_o = regData2;
                        aluOp_o = `ALU_SUBU_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = {1'b0,sec3};
                    end
                    default: begin
                    	
                    end
                endcase
            end    //EXE_ADDU_SUBU END

            //11101
            `EXE_AND_OR_CMP_SLTU_MFPC_JR_JRRA_JALR: begin
                case({sec3,sec4})
                    //AND
                    5'b01100: begin
                        //reg
                        re1_o = `Enable;
                        reg1Addr_o = {1'b0,sec1};
                        re2_o = `Enable;
                        reg2Addr_o = {1'b0,sec2};
                        //alu
                        operand1_o = regData1;
                        operand2_o = regData2;
                        aluOp_o = `ALU_AND_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = {1'b0,sec1};
                    end
                    //OR
                    5'b01101: begin
                        //reg
                        re1_o = `Enable;
                        reg1Addr_o = {1'b0,sec1};
                        re2_o = `Enable;
                        reg2Addr_o = {1'b0,sec2};
                        //alu
                        operand1_o = regData1;
                        operand2_o = regData2;
                        aluOp_o = `ALU_OR_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = {1'b0,sec1};
                    end
                    //CMP
                    5'b01010: begin
                        //reg
                        re1_o = `Enable;
                        reg1Addr_o = {1'b0,sec1};
                        re2_o = `Enable;
                        reg2Addr_o = {1'b0,sec2};
                        //alu
                        operand1_o = regData1;
                        operand2_o = regData2;
                        aluOp_o = `ALU_CMP_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = `REG_T;
                    end
                    //SLTU
                    5'b00011: begin
                        //reg
                        re1_o = `Enable;
                        reg1Addr_o = {1'b0,sec1};
                        re2_o = `Enable;
                        reg2Addr_o = {1'b0,sec2};
                        //alu
                        operand1_o = regData1;
                        operand2_o = regData2;
                        aluOp_o = `ALU_SLTU_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = `REG_T;
                    end
                    //MFPC_JR_JRRA_JALR
                    5'b00000: begin
                        case(sec2)
                        	//MFPC
                        	3'b010: begin
                            	//alu
                            	operand1_o = pc_i + 1;
                            	operand2_o = 16'b0;
                            	aluOp_o = `ALU_MFPC_OP;
                            	//wb
                            	wreg_o = `Enable;
                            	wd_o = {1'b0,sec1};
                        	end
                        	//JR
                        	3'b000: begin
                        	    //reg
                        		re1_o = `Enable;
                        		reg1Addr_o = {1'b0,sec1};
                        		//alu
                        		operand1_o = 16'b0;
                        		operand2_o = 16'b0;
                        		aluOp_o = `ALU_JR_OP;
                        		//branch
                        		branchPC_o = regData1;
                        		branchFlag_o = `Enable;
                        	end
                        	//JRRA
                        	3'b001: begin
                        	    //reg
                        		re1_o = `Enable;
                        		reg1Addr_o = `REG_RA;
                        		//alu
                        		operand1_o = 16'b0;
                        		operand2_o = 16'b0;
                        		aluOp_o = `ALU_JRRA_OP;
                        		//branch
                        		branchPC_o = regData1;
                        		branchFlag_o = `Enable;
                        	end
                        	//JALR
                        	3'b110: begin
                        	    //reg
                        		re1_o = `Enable;
                        		reg1Addr_o = {1'b0,sec1};
                        		re2_o = `Enable;
                        		reg2Addr_o = `REG_RA;
                        		//alu
                        		operand1_o = pc_i + 2;
                        		operand2_o = 16'b0;
                        		aluOp_o = `ALU_JALR_OP;
                        		//branch
                        		branchPC_o = regData1;
                        		branchFlag_o = `Enable;
                        		//wb
                        		wreg_o = `Enable;
                            	wd_o = `REG_RA;
                        	end
                        	default: begin
                    	
                    		end
                        endcase
                    end
                    default: begin
                    	
                    end
                endcase
            end    //EXE_AND_OR_CMP_SLTU_MFPC_JR_JRRA_JALR END

            //01100
            `EXE_MTSP_ADDSP_SWRS_BTEQZ_BTNEZ: begin
                case(sec1)
                    //MTSP
                    3'b100: begin
                        //reg
                        re1_o = `Enable;
                        reg1Addr_o = {1'b0,sec2};
                        //alu
                        operand1_o = regData1;
                        operand2_o = 16'b0;
                        aluOp_o = `ALU_MTSP_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = `REG_SP;
                    end
                    //ADDSP
                    3'b011: begin
                        //reg
                        re1_o = `Enable;
                        reg1Addr_o = `REG_SP;
                        //alu
                        operand1_o = regData1;
                        operand2_o = {{8{sec2[2]}},sec2,sec3,sec4};
                        aluOp_o = `ALU_ADDSP_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = `REG_SP;
                    end
                    //SWRS
                    3'b010: begin
                    	//reg
                        re1_o = `Enable;
                        reg1Addr_o = `REG_SP;
                        re2_o = `Enable;
                        reg2Addr_o = `REG_RA;
                        //alu
                        operand1_o = regData1 + {{8{sec2[2]}},sec2,sec3,sec4};
                        operand2_o = regData2;
                        aluOp_o = `ALU_SWRS_OP;
                		//mem
                		memOp_o = `MEM_WRITE_OP;
                    end
                    //BTEQZ
                    3'b000: begin
                    	//reg
                		re1_o = `Enable;
                		reg1Addr_o = `REG_T;
            			//alu
                		aluOp_o = `ALU_BTEQZ_OP;
                		//branch
                		if(regData1 == 16'b0) begin
                			branchPC_o = pc_i + 1 + {{8{sec2[2]}},sec2,sec3,sec4};
                			branchFlag_o = `Enable;
                		end else begin
                			
                		end
                    end
                    //BTNEZ
                    3'b001: begin
                    	//reg
                		re1_o = `Enable;
                		reg1Addr_o = `REG_T;
            			//alu
                		aluOp_o = `ALU_BTNEZ_OP;
                		//branch
                		if(regData1 == 16'b0) begin
                			
                		end else begin
                			branchPC_o = pc_i + 1 + {{8{sec2[2]}},sec2,sec3,sec4};
                			branchFlag_o = `Enable;
                		end
                    end
                    default: begin
                    	
                    end
                endcase
            end    //EXE_MTSP_ADDSP_SWRS_BTEQZ_BTNEZ END

            //11110
            `EXE_MFIH_MTIH: begin
            	case(sec4)
            		//MFIH
            		2'b00: begin
            			//reg
                        re1_o = `Enable;
                        reg1Addr_o = `REG_IH;
                        //alu
                        operand1_o = regData1;
                        operand2_o = 16'b0;
                        aluOp_o = `ALU_MFIH_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = {1'b0,sec1};
            		end
            		//MTIH
            		2'b01: begin
            			//reg
                        re1_o = `Enable;
                        reg1Addr_o = {1'b0,sec1};
                        //alu
                        operand1_o = regData1;
                        operand2_o = 16'b0;
                        aluOp_o = `ALU_MTIH_OP;
                        //wb
                        wreg_o = `Enable;
                        wd_o = `REG_IH;
            		end
            		default: begin
                    	
                    end
            	endcase
            end    //EXE_MFIH_MTIH END

            //01001
            `EXE_ADDIU: begin
            	//reg
                re1_o = `Enable;
                reg1Addr_o = {1'b0,sec1};
                //alu
                operand1_o = regData1;
                operand2_o = {{8{sec2[2]}},sec2,sec3,sec4};
                aluOp_o = `ALU_ADDIU_OP;
                //wb
                wreg_o = `Enable;
                wd_o = {1'b0,sec1};
            end    //EXE_ADDIU END

            //01000
            `EXE_ADDIU3: begin
            	//reg
                re1_o = `Enable;
                reg1Addr_o = {1'b0,sec1};
                //alu
                operand1_o = regData1;
                operand2_o = {{12{sec3[1]}},sec3[1:0],sec4};
                aluOp_o = `ALU_ADDIU3_OP;
                //wb
                wreg_o = `Enable;
                wd_o = {1'b0,sec2};
            end    //EXE_ADDIU3 END

            //01101
            `EXE_LI: begin
                //alu
                operand1_o = {{8{sec2[2]}},sec2,sec3,sec4};
                operand2_o = 16'b0;
                aluOp_o = `ALU_LI_OP;
                //wb
                wreg_o = `Enable;
                wd_o = {1'b0,sec1};
            end    //EXE_LI END

            //10011
            `EXE_LW: begin
            	//reg
                re1_o = `Enable;
                reg1Addr_o = {1'b0,sec1};
                //alu
                operand1_o = regData1;
                operand2_o = {{11{sec3[2]}},sec3,sec4};
                aluOp_o = `ALU_LW_OP;
                //wb
                wreg_o = `Enable;
                wd_o = {1'b0,sec2};
                //mem
                memOp_o = `MEM_READ_OP;
            end    //EXE_LW END

            //10010
            `EXE_LWSP: begin
            	//reg
                re1_o = `Enable;
                reg1Addr_o = `REG_SP;
                //alu
                operand1_o = regData1;
                operand2_o = {{8{sec2[2]}},sec2,sec3,sec4};
                aluOp_o = `ALU_LWSP_OP;
                //wb
                wreg_o = `Enable;
                wd_o = {1'b0,sec1};
                //mem
                memOp_o = `MEM_READ_OP;
            end    //EXE_LWSP END

            //11011
            `EXE_SW: begin
            	//reg
                re1_o = `Enable;
                reg1Addr_o = {1'b0,sec1};
                re2_o = `Enable;
                reg2Addr_o = {1'b0,sec2};
                //alu
                operand1_o = regData1 + {{11{sec3[2]}},sec3,sec4};
                operand2_o = regData2;
                aluOp_o = `ALU_SW_OP;
                //mem
                memOp_o = `MEM_WRITE_OP;
            end    //EXE_SW END

            //11010
            `EXE_SWSP: begin
            	//reg
                re1_o = `Enable;
                reg1Addr_o = `REG_SP;
                re2_o = `Enable;
                reg2Addr_o = {1'b0,sec1};
                //alu
                operand1_o = regData1 + {{8{sec2[2]}},sec2,sec3,sec4};
                operand2_o = regData2;
                aluOp_o = `ALU_SWSP_OP;
                //mem
                memOp_o = `MEM_WRITE_OP;
            end    //EXE_SWSP END

            //00010
            `EXE_B: begin
                //alu
                aluOp_o = `ALU_B_OP;
                //branch
                branchPC_o = pc_i + 1 + {{5{sec1[2]}},sec1,sec2,sec3,sec4};
                branchFlag_o = `Enable;

            end    //EXE_B END

            //00100
            `EXE_BEQZ: begin
            	//reg
                re1_o = `Enable;
                reg1Addr_o = {1'b0,sec1};
            	//alu
                aluOp_o = `ALU_BEQZ_OP;
                //branch
                if(regData1 == 16'b0) begin
                	branchPC_o = pc_i + 1 + {{8{sec2[2]}},sec2,sec3,sec4};
                	branchFlag_o = `Enable;
                end else begin
                	
                end
            end    //EXE_BEQZ END

            //00101
            `EXE_BNEZ: begin
            	//reg
                re1_o = `Enable;
                reg1Addr_o = {1'b0,sec1};
            	//alu
                aluOp_o = `ALU_BNEZ_OP;
                //branch
                if(regData1 == 16'b0) begin
                	
                end else begin
                	branchPC_o = pc_i + 1 + {{8{sec2[2]}},sec2,sec3,sec4};
                	branchFlag_o = `Enable;
                end
            end    //EXE_BNEZ END

            //00001
            `EXE_NOP: begin
                //alu
                    operand1_o = 16'b0;
                    operand2_o = 16'b0;
                    aluOp_o = `ALU_NOP_OP;
            end    //EXE_NOP END

            default: begin
				//default process is done at the first
			end
		endcase
    end

endmodule
