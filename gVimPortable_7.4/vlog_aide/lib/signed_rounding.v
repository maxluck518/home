# signed_rounding(INPUT, OUTPUT, MSB, LSB)
assign $(INPUT)_ext[MSB+1:0] = {$(INPUT)[MSB], $(INPUT)} + $(INPUT)[LSB-1]
