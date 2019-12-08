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

module logical(
  rst_n_i,
  clk_i,

  funct_i,
  is_branch_op_i,

  op1_i,
  op2_i,

  res_o,
  branch_taken_o
);

  // Input/Output Definitions
  input logic rst_n_i;
  input logic clk_i;
  input logic [3:0] funct_i;
  input logic is_branch_op_i;
  input logic [31:0] op1_i;
  input logic [31:0] op2_i;
  output logic [31:0] res_o;
  output logic branch_taken_o;

  // Local signals
  logic [31:0] res;
  logic branch_taken;

  assign res_o = res;
  assign branch_taken_o = branch_taken;

  always_comb begin
    res = '0;
    if (is_branch_op_i == 1'b0) begin
      case (funct_i)
        `FUNCT3_SLT:
          res = $signed(op1_i) < $signed(op2_i);
        `FUNCT3_SLTU:
          res = op1_i < op2_i;
        `FUNCT3_XOR:
          res = op1_i ^ op2_i;
        `FUNCT3_OR:
          res = op1_i | op2_i;
        `FUNCT3_AND:
          res = op1_i & op2_i;
      endcase
    end else begin
      case (funct_i)
        `FUNCT3_EQ:
          branch_taken = (op1_i == op2_i);
        `FUNCT3_NE:
          branch_taken = (op1_i != op2_i);
        `FUNCT3_LT:
          branch_taken = ($signed(op1_i) < $signed(op2_i));
        `FUNCT3_GE:
          branch_taken = ($signed(op1_i) >= $signed(op2_i));
        `FUNCT3_LTU:
          branch_taken = (op1_i < op2_i);
        `FUNCT3_GEU:
          branch_taken = (op1_i >= op2_i);
      endcase
    end
  end

endmodule
