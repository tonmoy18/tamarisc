///////////////////////////////////////////////////////////
//
//
//
//
//
//
//
//
//
//
//
//
//
///////////////////////////////////////////////////////////


`define DATA_WIDTH 32

`define     LUI_OPCODE        7'b0110111
`define     AUIPC_OPCODE      7'b0110111
`define     RTYPE_OPCODE      7'b0110011
`define     ITYPE_ALU_OPCODE  7'b0010011
`define     BRANCH_OPCODE     7'b1100011

`define     FUNCT3_ADD  3'b000
`define     FUNCT3_SUB  3'b000
`define     FUNCT3_SLL  3'b001
`define     FUNCT3_SLT  3'b010
`define     FUNCT3_SLTU 3'b011
`define     FUNCT3_XOR  3'b100
`define     FUNCT3_SRL  3'b101
`define     FUNCT3_SRA  3'b101
`define     FUNCT3_OR   3'b110
`define     FUNCT3_AND  3'b111

`define     FUNCT3_EQ   3'b000
`define     FUNCT3_NE   3'b001
`define     FUNCT3_LT   3'b100
`define     FUNCT3_GE   3'b101
`define     FUNCT3_LTU  3'b110
`define     FUNCT3_GEU  3'b111
