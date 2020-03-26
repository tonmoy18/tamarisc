# tamarisc

![Image of Tamarisc Architecture](https://raw.githubusercontent.com/tonmoy18/tamarisc/master/docs/images/architecture.png)

Tamarisc is a six stage CPU core implementing the RV32I subset of the [RISCV](https://riscv.org/specifications/) instruction set architecture in machine mode only. The implementation is done using SystemVerilog hardware definition language. The architecture assumes either two separate memory for instruction or data, or the same memory with two different ports for instruction and data. The design implements a simple always un-taken branch predictor. Conflict is resolved by stalling the instruction on the fetch stage until the conflict is resolved. Multiple jump or branch instructions on the pipeline at the same time stalls the later instruction on the fetch stage as well. This implementation has most of the machine mode SYSTEM instructions except for CSR*I and all of the machine mode CSR registers except for the counter related CSR registers.

## Getting started

The src directory holds the RTL files for the core and should be usable as is. A cycle accurate simulation using [verilator](https://www.veripool.org/wiki/verilator) is used for the development and can be used to run programs converted to verilog friendly hex format. A few tests are taken from riscv-tests repository. These tests are kept in vsim/riscv-tests directory for quick simulation during development.

### Running Simulations
Prerequisite for running the simulation is to install [verilator](https://www.veripool.org/wiki/verilator). Then to run a particular program run the following commands:
```bash
cd vsim
make HEX=<im_hexfile> HEX2=<dm_hexfile>
```

The simulation will run until the core writes a data to `tohost` memory address, which is currently set to `0x80001000`. If the written value is 1, then the test is considers a "PASS". For example, to run the rv32i-p-add test, run the following commands:

```bash
cd vsim
make HEX=riscv-tests/hexfiles/rv32ui-p-add.hex
```

### Generating Hex file from Assembly

Prerequisite for generation hex from assebmly is to install [riscv-gnu-toolchain](https://github.com/riscv/riscv-gnu-toolchain). Using the toolchain a .S assembly file can be assembled into a ELF file, which can finally be dumped using the readelf command. If the generated output is kept into a file, then the python script in vsim/riscv-tests/scripts/dump2hex.py can be run with the dump file as a command line argument to generate the .hex file for the instruction memory. The .hex file for the data still needs to be hand crafted as the python script does not support conversion of data less than 4 bytes in a single line.

## Architecture Description

The implementation features a six stage pipeline which consists of the stages: (1) address, (2) fetch, (3) decode, (4) execute, (5) memory, and (6) write back. The regfile has dual read and single write port. The design has separate arithmetic, logic and shift units. Both the arithmetic and the logic units can be active simultaneously on the execute step only for the branch instruction. The current versions of the instruction "cache" and data "cache" modules are very rudimentary latching the address values until memory busy signals become low. All muxes that select different sources of data reside in the datapath module.

## Future Improvements
* Implement the remaining CSR registers
* Implement CSR*I instruction (currently CSRRW, CSRRS and CSRRC are implemented)
* Implement better instruction and data cache modules
* Implement more intelligent branch predictor
* Implement full suite of riscv benchmark tests for RV32MI
* Fix synthesis related issues
* Add assertions for formal proof
