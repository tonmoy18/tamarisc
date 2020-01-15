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

module dcache(
  rst_n_i,
  clk_i,

  x_dm_wen_i,
  x_dm_addr_i,
  x_dm_din_i,

  m_dm_dout_o,

  dm_dout_i,

  dm_wen_o,
  dm_addr_o,
  dm_din_o   
);


  input logic rst_n_i;
  input logic clk_i;

  input logic x_dm_wen_i;
  input logic [31:0] x_dm_addr_i;
  input logic [31:0] x_dm_din_i;

  input logic [31:0] dm_dout_i;

  output logic [31:0] m_dm_dout_o;

  output logic dm_wen_o;
  output logic [31:0] dm_addr_o;
  output logic [31:0] dm_din_o;

  assign dm_addr_o = x_dm_addr_i;

  always_ff @ (posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      dm_din_o <= '0;
      dm_wen_o <= '0;
    end else begin
      dm_din_o <= x_dm_din_i;
      dm_wen_o <= x_dm_wen_i;
    end
  end

  always_ff @ (posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      m_dm_dout_o <= '0;
    end else begin
      m_dm_dout_o <= dm_dout_i;
    end
  end

endmodule