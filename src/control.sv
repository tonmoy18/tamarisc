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

module control(
  rst_n_i,
  clk_i,

  d_inst_i,
  branch_taken_i,

  pc_load_arith_out_o,
  reg1_addr_o,
  reg2_addr_o,

  alu_mux_sel_o,
  x_op1_mux_sel_o,
  x_op2_mux_sel_o,
  x_arith_op1_mux_sel_o,
  x_arith_op2_mux_sel_o,

  w_mux_sel_o,

  x_funct3_o,
  x_funct7_30_o,
  x_is_branch_op_o,
  x_logical_en_o,

  reg_w_addr_o,


  imm_signed_o,

  incr_pc_o,
  
  stall_o,
  x_arith_zero_lsb_o
);

  import proc_pkg::*;
  // Input/Output Definitions
  input logic rst_n_i, clk_i;

  input logic [31:0] d_inst_i;
  input logic branch_taken_i;

  output logic pc_load_arith_out_o;
  output logic [4:0] reg1_addr_o;
  output logic [4:0] reg2_addr_o;

  output alu_mux_sel_t alu_mux_sel_o;
  output x_op1_mux_sel_t x_op1_mux_sel_o;
  output x_op2_mux_sel_t x_op2_mux_sel_o;
  output x_op1_mux_sel_t x_arith_op1_mux_sel_o;
  output x_op2_mux_sel_t x_arith_op2_mux_sel_o;
  output w_mux_sel_t w_mux_sel_o;

  output logic [2:0] x_funct3_o;
  output logic x_funct7_30_o;
  output logic x_is_branch_op_o;
  output logic x_logical_en_o;

  output logic [4:0] reg_w_addr_o;
  output logic [31:0] imm_signed_o;
  output logic incr_pc_o;
  output logic stall_o;
  output logic x_arith_zero_lsb_o;

  // Local signals
  logic [2:0] x_funct3_q, x_funct3_next;
  logic x_funct7_30_q, x_funct7_30_next;
  logic x_is_branch_op_next, x_is_branch_op_q;
  logic x_logical_en_next, x_logical_en_q;
  logic [31:0] reg1_addr, reg2_addr;
  logic [6:0] d_opcode;

  logic [6:0] x_opcode, next_x_opcode;
  logic [6:0] m_opcode, next_m_opcode;
  logic [6:0] w_opcode, next_w_opcode;

  logic [4:0] d_rd, x_rd, m_rd, w_rd;
  logic [4:0] next_x_rd, next_m_rd, next_w_rd;
  logic conflict;
  logic d_jump, x_jump, m_jump;

  // Assign outputs
  assign reg1_addr_o = (conflict == 1'b1) ? '0 : reg1_addr;
  assign reg2_addr_o = (conflict == 1'b1) ? '0 : reg2_addr;
  assign x_funct3_o = x_funct3_q;
  assign x_funct7_30_o = x_funct7_30_q ;
  assign x_is_branch_op_o = x_is_branch_op_q;
  assign x_logical_en_o = x_logical_en_q;
  assign incr_pc_o = ~stall;
  assign stall_o = stall;
  assign pc_load_arith_out_o = branch_taken_i | m_jump;

  assign d_opcode = d_inst_i[6:0];
  assign d_rd = d_inst_i[11:7];

  always_comb begin
    next_m_rd = x_rd;
    next_w_rd = m_rd;
    next_m_opcode = x_opcode;
    next_w_opcode = m_opcode;
    
    if (stall == 1'b0 && branch_taken_i == 1'b0) begin
      next_x_rd = d_rd;
      next_x_opcode = d_opcode;
    end else begin
      next_x_rd = '0;
      next_x_opcode = '0;
    end
  end
  
  assign stall = conflict; // TODO: need other logic for stall

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin      
      x_opcode <= '0;
      x_rd <= '0;
      x_jump <= '0;
      m_opcode <= '0;
      m_rd <= '0;
      m_jump <= '0;
      w_opcode <= '0;
      w_rd <= '0;
    end else begin
      x_opcode <= next_x_opcode;
      x_rd <= next_x_rd;
      x_jump <= d_jump;
      m_opcode <= next_m_opcode;
      m_rd <= next_m_rd;
      m_jump <= x_jump;
      w_opcode <= next_w_opcode;
      w_rd <= next_w_rd;
    end
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      x_funct3_q <= '0;
      x_funct7_30_q <= '0;
      x_is_branch_op_q <= '0;
      x_logical_en_q <= '0;
    end else begin
      x_funct3_q <= x_funct3_next;
      x_funct7_30_q <= x_funct7_30_next;
      x_is_branch_op_q <= x_is_branch_op_next;
      x_logical_en_q <= x_logical_en_next;
    end
  end
  
  always_comb begin
    if (reg1_addr != '0 &&
        (reg1_addr == x_rd || reg1_addr == m_rd || reg1_addr == w_rd))
      conflict = 1'b1;
    else if (reg2_addr != '0 &&
             (reg2_addr == x_rd || reg2_addr == m_rd || reg2_addr == w_rd))
      conflict = 1'b1;
    else
      conflict = 1'b0;
  end

  always_comb begin
    reg1_addr = '0;
    reg2_addr = '0;
    case (d_opcode)
      `RTYPE_OPCODE, `ITYPE_ALU_OPCODE, `BRANCH_OPCODE: begin
        reg1_addr = d_inst_i[19:15];
        reg2_addr = d_inst_i[24:20];
      end
      `AUIPC_OPCODE: begin
        reg1_addr = d_inst_i[19:15];
      end
    endcase
  end

  always_comb begin
    x_funct3_next = '0;
    x_funct7_30_next = 1'b0;
    x_is_branch_op_next = 1'b0;
    x_logical_en_next = 1'b0;
    x_op1_mux_sel_o = REG1_DATA;
    x_op2_mux_sel_o = REG2_DATA;
    x_arith_op1_mux_sel_o = REG1_DATA;
    x_arith_op2_mux_sel_o = REG2_DATA;
    imm_signed_o = '0;
    d_jump = '0;
    x_arith_zero_lsb_o = '0;
    if (conflict == 1'b0) begin
      case (d_opcode)
        `RTYPE_OPCODE: begin
          x_funct3_next = d_inst_i[14:12];
          x_funct7_30_next = d_inst_i[30];
          x_op1_mux_sel_o = REG1_DATA;
          x_op2_mux_sel_o = REG2_DATA;
          x_arith_op1_mux_sel_o = REG1_DATA;
          x_arith_op2_mux_sel_o = REG2_DATA;
          x_logical_en_next = 1'b1; // TODO: enable only for logical ops
        end
        `ITYPE_ALU_OPCODE: begin
          x_funct3_next = d_inst_i[14:12];
          if (d_inst_i[14:12] == `FUNCT3_SRA ||
              d_inst_i[14:12] == `FUNCT3_SRL) begin
              x_funct7_30_next = d_inst_i[30];
          end
          x_op1_mux_sel_o = REG1_DATA;
          x_op2_mux_sel_o = IMM_SIGNED;
          x_arith_op1_mux_sel_o = REG1_DATA;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { {20{d_inst_i[31]}}, d_inst_i[31:20]};
          x_logical_en_next = 1'b1; // TODO: enable only for logical ops
        end
        `LUI_OPCODE: begin
          x_funct3_next = d_inst_i[14:12];
          x_arith_op1_mux_sel_o = REG1_DATA;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { d_inst_i[31:12], 12'h000};
        end
        `AUIPC_OPCODE: begin
          x_funct3_next = d_inst_i[14:12];
          x_arith_op1_mux_sel_o = PC_VAL_D2;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { d_inst_i[31:12], 12'h000};
        end
        `BRANCH_OPCODE: begin
          x_is_branch_op_next = 1'b1;
          x_op1_mux_sel_o = REG1_DATA;
          x_op2_mux_sel_o = REG2_DATA;
          x_arith_op1_mux_sel_o = PC_VAL_D2;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { {20{d_inst_i[31]}}, d_inst_i[7], d_inst_i[30:25], d_inst_i[11:8], 1'b0};
          x_logical_en_next = 1'b1; // TODO: enable only for logical ops
        end
        `JAL_OPCODE: begin
          x_arith_op1_mux_sel_o = PC_VAL_D2;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { {12{d_inst_i[31]}}, d_inst_i[31], d_inst_i[19:12], d_inst_i[20], d_inst_i[30:21]};
        end
        `JALR_OPCODE: begin
          x_arith_zero_lsb_o = 1'b1;
          x_op1_mux_sel_o = REG1_DATA;
          x_op2_mux_sel_o = IMM_SIGNED;
          x_arith_op1_mux_sel_o = REG1_DATA;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { {20{d_inst_i[31]}}, d_inst_i[31:20]};
          x_logical_en_next = 1'b1; // TODO: enable only for logical ops
        end
      endcase
    end
  end

  always_comb begin
    alu_mux_sel_o = ARITH;
    case (x_opcode)
      `RTYPE_OPCODE, `ITYPE_ALU_OPCODE: begin
        case (x_funct3_o)
          `FUNCT3_ADD, `FUNCT3_SUB:
            alu_mux_sel_o = ARITH;
          `FUNCT3_SLL, `FUNCT3_SRL, `FUNCT3_SRA:
            alu_mux_sel_o = SHIFT;
          `FUNCT3_SLT, `FUNCT3_SLTU, `FUNCT3_XOR,
          `FUNCT3_OR, `FUNCT3_AND:
            alu_mux_sel_o = LOGIC;
        endcase
      end
      `LUI_OPCODE, `AUIPC_OPCODE: begin
        alu_mux_sel_o = ARITH;
      end
      `BRANCH_OPCODE, `JAL_OPCODE: begin
        alu_mux_sel_o = ARITH; // Doesn't matter, won't be used
      end
      `JALR_OPCODE: begin
        alu_mux_sel_o = ALU_PC_VAL_D2;
      end
    endcase
  end


  always_comb begin
    w_mux_sel_o = ALU;
    case (m_opcode)
      `RTYPE_OPCODE, `ITYPE_ALU_OPCODE, `LUI_OPCODE, `AUIPC_OPCODE, `JALR_OPCODE: begin
        w_mux_sel_o = ALU;
      end
    endcase
  end

  always_comb begin
    reg_w_addr_o = '0;
    case (w_opcode)
    `RTYPE_OPCODE, `ITYPE_ALU_OPCODE, `LUI_OPCODE, `AUIPC_OPCODE, `JALR_OPCODE: begin
      reg_w_addr_o = w_rd;
    end
    endcase
  end

endmodule
