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

  typedef enum {ARITH, LOGIC, SHIFT, X_OP1, ALU_PC_VAL_D2}  alu_mux_sel_t;
  typedef enum {REG1_DATA, PC_VAL_D1}  x_op1_mux_sel_t;
  typedef enum {REG2_DATA, IMM_SIGNED}  x_op2_mux_sel_t;
  typedef enum {ALU}  w_mux_sel_t;

endpackage
