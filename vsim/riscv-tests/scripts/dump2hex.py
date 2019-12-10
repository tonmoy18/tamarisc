
import sys
import re

filename = sys.argv[1]
offset_addr = sys.argv[2]

with open(filename) as f:
    for line in f:
        m = re.match('^([0-9A-Fa-f]{8}):\t([0-9A-Fa-f]{8}).*', line.rstrip())
        if m:
            if int(m.group(1), 16) >= int(offset_addr, 16):
                print(m.group(2))

