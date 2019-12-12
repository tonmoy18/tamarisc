#!/bin/bash

for f in "$@"
do
    python ./scripts/dump2hex.py $f 80000100 > hexfiles/$(basename $(echo $f) | sed s/dump/hex/g)
done

