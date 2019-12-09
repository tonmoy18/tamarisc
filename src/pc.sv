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

    stall_i,
    incr_pc_i,
    load_arith_i,
    arith_out_i,

    pc_o,

    pc_d2_o
);
  // Input/Output Definitions
  input logic rst_n_i, clk_i;
  input logic stall_i;
  input logic incr_pc_i;
  input logic load_arith_i;
  input logic [31:0] arith_out_i;

  output logic [31:0] pc_o;
  output logic [31:0] pc_d2_o;

  // Local signals
  logic [31:0] next_pc, pc_q;
  logic [31:0] pc_d_q, pc_d2_q;
  logic [31:0] next_pc_d, next_pc_d2;

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
      pc_d_q <= next_pc_d;
      pc_d2_q <= next_pc_d2;
    end
  end

  always_comb begin
    if (stall_i == 1'b1) begin
      next_pc_d = pc_d2_q;
      next_pc_d2 = pc_d2_q;
    end else begin
      next_pc_d = pc_q;
      next_pc_d2 = pc_d_q;
    end
  end

  always_comb begin
    if (stall_i == 1'b1) next_pc = pc_q;
    else if (load_arith_i == 1'b1) next_pc = arith_out_i;
    else if (incr_pc_i == 1'b1) next_pc = pc_q + 'd4;
    else next_pc = pc_q;
  end

endmodule
