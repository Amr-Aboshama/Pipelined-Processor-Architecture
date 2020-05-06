import sys

opcode = dict()
sz = dict()

def init():
    opcode['.org']  ='#'
    #One Operand
    cat='00'
    opcode['nop']   =cat+'000'+11*'0'
    opcode['not']   =cat+'001'+11*'0'
    opcode['inc']   =cat+'010'+11*'0'
    opcode['dec']   =cat+'011'+11*'0'
    opcode['out']   =cat+'100'+11*'0'
    opcode['in']    =cat+'101'+11*'0'


    #Two Operands
    cat='01'
    opcode['and']   =cat+'000'+11*'0'
    opcode['or']    =cat+'001'+11*'0'
    opcode['add']   =cat+'010'+11*'0'
    opcode['sub']   =cat+'011'+11*'0'
    opcode['swap']  =cat+'100'+11*'0'
    opcode['iadd']  =cat+'101'+11*'0'+16*'0'
    opcode['shl']   =cat+'110'+11*'0'+16*'0'
    opcode['shr']   =cat+'111'+11*'0'+16*'0'

    #Memory Operations
    cat='10'
    opcode['push']  =cat+'000'+11*'0'
    opcode['pop']   =cat+'001'+11*'0'
    opcode['std']   =cat+'101'+11*'0'+16*'0'
    opcode['ldd']   =cat+'110'+11*'0'+16*'0'
    opcode['ldm']   =cat+'111'+11*'0'+16*'0'

    #Branch
    cat='11'
    opcode['jz']    =cat+'000'+11*'0'
    opcode['jmp']   =cat+'001'+11*'0'
    opcode['call']  =cat+'010'+11*'0'
    opcode['ret']   =cat+'011'+11*'0'
    opcode['rti']   =cat+'100'+11*'0'


#Instructions Sizes

    sz['.org']  =1+2
    #One Operand
    sz['nop']   =1+1
    sz['not']   =1+2
    sz['inc']   =1+2
    sz['dec']   =1+2
    sz['out']   =1+2
    sz['in']    =1+2


    #Two Operand
    sz['and']   =1+4
    sz['or']    =1+4
    sz['add']   =1+4
    sz['sub']   =1+4
    sz['swap']  =1+3
    sz['iadd']  =1+4
    sz['shl']   =1+3
    sz['shr']   =1+3

    #Memory Operations
    sz['push']  =1+2
    sz['pop']   =1+2
    sz['std']   =1+3
    sz['ldd']   =1+3
    sz['ldm']   =1+3

    #Branch
    sz['jz']    =1+2
    sz['jmp']   =1+2
    sz['call']  =1+2
    sz['ret']   =1+1
    sz['rti']   =1+1


    
def clearCode(lst):
    ret = []
    for i in range(0,len(lst)):
        lst[i] = lst[i].replace('\t',' ')
        lst[i] = lst[i].replace(',',' ')
        lst[i] = lst[i].split('#')[0]               #Remove Comments
        lst[i] = lst[i].split('\n')[0]              #Remove Endline
        while len(lst[i]) and lst[i][-1]==' ':      #Remove Trailing spaces
            lst[i]=lst[i][:-1]

        while len(lst[i]) and lst[i][0]==' ':       #Remove Leading spaces
            lst[i]=lst[i][1:len(lst[i])]

        if len(lst[i]):                             #Remove Empty Lines
            lst[i] = lst[i].split(' ')
            ret.append(list())
            for r in lst[i]:                        #Split Instruction
                if(r!=''):
                    ret[-1].append(r)

            if ret[-1][0][-1]==':':                 #Extract label => Label must be followed by space (e.g. [LB: Add R1,R2])
                ret[-1][0]=ret[-1][0][:-1]
            else:
                ret[-1].insert(0,'#')
            ret[-1][1] = ret[-1][1].lower()
        
    return ret

def getOpcode(inst):
    def getRegister(idx):
        ret = int(inst[idx][-1])
        ret = "{0:03b}".format(ret)
        return ret


    ret = opcode[inst[1]]


    cat = int(ret[0:2],2)
    code = int(ret[2:5],2)
    src1 = src2 = dst = '000'
    imd =0
    if cat==0:
        reg = 0
        if code!=0:
            reg = getRegister(2)
        
        if code!=0 and code!=4:
            dst=reg

        if code!=0 and code!=5:
            src1=reg

    elif cat==1:
        src1 = getRegister(2)

        if code<4:
            src2 = getRegister(3)
            dst = getRegister(4)
        elif code<6:
            dst = getRegister(3)
        else:
            dst=src1
        
        if code>4:
            imd = int(inst[-1],16)
            imd = "{0:020b}".format(imd)

    elif cat==2:
        reg = getRegister(2)
        
        if (code==0 or code==5):
            src1=reg
        else:
            dst=reg

        if code>1:
            imd = int(inst[-1],16)
            imd = "{0:020b}".format(imd)

    else:
        if code<3:
            src1=getRegister(2)

    ret = ret[0:5] + dst + src1 + src2 + ret[14:len(ret)]
    if len(ret)==32:
        ret = ret[0:12] + imd
    return ret


def fillMemory(lst):
    cur=-1
    ret = []
    for r in lst:
        if(r[1]=='.org'):
            cur = int(r[2],16)-1
            continue
        
        cur += 1
        if((r[1] in sz) and (len(r)==sz[r[1]]))==False:
            ret.append([cur,"{0:016b}".format(int(r[1],16))])
            continue
        
        op = getOpcode(r)
        ret.append([cur,op[0:16]])
        if len(op)==32:
            cur += 1
            ret.append([cur,op[16:32]])
    
    ret.sort()
    return ret


inFile = open(sys.argv[1],'r')
hexFile = open(sys.argv[1].split('.')[0]+'.hex','w')
binFile = open(sys.argv[1].split('.')[0]+'.bin','w')

init()
instList = clearCode(inFile.readlines())

mem = fillMemory(instList)
empty = 16*'0'
j=0
siz=mem[-1][0]+1
for i in range(0,siz):
    out = ''
    if(i!=mem[j][0]):
        out=empty
    else:
        out=mem[j][1]
        j=j+1
    binFile.write(out+'\n')
    hexFile.write("{0:04x}".format(int(out,2)).upper()+'\n')