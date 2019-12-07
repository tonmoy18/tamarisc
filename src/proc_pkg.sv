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

  typedef enum {ARITH, LOGIC, SHIFT}  alu_mux_sel_t;
  typedef enum {REG1_DATA}  x_op1_mux_sel_t;
  typedef enum {REG2_DATA, IMM_SIGNED}  x_op2_mux_sel_t;
  typedef enum {REG_WRITE}  w_mux_sel_t;

endpackage
