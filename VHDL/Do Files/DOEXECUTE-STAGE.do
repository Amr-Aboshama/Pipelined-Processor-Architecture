vcom -work work *.vhd
vsim work.EXECUTE_STAGE
add wave *

force -freeze sim:/execute_stage/RESET 1
force -freeze sim:/execute_stage/Rsrc1 32'h00000000 
force -freeze sim:/execute_stage/Rsrc2 32'h00000000 
force -freeze sim:/execute_stage/EXT_IN 32'h00000000 
force -freeze sim:/execute_stage/INPUT_PORT 32'h00000000 
force -freeze sim:/execute_stage/Rsrc1_num 3'b000
force -freeze sim:/execute_stage/Rsrc2_num 3'b000 
force -freeze sim:/execute_stage/Rdst1_INnum 3'b000
force -freeze sim:/execute_stage/EX_IN 6'b000000
force -freeze sim:/execute_stage/INTERRUPT 0
force -freeze sim:/execute_stage/JZ 0
force -freeze sim:/execute_stage/WB_IN 5'b00000
puts "CASE #01 :RESET"
run 100

force -freeze sim:/execute_stage/RESET 0 
force -freeze sim:/execute_stage/Rsrc1 32'hffffffff
force -freeze sim:/execute_stage/Rsrc2 32'h00000007
force -freeze sim:/execute_stage/EX_IN 6'b000001
puts "CASE #02 :NOT"
puts "ALU_RESULT = 0, c=0, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000005
force -freeze sim:/execute_stage/Rsrc2 32'h00000007
force -freeze sim:/execute_stage/EX_IN 6'b000100
force -freeze sim:/execute_stage/Rsrc1_num 3'b000
force -freeze sim:/execute_stage/Rsrc2_num 3'b001
force -freeze sim:/execute_stage/WB_IN 5'b00111
puts "CASE #03 :SWAP"
puts "ALU_RESULT = 5, RESULT =7, Rdst1 =001, Rdst2 = 000, c=0, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000005
force -freeze sim:/execute_stage/Rsrc2 32'h00000009
force -freeze sim:/execute_stage/EXT_IN 32'h00000002
force -freeze sim:/execute_stage/INPUT_PORT 32'h00000007
force -freeze sim:/execute_stage/EX_IN 6'b100000
force -freeze sim:/execute_stage/WB_IN 5'b00101
puts "CASE #04 :IN"
puts "ALU_RESULT = 7,ALU_RESULT_INTERNAL=2 , c=0, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000004
force -freeze sim:/execute_stage/Rsrc2 32'h00000009
force -freeze sim:/execute_stage/EXT_IN 32'h00000002
force -freeze sim:/execute_stage/EX_IN 6'b010000
force -freeze sim:/execute_stage/WB_IN 5'b00000
puts "CASE #05 :OUT"
puts "ALU_RESULT = 2,OUTPUT_PORT = 4, c=0, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000004
force -freeze sim:/execute_stage/Rsrc2 32'h00000009
force -freeze sim:/execute_stage/EXT_IN 32'h00000003
force -freeze sim:/execute_stage/EX_IN 6'b000000
force -freeze sim:/execute_stage/WB_IN 5'b00001  
puts "CASE #06 :LDM"
puts "ALU_RESULT = 3,c=0, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000004
force -freeze sim:/execute_stage/Rsrc2 32'h00000009
force -freeze sim:/execute_stage/EXT_IN 32'h00000003
force -freeze sim:/execute_stage/EX_IN 6'b001111
force -freeze sim:/execute_stage/WB_IN 5'b00101  
puts "CASE #07 :SHR"
puts "ALU_RESULT = 0,c=1, n=0, z=1"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000004
force -freeze sim:/execute_stage/Rsrc2 32'h00000005
force -freeze sim:/execute_stage/EXT_IN 32'h00000003
force -freeze sim:/execute_stage/EX_IN 6'b001010
force -freeze sim:/execute_stage/WB_IN 5'b00101  
puts "CASE #08 :ADD"
puts "ALU_RESULT = 9,c=0, n=0, z=0"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000004
force -freeze sim:/execute_stage/Rsrc2 32'h00000005
force -freeze sim:/execute_stage/EXT_IN 32'h00000003
force -freeze sim:/execute_stage/EX_IN 6'b001101
force -freeze sim:/execute_stage/WB_IN 5'b00101  
puts "CASE #09 :IADD"
puts "ALU_RESULT = 7,c=0, n=0, z=0"
run 100

force -freeze sim:/execute_stage/Rsrc1 32'h00000004
force -freeze sim:/execute_stage/Rsrc2 32'h00000005
force -freeze sim:/execute_stage/EXT_IN 32'h00000003
force -freeze sim:/execute_stage/EX_IN 6'b001011
force -freeze sim:/execute_stage/WB_IN 5'b00101  
puts "CASE #10 :sub"
puts "ALU_RESULT = h'ffffffff ,c=1, n=1, z=0"
run 100