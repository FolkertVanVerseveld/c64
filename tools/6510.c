#include "6510.h"

const struct op optbl[256] = {
	{O_IMP, "BRK"}, {O_IZX, "ORA"}, {O_IMP, "KIL"}, {O_IZX, "SLO"}, {O_ZP, "NOP"}, {O_ZP, "ORA"}, {O_ZP, "ASL"}, {O_ZP, "SLO"},
	{O_IMP, "PHP"}, {O_IMM, "ORA"}, {O_IMP, "ASL"}, {O_IMM, "ANC"}, {O_ABS, "NOP"}, {O_ABS, "ORA"}, {O_ABS, "ASL"}, {O_ABS, "SLO"},
	{O_REL, "BPL"}, {O_IZY, "ORA"}, {O_IMP, "KIL"}, {O_IZY, "SLO"}, {O_ZPX, "NOP"}, {O_ZPX, "ORA"}, {O_ZPX, "ASL"}, {O_ZPX, "SLO"},
	{O_IMP, "CLC"}, {O_ABY, "ORA"}, {O_IMP, "NOP"}, {O_ABY, "SLO"}, {O_ABX, "NOP"}, {O_ABX, "ORA"}, {O_ABX, "ASL"}, {O_ABX, "SLO"},
	{O_ABS, "JSR"}, {O_IZX, "AND"}, {O_IMP, "KIL"}, {O_IZX, "RLA"}, {O_ZP, "BIT"}, {O_ZP, "AND"}, {O_ZP, "ROL"}, {O_ZP, "RLA"},
	{O_IMP, "PLP"}, {O_IMM, "AND"}, {O_IMP, "ROL"}, {O_IMM, "ANC"}, {O_ABS, "BIT"}, {O_ABS, "AND"}, {O_ABS, "ROL"}, {O_ABS, "RLA"},
	{O_REL, "BMI"}, {O_IZY, "AND"}, {O_IMP, "KIL"}, {O_IZY, "RLA"}, {O_ZPX, "NOP"}, {O_ZPX, "AND"}, {O_ZPX, "ROL"}, {O_ZPX, "RLA"},
	{O_IMP, "SEC"}, {O_ABY, "AND"}, {O_IMP, "NOP"}, {O_ABY, "RLA"}, {O_ABX, "NOP"}, {O_ABX, "AND"}, {O_ABX, "ROL"}, {O_ABX, "RLA"},
	{O_IMP, "RTI"}, {O_IZX, "EOR"}, {O_IMP, "KIL"}, {O_IZY, "SRE"}, {O_ZP, "NOP"}, {O_ZP, "EOR"}, {O_ZP, "LSR"}, {O_ZP, "SRE"},
	{O_IMP, "PHA"}, {O_IMM, "EOR"}, {O_IMP, "LSR"}, {O_IMM, "ALR"}, {O_ABS, "JMP"}, {O_ABS, "EOR"}, {O_ABS, "LSR"}, {O_ABS, "SRE"},
	{O_REL, "BVC"}, {O_IZY, "EOR"}, {O_IMP, "KIL"}, {O_IZY, "SRE"}, {O_ZPX, "NOP"}, {O_ZPX, "EOR"}, {O_ZPX, "LSR"}, {O_ZPX, "SRE"},
	{O_IMP, "CLI"}, {O_ABY, "EOR"}, {O_IMP, "NOP"}, {O_ABY, "SRE"}, {O_ABX, "NOP"}, {O_ABX, "EOR"}, {O_ABX, "LSR"}, {O_ABX, "SRE"},
	{O_IMP, "RTS"}, {O_IZX, "ADC"}, {O_IMP, "KIL"}, {O_IZY, "RRA"}, {O_ZP, "NOP"}, {O_ZP, "ADC"}, {O_ZP, "ROR"}, {O_ZP, "RRA"},
	{O_IMP, "PLA"}, {O_IMM, "ADC"}, {O_IMP, "ROR"}, {O_IMM, "ARR"}, {O_IND, "JMP"}, {O_ABS, "ADC"}, {O_ABS, "ROR"}, {O_ABS, "RRA"},
	{O_REL, "BVS"}, {O_IZY, "ADC"}, {O_IMP, "KIL"}, {O_IZY, "RRA"}, {O_ZPX, "NOP"}, {O_ZPX, "ADC"}, {O_ZPX, "ROR"}, {O_ZPX, "RRA"},
	{O_IMP, "SEI"}, {O_ABY, "ADC"}, {O_IMP, "NOP"}, {O_ABY, "RRA"}, {O_ABX, "NOP"}, {O_ABX, "ADC"}, {O_ABX, "ROR"}, {O_ABX, "RRA"},
	{O_IMM, "NOP"}, {O_IZX, "STA"}, {O_IMM, "NOP"}, {O_IZX, "SAX"}, {O_ZP, "STY"}, {O_ZP, "STA"}, {O_ZP, "STX"}, {O_ZP, "SAX"},
	{O_IMP, "DEY"}, {O_IMM, "NOP"}, {O_IMP, "TXA"}, {O_IMM, "XAA"}, {O_ABS, "STY"}, {O_ABS, "STA"}, {O_ABS, "STX"}, {O_ABS, "SAX"},
	{O_REL, "BCC"}, {O_IZY, "STA"}, {O_IMP, "KIL"}, {O_IZY, "AHX"}, {O_ZPX, "STY"}, {O_ZPX, "STA"}, {O_ZPY, "STX"}, {O_ZPY, "SAX"},
	{O_IMP, "TYA"}, {O_ABY, "STA"}, {O_IMP, "TXS"}, {O_ABY, "TAS"}, {O_ABX, "SHY"}, {O_ABX, "STA"}, {O_ABY, "SHX"}, {O_ABY, "AHX"},
	{O_IMM, "LDY"}, {O_IZX, "LDA"}, {O_IMM, "LDX"}, {O_IZX, "LAX"}, {O_ZP, "LDY"}, {O_ZP, "LDA"}, {O_ZP, "LDX"}, {O_ZP, "LAX"},
	{O_IMP, "TAY"}, {O_IMM, "LDA"}, {O_IMP, "TAX"}, {O_IMM, "LAX"}, {O_ABS, "LDY"}, {O_ABS, "LDA"}, {O_ABS, "LDX"}, {O_ABS, "LAX"},
	{O_REL, "BCS"}, {O_IZY, "LDA"}, {O_IMM, "KIL"}, {O_IZY, "LAX"}, {O_ZPX, "LDY"}, {O_ZPX, "LDA"}, {O_ZPY, "LDX"}, {O_ZPY, "LAX"},
	{O_IMM, "CLV"}, {O_ABY, "LDA"}, {O_IMP, "TSX"}, {O_ABY, "LAS"}, {O_ABX, "LDY"}, {O_ABX, "LDA"}, {O_ABY, "LDX"}, {O_ABY, "LAX"},
	{O_IMM, "CPY"}, {O_IZX, "CMP"}, {O_IMM, "NOP"}, {O_IZX, "DCP"}, {O_ZP, "CPY"}, {O_ZP, "CMP"}, {O_ZP, "DEC"}, {O_ZP, "DCP"},
	{O_IMP, "INY"}, {O_IMM, "CMP"}, {O_IMP, "DEX"}, {O_IMM, "AXS"}, {O_ABS, "CPY"}, {O_ABS, "CMP"}, {O_ABS, "DEC"}, {O_ABS, "DCP"},
	{O_REL, "BNE"}, {O_IZY, "CMP"}, {O_IMP, "KIL"}, {O_IZY, "DCP"}, {O_ZPX, "NOP"}, {O_ZPX, "CMP"}, {O_ZPX, "DEC"}, {O_ZPX, "DCP"},
	{O_IMP, "CLD"}, {O_ABY, "CMP"}, {O_IMP, "NOP"}, {O_ABY, "DCP"}, {O_ABX, "NOP"}, {O_ABX, "CMP"}, {O_ABX, "DEC"}, {O_ABX, "DCP"},
	{O_IMM, "CPX"}, {O_IZX, "SBC"}, {O_IMM, "NOP"}, {O_IZX, "ISC"}, {O_ZP, "CPX"}, {O_ZP, "SBC"}, {O_ZP, "INC"}, {O_ZP, "ISC"},
	{O_IMP, "INX"}, {O_IMM, "SBC"}, {O_IMP, "NOP"}, {O_IMM, "SBC"}, {O_ABS, "CPX"}, {O_ABS, "SBC"}, {O_ABS, "INC"}, {O_ABS, "ISC"},
	{O_REL, "BEQ"}, {O_IZY, "SBC"}, {O_IMP, "KIL"}, {O_IZY, "ISC"}, {O_ZPX, "NOP"}, {O_ZPX, "SBC"}, {O_ZPX, "INC"}, {O_ZPX, "ISC"},
	{O_IMP, "SED"}, {O_ABY, "SBC"}, {O_IMP, "NOP"}, {O_ABY, "ISC"}, {O_ABX, "NOP"}, {O_ABX, "SBC"}, {O_ABX, "INC"}, {O_ABX, "ISC"},
};

const unsigned opl[O_REL + 1] = {
	1, 1, 2, 2, 2, 2, 2, 2,
	3, 3, 3, 3, 2,
};
