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

`define     RTYPE_OPCODE      7'b0110011

`define     RTYPE_FUNCT3_ADD  3'b000
`define     RTYPE_FUNCT3_SUB  3'b000
`define     RTYPE_FUNCT3_SLL  3'b001
`define     RTYPE_FUNCT3_SLT  3'b010
`define     RTYPE_FUNCT3_SLTU 3'b011
`define     RTYPE_FUNCT3_XOR  3'b100
`define     RTYPE_FUNCT3_SRL  3'b101
`define     RTYPE_FUNCT3_SRA  3'b101
`define     RTYPE_FUNCT3_OR   3'b110
`define     RTYPE_FUNCT3_AND  3'b111

`define     ITYPE_ALU_OPCODE  7'b0010011

`define     ITYPE_FUNCT3_ADD  3'b000