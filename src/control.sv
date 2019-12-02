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

  reg_w_addr_o
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

  // Local signals
  logic [2:0] x_funct3_q, x_funct3_next;
  logic x_funct7_30_q, x_funct7_30_next;
  logic [31:0] reg1_addr, reg2_addr;
  logic [6:0] d_opcode;

  logic [6:0] x_opcode;
  logic [6:0] m_opcode;
  logic [6:0] w_opcode;

  logic [4:0] d_rd, x_rd, m_rd;
  logic [4:0] next_x_rd, next_m_rd;

  assign reg1_addr_o = reg1_addr;
  assign reg2_addr_o = reg2_addr;
  assign x_funct3_o = x_funct3_q;
  assign x_funct7_30_o = x_funct7_30_q ;

  assign d_opcode = d_inst_i[6:0];
  assign d_rd = d_inst_i[11:7];

  // TODO: stall etc logic needed
  assign next_x_rd = d_rd;
  assign next_m_rd = x_rd;

  always_ff @(posedge clk_i, negedge rst_n_i) begin
    if (rst_n_i == 1'b0) begin      
      x_opcode <= '0;
      x_rd <= '0;
      m_opcode <= '0;
      m_rd <= '0;
      w_opcode <= '0;
    end else begin
      x_opcode <= d_opcode;
      x_rd <= next_x_rd;
      m_opcode <= x_opcode;
      m_rd <= next_m_rd;
      w_opcode <= m_opcode;
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
    case (x_opcode)
      `RTYPE_OPCODE: begin
        case (x_funct3_o)
          3'b000:
            alu_mux_sel_o = ARITH;
        endcase
      end
    endcase
  end

  always_comb begin
    case (d_opcode)
      `RTYPE_OPCODE: begin
        x_funct3_next = d_inst_i[14:12];
        x_funct7_30_next = d_inst_i[30];
      end
    endcase
  end

  always_comb begin
    case (d_opcode)
      `RTYPE_OPCODE: begin
        reg1_addr = d_inst_i[19:15];
        reg2_addr = d_inst_i[24:20];
      end
    endcase
  end

  always_comb begin
    case (d_opcode) 
      `RTYPE_OPCODE: begin
        x_op1_mux_sel_o = REG1_DATA;
        x_op2_mux_sel_o = REG2_DATA;
      end
    endcase
  end

  always_comb begin
    case (m_opcode)
      `RTYPE_OPCODE: begin
        w_mux_sel_o = REG_WRITE;
      end
    endcase
  end

  always_comb begin
    case (w_opcode)
    `RTYPE_OPCODE: begin
      reg_w_addr_o = m_rd;
    end
    endcase
  end

endmodule
