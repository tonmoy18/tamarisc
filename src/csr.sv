///////////////////////////////////////////////////////////
//
// Note:
//    CSR addr is loaded on the executing stage 
//    The register value is loaded on Memory stage
//
//    CSR read output should be available on memroy stage
//
//
//
//
//
//
//
///////////////////////////////////////////////////////////

module csr(
  rst_n_i,
  clk_i,

  csr_addr_i,
  mode_i,
  reg_val_i,

  load_mcause_i,
  excep_code_i,

  raise_exception_o,
  csr_val_o,

  mtvec_o,
  mepc_o
);

`define HARTID 0


`define csr_addr_to_idx(addr) \
    (addr >= 'hF11 && addr <= 'hF14) ? addr - 'hF11 : \
    (addr >= 'h300 && addr <= 'h306) ? addr - 'h300 + 'd4 : \
    (addr >= 'h340 && addr <= 'h344) ? addr - 'h340 + 'd11 : \
    (addr >= 'hB00 && addr <= 'hB9F) ? addr - 'hB00 + 'd16 : '0


import proc_pkg::*;
// import csr_pkg::*;

input logic rst_n_i;
input logic clk_i;

input logic [12:0] csr_addr_i;
input logic [1:0] mode_i;

input logic [31:0] reg_val_i;

input logic [31:0] excep_code_i;
input logic load_mcause_i;

output logic raise_exception_o;
output logic [31:0] csr_val_o;

output logic [31:0] mtvec_o;
output logic [31:0] mepc_o;

logic raise_exception_next;

// MRO
logic [31:0] mvendorid;
logic [31:0] marchid;
logic [31:0] mimpid;
logic [31:0] mhartid;

// MRW
logic [31:0] mstatus;
logic [31:0] misa;
// logic [31:0] medeleg;
// logic [31:0] mideleg;
logic [31:0] mie;
logic [31:0] mtvec;
logic [31:0] mcounteren;

logic [31:0] mscratch;
logic [31:0] mepc;
logic [31:0] mcause;
logic [31:0] mtval;
logic [31:0] mip;

logic [31:0] mcycle;
logic [31:0] minstret;
logic [31:0] mhpmcoutner[3:31];
logic [31:0] mcycleh;
logic [31:0] minstreth;
logic [31:0] mhpmcounterh[3:31];

logic [31:0] mcountinhibit;
logic [31:0] mhpmevent[3:31];

integer i;
// Make sure synthesize optimized unused ones away
logic [31:0] csr_regfield_q[0:175];
logic [31:0] csr_regfield_next[0:175];

logic [31:0] csr_val_next;

assign mtvec_o = mtvec;
assign mepc_o = mepc;

always_comb begin
  if (csr_addr_i[11:10] === 2'b11) begin // read-only
    case (csr_addr_i)
    'h305:
      csr_val_next = `HARTID;
    default:
      csr_val_next = '0;
    endcase
  end
  else begin
    csr_val_next = csr_regfield_q[`csr_addr_to_idx(csr_addr_i)];
  end
  raise_exception_next = 1'b0;

  // TODO: skip read only values
  for (i = 0; i < 175; i++) begin
    csr_regfield_next[i] = csr_regfield_q[i];
  end

  if ((csr_addr_i >= 12'hF11 && csr_addr_i <= 12'hF14) || 
      (csr_addr_i >= 12'h300 && csr_addr_i <= 12'h306) ||
      (csr_addr_i >= 12'h340 && csr_addr_i <= 12'h344) ||
      (csr_addr_i >= 12'hB00 && csr_addr_i <= 12'hB9F)) begin /*||
      (csr_addr_i >= 12'h300 && csr_addr_i <= 12'h306) ||
      (csr_addr_i >= 12'h300 && csr_addr_i <= 12'h306) ||
      (csr_addr_i >= 12'h300 && csr_addr_i <= 12'h306)) begin */
    if (csr_addr_i[11:10] !== 2'b11) begin // not read-only
      if (mode_i == CLR) begin
        csr_regfield_next[`csr_addr_to_idx(csr_addr_i)] &= ~reg_val_i;
      end else if (mode_i == SET) begin
        csr_regfield_next[`csr_addr_to_idx(csr_addr_i)] |= reg_val_i;
      end else if (mode_i == READ_WRITE) begin
        csr_regfield_next[`csr_addr_to_idx(csr_addr_i)] = reg_val_i;
      end
    end
  end else if (mode_i != NONE) begin
    raise_exception_next = 1'b1;
  end
  if (load_mcause_i == 1'b1) begin
    csr_regfield_next[13] = excep_code_i;
  end
end

always_comb begin
  mvendorid = csr_regfield_q[`csr_addr_to_idx('hF11)];
  marchid = csr_regfield_q[`csr_addr_to_idx('hF12)];
  mimpid = csr_regfield_q[`csr_addr_to_idx('hF13)];
  mhartid = csr_regfield_q[`csr_addr_to_idx('hF14)];
  mstatus = csr_regfield_q[`csr_addr_to_idx('h300)];
  misa = csr_regfield_q[`csr_addr_to_idx('h301)];
  // medeleg = csr_regfield_q['hF11];
  // mideleg = csr_regfield_q['hF11];
  mie = csr_regfield_q[`csr_addr_to_idx('h304)];
  mtvec = csr_regfield_q[`csr_addr_to_idx('h305)];
  mcounteren = csr_regfield_q[`csr_addr_to_idx('h306)];
  mscratch = csr_regfield_q[`csr_addr_to_idx('h340)];
  mepc = csr_regfield_q[`csr_addr_to_idx('h341)];
  mcause = csr_regfield_q[`csr_addr_to_idx('h342)];
  mtval = csr_regfield_q[`csr_addr_to_idx('h343)];
  mip = csr_regfield_q[`csr_addr_to_idx('h344)];
end

always_ff @(posedge clk_i, negedge rst_n_i) begin
  if (rst_n_i == 1'b0) begin
    raise_exception_o <= 1'b0;
  end else begin
    raise_exception_o <= raise_exception_next;
  end
end

always_ff @(posedge clk_i, negedge rst_n_i) begin
  if (rst_n_i == 1'b0) begin
    for (i = 0; i <= 175; i++) begin
      csr_regfield_q[i] = '0; // TODO: use proper reset values
    end
  end else begin
    for (i = 0; i <= 175; i++) begin
      csr_regfield_q[i] = csr_regfield_next[i];
    end
  end
end

always_ff @(posedge clk_i, posedge rst_n_i) begin
  if (rst_n_i == 1'b0) begin
    csr_val_o <= '0;
  end else begin
    csr_val_o <= csr_val_next;
  end
end

endmodule