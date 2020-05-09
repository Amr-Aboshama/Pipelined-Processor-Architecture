vcom -work work *.vhd
vsim work.ALU
add wave *

force OPERAND1 32'h00000005
force OPERAND2 32'h00000007
force SEL 1010
puts "01# ADD=> 5+7 :: res = 12, c=0, n=0, z=0"
run 100

force OPERAND1 32'hffffffff
force OPERAND2 32'hffffffff
force SEL 1010
puts "02# ADD=> h'ffffffff+h'ffffffff :: res = h'fffffffe , c=1, n=1, z=0"
run 100

force OPERAND1 32'h00000005
force OPERAND2 32'h0000000b
force SEL 1011
puts "03# sub=> 5-11 :: res = -6 , c=1, n=1, z=0"
run 100

force OPERAND1 32'h00000003
force OPERAND2 32'hffffffff
force SEL 0010
puts "04# inc=> 3+1 :: res = 4 , c=0, n=0, z=0"
run 100

force OPERAND1 32'h00000001
force OPERAND2 32'hffffffff
force SEL 0011
puts "05# dec=> 1-1 :: res = 0 , c=0, n=0, z=1"
run 100

force OPERAND1 32'h00000008
force OPERAND2 32'hffffffff
force SEL 0011
puts "06# dec=> 8-1 :: res = 7 , c=0, n=0, z=0"
run 100

force OPERAND1 32'hffffffff
force OPERAND2 32'hffffffff
force SEL 0010
puts "07# inc=> h'fffffff+1 :: res = 0 , c=1, n=0, z=1"
run 100

force OPERAND1 32'h0ffffff7
force OPERAND2 32'h00000004
force SEL 1111
puts "08# SHR=> h'0ffffff7 by 4 :: res = h'00fffffff , c=0, n=0, z=0"
run 100

force OPERAND1 32'hf0000001
force OPERAND2 32'h00000004
force SEL 1110
puts "09# SHL=> h'f0000001 by 4 :: res = h'000000010 , c=1, n=0, z=0"
run 100

force OPERAND1 32'h00000002
force OPERAND2 32'h00000001
force SEL 1001
puts "10# OR=> h'00000002 || h'00000001 :: res = h'00000003 , c=1, n=0, z=0"
run 100

force OPERAND1 32'h00000002
force OPERAND2 32'h00000001
force SEL 1000
puts "11# AND=> h'00000002 && h'00000001 :: res = h'00000000 , c=1, n=0, z=1"
run 100

force OPERAND1 32'h7fffffff
force OPERAND2 32'h00000001
force SEL 0001
puts "12# NOT=> h'7fffffff :: res = h'80000000 , c=1, n=1, z=0"
run 100

force OPERAND1 32'h00000000
force OPERAND2 32'h00000001
force SEL 0000
puts "13# idle=> h'00000000 :: res = h'00000000 , c=1, n=1, z=0"
run 100
