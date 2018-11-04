# THCO-mips 指令

##指令集

#####R型指令(12)
SLL,SRA,ADDU,AND,CMP,MFIH,MFPC,MTIH,MTSP,OR,SUBU,SLTU
#####I型指令(9)
ADDIU,ADDIU3,ADDSP,LI,LW,LW\_SP,SW,SW\_RS,SW_SP 
#####B型指令(5)
B,BEQZ,BNEZ,BTEQZ,BTNEZ
#####J型指令(4)
JR,NOP,JRRA,JALR

##指令说明：

|      指令格式      |     汇编语句    |      功能说明     |
|--------------------|-----------------|-------------------|
| 00110 rx ry imm 00 | SLL rx ry imm   | rx ← ry << imm(L) |
| 00110 rx ry imm 11 | SRA rx ry imm   | rx ← ry >> imm(A) |
| 11100 rx ry rz 01  | ADDU rx ry rz   | rz ← rx + ry      |
| 11100 rx ry rz 11  | SUBU rx ry rz   | rz ← rx - ry      |
| 11101 rx ry 011 00 | AND rx ry       | rx ← rx & ry      |
| 11101 rx ry 011 01 | OR rx ry        | rx ← rx or ry     |
| 11101 rx ry 010 10 | CMP rx ry       | if rx = ry, T ← 0 |
| 11101 rx ry 000 11 | SLTU rx ry      | if rx < ry (unsigned), T ← 1  |
| 01100 100 rx 000 00 | MTSP rx        | SP ← rx           |
| 11101 rx 010 000 00 | MFPC rx        | rx ← PC           |
| 11110 rx 000 000 00 | MFIH rx        | rx ← IH           |
| 11110 rx 000 000 01 | MTIH rx        | IH ← rx           |
| 01001 rx imm       | ADDIU rx imm    | rx ← rx + sign_ext(imm) |
| 01000 rx ry 0 imm | ADDIU3 rx ry imm | ry ← rx + sign_ext(imm) |
| 01100 011 imm      | ADDSP imm       | SP ← SP + sign_ext(imm) |
| 01101 rx imm       | LI rx imm       | rx ← sign_ext(imm) |
| 10011 rx ry imm    | LW rx ry imm    | ry ← MEM[rx + imm] |
| 10010 rx imm       | LW_SP rx imm    | rx ← MEM[SP + imm] |
| 11011 rx ry imm    | SW rx ry imm    | MEM[rx + imm] ← ry |
| 01100 010 imm      | SW_RS imm       | MEM[SP + imm] ← RA |
| 11010 rx imm       | SW_SP rx imm    | MEM[SP + imm] ← rx |
| 00010 imm          | B imm           | PC ← PC + sign_ext(imm) |
| 00100 rx imm       | BEQZ rx imm     | branch when rx=0   |
| 00101 rx imm       | BNEZ rx imm     | branch when rx!=0  |
| 01100 000 imm      | BTEQZ imm       | branch when T=0    |
| 01100 001 imm      | BTNEZ imm       | branch when T!=0   |
| 11101 rx 00000000  | JR rx           | PC ← rx            |
| 11101 000 00100000 | JRRA            | PC ← RA            |
| 11101 rx 11000000  | JALR rx         | PC ← rx RA ← PC    |
| 00001 000 00000000 | NOP             | empty instruction  |