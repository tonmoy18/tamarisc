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

  parameter string MEMFILE = "hex/zeros.hex";

  parameter int HEXFILE_FROM_ARG = 0;
  parameter int MEMSIZE = 4096;  // Has to be multiple of 4

  localparam int MEMSIZE_BY_4 = MEMSIZE / 4;

  string memfile = "hex/zeros.hex";

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
    if (HEXFILE_FROM_ARG) begin 
      if ($value$plusargs("hexfile=%s", memfile)) begin
        $display("INFO: loading %s", memfile);
        $readmemh(memfile, data);
      end else
        $display("ERROR opening hexfile");
    end else begin
      $readmemh(MEMFILE, data);
    end
  end

endmodule
