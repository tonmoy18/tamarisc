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


module pc(
    rst_n_i,
    clk_i,

    incr_pc_i,
    branch_taken_i,
    logical_out_i,

    pc_o,

    pc_d2_o
);
  // Input/Output Definitions
  input logic rst_n_i, clk_i;
  input logic incr_pc_i;
  input logic branch_taken_i;
  input logic [31:0] logical_out_i;

  output logic [31:0] pc_o;
  output logic [31:0] pc_d2_o;

  // Local signals
  logic [31:0] next_pc, pc_q;
  logic [31:0] pc_d_q, pc_d2_q;

  // Output assignments
  assign pc_o = pc_q;
  assign pc_d2_o = pc_d2_q;

  // Module main body

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      pc_q <= '0;
      pc_d_q <= '0;
      pc_d2_q <= '0;
    end else begin
      pc_q <= next_pc;
      pc_d_q <= pc_q;
      pc_d2_q <= pc_d_q;
    end
  end

  always_comb begin
    next_pc = pc_q;
    if (branch_taken_i) next_pc = logical_out_i;
    else if (incr_pc_i) next_pc = pc_q + 'd4;
  end

endmodule
