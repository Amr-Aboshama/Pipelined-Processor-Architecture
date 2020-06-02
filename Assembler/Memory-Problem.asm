.ORG 0
10

.ORG 2
100

# Problem because memorysignal doesn't change in 2 consecutive instructions
# So for any consecutive instructions with the same memorysignal, the first one only will be executed normally.
.ORG 10
LDM R0,5
LDM R1,10
NOP
NOP
PUSH R0
PUSH R1
POP R2
POP R3
#JMP R0
