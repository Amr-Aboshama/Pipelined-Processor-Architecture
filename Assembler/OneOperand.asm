# all numbers in hex format
# we always start by reset signal
#this is a commented line
.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
10
#you should ignore empty lines

.ORG 2  #this is the interrupt address
100

.ORG 10
NOP            #No change
NOT R1         #R1 =FFFFFFFF , C--> no change, N --> 1, Z --> 0
inc R2	       #R1 =00000000 , C --> 1 , N --> 0 , Z --> 1
DEC R2	       #R1 =00000000 , C --> 1 , N --> 0 , Z --> 1
OUT R4          #R2= 10,add 10 on the in port, flags no change
in R3	       #R1= 5,add 5 on the in port,flags no change	


AND R1,R2,R3	       #R2= FFFFFFEF, C--> no change, N -->1,Z-->0
OR R4,R5,R6	       #R2= FFFFFFEF, C--> no change, N -->1,Z-->0
ADD R7,R6,R5	       #R2= FFFFFFEF, C--> no change, N -->1,Z-->0
SUB R1,R2,R3	       #R2= FFFFFFEF, C--> no change, N -->1,Z-->0
SWAP R1,R2         #R1= 6, C --> 0, N -->0, Z-->0
IADD R1,R2,F         #R2= FFEE,C-->1 , N-->1, Z-->0
SHL R1,5
SHR R2,B

LB: PUSH R1
POP R2
STD R0,FF
LDD R2,FF
LDM R3,E

JZ R1
JMP R2
CALL R3
RET
RTI
