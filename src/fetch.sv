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

    im_dout_i,

    im_addr_o,

    inst_o
);

  input logic rst_n_i, clk_i;
  input logic [31:0] im_dout_i;

  output logic [31:0] im_addr_o;
  output logic [31:0] inst_o;

  assign im_addr_o = '0;

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      inst_o <= '0;
    end else begin
      inst_o <= im_dout_i;
      // inst_o <= 'd22;
    end
  end

endmodule