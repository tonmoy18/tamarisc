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

`include "proc_define.sv"


module regfile(
    rst_n_i,
    clk_i,

    w_addr_i,
    din_i,

    r1_addr_i,
    d1out_o,

    r2_addr_i,
    d2out_o
    
);

  input logic rst_n_i;
  input logic clk_i;

  input logic [4:0] w_addr_i;
  input logic [`DATA_WIDTH-1:0] din_i;

  input logic [4:0] r1_addr_i, r2_addr_i;
  output logic [`DATA_WIDTH-1:0] d1out_o, d2out_o;

  logic [`DATA_WIDTH-1:0] reg_content [31:1];

  always_comb begin
    if (r1_addr_i == '0) begin
      d1out_o = '0;
    end else begin
      d1out_o = reg_content[r1_addr_i];
    end

    if (r2_addr_i == '0) begin
      d2out_o = '0;
    end else begin
      d2out_o = reg_content[r2_addr_i];
    end
  end

  always_ff@(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      // for (integer i = 1; i < 32; i++) begin
      //   reg_content[i] = 0;
      // end
    end else begin
      if (w_addr_i != '0) begin
        reg_content[w_addr_i] <= din_i;
      end
    end
  end

  initial begin
    reg_content[1] = 'd7;
    reg_content[2] = 'd5;
    reg_content[3] = 'd0;
    reg_content[4] = 'd3;
    reg_content[5] = 'd9;
    reg_content[6] = 'd8;
  end

endmodule
