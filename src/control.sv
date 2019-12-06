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

  reg1_addr_o,
  reg2_addr_o,

  alu_mux_sel_o,
  x_op1_mux_sel_o,
  x_op2_mux_sel_o,

  w_mux_sel_o,

  x_funct3_o,
  x_funct7_30_o,

  reg_w_addr_o,

  imm_signed_o,

  incr_pc_o,
  
  stall_o
);

  import proc_pkg::*;
  // Input/Output Definitions
  input logic rst_n_i, clk_i;

  input logic [31:0] d_inst_i;
  // input logic [6:0]  x_opcode_i;
  // input logic [6:0]  m_opcode_i;

  output logic [4:0] reg1_addr_o;
  output logic [4:0] reg2_addr_o;

  output alu_mux_sel_t alu_mux_sel_o;
  output x_op1_mux_sel_t x_op1_mux_sel_o;
  output x_op2_mux_sel_t x_op2_mux_sel_o;
  output w_mux_sel_t w_mux_sel_o;

  output logic [2:0] x_funct3_o;
  output logic x_funct7_30_o;

  output logic [4:0] reg_w_addr_o;
  output logic [31:0] imm_signed_o;
  output logic incr_pc_o;
  output logic stall_o;

  // Local signals
  logic [2:0] x_funct3_q, x_funct3_next;
  logic x_funct7_30_q, x_funct7_30_next;
  logic [31:0] reg1_addr, reg2_addr;
  logic [6:0] d_opcode;

  logic [6:0] x_opcode, next_x_opcode;
  logic [6:0] m_opcode, next_m_opcode;
  logic [6:0] w_opcode, next_w_opcode;

  logic [4:0] d_rd, x_rd, m_rd, w_rd;
  logic [4:0] next_x_rd, next_m_rd, next_w_rd;
  logic conflict;

  // Assign outputs
  assign reg1_addr_o = reg1_addr;
  assign reg2_addr_o = reg2_addr;
  assign x_funct3_o = x_funct3_q;
  assign x_funct7_30_o = x_funct7_30_q ;

  assign d_opcode = d_inst_i[6:0];
  assign d_rd = d_inst_i[11:7];

  always_comb begin
    next_m_rd = x_rd;
    next_w_rd = m_rd;
    next_m_opcode = x_opcode;
    next_w_opcode = m_opcode;
    
    if (stall == 1'b0) begin
      next_x_rd = d_rd;
      next_x_opcode = d_opcode;
    end else begin
      next_x_rd = '0;
      next_x_opcode = '0;
    end
  end
  
  assign incr_pc_o = ~stall;
  
  assign stall = conflict; // TODO: need other logic for stall

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin      
      x_opcode <= '0;
      x_rd <= '0;
      m_opcode <= '0;
      m_rd <= '0;
      w_opcode <= '0;
      w_rd <= '0;
    end else begin
      x_opcode <= next_x_opcode;
      x_rd <= next_x_rd;
      m_opcode <= next_m_opcode;
      m_rd <= next_m_rd;
      w_opcode <= next_w_opcode;
      w_rd <= next_w_rd;
    end
  end

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin
      x_funct3_q <= '0;
      x_funct7_30_q <= '0;
    end else begin
      x_funct3_q <= x_funct3_next;
      x_funct7_30_q <= x_funct7_30_next;
    end
  end
  
  always_comb begin
    if (reg1_addr != '0 &&
        (reg1_addr == x_rd || reg1_addr == m_rd))
      conflict = 1'b1;
    else if (reg2_addr != '0 &&
             (reg2_addr == x_rd || reg_addr2 == m_rd))
      conflict = 1'b1;
    else
      conflict = 1'b0;
  end

  always_comb begin
    x_funct3_next = '0;
    x_funct7_30_next = 1'b0;
    reg1_addr = '0;
    reg2_addr = '0;
    x_op1_mux_sel_o = REG1_DATA;
    x_op2_mux_sel_o = REG2_DATA;
    imm_signed_o = '0;
    case (d_opcode)
      `RTYPE_OPCODE: begin
        x_funct3_next = d_inst_i[14:12];
        x_funct7_30_next = d_inst_i[30];
        reg1_addr = d_inst_i[19:15];
        reg2_addr = d_inst_i[24:20];
        x_op1_mux_sel_o = REG1_DATA;
        x_op2_mux_sel_o = REG2_DATA;
      end
      `ITYPE_ALU_OPCODE: begin
        x_funct3_next = d_inst_i[14:12];
        if (d_inst_i[14:12] == `FUNCT3_SRA ||
            d_inst_i[14:12] == `FUNCT3_SRL) begin
            x_funct7_30_next = d_inst_i[30];
        end
        reg1_addr = d_inst_i[19:15];
        x_op1_mux_sel_o = REG1_DATA;
        x_op2_mux_sel_o = IMM_SIGNED;
        imm_signed_o = { {20{d_inst_i[31]}}, d_inst_i[31:20]};
      end
    endcase
  end

  always_comb begin
    alu_mux_sel_o = ARITH;
    case (x_opcode)
      `RTYPE_OPCODE, `ITYPE_OPCODE: begin
        case (x_funct3_o)
          `FUNCT3_ADD, `FUNCT3_SUB:
            alu_mux_sel_o = ARITH;
          `FUNCT3_SLL, `FUNCT3_SRL, `FUNCT3_SRA:
            alu_mux_sel_o = SHIFT;
          `FUNCT3_SLT, `FUNCT3_SLTU, `FUNCT3_XOR,
          `FUNCT3_OR, `FUNCT3_AND:
            alu_mux_sel_o = LOGICAL;
        endcase
      end
    endcase
  end


  always_comb begin
    w_mux_sel_o = REG_WRITE;
    case (m_opcode)
      `RTYPE_OPCODE, `ITYPE_ALU_OPCODE: begin
        w_mux_sel_o = REG_WRITE;
      end
    endcase
  end

  always_comb begin
    reg_w_addr_o = '0;
    case (w_opcode)
    `RTYPE_OPCODE, `ITYPE_ALU_OPCODE: begin
      reg_w_addr_o = w_rd;
    end
    endcase
  end

endmodule
