# THCO

## 文件说明
test.v和VirualSram.v是仿真文件，其余所有文件都是工程中用到的文件。
tools/文件夹下是我们开发过程中用到的一些脚本：
* converter.py是一个汇编器，用于将汇编代码（包括）汇编成机器码，可以输出成verilog的查找表；
* parseFont.m用于从字符集图片中得到每个字符的01掩码；
* make\_vga\_rom.py用于将parseFont.m得到的掩码文件写成verilog代码查找表；
* kernel.s是监控程序的汇编代码；
* font.png是字符集图片。

## 指令集

##### R型指令(12)
SLL,SRA,ADDU,AND,CMP,MFIH,MFPC,MTIH,MTSP,OR,SUBU,SLTU
##### I型指令(9)
ADDIU,ADDIU3,ADDSP,LI,LW,LW\_SP,SW,SW\_RS,SW_SP 
##### B型指令(5)
B,BEQZ,BNEZ,BTEQZ,BTNEZ
##### J型指令(4)
JR,NOP,JRRA,JALR

## 相关文档
指令详细说明：[instructions.md](docs/instructions.md)
控制信号说明：[control.md](docs/control.md)
