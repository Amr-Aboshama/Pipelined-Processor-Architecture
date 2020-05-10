library IEEE ;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPU is
	port(	CLK,RST,INT: 	in std_logic
	    
	);
end CPU;

architecture CPU_ARCH of CPU is
	signal DE_ENABLE: std_logic;
	signal DE_IN, DE_OUT: std_logic_vector(151 downto 0);
	
	-----------> FETCH Signals <-------------
	signal F_ENABLE, FD_ENABLE:	std_logic;
	signal INST_MEM_DATA:	std_logic_vector(15 downto 0);
	signal INST_MEM_ADD:	unsigned(10 downto 0);
	signal INST_MEM_RD_DONE, INST_MEM_RD_ENABLE, TMP:	std_logic;
	signal INST2, INST1: unsigned(15 downto 0);
	signal HAVE_SRC1, HAVE_SRC2:	std_logic;
	signal CHANGE_PC:	std_logic;
	signal PC, NEW_PC:	unsigned(31 downto 0);
	signal FD_IN, FD_OUT: std_logic_vector(67 downto 0);
begin

	--------------------------------------> Instruction Memory <-----------------------------------------------

	INST_MEMORY: entity work.MEMORYMODULE generic map(16) port map(CLK, INST_MEM_RD_ENABLE, '0', (others=>'0'), 
														std_logic_vector(INST_MEM_ADD), INST_MEM_RD_DONE, TMP, INST_MEM_DATA);

	------------------------------------------> FETCH_STAGE <--------------------------------------------------
	FETCH:	entity work.FETCH_STAGE generic map(16,32,11) port map(CLK, RST, F_ENABLE, INT, FD_ENABLE, PC, 
														unsigned(INST_MEM_DATA), INST_MEM_ADD, INST_MEM_RD_DONE, INST_MEM_RD_ENABLE, 
														INST1, INST2, HAVE_SRC1, HAVE_SRC2, CHANGE_PC, NEW_PC);
	
	FD_IN <= std_logic_vector(PC & INST2 & INST1 & HAVE_SRC1 & HAVE_SRC2 & "00");
	
	
	---------- PC(32 bits) + IR(32 bits) + src_exist(2 bits) + "00" ---------
	FD: entity work.Reg generic map(68) port map(CLK, RST, FD_ENABLE, FD_IN, FD_OUT);

	------ PC(32 bits) + EXT(32 bits) + Rsrc1(32 bits) + Rsrc2(32 bits) + Rsrc1_num(3 bits) -------------------
	------ + Rsrc2_num(3 bits) + Rdst_num(3 bits) + EX(6 bits) + M(4 bits) + WB(5 bits) --------------------------
	DE: entity work.Reg generic map(152) port map(CLK, RST, DE_ENABLE, DE_IN, DE_OUT);

end CPU_ARCH;
