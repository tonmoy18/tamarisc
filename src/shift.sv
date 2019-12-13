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


`include "proc_define.sv"

module shift(
  rst_n_i,
  clk_i,

  funct3_i,
  funct7_i,

  op1_i,
  op2_i,

  res_o
);

  // Input/Output Definitions
  input logic rst_n_i;
  input logic clk_i;
  input logic [3:0] funct3_i;
  input logic funct7_i;
  input logic [31:0] op1_i;
  input logic [31:0] op2_i;
  output logic [31:0] res_o;

  // Local signals
  logic [31:0] res;

  assign res_o = res;

  always_comb begin
    case (funct3_i)
      `FUNCT3_SLL:
        res = op1_i << op2_i[5:0];
      `FUNCT3_SRL, `FUNCT3_SRA:
        if (funct7_i) res = $signed(op1_i) >>> op2_i[5:0];
        else res = op1_i >> op2_i[5:0];
    endcase
  end

endmodule
