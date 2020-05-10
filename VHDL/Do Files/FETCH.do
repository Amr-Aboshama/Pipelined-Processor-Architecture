
vsim work.cpu

#add wave -position insertpoint sim:/cpu/*
#add wave -position insertpoint sim:/cpu/FETCH/*
#add wave -position insertpoint sim:/cpu/FETCH/MAIN/*
#add wave -position insertpoint sim:/cpu/INST_MEMORY/*
#add wave -position insertpoint sim:/cpu/INST_MEMORY/CONTROLLER_U/*
#add wave -position insertpoint sim:/cpu/INST_MEMORY/CACHE_U/*
#add wave -position insertpoint sim:/cpu/INST_MEMORY/RAM_U/*


add wave -position insertpoint sim:/cpu/*
add wave -position insertpoint sim:/cpu/FETCH/MAIN/*

force -freeze sim:/cpu/CLK 1 0, 0 {50 ps} -r 100
force sim:/cpu/RST 1
force sim:/cpu/INT 0
force sim:/cpu/CHANGE_PC 0
force sim:/cpu/F_ENABLE 1
force sim:/cpu/DE_ENABLE 0
force sim:/cpu/DE_IN 0

for {set i 0} {$i < 100} {incr i} {
    mem load -filltype value -filldata $i -fillradix unsigned /cpu/INST_MEMORY/RAM_U/MEMORY($i)
}

#mem load -filltype value -filldata 1 -fillradix unsigned /cpu/INST_MEMORY/RAM_U/MEMORY(1)

run 1400
force RST 0
run 1700
force CHANGE_PC 1
force NEW_PC 0
run 200
force CHANGE_PC 0
run 4000