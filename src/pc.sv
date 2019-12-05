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
    pc_o
);
  // Input/Output Definitions
  input logic rst_n_i, clk_i;
  input logic incr_pc_i;

  output logic [31:0] pc_o;

  // Local signals
  logic [31:0] next_pc, pc_q;

  // Output assignments
  assign pc_o = pc_q;

  // Module main body

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      pc_q <= '0;
    end else begin
      pc_q <= next_pc;
    end
  end

  always_comb begin
    next_pc = pc_q;
    if (incr_pc_i) next_pc = pc_q + 'd4;
  end

endmodule
