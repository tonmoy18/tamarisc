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

  csr_exception_i,

  pc_load_arith_out_o,
  reg1_addr_o,
  reg2_addr_o,

  csr_r_en_o,
  csr_op_mode_o,
  csr_w_en_o,
  csr_addr_o,

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

  x_jump_o,

  x_dm_wen_o,

  w_funct3_o,

  reg_w_addr_o,

  imm_signed_o,

  incr_pc_o,
  
  conflict_o,
  x_arith_zero_lsb_o,
  x_excep_code_o,
  x_load_mcause_o,

  ret_o,
  exception_o
);

  import proc_pkg::*;
  // Input/Output Definitions
  input logic rst_n_i, clk_i;

  input logic [31:0] d_inst_i;
  input logic branch_taken_i;

  input logic csr_exception_i;

  output logic pc_load_arith_out_o;
  output logic [4:0] reg1_addr_o;
  output logic [4:0] reg2_addr_o;

  output logic csr_r_en_o;
  output logic [12:0] csr_addr_o;
  output csr_op_mode_t csr_op_mode_o;
  output logic csr_w_en_o;

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
  output logic x_jump_o;

  output logic x_dm_wen_o;

  output logic [2:0] w_funct3_o;

  output logic [4:0] reg_w_addr_o;
  output logic [31:0] imm_signed_o;
  output logic incr_pc_o;
  output logic conflict_o;
  output logic x_arith_zero_lsb_o;
  output logic [31:0] x_excep_code_o;
  output logic x_load_mcause_o;
  output logic ret_o;
  output logic exception_o;

  // Local signals
  logic csr_r_en_next;
  logic [12:0] csr_addr_next;
  csr_op_mode_t csr_op_mode_next;
  logic [2:0] x_funct3_q, x_funct3_next;
  logic [2:0] m_funct3_q;
  logic x_funct7_30_q, x_funct7_30_next;
  logic x_is_branch_op_next, x_is_branch_op_q;
  logic x_logical_en_next, x_logical_en_q;
  logic [4:0] reg1_addr, reg2_addr;
  logic [6:0] d_opcode;

  logic [6:0] x_opcode, next_x_opcode;
  logic [6:0] m_opcode, next_m_opcode;
  logic [6:0] w_opcode, next_w_opcode;

  logic [4:0] d_rd, x_rd, m_rd, w_rd;
  logic [4:0] next_x_rd, next_m_rd, next_w_rd;
  logic conflict;
  logic d_jump, x_jump, m_jump, next_x_jump, w_jump;
  logic x_exception, m_exception, w_exception;
  logic x_ret, m_ret, w_ret;
  logic [3:0] d_excep_code, x_excep_code, m_excep_code;
  logic x_load_mcause;
  logic jumping;
  logic jump_or_branch_conflict;

  // Assign outputs
  assign reg1_addr_o = (conflict == 1'b1) ? '0 : reg1_addr;
  assign reg2_addr_o = (conflict == 1'b1) ? '0 : reg2_addr;
  assign x_funct3_o = x_funct3_q;
  assign x_funct7_30_o = x_funct7_30_q ;
  assign x_is_branch_op_o = x_is_branch_op_q;
  assign x_logical_en_o = x_logical_en_q;
  assign x_jump_o = x_jump;
  assign incr_pc_o = ~conflict;
  assign conflict_o = conflict;
  assign pc_load_arith_out_o = branch_taken_i | x_jump;
  assign ecall_o = 1'b0;
  assign w_funct3_o = m_funct3_q;

  assign jumping = m_jump;

  assign d_opcode = d_inst_i[6:0];

  assign exception_o = m_exception | csr_exception_i;
  assign ret_o = m_ret;
  assign x_excep_code_o = x_excep_code;
  assign x_load_mcause_o = x_load_mcause;

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      csr_addr_o <= '0;
      csr_op_mode_o <= NONE;
      csr_r_en_o <= '0;
    end else begin
      csr_addr_o <= csr_addr_next;
      csr_op_mode_o <= csr_op_mode_next;
      csr_r_en_o <= csr_r_en_next;
    end
  end
  
  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      m_exception <= '0;
      w_exception <= '0;
      m_ret <= '0;
      w_ret <= '0;
    end else begin
      m_exception <= x_exception;
      w_exception <= m_exception;
      m_ret <= x_ret;
      w_ret <= m_ret; 
    end
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin      
      x_opcode <= '0;
      x_rd <= '0;
      x_jump <= '0;
      m_opcode <= '0;
      m_rd <= '0;
      m_jump <= '0;
      m_funct3_q <= '0;
      w_opcode <= '0;
      w_rd <= '0;
      w_jump <= '0;
    end else begin
      x_opcode <= next_x_opcode;
      x_rd <= next_x_rd;
      x_jump <= next_x_jump;
      m_opcode <= next_m_opcode;
      m_rd <= next_m_rd;
      m_jump <= x_jump;
      m_funct3_q <= (x_opcode == `LOAD_OPCODE) ? x_funct3_q : '0;
      w_opcode <= next_w_opcode;
      w_rd <= next_w_rd;
      w_jump <= m_jump;
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
    next_m_rd = x_rd;
    next_w_rd = m_rd;
    next_m_opcode = x_opcode;
    next_w_opcode = m_opcode;
    
    // Probably should keep in decode structure
    // if (conflict == 1'b0 && branch_taken_i == 1'b0 && x_jump == 1'b0 && jumping == 1'b0) begin
    if (conflict == 1'b0 && branch_taken_i == 1'b0 && x_jump == 1'b0 && jumping == 1'b0 && x_exception == 1'b0 && x_ret == 1'b0) begin
      next_x_rd = d_rd;
      next_x_opcode = d_opcode;
      next_x_jump = d_jump;
    end else begin
      next_x_rd = '0;
      next_x_opcode = '0;
      next_x_jump = '0;
    end
  end
  
  always_comb begin
    jump_or_branch_conflict = 1'b0;
    if (d_opcode == `BRANCH_OPCODE ||
        d_opcode == `JAL_OPCODE ||
        d_opcode == `JALR_OPCODE ||
        d_opcode == `SYSTEM_OPCODE ||
        m_exception == 1'b1 ||
        m_ret == 1'b1) begin
      if (x_opcode == `BRANCH_OPCODE && branch_taken_i) begin
        jump_or_branch_conflict = 1'b1;
      end
      case(`JAL_OPCODE)
        x_opcode, m_opcode, w_opcode:
          jump_or_branch_conflict = 1'b1;
      endcase
      case(`JALR_OPCODE)
        x_opcode, m_opcode, w_opcode:
          jump_or_branch_conflict = 1'b1;
      endcase
    end
    if (m_exception == 1'b1 || m_ret == 1'b1) begin
      case(`SYSTEM_OPCODE)
        x_opcode, m_opcode, w_opcode:
          jump_or_branch_conflict = 1'b1;
      endcase
    end
  end
  
  always_comb begin
    if (reg1_addr != '0 &&
        (reg1_addr == x_rd || reg1_addr == m_rd || reg1_addr == w_rd))
      conflict = 1'b1;
    else if (reg2_addr != '0 &&
             (reg2_addr == x_rd || reg2_addr == m_rd || reg2_addr == w_rd))
      conflict = 1'b1;
    else if (jump_or_branch_conflict == 1'b1)
      conflict = 1'b1;
    else
      conflict = 1'b0;
  end

  always_comb begin
    reg1_addr = '0;
    reg2_addr = '0;
    case (d_opcode)
      `RTYPE_OPCODE, `BRANCH_OPCODE, `STORE_OPCODE: begin
        reg1_addr = d_inst_i[19:15];
        reg2_addr = d_inst_i[24:20];
      end
      `LOAD_OPCODE, `ITYPE_ALU_OPCODE, `JALR_OPCODE, `LOAD_OPCODE:  begin
        reg1_addr = d_inst_i[19:15];
      end
      `SYSTEM_OPCODE: begin
        if (d_inst_i[14] == 1'b0) begin // non-immidiate
          reg1_addr = d_inst_i[19:15];
        end
      end
    endcase
  end

  always_comb begin
    d_rd = '0; 
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
    x_dm_wen_o = '0;
    csr_r_en_next = 1'b0;
    csr_addr_next = '0;
    csr_op_mode_next = NONE;
    x_exception = 1'b0;
    x_excep_code = '0;
    x_load_mcause = '0;
    x_ret = 1'b0;
    if (conflict == 1'b0) begin
      case (d_opcode)
        `SYSTEM_OPCODE: begin
          if (d_inst_i[14:12] !== 3'b000) begin
            csr_r_en_next = 1'b1;
            csr_addr_next = d_inst_i[31:20];
            if (d_inst_i[14:12] == 3'b001) csr_op_mode_next = READ_WRITE;
            else if (d_inst_i[14:12] == 3'b010) csr_op_mode_next = SET;
            else if (d_inst_i[14:12] == 3'b011) csr_op_mode_next = CLR;
            else csr_op_mode_next = NONE;
            d_rd = d_inst_i[11:7];
            if (d_inst_i[14] == 1'b0) begin // non-immediate
              x_op1_mux_sel_o = REG1_DATA;
            end else begin // immediate
              x_op1_mux_sel_o = IMM_SIGNED;
              imm_signed_o = {27'b0, d_inst_i[19:15]};
            end
          end else begin
            if (d_inst_i[31:20] == 12'h302) begin
              x_ret = 1'b1;
            end else begin
              x_exception = 1'b1;
              if (d_inst_i[31:20] == 12'h000) begin
                x_excep_code = 4'hB;    // ECALL from M-mode
                x_load_mcause = 1'b1;
              end else if (d_inst_i[31:20] == 12'h001) begin
                x_excep_code = 4'h3;    // Breakpoint
                x_load_mcause = 1'b1;
              end
            end
          end
        end
        `RTYPE_OPCODE: begin
          d_rd = d_inst_i[11:7];
          x_funct3_next = d_inst_i[14:12];
          x_funct7_30_next = d_inst_i[30];
          x_op1_mux_sel_o = REG1_DATA;
          x_op2_mux_sel_o = REG2_DATA;
          x_arith_op1_mux_sel_o = REG1_DATA;
          x_arith_op2_mux_sel_o = REG2_DATA;
          x_logical_en_next = 1'b1; // TODO: enable only for logical ops
        end
        `ITYPE_ALU_OPCODE, `LOAD_OPCODE: begin
          d_rd = d_inst_i[11:7];
          x_funct3_next = d_inst_i[14:12];
          if (d_opcode == `ITYPE_ALU_OPCODE) begin
            if (d_inst_i[14:12] == `FUNCT3_SRA ||
                d_inst_i[14:12] == `FUNCT3_SRL) begin
                x_funct7_30_next = d_inst_i[30];
            end
          end
          x_op1_mux_sel_o = REG1_DATA;
          x_op2_mux_sel_o = IMM_SIGNED;
          x_arith_op1_mux_sel_o = REG1_DATA;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { {20{d_inst_i[31]}}, d_inst_i[31:20]};
          x_logical_en_next = 1'b1; // TODO: enable only for logical ops
        end
        `STORE_OPCODE: begin
          x_funct3_next = d_inst_i[14:12];
          x_arith_op1_mux_sel_o = REG1_DATA;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { {20{d_inst_i[31]}}, d_inst_i[31:25], d_inst_i[11:7]};
          x_dm_wen_o = 1'b1;
        end
        `LUI_OPCODE: begin
          d_rd = d_inst_i[11:7];
          x_arith_op1_mux_sel_o = REG1_DATA;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { d_inst_i[31:12], 12'h000};
        end
        `AUIPC_OPCODE: begin
          d_rd = d_inst_i[11:7];
          x_arith_op1_mux_sel_o = PC_VAL_D1;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { d_inst_i[31:12], 12'h000};
        end
        `BRANCH_OPCODE: begin
          x_funct3_next = d_inst_i[14:12];
          x_is_branch_op_next = 1'b1;
          x_op1_mux_sel_o = REG1_DATA;
          x_op2_mux_sel_o = REG2_DATA;
          x_arith_op1_mux_sel_o = PC_VAL_D1;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { {20{d_inst_i[31]}}, d_inst_i[7], d_inst_i[30:25], d_inst_i[11:8], 1'b0};
          x_logical_en_next = 1'b1; // TODO: enable only for logical ops
        end
        `JAL_OPCODE: begin
          d_rd = d_inst_i[11:7];
          x_arith_op1_mux_sel_o = PC_VAL_D1;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { {12{d_inst_i[31]}}, d_inst_i[19:12], d_inst_i[20], d_inst_i[30:21], 1'b0 };
          d_jump = 1'b1;
        end
        `JALR_OPCODE: begin
          d_rd = d_inst_i[11:7];
          x_arith_zero_lsb_o = 1'b1;
          x_op1_mux_sel_o = REG1_DATA;
          x_op2_mux_sel_o = IMM_SIGNED;
          x_arith_op1_mux_sel_o = REG1_DATA;
          x_arith_op2_mux_sel_o = IMM_SIGNED;
          imm_signed_o = { {20{d_inst_i[31]}}, d_inst_i[31:20]};
          x_logical_en_next = 1'b1; // TODO: enable only for logical ops
          d_jump = 1'b1;
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
      `LOAD_OPCODE, `STORE_OPCODE: begin
        alu_mux_sel_o = ARITH;
      end
      `LUI_OPCODE, `AUIPC_OPCODE: begin
        alu_mux_sel_o = ARITH; // Just for datapath to check addr % 2 == 1
      end
      `BRANCH_OPCODE: begin
        alu_mux_sel_o = ARITH; // Doesn't matter, won't be used
      end
      `JAL_OPCODE, `JALR_OPCODE: begin
        alu_mux_sel_o = ALU_PC_VAL_PLUS_4_D2;
      end
    endcase
  end


  always_comb begin
    w_mux_sel_o = ALU;
    case (m_opcode)
      `RTYPE_OPCODE, `ITYPE_ALU_OPCODE, `LUI_OPCODE, `AUIPC_OPCODE, `JAL_OPCODE, `JALR_OPCODE: begin
        w_mux_sel_o = ALU;
      end
      `LOAD_OPCODE: begin
        w_mux_sel_o = DM;
      end
      `SYSTEM_OPCODE: begin
        w_mux_sel_o = CSR;
      end
    endcase
  end

  always_comb begin
    reg_w_addr_o = '0;
    case (w_opcode)
    `RTYPE_OPCODE, `ITYPE_ALU_OPCODE, `LUI_OPCODE, `AUIPC_OPCODE, `JAL_OPCODE, `JALR_OPCODE, `LOAD_OPCODE, `SYSTEM_OPCODE: begin
      reg_w_addr_o = w_rd;
    end
    endcase
  end

endmodule
