#!/bin/bash
for f in riscv-tests/hexfiles/rv32ui-p*hex
do
    make HEX=$f
done
