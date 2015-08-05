#!/usr/bin/python

import re
import os

path= os.getenv("NF_DESIGN_DIR")
print path
output_file = open("./reg_defines_com.h", "w")
lines = 0

with open( os.path.join(path, 'sw/embedded/reg_defines.h'), "r") as output:
    f = output.readlines()    

    for line in f:
        lines = lines + 1
        if 'AXI4' in line:
	    newline= "/* */\n"
	    output_file.write(newline)
	elif 'GENERIC' in line:
	    newline= "/* */\n"
	    output_file.write(newline)
	elif '8.00.b' in line:
	    newline= "/* */\n"
	    output_file.write(newline)

        else:
            output_file.write(line)


