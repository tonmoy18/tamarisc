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

module top(rst_n, clk, ecall, debug_port);

  input logic rst_n, clk;
  output logic ecall;
  output logic [31:0] debug_port; // Temporary, need better intf

  logic [31:0] dm_dout;
  logic dm_wen;
  logic [31:0] dm_din;
  logic [31:0] dm_addr;

  logic [31:0] im_dout;
  logic [31:0] im_addr;

  core u_core(
    .clk_i      (clk),
    .rst_n_i    (rst_n),
    
    .dm_dout_i      (dm_dout),
    .dm_wen_o       (dm_wen),
    .dm_din_o       (dm_din),
    .dm_addr_o      (dm_addr),

    .im_dout_i      (im_dout),
    .im_addr_o      (im_addr),

    .debug_port_o   (debug_port),

    .ecall_o        (ecall)
  );

  dual_port_mem #(
    .HEXFILE_FROM_ARG(1),
    .TEXT_OFFSET(32'h80000000),
    .DATA_OFFSET(32'h80002000)
  ) u_mem (
    .rst_n_i      (rst_n),
    .clk_i        (clk),
    .wen1_i       (dm_wen),
    .addr1_i      (dm_addr),
    .data1_in_i   (dm_din),
    .data1_out_o  (dm_dout),
    .wen2_i       (1'b0),
    .addr2_i      (im_addr),
    .data2_in_i   (32'h0000),
    .data2_out_o  (im_dout)
  );

  // mem u_dm(
  //   .rst_n_i      (rst_n),
  //   .clk_i        (clk),
  //   .wen_i        (dm_wen),
  //   .addr_i       (dm_addr),
  //   .data_in_i    (dm_din),
  //   .data_out_o   (dm_dout)
  // );

  // mem # (
  //   .HEXFILE_FROM_ARG(1)
  //   )u_im(
  //   .rst_n_i      (rst_n),
  //   .clk_i        (clk),
  //   .wen_i        (1'b0),
  //   .addr_i       (im_addr),
  //   .data_in_i    (32'h0000),
  //   .data_out_o   (im_dout)
  // );



endmodule
