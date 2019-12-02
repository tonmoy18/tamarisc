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

module mem(
  rst_n_i,
  clk_i,
  wen_i,
  addr_i,
  data_in_i,
  data_out_o
);

  parameter int MEMSIZE = 4096;  // Has to be multiple of 4

  localparam int MEMSIZE_BY_4 = MEMSIZE / 4;

  input logic rst_n_i, clk_i;

  input logic wen_i;

  input logic [31:0] addr_i;
  input logic [31:0] data_in_i;

  output logic [31:0] data_out_o;

  logic [31:0] data[MEMSIZE_BY_4-1:0];  // MEMSIZE bytes

  always_ff @ (posedge clk_i) begin
    if (rst_n_i == 1'b0) begin
      data_out_o <= 32'h0000;
    end else begin
      if (wen_i == 1'b0) begin
        data_out_o <= data[addr_i];
      end else begin
        data_out_o <= 32'h0000;
        data[addr_i] <= data_in_i;
      end
    end
  end

  initial begin
    data[0] = 'h2081B3;
    data[1] = 'd7;
    data[2] = 'd9;
    data[3] = 'd11;
    data[4] = 'd13;
    data[5] = 'd15;
  end

endmodule
