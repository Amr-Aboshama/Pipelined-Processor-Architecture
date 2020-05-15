add wave -position insertpoint sim:/memorystage_test/*

add wave -position insertpoint sim:/memorystage_test/MEMORY/*
add wave -position insertpoint sim:/memorystage_test/MEMORYSTAGE/*


force -freeze sim:/memorystage_test/M_CLK 1 0, 0 {50 ps} -r 100
# fill the ram in address 0 with 1's 
mem load -filltype value -filldata {1111111111111111 } -fillradix symbolic /memorystage_test/MEMORY/RAM_U/MEMORY(0)
mem load -filltype value -filldata {1111111111111111 } -fillradix symbolic /memorystage_test/MEMORY/RAM_U/MEMORY(1)
mem load -filltype value -filldata {1111111100000000 } -fillradix symbolic /memorystage_test/MEMORY/RAM_U/MEMORY(2)
mem load -filltype value -filldata {0000000000000000 } -fillradix symbolic /memorystage_test/MEMORY/RAM_U/MEMORY(3)
mem load -filltype value -filldata {0000111100001111 } -fillradix symbolic /memorystage_test/MEMORY/RAM_U/MEMORY(4) 
mem load -filltype value -filldata {0000111100001111 } -fillradix symbolic /memorystage_test/MEMORY/RAM_U/MEMORY(5)

# test reset 
force -freeze sim:/memorystage_test/M_RST 1 0
run 900
force -freeze sim:/memorystage_test/M_RST 0 0

# test interrupt 
force -freeze sim:/memorystage_test/M_INTERRUPT 1 0
force -freeze sim:/memorystage_test/M_FLAGREGISTERIN 1010 0
force -freeze sim:/memorystage_test/M_FETCHPC 00000000000000000000010101010101 0
run 
force -freeze sim:/memorystage_test/M_INTERRUPT 0 0
run 1300

#test push 
force -freeze sim:/memorystage_test/M_GROUP2SELECTOR 1 0   
force -freeze sim:/memorystage_test/M_MEMORYSIGNALS 0101 0
force -freeze sim:/memorystage_test/M_ALURESULT 00000000111111110000000011111111 0

# test call 
force -freeze sim:/memorystage_test/M_GROUP2SELECTOR 0 0
force -freeze sim:/memorystage_test/M_ALURESULT 00000000111111110000000011111111 0
force -freeze sim:/memorystage_test/M_MEMORYSIGNALS 0101 0
force -freeze sim:/memorystage_test/M_EXECUTEPC 00000000001010101010110101010101 0
#if more than that it will repeat the call functionality
run 200

# di lwahdaha after restart
# test RET 
force -freeze sim:/memorystage_test/MEMORYSTAGE/STACKPOINTER 00000000000000000000000000000010 0
force -freeze sim:/memorystage_test/M_MEMORYSIGNALS 1000 0
force -freeze sim:/memorystage_test/M_GROUP1SELECTOR 00 0
run 300 



