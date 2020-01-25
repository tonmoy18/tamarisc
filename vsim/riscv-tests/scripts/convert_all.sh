#!/bin/bash

for f in "$@"
do
    python ./scripts/dump2hex.py $f 80000000 > hexfiles/$(basename $(echo $f) | sed s/dump/hex/g)
done

