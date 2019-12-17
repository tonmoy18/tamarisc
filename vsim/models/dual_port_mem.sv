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

module dual_port_mem(
  rst_n_i,
  clk_i,
  wen1_i,
  addr1_i,
  data1_in_i,

  wen2_i,
  addr2_i,
  data2_in_i,

  data2_out_o,
  data1_out_o
);

  parameter string MEMFILE = "hex/zeros.hex";
  parameter int TEXT_OFFSET = 'h0;
  parameter int DATA_OFFSET = 'h4000;

  parameter int HEXFILE_FROM_ARG = 0;
  parameter int MEMSIZE = 'h10000;  // Has to be multiple of 4

  localparam int MEMSIZE_BY_4 = MEMSIZE / 4;

  string memfile = "hex/zeros.hex";

  input logic rst_n_i, clk_i;

  input logic wen1_i, wen2_i;

  input logic [31:0] addr1_i, addr2_i;
  input logic [31:0] data1_in_i, data2_in_i;

  output logic [31:0] data1_out_o, data2_out_o;

  logic [31:0] data[MEMSIZE_BY_4-1:0];  // MEMSIZE bytes

  assign data1_out_o = (wen1_i == 1'b0) ? data[(addr1_i - TEXT_OFFSET)/4] : '0;
  assign data2_out_o = (wen2_i == 1'b0) ? data[(addr2_i - TEXT_OFFSET)/4] : '0;

  always_ff @ (posedge clk_i) begin
    if (wen1_i == 1'b1) begin
      data[(addr1_i - TEXT_OFFSET)/4] <= data1_in_i;
    end
  end

  always_ff @ (posedge clk_i) begin
    if (wen2_i == 1'b1) begin
      data[(addr2_i - TEXT_OFFSET)/4] <= data2_in_i;
    end
  end

  initial begin
    if (HEXFILE_FROM_ARG) begin 
      if ($value$plusargs("text_hexfile=%s", memfile)) begin
        $display("INFO: loading %s", memfile);
        $readmemh(memfile, data);
      end else
        $display("ERROR opening hexfile");
      if ($value$plusargs("data_hexfile=%s", memfile)) begin
        $display("INFO: loading %s", memfile);
        $readmemh(memfile, data, (DATA_OFFSET - TEXT_OFFSET) / 4);
      end else
        $display("ERROR opening hexfile");

    end else begin
      $readmemh(MEMFILE, data);
    end
  end

endmodule
