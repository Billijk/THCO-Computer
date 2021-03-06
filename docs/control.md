# 控制信号列表

| 指令   | ALUOP | OPERAND1          | OPERAND2     | WREG | MEMOP      | WD       | branchFlag |
|--------|-------|-------------------|--------------|------|------------|----------|------------|
| SLL    | 00001 | ry值              | ZeroExt(imm) | 1    | 000        | rx地址   | 0          |
| SRA    | 00010 | ry值              | ZeroExt(imm) | 1    | 000        | rx地址   | 0          |
| ADDU   | 00011 | rx值              | ry值         | 1    | 000        | rz地址   | 0          |
| SUBU   | 00100 | rx值              | ry值         | 1    | 000        | rz地址   | 0          |
| AND    | 00101 | rx值              | ry值         | 1    | 000        | rx地址   | 0          |
| OR     | 00110 | rx值              | ry值         | 1    | 000        | rx地址   | 0          |
| CMP    | 00111 | rx值              | ry值         | 1    | 000        | 1010(T)  | 0          |
| SLTU   | 01000 | rx值              | ry值         | 1    | 000        | 1010     | 0          |
| MTSP   | 01001 | rx值              | 0            | 1    | 000        | 1000(SP) | 0          |
| MFPC   | 01010 | PC值              | 0            | 1    | 000        | rx地址   | 0          |
| MFIH   | 01011 | IH值              | 0            | 1    | 000        | rx地址   | 0          |
| MTIH   | 01100 | rx值              | 0            | 1    | 000        | 1011(IH) | 0          |
| ADDIU  | 01101 | rx值              | SignExt(imm) | 1    | 000        | rx地址   | 0          |
| ADDIU3 | 01110 | rx值              | SignExt(imm) | 1    | 000        | ry地址   | 0          |
| ADDSP  | 01111 | rx值              | SignExt(imm) | 1    | 000        | 1000(SP) | 0          |
| LI     | 10000 | SignExt(imm)      | 0            | 1    | 000        | rx地址   | 0          |
| LW     | 10001 | rx值              | SignExt(imm) | 1    | 001(READ)  | ry地址   | 0          |
| LW_SP  | 10010 | rx值              | SignExt(imm) | 1    | 001        | rx地址   | 0          |
| SW     | 10011 | rx值+SignExt(imm) | ry值         | 0    | 010(WRITE) | -        | 0          |
| SW_RS  | 10100 | rx值+SignExt(imm) | RA值         | 0    | 010        | -        | 0          |
| SW_SP  | 10101 | rx值+SignExt(imm) | SP值         | 0    | 010        | -        | 0          |
| B      | 10100 | 0                 | 0            | 0    | 000        | -        | 1          |
| BEQZ   | 10111 | 0                 | 0            | 0    | 000        | -        | 1(条件)    |
| BNEZ   | 11000 | 0                 | 0            | 0    | 000        | -        | 1(条件)    |
| BTEQZ  | 11001 | 0                 | 0            | 0    | 000        | -        | 1(条件)    |
| BTNEZ  | 11010 | 0                 | 0            | 0    | 000        | -        | 1(条件)    |
| JR     | 11011 | 0                 | 0            | 0    | 000        | -        | 1          |
| JRRA   | 11100 | 0                 | 0            | 0    | 000        | -        | 1          |
| JALR   | 11101 | 0                 | 0            | 1    | 000        | 1001(RA) | 1          |
| NOP    | 11110 | 0                 | 0            | 0    | 000        | -        | 0          |