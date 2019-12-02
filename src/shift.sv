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

    funct_i,

    op1_i,
    op2_i,

    res_o
);

  // Input/Output Definitions
  input logic rst_n_i;
  input logic clk_i;
  input logic [3:0] funct_i;
  input logic [31:0] op1_i;
  input logic [31:0] op2_i;
  output logic [31:0] res_o;

  // Local signals
  logic [31:0] res;

  assign res_o = res;

  always_comb begin
    case (funct_i)
      // TODO
    endcase
  end

endmodule