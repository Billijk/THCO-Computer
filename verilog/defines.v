// ****** Global Definitions ******
`define RstEnable			1'b0
`define RstDisable		1'b1
`define Enable 				1'b1
`define Disable 			1'b0
`define HighZ               16'bz
`define ZERO                16'd0

// ****** Instruction Definitions ******
// Logic Instructions
`define EXE_SLL_SRA				5'b00110
`define EXE_ADDU_SUBU		5'b11100
`define EXE_AND_OR_CMP_SLTU_MFPC_JR_JRRA_JALR		5'b11101
`define EXE_NOP 			5'b00001
`define EXE_MTSP_ADDSP_SWRS_BTEQZ_BTNEZ 			5'b01100
`define EXE_MFIH_MTIH       5'b11110
`define EXE_ADDIU 			5'b01001
`define EXE_ADDIU3 		    5'b01000
`define EXE_LI              5'b01101
`define EXE_LW 				5'b10011
`define EXE_LWSP    		5'b10010
`define EXE_SW              5'b11011
`define EXE_SWSP            5'b11010
`define EXE_B 				5'b00010
`define EXE_BEQZ 			5'b00100
`define EXE_BNEZ 			5'b00101

// ALU Operators
`define ALU_SLL_OP			5'b00001 // Shift
`define ALU_SRA_OP			5'b00010 // Shift
`define ALU_ADDU_OP			5'b00011 // Math
`define ALU_SUBU_OP			5'b00100 // Math
`define ALU_ADDIU_OP		5'b01101 // Math
`define ALU_ADDIU3_OP		5'b01110 // Math
`define ALU_SLTU_OP			5'b01000 // Math
`define ALU_ADDSP_OP		5'b01111 // Math
`define ALU_CMP_OP			5'b00111 // Math
`define ALU_AND_OP			5'b00101 // Logic
`define ALU_OR_OP			5'b00110 // Logic
`define ALU_MTSP_OP			5'b01001
`define ALU_MFPC_OP			5'b01010
`define ALU_MFIH_OP			5'b01011
`define ALU_MTIH_OP			5'b01100
`define ALU_LI_OP			5'b10000
`define ALU_LW_OP			5'b10001
`define ALU_LWSP_OP			5'b10010
`define ALU_SW_OP			5'b10011
`define ALU_SWRS_OP			5'b10100
`define ALU_SWSP_OP			5'b10101
`define ALU_B_OP 			5'b10110
`define ALU_BEQZ_OP			5'b10111
`define ALU_BNEZ_OP			5'b11000
`define ALU_BTEQZ_OP		5'b11001
`define ALU_BTNEZ_OP		5'b11010
`define ALU_JR_OP			5'b11011
`define ALU_JRRA_OP			5'b11100
`define ALU_JALR_OP			5'b11101
`define ALU_NOP_OP			5'b11110

// MemOp
`define MEM_NOP_OP          2'b00
`define MEM_READ_OP         2'b01
`define MEM_WRITE_OP   		2'b10

`define NOPRegAddr			5'b00000

// ****** MMU Definitions ******
`define MMU_NOP             3'b000

// Special registers
`define REG_SP				4'b1000
`define REG_RA				4'b1001
`define REG_T				4'b1010
`define REG_IH 				4'b1011

// Serial port mode
`define COM_READ			1'b0
`define COM_WRITE			1'b1

//ram sec
`define SYS_PRO_SEC_MIN     16'h0000
`define SYS_PRO_SEC_MAX     16'h3fff
`define USER_PRO_SEC_MIN    16'h4000
`define USER_PRO_SEC_MAX    16'h7fff
`define SYS_DATA_SEC_MIN    16'h8000
`define SYS_DATA_SEC_MAX    16'hBEFF
`define USER_DATA_SEC_MIN   16'hc000
`define USER_DATA_SEC_MAX   16'hffff
`define COM_DATA_REG        16'hBF00
`define COM_SITU_REG        16'hBF01
`define KEYB_DATA_REG       16'hBF02
`define KEYB_SITU_REG       16'hBF03

`define ROM_SEC_MIN         16'h0000
`define ROM_SEC_MAX         16'h3fff
`define RAM_SEC_MIN         16'h4000
`define RAM_SEC_MAX         16'hfdff       //we need 512 bytes for the VGA
`define VGA_SEC_MIN         16'hfe00
`define VGA_SEC_MAX         16'hffff

