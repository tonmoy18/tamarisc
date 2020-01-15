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

module datapath(
    rst_n_i,
    clk_i,

    reg1_data_i,
    reg2_data_i,

    alu_mux_sel_i,
    x_op1_mux_sel_i,
    x_op2_mux_sel_i,
    x_arith_op1_mux_sel_i,
    x_arith_op2_mux_sel_i,
    w_mux_sel_i,

    arith_out_i,
    logical_out_i,
    shift_out_i,
    csr_val_i,

    imm_signed_i,

    pc_val_d1_i,
    pc_val_d2_i,

    w_load_funct3_i,
    m_dm_dout_i,
    
    x_op1_o,
    x_op2_o,
    x_arith_op1_o,
    x_arith_op2_o,

    m_alu_data_o,
    w_mux_o
);
  import proc_pkg::*;
  // Input/Output Definitions
  input logic rst_n_i, clk_i;

  input logic [31:0] reg1_data_i;
  input logic [31:0] reg2_data_i;

  input logic [31:0] arith_out_i;
  input logic [31:0] logical_out_i;
  input logic [31:0] shift_out_i;
  input logic [31:0] csr_val_i;

  input logic [31:0] pc_val_d1_i;
  input logic [31:0] pc_val_d2_i;

  input logic [2:0] w_load_funct3_i;
  input logic [31:0] m_dm_dout_i;

  input logic [31:0] imm_signed_i;

  input alu_mux_sel_t alu_mux_sel_i;
  input x_op1_mux_sel_t x_op1_mux_sel_i;
  input x_op2_mux_sel_t x_op2_mux_sel_i;
  input x_op1_mux_sel_t x_arith_op1_mux_sel_i;
  input x_op2_mux_sel_t x_arith_op2_mux_sel_i;
  input w_mux_sel_t w_mux_sel_i;

  output logic [31:0] x_op1_o;
  output logic [31:0] x_op2_o;
  output logic [31:0] x_arith_op1_o;
  output logic [31:0] x_arith_op2_o;
  output logic [31:0] m_alu_data_o;
  output logic [31:0] w_mux_o;

  // Local signals
  logic [31:0] x_op1_next, x_op1_q;
  logic [31:0] x_op2_next, x_op2_q;
  logic [31:0] x_arith_op1_next, x_arith_op1_q;
  logic [31:0] x_arith_op2_next, x_arith_op2_q;
  logic [31:0] m_alu_data_q, m_alu_data_next;
  logic [31:0] w_mux_q, w_mux_next;
  logic load_signed;
  logic load_sign_bit;

  assign m_alu_data_o = m_alu_data_q;
  assign x_op1_o = x_op1_q;
  assign x_op2_o = x_op2_q;
  assign x_arith_op1_o = x_arith_op1_q;
  assign x_arith_op2_o = x_arith_op2_q;
  assign w_mux_o = w_mux_q;

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      m_alu_data_q <= '0;
      x_op1_q <= '0;
      x_op2_q <= '0;
      x_arith_op1_q <= '0;
      x_arith_op2_q <= '0;
      w_mux_q <= '0;
  end else begin
      m_alu_data_q <= m_alu_data_next;
      x_op1_q <= x_op1_next;
      x_op2_q <= x_op2_next;
      x_arith_op1_q <= x_arith_op1_next;
      x_arith_op2_q <= x_arith_op2_next;
      w_mux_q <= w_mux_next;
    end
  end

  always_comb begin
    case (alu_mux_sel_i) // synopsys infer_mux
      ARITH:
        m_alu_data_next = arith_out_i;
      LOGIC:
        m_alu_data_next = logical_out_i;
      SHIFT:
        m_alu_data_next = shift_out_i;
      X_OP1:
        m_alu_data_next = x_op1_q;
      ALU_PC_VAL_D2:
        m_alu_data_next = pc_val_d2_i;
      ALU_PC_VAL_PLUS_4_D2:
        m_alu_data_next = pc_val_d2_i + 32'h00000004;
    endcase
  end

  always_comb begin
    case (x_op1_mux_sel_i) // synopsys infer_mux
      REG1_DATA:
        x_op1_next = reg1_data_i;
      PC_VAL_D1:
        x_op1_next = pc_val_d1_i;
    endcase
  end

  always_comb begin
    case (x_op2_mux_sel_i) // synopsys infer_mux
      REG2_DATA:
        x_op2_next = reg2_data_i;
      IMM_SIGNED:
        x_op2_next = imm_signed_i;
    endcase
  end

  always_comb begin
    case (x_arith_op1_mux_sel_i) // synopsys infer_mux
      REG1_DATA:
        x_arith_op1_next = reg1_data_i;
      PC_VAL_D1:
        x_arith_op1_next = pc_val_d1_i;
    endcase
  end

  always_comb begin
    case (x_arith_op2_mux_sel_i) // synopsys infer_mux
      REG2_DATA:
        x_arith_op2_next = reg2_data_i;
      IMM_SIGNED:
        x_arith_op2_next = imm_signed_i;
    endcase
  end

  always_comb begin
    case (w_mux_sel_i) // synopsys infer_mux
      ALU:
        w_mux_next = m_alu_data_q;
      DM: begin
        load_signed = 1'b0;
        case(w_load_funct3_i)
        `LOAD_B, `LOAD_H, `LOAD_W:
          load_signed = 1'b1;
        `LOAD_BU, `LOAD_HU:
          load_signed = 1'b0;
        endcase

        case (w_load_funct3_i)
        `LOAD_B, `LOAD_BU: begin
          load_sign_bit = 1'b0;
          case (m_alu_data_q[1:0]) 
          2'b00: begin
            if (load_signed) load_sign_bit = m_dm_dout_i[7];
            w_mux_next = {{ 24{load_sign_bit}}, m_dm_dout_i[7:0]};
          end
          2'b01: begin
            if (load_signed) load_sign_bit = m_dm_dout_i[15];
            w_mux_next = {{ 24{load_sign_bit}}, m_dm_dout_i[15:8]};
          end
          2'b10: begin
            if (load_signed) load_sign_bit = m_dm_dout_i[23];
            w_mux_next = {{ 24{load_sign_bit}}, m_dm_dout_i[23:16]};
          end
          2'b11: begin
            if (load_signed) load_sign_bit = m_dm_dout_i[31];
            w_mux_next = {{ 24{load_sign_bit}}, m_dm_dout_i[31:24]};
          end
          endcase
        end
        `LOAD_H, `LOAD_HU: begin
          load_sign_bit = 1'b0;
          if (m_alu_data_q[1] == 1'b1) begin
            if (load_signed) load_sign_bit  = m_dm_dout_i[31];
            w_mux_next = {{ 16{load_sign_bit}}, m_dm_dout_i[31:16]};
          end else begin
            if (load_signed) load_sign_bit  = m_dm_dout_i[15];
            w_mux_next = {{ 16{load_sign_bit}}, m_dm_dout_i[15:0]};
          end
        end
        `LOAD_W:
          w_mux_next = m_dm_dout_i;
        endcase
      end
    endcase
  end

endmodule