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

module arith(
    rst_n_i,
    clk_i,

    funct_i,

    op1_i,
    op2_i,

    res_o
);

  // Input/Output Definitions
  input logic rst_n_i;
  input logic clk_i;
  input logic [2:0] funct_i;
  input logic [31:0] op1_i;
  input logic [31:0] op2_i;
  output logic [31:0] res_o;

  // Local signals
  logic [31:0] res;

  assign res_o = res;

  always_comb begin
    if (funct_i == 1'0) begin
      res = op1_i + op2_i;
    end else begin
      res = op1_i - op2_i;
    end
  end

endmodule