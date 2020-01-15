// DESCRIPTION: Verilator: Verilog example module
//
// This file ONLY is placed into the Public Domain, for any use,
// without warranty, 2017 by Wilson Snyder.
//======================================================================
#include <string>
#include <iostream>
#include <fstream>

// Include common routines
#include <verilated.h>

#include <sys/stat.h>  // mkdir

// Include model header, generated from Verilating "top.v"
#include "Vtop.h"

// If "verilator --trace" is used, include the tracing class
#if VM_TRACE
# include <verilated_vcd_c.h>
#endif

// Current simulation time (64-bit unsigned)
vluint64_t main_time = 0;
// Called by $time in Verilog
double sc_time_stamp () {
    return main_time; // Note does conversion to real, to match SystemC
}

int main(int argc, char** argv, char** env) {
    // This is a more complicated example, please also see the simpler examples/hello_world_c.
    std::string logout = "";
    for (int i = 0; i < argc; i++) {
        if ((std::string(argv[i]) ==  "--logfile") && i+1 < argc)
            logout += std::string(argv[i+1]);
    }

    // Prevent unused variable warnings
    if (0 && argc && argv && env) {}
    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    Verilated::commandArgs(argc, argv);

    // Set debug level, 0 is off, 9 is highest presently used
    Verilated::debug(0);

    // Randomization reset policy
    Verilated::randReset(2);

    // Construct the Verilated model, from Vtop.h generated from Verilating "board.v"
    Vtop* top = new Vtop; // Or use a const unique_ptr, or the VL_UNIQUE_PTR wrapper

#if VM_TRACE
    // If verilator was invoked with --trace argument,
    // and if at run time passed the +trace argument, turn on tracing
    VerilatedVcdC* tfp = NULL;
    const char* flag = Verilated::commandArgsPlusMatch("trace");
    if (flag && 0==strcmp(flag, "+trace")) {
        Verilated::traceEverOn(true);  // Verilator must compute traced signals
        VL_PRINTF("Enabling waves into logs/vlt_dump.vcd...\n");
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);  // Trace 99 levels of hierarchy
        mkdir("logs", 0777);
        tfp->open("logs/vlt_dump.vcd");  // Open the dump file
    }
#endif

    // Set some inputs
    // top->data_in = 0x0f8a;
    top->rst_n = 0;
    top->eval();
    top->clk = 0;
    top->eval();
    top->clk = 1;
    top->eval();
    top->rst_n = 1;
    top->eval();

    int test_done = 0;
    
    // Simulate until $finish
    while (!Verilated::gotFinish() && main_time < 6000) {
        main_time++;
        top->clk ^= 1;

        if (main_time % 2 == 1) {
            if (top->tohost_int_o == 1) {
                std::string test_status;
                if (top->tohost_data_o == 1) {
                    test_status = "PASS";
                } else {
                    test_status = "FAIL";
                }
                printf("TEST %sED\n", test_status.c_str());
                std::ofstream f;
                f.open(logout.c_str(), std::ios::out);
                f << test_status << std::endl;
                f.close();
                test_done = 1;
                break;
            }
        }

        
        top->eval();
#if VM_TRACE        
        tfp->dump(main_time);
#endif
    }

    // Do a couple of clock cycles for easier waveform debugging
    main_time++;
    top->clk ^= 1;
    top->eval();
#if VM_TRACE        
        tfp->dump(main_time);
#endif
    main_time++;
    top->clk ^= 1;
    top->eval();
#if VM_TRACE        
        tfp->dump(main_time);
#endif


    if (test_done == 0) {
        printf("TEST TIMEOUT");
    }


    // Final model cleanup
    top->final();

    // Close trace if opened
#if VM_TRACE
    if (tfp) { tfp->close(); }
#endif

    //  Coverage analysis (since test passed)
#if VM_COVERAGE
    mkdir("logs", 0777);
    VerilatedCov::write("logs/coverage.dat");
#endif

    // Destroy model
    delete top; top = NULL;

    // Fin
    exit(0);
}
