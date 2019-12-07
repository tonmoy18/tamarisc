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

  parameter string memfile = "hex/zeros.hex";

  parameter int MEMSIZE = 4096;  // Has to be multiple of 4

  localparam int MEMSIZE_BY_4 = MEMSIZE / 4;

  input logic rst_n_i, clk_i;

  input logic wen_i;

  input logic [31:0] addr_i;
  input logic [31:0] data_in_i;

  output logic [31:0] data_out_o;

  logic [31:0] data[MEMSIZE_BY_4-1:0];  // MEMSIZE bytes

  assign data_out_o = (wen_i == 1'b0) ? data[addr_i/4] : '0;

  always_ff @ (posedge clk_i) begin
    if (wen_i == 1'b1) begin
      data[addr_i/4] <= data_in_i;
    end
  end

  initial begin
    $readmemh(memfile, data);
  end

endmodule
