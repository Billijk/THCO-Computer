#!/usr/bin/env python
# encoding: utf-8
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('input', type=str, help='input file')
parser.add_argument('--output', default='rom.v', help='output file (default: rom.v)')
parser.add_argument('--raw', action="store_true")

class Converter(object):
    '''
    This class is aimed at translating assembly code into a THCO-MIPS rom module
    '''

    def __init__(self, output_filename, keep_raw):
        self.addr = 0
        self.f = None  # Input file
        self.backup = ''  # Current command
        self.linenum = 0  # Current line num
        self.keep_raw = keep_raw # output fotmat
        self.output_filename = output_filename
        self.command_lut = {  # Command parameter number look-up table
            'SLL': 4,
            'SRA': 4,
            'ADDU': 4,
            'SUBU': 4,
            'AND': 3,
            'OR': 3,
            'CMP': 3,
            'SLTU': 3,
            'MTSP': 2,
            'MFPC': 2,
            'MFIH': 2,
            'MTIH': 2,
            'ADDIU': 3,
            'ADDIU3': 4,
            'ADDSP': 2,
            'LI': 3,
            'LW': 4,
            'LW_SP': 3,
            'SW': 4,
            'SW_RS': 2,
            'SW_SP': 3,
            'B': 2,
            'BEQZ': 3,
            'BNEZ': 3,
            'BTEQZ': 2,
            'BTNEZ': 2,
            'JR': 2,
            'JRRA': 1,
            'JALR': 2,
            'NOP': 1
        }
        self.symtable = {}  # For jump branches

    # Tool functions

    def parse_imm(self, imm, length, ishex=True):
        if ishex:
            imm = bin(int(imm, 16))[2:]
        if len(imm) > length:
            self.throw_exception("Imm too long")
        return imm.zfill(length)

    def parse_reg(self, regstr):
        if len(regstr) != 2 or regstr[0] != 'R':
            self.throw_exception("Register format error")
        dig = regstr[1]
        try:
            bindig = bin(int(dig))[2:]
        except:
            self.throw_exception("Compiler internal error")
        return self.parse_imm(bindig, 3, False)

    def parse_flag(self, flag, length=8):
        if flag not in self.symtable:
            if all(list(map(lambda x: x in ['A', 'B', 'C', 'D', 'E', 'F',
                    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'], flag))):
                print ("Warning: symbol {flag} at line {linenum} not found. Treat as hex".format(
                    flag=flag, linenum=self.linenum))
                return flag
            else:
                self.throw_exception("Symbol not found")
        delta = self.symtable[flag] - (self.addr + 1)
        over_max_imm = int('1' + ''.join(['0'] * length), 2)
        if delta >= over_max_imm / 2:
            self.throw_exception("Relative distance overflow")
        if delta < 0:
            delta += over_max_imm
        if delta < 0:
            self.throw_exception("Relative distance overflow")
        self.current_symbol = flag
        self.current_delta = hex(delta)
        return hex(delta)

    def throw_exception(self, text):
        print ("Exception at line {linenum}, command {command}: {text}".format(
            linenum=self.linenum, command=self.backup, text=text))
        sys.exit(1)

    def translate_commands(self, digit):
        if len(digit) != 16:
            self.throw_exception("Command length is not 16bits")
        try:
            addr = hex(self.addr)[2:].zfill(4)
            digit = bin(int(digit, 2))[2:].zfill(16)
        except:
            self.throw_exception("Compiler internal error")
        if self.keep_raw == True:
            '''
            if self.current_symbol is None:
                self.f.write('{command}\n'.format(
                    command=self.backup.replace('0x', '')
                                       .replace('_', '-')))
            else:
                self.f.write('{command}\n'.format(
                    command=self.backup.replace(self.current_symbol, self.current_delta)
                                       .replace('0x', '')
                                       .replace('_', '-')))
            '''
            digit = hex(int(digit, 2))[2:].zfill(4)
            self.f.write('{command}\n'.format(command=digit))
        elif self.current_symbol is None:
            self.f.write("\t\t\t16'h{addr}: ins_o = 16'b{digit};    // {command}\n".format(
                addr=addr, digit=digit, command=self.backup))
        else:
            self.f.write("\t\t\t16'h{addr}: ins_o = 16'b{digit};    // {command} ({symbol} Addr={symaddr})\n".format(
                addr=addr, digit=digit, command=self.backup, symbol=self.current_symbol, symaddr=hex(self.symtable[self.current_symbol])))
        self.addr += 1

    # Parsers

    def parse_command(self, raw_command):
        self.backup = raw_command
        command = raw_command.strip()
        command = ' '.join(filter(lambda x: x, command.split(' ')))
        commands = command.split(' ')

        if len(commands) < 1:
            commands = ['NOP']
        raw_command = commands[0]

        if raw_command[-1] == ':':
            return

        if len(commands) != self.command_lut[raw_command]:
            self.throw_exception("Parameter num error")

        self.current_symbol = None
        self.current_delta = None

        if raw_command == 'SLL':
            header = '00110'
            reg1 = self.parse_reg(commands[1])
            reg2 = self.parse_reg(commands[2])
            imm = self.parse_imm(commands[3], 3)
            tail = '00'
            seq = header + reg1 + reg2 + imm + tail
        elif raw_command == 'SRA':
            header = '00110'
            reg1 = self.parse_reg(commands[1])
            reg2 = self.parse_reg(commands[2])
            imm = self.parse_imm(commands[3], 3)
            tail = '11'
            seq = header + reg1 + reg2 + imm + tail
        elif raw_command == 'ADDU':
            header = '11100'
            reg1 = self.parse_reg(commands[1])
            reg2 = self.parse_reg(commands[2])
            reg3 = self.parse_reg(commands[3])
            tail = '01'
            seq = header + reg1 + reg2 + reg3 + tail
        elif raw_command == 'SUBU':
            header = '11100'
            reg1 = self.parse_reg(commands[1])
            reg2 = self.parse_reg(commands[2])
            reg3 = self.parse_reg(commands[3])
            tail = '11'
            seq = header + reg1 + reg2 + reg3 + tail
        elif raw_command == 'AND':
            header = '11101'
            reg1 = self.parse_reg(commands[1])
            reg2 = self.parse_reg(commands[2])
            tail = '01100'
            seq = header + reg1 + reg2 + tail
        elif raw_command == 'OR':
            header = '11101'
            reg1 = self.parse_reg(commands[1])
            reg2 = self.parse_reg(commands[2])
            tail = '01101'
            seq = header + reg1 + reg2 + tail
        elif raw_command == 'CMP':
            header = '11101'
            reg1 = self.parse_reg(commands[1])
            reg2 = self.parse_reg(commands[2])
            tail = '01010'
            seq = header + reg1 + reg2 + tail
        elif raw_command == 'SLTU':
            header = '11101'
            reg1 = self.parse_reg(commands[1])
            reg2 = self.parse_reg(commands[2])
            tail = '00011'
            seq = header + reg1 + reg2 + tail
        elif raw_command == 'MTSP':
            header = '01100100'
            reg1 = self.parse_reg(commands[1])
            tail = '00000'
            seq = header + reg1 + tail
        elif raw_command == 'MFPC':
            header = '11101'
            reg1 = self.parse_reg(commands[1])
            tail = '01000000'
            seq = header + reg1 + tail
        elif raw_command == 'MFIH':
            header = '11110'
            reg1 = self.parse_reg(commands[1])
            tail = '00000000'
            seq = header + reg1 + tail
        elif raw_command == 'MTIH':
            header = '11110'
            reg1 = self.parse_reg(commands[1])
            tail = '00000001'
            seq = header + reg1 + tail
        elif raw_command == 'ADDIU':
            header = '01001'
            reg1 = self.parse_reg(commands[1])
            imm = self.parse_imm(commands[2], 8)
            seq = header + reg1 + imm
        elif raw_command == 'ADDIU3':
            header = '01000'
            reg1 = self.parse_reg(commands[1])
            reg2 = self.parse_reg(commands[2])
            interrupt = '0'
            imm = self.parse_imm(commands[3], 4)
            seq = header + reg1 + reg2 + interrupt + imm
        elif raw_command == 'ADDSP':
            header = '01100011'
            imm = self.parse_imm(commands[1], 8)
            seq = header + imm
        elif raw_command == 'LI':
            header = '01101'
            reg1 = self.parse_reg(commands[1])
            imm = self.parse_imm(commands[2], 8)
            seq = header + reg1 + imm
        elif raw_command == 'LW':
            header = '10011'
            reg1 = self.parse_reg(commands[1])
            reg2 = self.parse_reg(commands[2])
            imm = self.parse_imm(commands[3], 5)
            seq = header + reg1 + reg2 + imm
        elif raw_command == 'LW_SP':
            header = '10010'
            reg1 = self.parse_reg(commands[1])
            imm = self.parse_imm(commands[2], 8)
            seq = header + reg1 + imm
        elif raw_command == 'SW':
            header = '11011'
            reg1 = self.parse_reg(commands[1])
            reg2 = self.parse_reg(commands[2])
            imm = self.parse_imm(commands[3], 5)
            seq = header + reg1 + reg2 + imm
        elif raw_command == 'SW_RS':
            header = '01100010'
            imm = self.parse_imm(commands[1], 8)
            seq = header + imm
        elif raw_command == 'SW_SP':
            header = '11010'
            reg1 = self.parse_reg(commands[1])
            imm = self.parse_imm(commands[2], 8)
            seq = header + reg1 + imm
        elif raw_command == 'B':
            header = '00010'
            if commands[1][0].isalpha():
                commands[1] = self.parse_flag(commands[1], 11)
            imm = self.parse_imm(commands[1], 11)
            seq = header + imm
        elif raw_command == 'BEQZ':
            header = '00100'
            reg1 = self.parse_reg(commands[1])
            if commands[2][0].isalpha():
                commands[2] = self.parse_flag(commands[2])
            imm = self.parse_imm(commands[2], 8)
            seq = header + reg1 + imm
        elif raw_command == 'BNEZ':
            header = '00101'
            reg1 = self.parse_reg(commands[1])
            if commands[2][0].isalpha():
                commands[2] = self.parse_flag(commands[2])
            imm = self.parse_imm(commands[2], 8)
            seq = header + reg1 + imm
        elif raw_command == 'BTEQZ':
            header = '01100000'
            if commands[1][0].isalpha():
                commands[1] = self.parse_flag(commands[1])
            imm = self.parse_imm(commands[1], 8)
            seq = header + imm
        elif raw_command == 'BTNEZ':
            header = '01100001'
            if commands[1][0].isalpha():
                commands[1] = self.parse_flag(commands[1])
            imm = self.parse_imm(commands[1], 8)
            seq = header + imm
        elif raw_command == 'JR':
            header = '11101'
            reg1 = self.parse_reg(commands[1])
            tail = '00000000'
            seq = header + reg1 + tail
        elif raw_command == 'JRRA':
            header = '1110100000100000'
            seq = header
        elif raw_command == 'JALR':
            header = '11101'
            reg1 = self.parse_reg(commands[1])
            tail = '11000000'
            seq = header + reg1 + tail
        elif raw_command == 'NOP':
            header = '0000100000000000'
            seq = header
        else:
            self.throw_exception("No such THCO-MIPS command")

        self.translate_commands(seq)

    def build_sym(self, raw_code):  # First part: build up symbol table
        code = raw_code.splitlines()
        for linenum, line in enumerate(code):
            self.linenum = linenum + 1
            self.backup = line
            command = line.split(';')[0].strip()
            if ':' in command:
                flag = command.split(':')[0].strip()
                if ' ' in flag or not flag[0].isalpha():  # Flag should start with 'a'~'z' or 'A'~'Z'
                    self.throw_exception("Branch flag format error")
                self.symtable[flag] = self.addr
            else:  # No need to check grammer here
                if len(command) >= 1:
                    self.addr += 1
        print ("SymTable built successfully")
        print ("SymTable = {}".format(self.symtable))
        self.linenum = 0
        self.backup = ''
        self.addr = 0

    def parse_program(self, raw_code):  # Second part: parse other commands and calculate address of branches
        code = raw_code.splitlines()
        for linenum, line in enumerate(code):
            self.linenum = linenum + 1
            command = line.split(';')[0].strip()
            
            if len(command) >= 1:
                self.parse_command(command)
            else:
                pass

    def __call__(self, input_filename):
        self.addr = 0
        self.backup = ''
        self.linenum = 0

        self.f = open(self.output_filename, 'w')
        if (not self.keep_raw):
            self.f.write("`include \"defines.v\"\n")
            self.f.write("\n")
            self.f.write("module rom(\n\tinput wire[15:0] pc,")
            self.f.write("\n\toutput reg[15:0] ins_o\n\t);")
            self.f.write("\n\n\talways @(*) begin\n\t\t//-*case*-/\n\t\t")
            self.f.write("case (pc[15:0])\n")

        program = open(input_filename, 'r').read()
        self.build_sym(program)
        self.parse_program(program)
        if (not self.keep_raw):
            self.f.write("\t\t\tdefault: ins_o = 16'h0800;\n")
            self.f.write("\t\tendcase\n\t\t//-*case*-/\n\tend\n\nendmodule")
        self.f.close()
        print ("Complete!")

if __name__ == "__main__":
    args = parser.parse_args()
    convert = Converter(args.output, args.raw)
    convert(args.input)
