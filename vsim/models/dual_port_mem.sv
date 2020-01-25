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
  
  en1_i,
  wen1_i,
  addr1_i,
  data1_in_i,

  en2_i,
  wen2_i,
  addr2_i,
  data2_in_i,

  data1_busy_o,
  data2_busy_o,
  
  data2_out_o,
  data1_out_o
);

  parameter string MEMFILE = "hex/zeros.hex";
  parameter int TEXT_OFFSET = 'h0;
  parameter int DATA_OFFSET = 'h4000;

  parameter int HEXFILE_FROM_ARG = 0;
  parameter int MEMSIZE = 'h10000;  // Has to be multiple of 4

  localparam int MEMSIZE_BY_4 = MEMSIZE / 4;
  localparam int DELAY_MAX = 2;

  string memfile = "hex/zeros.hex";

  input logic rst_n_i, clk_i;

  input logic en1_i, en2_i, wen1_i, wen2_i;

  input logic [31:0] addr1_i, addr2_i;
  input logic [31:0] data1_in_i, data2_in_i;

  output logic [31:0] data1_out_o, data2_out_o;
  
  output logic data1_busy_o, data2_busy_o;

  logic [31:0] data[MEMSIZE_BY_4-1:0];  // MEMSIZE bytes
  logic [1:0] count1, count2;
  logic [1:0] count1_next, count2_next;
  logic [31:0] addr1_d, addr2_d;

  assign data1_out_o = (wen1_i == 1'b0 && en1_i == 1'b1 && data1_busy_o == 1'b0) ? data[(addr1_i - TEXT_OFFSET)/4] : '0;
  assign data2_out_o = (wen2_i == 1'b0 && en2_i == 1'b1 && data2_busy_o == 1'b0) ? data[(addr2_i - TEXT_OFFSET)/4] : '0;
  
  always_comb begin
    count1_next = 0;
    count2_next = 0;
    if (en1_i == 1'b1) begin
        if (addr1_i % 32 == 0) begin
          if (addr1_i != addr1_d) 
            count1_next = DELAY_MAX;
          else if (count1 > 0)
            count1_next <= count1 - 1;
        end
    end
    
    if (en2_i == 1'b1) begin
        if (addr2_i % 32 == 0) begin
          if (addr2_i != addr2_d) 
            count2_next = DELAY_MAX;
          else if (count2 > 0)
            count2_next <= count2 - 1;
        end
    end
  end
  
  always_ff @ (posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      count1 <= 0;
      count2 <= 0;
      addr1_d <= 0;
      addr2_d <= 0;
    end else begin
      addr1_d <= addr1_i;
      addr2_d <= addr2_i;
      count1 <= count1_next;
      count2 <= count2_next;
    end
  end
  
  assign data1_busy_o = (count1 != 0);
  assign data2_busy_o = (count2 != 0);
  
  // always_ff @ (posedge clk_i, negedge rst_n_i) begin
    // if (rst_n_i == 1'b0) begin
      // data1_busy_o <= 1'b0;
      // data2_busy_o <= 1'b0;
    // end else begin
      // data1_busy_o <= (count1 != 0);
      // data2_busy_o <= (count2 != 0);
    // end
  // end

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
