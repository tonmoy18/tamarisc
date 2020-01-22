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
    dm_busy_i,
    
    im_dout_i,
    im_addr_o,
    im_busy_i,

    debug_port_o,
    ecall_o
);

  import proc_pkg::*;

  input logic rst_n_i;
  input logic clk_i;

  input logic [31:0] dm_dout_i;
  output logic dm_wen_o;
  output logic [31:0] dm_din_o;
  output logic [31:0] dm_addr_o;
  input logic dm_busy_i;

  input logic [31:0] im_dout_i;
  output logic [31:0] im_addr_o;
  input logic im_busy_i;

  output logic [31:0] debug_port_o;
  output logic ecall_o;

  logic [`DATA_WIDTH-1:0] reg_din;
  logic [`DATA_WIDTH-1:0] reg_d1out;
  logic [`DATA_WIDTH-1:0] reg_d2out;

  logic [31:0] d_inst, x_inst, m_inst;

  logic [31:0] x_op1;
  logic [31:0] x_op2;
  logic [31:0] x_arith_op1;
  logic [31:0] x_arith_op2;
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
  logic [31:0] pc_val_d1;
  logic [31:0] pc_val_d2;
  logic incr_pc;
  logic pc_load_arith_out;
  logic conflict;
  logic stall;
  logic branch_taken;

  logic x_logical_en;
  logic x_jump;
  alu_mux_sel_t alu_mux_sel;
  x_op1_mux_sel_t x_op1_mux_sel;
  x_op2_mux_sel_t x_op2_mux_sel;
  x_op1_mux_sel_t x_arith_op1_mux_sel;
  x_op2_mux_sel_t x_arith_op2_mux_sel;
  w_mux_sel_t w_mux_sel;
  csr_op_mode_t csr_op_mode;
  logic [12:0] csr_addr;

  logic [31:0] mtvec;
  logic [31:0] mepc;

  logic x_load_mcause;
  logic [31:0] x_excep_code;

  logic [31:0] csr_val;

  logic x_dm_wen;
  logic [31:0] x_dm_addr;
  logic [31:0] x_dm_din;
  logic [31:0] m_dm_dout;
  logic [3:0] w_funct3;

  logic exception, ret;

  // Main body of module
  assign reg_din = w_mux;

  pc u_pc (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),

    .stall_i        (im_busy_i),
    .conflict_i     (conflict),
    .incr_pc_i      (incr_pc),
    .exception_i    (exception),
    .ret_i          (ret),
    .load_arith_i   (pc_load_arith_out),
    .arith_out_i    (arith_out),
    .mtvec_i        (mtvec),
    .mepc_i         (mepc),
     
    .pc_o           (pc_val),

    .pc_d1_o        (pc_val_d1),
    .pc_d2_o        (pc_val_d2)
  );

  fetch u_fetch (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),
    
    .pc_i           (pc_val),
    .conflict_i     (conflict),
    .branch_taken_i (branch_taken),
    .x_jump_i       (x_jump),

    .im_busy_i      (im_busy_i),
    .im_dout_i      (im_dout_i),

    .im_addr_o      (im_addr_o),

    .inst_o         (d_inst),

    .stall_o        (stall)
  );

  regfile u_regfile (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),

    .w_addr_i       (reg_w_addr),
    .din_i          (reg_din),
    
    .r1_addr_i      (reg1_addr),
    .d1out_o        (reg_d1out),

    .r2_addr_i      (reg2_addr),
    .d2out_o        (reg_d2out),

    .debug_port_o   (debug_port_o)
  );

  control u_control (
    .rst_n_i                (rst_n_i),
    .clk_i                  (clk_i),
    
    .d_inst_i               (d_inst),

    .branch_taken_i         (branch_taken),

    .csr_exception_i        (csr_exception),

    .csr_op_mode_o          (csr_op_mode),
    .csr_addr_o             (csr_addr),

    .pc_load_arith_out_o    (pc_load_arith_out),
    .reg1_addr_o            (reg1_addr),
    .reg2_addr_o            (reg2_addr),

    .alu_mux_sel_o          (alu_mux_sel),
    .x_op1_mux_sel_o        (x_op1_mux_sel),
    .x_op2_mux_sel_o        (x_op2_mux_sel),
    .x_arith_op1_mux_sel_o  (x_arith_op1_mux_sel),
    .x_arith_op2_mux_sel_o  (x_arith_op2_mux_sel),

    .w_mux_sel_o             (w_mux_sel),

    .x_funct3_o             (x_funct3),
    .x_funct7_30_o          (x_funct7_30),
    .x_is_branch_op_o       (x_is_branch_op),
    .reg_w_addr_o           (reg_w_addr),

    .x_logical_en_o         (x_logical_en),

    .x_jump_o               (x_jump),

    .x_dm_wen_o             (x_dm_wen),

    .w_funct3_o             (w_funct3),

    .imm_signed_o           (imm_signed),

    .incr_pc_o              (incr_pc),
      
    .conflict_o             (conflict),

    .x_excep_code_o         (x_excep_code),
    .x_load_mcause_o        (x_load_mcause),
    .ret_o                  (ret),
    .exception_o            (exception)
  );

  datapath u_datapath (
    .rst_n_i                (rst_n_i),
    .clk_i                  (clk_i),

    .alu_mux_sel_i          (alu_mux_sel),
    .x_op1_mux_sel_i        (x_op1_mux_sel),
    .x_op2_mux_sel_i        (x_op2_mux_sel),
    .x_arith_op1_mux_sel_i  (x_arith_op1_mux_sel),
    .x_arith_op2_mux_sel_i  (x_arith_op2_mux_sel),

    .m_dm_dout_i            (m_dm_dout),

    .w_mux_sel_i            (w_mux_sel),
    .w_load_funct3_i        (w_funct3),

    .reg1_data_i            (reg_d1out),
    .reg2_data_i            (reg_d2out),

    .arith_out_i            (arith_out),
    .logical_out_i          (logical_out),
    .shift_out_i            (shift_out),
    .csr_val_i              (csr_val),

    .imm_signed_i           (imm_signed),

    .pc_val_d1_i            (pc_val_d1),
    .pc_val_d2_i            (pc_val_d2),

    
    .x_op1_o                (x_op1),
    .x_op2_o                (x_op2),
    .x_arith_op1_o          (x_arith_op1),
    .x_arith_op2_o          (x_arith_op2),

    .m_alu_data_o           (m_alu_data),

    .w_mux_o                (w_mux)
  );

  arith u_arith (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),

    .funct_i        (x_funct7_30),

    .op1_i          (x_arith_op1),
    .op2_i          (x_arith_op2),

    .res_o          (arith_out)
  );

  logical u_logical (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),

    .en_i           (x_logical_en),

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

    .funct3_i       (x_funct3),
    .funct7_i       (x_funct7_30),

    .op1_i          (x_op1),
    .op2_i          (x_op2),

    .res_o          (shift_out)
  );

  dcache u_dcache (
    .rst_n_i        (rst_n_i),
    .clk_i          (clk_i),

    .x_dm_wen_i     (x_dm_wen),
    .x_dm_addr_i    (arith_out),
    .x_dm_din_i     (reg_d2out),

    .m_dm_dout_o    (m_dm_dout),

    .dm_dout_i      (dm_dout_i),

    .dm_wen_o       (dm_wen_o),
    .dm_addr_o      (dm_addr_o),
    .dm_din_o       (dm_din_o)
  );

  csr u_csr(
    .rst_n_i            (rst_n_i),
    .clk_i              (clk_i),

    .csr_addr_i         (csr_addr),
    .mode_i             (csr_op_mode),
    .reg_val_i          (x_op1),

    .load_mcause_i      (x_load_mcause),
    .excep_code_i       (x_excep_code),

    .mtvec_o            (mtvec),
    .mepc_o             (mepc),

    .csr_val_o          (csr_val),
    .raise_exception_o  (csr_exception)
  );

endmodule
