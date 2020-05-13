library IEEE ;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPU is
	port(	
		CLK,RST,INT: 	IN std_logic;
		INPUT_PORT:		IN std_logic_vector(31 downto 0);
		OUTPUT_PORT:	OUT std_logic_vector(31 downto 0)
	);
end CPU;

architecture CPU_ARCH of CPU is
	-----------> Intermediate Registers Signals <-------------
	signal FD_ENABLE,DE_ENABLE: 					std_logic;
	signal FD_IN, FD_OUT: 						std_logic_vector(67 downto 0);
	signal DE_IN, DE_OUT: 						std_logic_vector(155 downto 0);
	signal EM_IN, EM_OUT: 						std_logic_vector(147 downto 0);
	signal MWB_IN, MWB_OUT: 					std_logic_vector(138 downto 0);
	
	-----------> FETCH Signals <-------------
	signal F_ENABLE:						std_logic;
	signal INST_MEM_DATA:						std_logic_vector(15 downto 0);
	signal INST_MEM_ADD:						unsigned(10 downto 0);
	signal INST_MEM_RD_DONE, INST_MEM_RD_ENABLE, TMP:		std_logic;
	signal INST2, INST1: 						unsigned(15 downto 0);
	signal HAVE_SRC1, HAVE_SRC2:					std_logic;
	signal CHANGE_PC:						std_logic;
	signal PC, NEW_PC:						unsigned(31 downto 0);

	-----------> DECODE Signals <-------------
	signal hazard_detected:						std_logic;
	signal jump_cat,uncond_jump,jz:					std_logic;
	signal intr:							std_logic_vector(1 downto 0);
	signal Rsrc1_num,Rsrc2_num,Rdst_num:				std_logic_vector(2 downto 0);
	signal m_to_DE:					std_logic_vector(3 downto 0);
	signal wb_to_DE:						std_logic_vector(4 downto 0);
	signal ex_to_DE:						std_logic_vector(5 downto 0);
	signal ext,Rsrc2,Rsrc1:						std_logic_vector(31 downto 0);

	-----------> EXECUTE Signals <-------------
	signal RDST1_NUM, RDST2_NUM:		std_logic_vector(2 downto 0);
	signal FLAG_REG:					std_logic_vector(3 downto 0);
	signal EX_RESULT1, EX_RESULT2:		std_logic_vector(31 downto 0);

	-----------> MEMORY Signals <--------------

	----------> WRITEBACK Signals <------------
	signal mem_result_in,alu_result,result:				std_logic_vector(31 downto 0);
	signal wb:							std_logic_vector(4 downto 0);
	signal dst1_num_in,dst2_num_in:					std_logic_vector(2 downto 0);

	signal dst1_result,dst2_result,mem_result:			std_logic_vector(31 downto 0);
	signal dst1_en,dst2_en: 					std_logic;
	signal dst1_num,dst2_num,dst1_num_fr,dst2_num_fr:		std_logic_vector(2 downto 0);
begin

	--------------------------------------> Instruction Memory <-----------------------------------------------

	INST_MEMORY: entity work.MEMORYMODULE generic map(16) port map(CLK, INST_MEM_RD_ENABLE, '0', (others=>'0'), 
														std_logic_vector(INST_MEM_ADD), INST_MEM_RD_DONE, TMP, INST_MEM_DATA);

	------------------------------------------> FETCH_STAGE <--------------------------------------------------
	FETCH:	entity work.FETCH_STAGE generic map(16,32,11) port map(CLK, RST, F_ENABLE, INT, FD_ENABLE, PC, 
														unsigned(INST_MEM_DATA), INST_MEM_ADD, INST_MEM_RD_DONE, INST_MEM_RD_ENABLE, 
														INST1, INST2, HAVE_SRC1, HAVE_SRC2, CHANGE_PC, NEW_PC);
	
	FD_IN <= std_logic_vector(PC & INST2 & INST1 & HAVE_SRC1 & HAVE_SRC2 & "00");	

	------------------------------------------> DECODE_STAGE <--------------------------------------------------
	DECODE:	entity work.DECODE_STAGE port map(CLK, RST,FD_OUT(67 downto 36),FD_OUT(35 downto 4),dst1_result,dst2_result,dst1_num,dst2_num,dst1_en,dst2_en,hazard_detected,intr,FLAG_REG,
						  ext,Rsrc2,Rsrc1,jump_cat,uncond_jump,jz,Rsrc1_num,Rsrc2_num,Rdst_num,m_to_DE,wb_to_DE,ex_to_DE);

	DE_IN <= std_logic_vector("000" & jz & FD_OUT(67 downto 36) & ext & Rsrc1 & Rsrc2 & Rsrc1_num & Rsrc2_num & Rdst_num & ex_to_DE & m_to_DE & wb_to_DE);

	------------------------------------------> EXECUTE_STAGE <--------------------------------------------------

	EXECUTE: entity work.EXECUTE_STAGE port map(DE_OUT(87 downto 56), DE_OUT(55 downto 24), DE_OUT(119 downto 88),
												DE_OUT(23 downto 21), DE_OUT(20 downto 18), DE_OUT(17 downto 15),
												DE_OUT(4 downto 0), DE_OUT(14 downto 9), RST, INT, DE_OUT(152), INPUT_PORT,
												OUTPUT_PORT, RDST1_NUM, RDST2_NUM, FLAG_REG, EX_RESULT1, EX_RESULT2);

	EM_IN <= std_logic_vector( '0' & DE_OUT(151 downto 120) & FLAG_REG & DE_OUT(119 downto 88)  & EX_RESULT1 & EX_RESULT2
								& RDST1_NUM & RDST2_NUM & DE_OUT(8 downto 0) );
	
	-------------------------------------------> MEMORY_STAGE <--------------------------------------------------

	------------------------------------------> WRITEBACK_STAGE <------------------------------------------------
	WRITEBACK: entity work.WRITE_BACK_STAGE port map(MWB_OUT(106 downto 75),MWB_OUT(74 downto 43),MWB_OUT(42 downto 11),MWB_OUT(4 downto 0),MWB_OUT(10 downto 8),MWB_OUT(7 downto 5),
							 dst1_result,dst2_result,mem_result,dst1_en,dst2_en,dst1_num,dst2_num,dst1_num_fr,dst2_num_fr);

	---------------------------------------> Intermediate Registers <--------------------------------------------
	
	---------- PC(67 downto 36) + IR(35 downto 4) + src_exist(3 downto 2) + "00" ---------
	FD: entity work.Reg generic map(68) port map(CLK, RST, FD_ENABLE, FD_IN, FD_OUT);

	------ "000"(155 downto 153) + JZ(152) + PC(151 downto 120) + EXT(119 downto 88) + Rsrc1(87 downto 56) + Rsrc2(55 downto 24) -------- 
	----------- Rsrc1_num(23 downto 21) + Rsrc2_num(20 downto 18) + Rdst_num(17 downto 15) ------------
	----------------------- EX(14 downto 9) + M(8 downto 5) + WB(4 downto 0) --------------------------
	DE: entity work.Reg generic map(156) port map(CLK, RST, DE_ENABLE, DE_IN, DE_OUT);

	---------- '0'(147) + PC(146 downto 115) + FR(114 downto 111) + EXT(110 downto 79) + EX1_RESUT(78 downto 47) ---------
	------------------ EX2_RESUTL(46 downto 15) + RDST1_NUM(14 downto 12) + RDST2_NUM(11 downto 9) ----------------------
	------------------------------------------ M(8 downto 5) + WB(4 downto 0) -------------------------------------------
	EM: entity work.Reg generic map(148) port map(CLK, RST, '1', EM_IN, EM_OUT);

	---------- PC(138 downto 107) + MEM_RESULT(106 downto 75) + ALU_RESULT(74 downto 43) + RESULT(42 downto 11) ---------
	---------------------------- Rdst1_Num(10 downto 8)+ Rdst2_Num(7 downto 5) + WB(4 downto 0) -------------------------
	MWB: entity work.Reg generic map(68) port map(CLK, RST, FD_ENABLE, MWB_IN, MWB_OUT);


end CPU_ARCH;