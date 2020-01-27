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

package proc_pkg;

  typedef enum {ARITH, LOGIC, SHIFT, X_OP1, ALU_PC_VAL_D2, ALU_PC_VAL_PLUS_4_D2}  alu_mux_sel_t;
  typedef enum {REG1_DATA, PC_VAL_D1}  op1_mux_sel_t;
  typedef enum {REG2_DATA, IMM_SIGNED}  op2_mux_sel_t;
  typedef enum {ALU, DM, CSR}  w_mux_sel_t;
  typedef enum {NONE, READ_WRITE, SET, CLR} csr_op_mode_t;

endpackage
