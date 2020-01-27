#!/bin/bash
for text_hex in riscv-tests/hexfiles/text/rv32ui-p*hex
do
    data_hex=$(echo $text_hex | sed "s%/text/\([^/]*\)\.hex$%/data/\1.data.hex%g")
    if [[ -f $data_hex ]]; then
        make HEX=$text_hex HEX2=$data_hex
    else
        make HEX=$text_hex
    fi
done
