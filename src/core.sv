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

module core(
    rst_n_i,
    clk_i,
    
    dm_dout_i,
    dm_wen_o,
    dm_din_o,
    dm_addr_o,
    
    im_dout_i,
    im_addr_o,

    debug_port_o
);

  import proc_pkg::*;

  input logic rst_n_i;
  input logic clk_i;

  input logic [31:0] dm_dout_i;
  output logic [31:0] dm_wen_o;
  output logic [31:0] dm_din_o;
  output logic [31:0] dm_addr_o;

  input logic [31:0] im_dout_i;
  output logic [31:0] im_addr_o;

  output logic [31:0] debug_port_o;

  logic [`DATA_WIDTH-1:0] reg_din;
  logic [`DATA_WIDTH-1:0] reg_d1out;
  logic [`DATA_WIDTH-1:0] reg_d2out;

  logic [31:0] d_inst, x_inst, m_inst;

  logic [31:0] x_op1;
  logic [31:0] x_op2;
  logic [3:0] x_funct3;
  logic x_funct7_30;
  logic x_is_branch_op;
  logic [31:0] arith_out;
  logic [31:0] logical_out;
  logic [31:0] shift_out;
  logic [31:0] imm_signed;

  logic [31:0] m_alu_data;
  logic [31:0] w_mux;

  logic [4:0] reg_w_addr;
  logic [4:0] reg1_addr;
  logic [4:0] reg2_addr;

  logic [31:0] pc_val;
  logic [31:0] pc_val_d2;
  logic incr_pc;
  logic stall;
  logic branch_taken;

  alu_mux_sel_t alu_mux_sel;
  x_op1_mux_sel_t x_op1_mux_sel;
  x_op2_mux_sel_t x_op2_mux_sel;
  w_mux_sel_t w_mux_sel;

  // Main body of module
  assign debug_port_o = m_alu_data;
  assign reg_din = w_mux;

  pc u_pc (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),

    .incr_pc_i      (incr_pc),
    .branch_taken_i (branch_taken),
    .logical_out_i  (logical_out),
     
    .pc_o           (pc_val),

    .pc_d2_o        (pc_val_d2)
  );

  fetch u_fetch (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),
    
    .pc_i           (pc_val),
    .im_dout_i      (im_dout_i),

    .im_addr_o      (im_addr_o),

    .inst_o         (d_inst)
  );

  regfile u_regfile (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),

    .w_addr_i       (reg_w_addr),
    .din_i          (reg_din),
    
    .r1_addr_i      (reg1_addr),
    .d1out_o        (reg_d1out),

    .r2_addr_i      (reg2_addr),
    .d2out_o        (reg_d2out)
  );

  control u_control (
    .rst_n_i          (rst_n_i),
    .clk_i            (clk_i),
    
    .d_inst_i         (d_inst),

    .branch_taken_i   (branch_taken),

    .reg1_addr_o      (reg1_addr),
    .reg2_addr_o      (reg2_addr),

    .alu_mux_sel_o    (alu_mux_sel),
    .x_op1_mux_sel_o  (x_op1_mux_sel),
    .x_op2_mux_sel_o  (x_op2_mux_sel),

    .x_funct3_o       (x_funct3),
    .x_funct7_30_o    (x_funct7_30),
    .x_is_branch_op_o (x_is_branch_op),
    .reg_w_addr_o     (reg_w_addr),

    .imm_signed_o     (imm_signed),

    .incr_pc_o        (incr_pc),
      
    .stall_o          (stall)
  );

  datapath u_datapath (
    .rst_n_i          (rst_n_i),
    .clk_i            (clk_i),

    .alu_mux_sel_i    (alu_mux_sel),
    .x_op1_mux_sel_i  (x_op1_mux_sel),
    .x_op2_mux_sel_i  (x_op2_mux_sel),
    .w_mux_sel_i      (w_mux_sel),

    .reg1_data_i      (reg_d1out),
    .reg2_data_i      (reg_d2out),

    .arith_out_i      (arith_out),
    .logical_out_i    (logical_out),
    .shift_out_i      (shift_out),

    .imm_signed_i     (imm_signed),

    .pc_val_d2_i      (pc_val_d2),
    
    .x_op1_o          (x_op1),
    .x_op2_o          (x_op2),

    .m_alu_data_o     (m_alu_data),

    .w_mux_o          (w_mux)
  );

  arith u_arith (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),

    .funct_i        (x_funct7_30),

    .op1_i          (x_op1),
    .op2_i          (x_op2),

    .res_o          (arith_out)
  );

  logical u_logical (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),

    .funct_i        (x_funct3),
    .is_branch_op_i (x_is_branch_op),

    .op1_i          (x_op1),
    .op2_i          (x_op2),

    .res_o          (logical_out),
    .branch_taken_o (branch_taken)
  );

  shift u_shift (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),

    .funct3_i       (shift_funct),
    .funct7_i       (x_funct7_30),

    .op1_i          (x_op1),
    .op2_i          (x_op2),

    .res_o          (shift_out)
  );

endmodule
