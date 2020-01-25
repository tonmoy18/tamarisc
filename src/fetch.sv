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


module fetch(
    rst_n_i,
    clk_i,

    pc_i,
    conflict_i,
    branch_taken_i,
    jump_i,

    im_busy_i,
    im_dout_i,

    im_addr_o,

    inst_o,

    stall_o
);

  input logic rst_n_i, clk_i;

  input logic [31:0] pc_i;
  input logic conflict_i;
  input logic branch_taken_i;
  input logic im_busy_i;
  input logic [31:0] im_dout_i;
  input logic jump_i;

  output logic [31:0] im_addr_o;
  output logic [31:0] inst_o;

  output logic stall_o;

  logic [31:0] im_addr_d1;

  always_comb begin
    if (im_busy_i == 1'b1) begin
      im_addr_o = im_addr_d1;
    end else begin 
      im_addr_o = pc_i;
    end
  end
  
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      stall_o <= '0;
      im_addr_d1 <= '0;
    end else begin
      stall_o <= im_busy_i;
      im_addr_d1 <= im_addr_o;
    end
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      inst_o <= '0;
    end else if (branch_taken_i == 1'b1 || jump_i == 1'b1) begin
      inst_o <= '0;
    end else if (conflict_i == 1'b1) begin
      inst_o <= inst_o;
    end else if (im_busy_i == 1'b1) begin
      inst_o <= '0;
    // end else if (im_busy_i == 1'b1 && stall_o == 1'b0) begin
    //   inst_o <= inst_o;
    // end else if (im_busy_i == 1'b1 && stall_o == 1'b1) begin
    //   inst_o <= '0;
    end else begin
      inst_o <= im_dout_i;
    end
  end

endmodule
