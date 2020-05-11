vcom -work work *.vhd
vsim work.EXECUTE_STAGE
add wave *

force -freeze sim:/execute_stage/RESET 1
run 100

force -freeze sim:/execute_stage/RESET 0 
force -freeze sim:/execute_stage/Rsrc1 32'hffffffff
force -freeze sim:/execute_stage/Rsrc2 32'h00000007
force -freeze sim:/execute_stage/EX_IN 000001
puts "CASE #01 :NOT"
puts "ALU_RESULT = 0, c=0, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000005
force -freeze sim:/execute_stage/Rsrc2 32'h00000007
force -freeze sim:/execute_stage/EX_IN 000100
force -freeze sim:/execute_stage/Rsrc1_num 000
force -freeze sim:/execute_stage/Rsrc2_num 001
force -freeze sim:/execute_stage/WB_IN 00111
puts "CASE #02 :SWAP"
puts "ALU_RESULT = 5, RESULT =7, Rdst1 =001, Rdst2 = 000, c=0, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000005
force -freeze sim:/execute_stage/Rsrc2 32'h00000009
force -freeze sim:/execute_stage/EXT_IN 32'h00000002
force -freeze sim:/execute_stage/INPUT_PORT 32'h00000007
force -freeze sim:/execute_stage/EX_IN 100000
force -freeze sim:/execute_stage/WB_IN 00101
puts "CASE #03 :IN"
puts "ALU_RESULT = 7,ALU_RESULT_INTERNAL=2 , c=0, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000004
force -freeze sim:/execute_stage/Rsrc2 32'h00000009
force -freeze sim:/execute_stage/EXT_IN 32'h00000002
force -freeze sim:/execute_stage/EX_IN 010000
force -freeze sim:/execute_stage/WB_IN 00000
puts "CASE #04 :OUT"
puts "ALU_RESULT = 2,OUTPUT_PORT = 4, c=0, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000004
force -freeze sim:/execute_stage/Rsrc2 32'h00000009
force -freeze sim:/execute_stage/EXT_IN 32'h00000003
force -freeze sim:/execute_stage/EX_IN 000000
force -freeze sim:/execute_stage/WB_IN 00001  
puts "CASE #05 :LDM"
puts "ALU_RESULT = 3,c=0, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000004
force -freeze sim:/execute_stage/Rsrc2 32'h00000009
force -freeze sim:/execute_stage/EXT_IN 32'h00000003
force -freeze sim:/execute_stage/EX_IN 001111
force -freeze sim:/execute_stage/WB_IN 00101  
puts "CASE #06 :SHR"
puts "ALU_RESULT = 0,c=1, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000004
force -freeze sim:/execute_stage/Rsrc2 32'h00000005
force -freeze sim:/execute_stage/EXT_IN 32'h00000003
force -freeze sim:/execute_stage/EX_IN 001010
force -freeze sim:/execute_stage/WB_IN 00101  
puts "CASE #07 :ADD"
puts "ALU_RESULT = 9,c=0, n=0, z=0"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000004
force -freeze sim:/execute_stage/Rsrc2 32'h00000005
force -freeze sim:/execute_stage/EXT_IN 32'h00000003
force -freeze sim:/execute_stage/EX_IN 001101
force -freeze sim:/execute_stage/WB_IN 00101  
puts "CASE #08 :IADD"
puts "ALU_RESULT = 7,c=0, n=0, z=0"
run 100