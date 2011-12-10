#!/bin/python

def div(N, D, nbits):
    q = ""
    P = N
    D = D << nbits
    for i in range(nbits-1,-1,-1):
        P = 2*P - D
        if P >= 0:
            q = q + '1' 
        else:
            q = q + '0'
            P = P + D
    print "%d / %d (%d bits) = " % (N, D, nbits) + q
