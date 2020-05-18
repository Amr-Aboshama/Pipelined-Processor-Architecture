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
	signal DE_ENABLE, EM_ENABLE: 				std_logic;
	signal FD_IN, FD_OUT: 						std_logic_vector(71 downto 0);
	signal DE_IN, DE_OUT: 						std_logic_vector(163 downto 0);
	signal EM_IN, EM_OUT: 						std_logic_vector(151 downto 0);
	signal MWB_IN, MWB_OUT: 					std_logic_vector(143 downto 0);
	
	-----------> FETCH Signals <-------------
	signal FETCH_ENABLE, FETCH_DONE:					std_logic;
	signal INST_MEM_DATA:								std_logic_vector(15 downto 0);
	signal INST_MEM_ADD:								unsigned(10 downto 0);
	signal INST_MEM_RD_DONE, INST_MEM_RD_ENABLE, TMP:	std_logic;
	signal INST2, INST1: 								unsigned(15 downto 0);
	signal HAVE_SRC1, HAVE_SRC2:						std_logic;
	-- signal MEMORY_CHANGE_PC:							std_logic;
	signal PC:											unsigned(31 downto 0);
	signal FETCH_FR:									std_logic_vector(3 downto 0);
	SIGNAL MEMORY_PC_IN:								STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL PC_IN_DONE:									STD_LOGIC;

	-----------> DECODE Signals <-------------
	signal hazard_detected:					std_logic;
	signal BRANCH_CHANGE_PC,jz:					std_logic;
	signal intr:							std_logic_vector(1 downto 0);
	signal Rsrc1_num,Rsrc2_num,Rdst_num:	std_logic_vector(2 downto 0);
	signal m_to_DE:							std_logic_vector(6 downto 0);
	signal wb_to_DE:						std_logic_vector(4 downto 0);
	signal ex_to_DE:						std_logic_vector(5 downto 0);
	signal ext,Rsrc2,Rsrc1:					std_logic_vector(31 downto 0);

	-----------> EXECUTE Signals <-------------
	signal RDST1_NUM, RDST2_NUM:		std_logic_vector(2 downto 0);
	signal FLAG_REG:					std_logic_vector(3 downto 0);
	signal EX_RESULT1, EX_RESULT2:		std_logic_vector(31 downto 0);

	-----------> MEMORY Signals <--------------
	SIGNAL DATA_MEM_RD_DONE, DATA_MEM_WRT_DONE, DATA_MEM_RD_ENABLE, DATA_MEM_WRT_ENABLE:	STD_LOGIC;
	SIGNAL DATA_MEM_DATAOUT, DATA_MEM_DATAIN :												STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL DATA_MEM_ADD:																	STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL MEMORY_FLAG_DONE, MEMORY_PC_DONE, MEMORY_DONE:									STD_LOGIC;
	SIGNAL MEMORY_PC_OUT, MEMORY_RESULT:													STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL MEMORY_FLAG_REGISTER:															STD_LOGIC_VECTOR(3 DOWNTO 0);

	----------> WRITEBACK Signals <------------
	signal mem_result_in,alu_result,result:				std_logic_vector(31 downto 0);
	signal wb:											std_logic_vector(4 downto 0);
	signal dst1_num_in,dst2_num_in:						std_logic_vector(2 downto 0);

	signal dst1_result,dst2_result, mem_result:			std_logic_vector(31 downto 0);
	signal dst1_en,dst2_en: 							std_logic;
	signal dst1_num,dst2_num,dst1_num_fr,dst2_num_fr:	std_logic_vector(2 downto 0);
begin

	--------------------------------------> Instruction Memory <-----------------------------------------------

	INST_MEMORY: entity work.MEMORYMODULE generic map(16) port map(CLK, INST_MEM_RD_ENABLE, '0', (others=>'0'), 
														std_logic_vector(INST_MEM_ADD), INST_MEM_RD_DONE, TMP, INST_MEM_DATA);

	-------------------------------------------> DATA Memory <-----------------------------------------------

	DATA_MEMORY: entity work.MEMORYMODULE generic map(32) port map(CLK, DATA_MEM_RD_ENABLE, DATA_MEM_WRT_ENABLE, DATA_MEM_DATAIN, 
														DATA_MEM_ADD, DATA_MEM_RD_DONE, DATA_MEM_WRT_DONE, DATA_MEM_DATAOUT);
	

	------------------------------------------> FETCH_STAGE <--------------------------------------------------
	FETCH:	entity work.FETCH_STAGE generic map(16,32,11) port map(CLK, RST, FETCH_ENABLE, INT, FETCH_DONE, PC, 
														unsigned(INST_MEM_DATA), INST_MEM_ADD, INST_MEM_RD_DONE, INST_MEM_RD_ENABLE, 
														INST1, INST2, HAVE_SRC1, HAVE_SRC2, MEMORY_PC_DONE, BRANCH_CHANGE_PC, unsigned(MEMORY_PC_OUT), unsigned(Rsrc1), 
														MEMORY_FLAG_DONE, MEMORY_FLAG_REGISTER, FETCH_FR, PC_IN_DONE, MEMORY_PC_IN);
	
	FD_IN <=  FETCH_FR & std_logic_vector(PC & INST2 & INST1 & HAVE_SRC1 & HAVE_SRC2 & FETCH_DONE & '0');

	------------------------------------------> DECODE_STAGE <--------------------------------------------------
	-- TODO: ADD GROUP_SEL1 (2 BITS) & GROUP_SEL2 (1 BIT)
	DECODE:	entity work.DECODE_STAGE port map(CLK, RST,FD_OUT(67 downto 36),FD_OUT(35 downto 4),dst1_result,dst2_result,dst1_num,dst2_num,dst1_en,dst2_en,hazard_detected,intr,FLAG_REG,
						  ext,Rsrc2,Rsrc1,BRANCH_CHANGE_PC,jz,Rsrc1_num,Rsrc2_num,Rdst_num,m_to_DE,wb_to_DE,ex_to_DE);

	DE_IN <= std_logic_vector( "000" & FD_OUT(1) & FD_OUT(71 DOWNTO 68) & m_to_DE(2 downto 0) & jz & FD_OUT(67 downto 36) & ext & Rsrc1 & Rsrc2 & Rsrc1_num & Rsrc2_num & Rdst_num & ex_to_DE & m_to_DE(6 downto 3) & wb_to_DE);

	------------------------------------------> EXECUTE_STAGE <--------------------------------------------------

	EXECUTE: entity work.EXECUTE_STAGE port map(DE_OUT(159 DOWNTO 156), DE_OUT(87 downto 56), DE_OUT(55 downto 24), DE_OUT(119 downto 88),
												DE_OUT(23 downto 21), DE_OUT(20 downto 18), DE_OUT(17 downto 15),
												DE_OUT(4 downto 0), DE_OUT(14 downto 9), RST, INT, DE_OUT(152), INPUT_PORT,
												OUTPUT_PORT, RDST1_NUM, RDST2_NUM, FLAG_REG, EX_RESULT1, EX_RESULT2);

	EM_IN <= std_logic_vector( '0' & DE_OUT(160) & DE_OUT(155 DOWNTO 153) & DE_OUT(151 downto 120) & FLAG_REG & DE_OUT(119 downto 88)  & EX_RESULT1 & EX_RESULT2
								& RDST1_NUM & RDST2_NUM & DE_OUT(8 downto 0) );
	
	-------------------------------------------> MEMORY_STAGE <--------------------------------------------------
	
	MEMORY: entity work.MEMORY_STAGE port map(CLK, RST, INT, EM_OUT(150), PC_IN_DONE, MEMORY_PC_IN, EM_OUT(146 downto 115), EM_OUT(110 downto 79), EM_OUT(78 downto 47),
								EM_OUT(8 downto 5), EM_OUT(149 downto 148), EM_OUT(147), EM_OUT(114 downto 111), 
								DATA_MEM_RD_DONE, DATA_MEM_WRT_DONE, DATA_MEM_DATAOUT,DATA_MEM_RD_ENABLE, DATA_MEM_WRT_ENABLE, DATA_MEM_ADD, DATA_MEM_DATAIN, 
								MEMORY_FLAG_REGISTER, MEMORY_FLAG_DONE, MEMORY_PC_OUT, MEMORY_PC_DONE, MEMORY_RESULT, MEMORY_DONE);

	MWB_IN <= STD_LOGIC_VECTOR( "000" & EM_OUT(150	) & MEMORY_PC_DONE & MEMORY_PC_OUT & MEMORY_RESULT & EM_OUT(78 DOWNTO 9) & EM_OUT(4 DOWNTO 0) );

	------------------------------------------> WRITEBACK_STAGE <------------------------------------------------
	WRITEBACK: entity work.WRITE_BACK_STAGE port map(MWB_OUT(106 downto 75),MWB_OUT(74 downto 43),MWB_OUT(42 downto 11),MWB_OUT(4 downto 0),MWB_OUT(10 downto 8),MWB_OUT(7 downto 5),
							 dst1_result,dst2_result,mem_result,dst1_en,dst2_en,dst1_num,dst2_num,dst1_num_fr,dst2_num_fr);

	---------------------------------------> Intermediate Registers <--------------------------------------------
	
	---------- FLAG_REGISTER(71 downto 68) + PC(67 downto 36) + IR(35 downto 4) + src_exist(3 downto 2) + FETCH_DONE(1) + '0'(0) ---------
	FD: entity work.Reg generic map(72) port map(CLK, RST, FETCH_DONE, FD_IN, FD_OUT);

	------ "000"(163 downto 161) + FETCH_DONE(160) + FLAG_REGISTER(159 DOWNTO 156) + GROUP1SELECTOR(155 downto 154) + GROUP2SELECTOR(153) + JZ(152) + PC(151 downto 120) -------- 
	----------- EXT(119 downto 88) + Rsrc1(87 downto 56) + Rsrc2(55 downto 24) + Rsrc1_num(23 downto 21) + Rsrc2_num(20 downto 18) + Rdst_num(17 downto 15) ------------
	----------------------- EX(14 downto 9) + M(8 downto 5) + WB(4 downto 0) --------------------------
	DE: entity work.Reg generic map(164) port map(CLK, RST, DE_ENABLE, DE_IN, DE_OUT);

	---------- '0'(151) + FETCH_DONE(150) + GROUP1SELECTOR(149 downto 148) + GROUP2SELECTOR(147) + PC(146 downto 115) + FR(114 downto 111) + EXT(110 downto 79) + EX1_RESUT(78 downto 47) ---------
	------------------ EX2_RESUT(46 downto 15) + RDST1_NUM(14 downto 12) + RDST2_NUM(11 downto 9) ----------------------
	------------------------------------------ M(8 downto 5) + WB(4 downto 0) -------------------------------------------
	EM: entity work.Reg generic map(152) port map(CLK, RST, EM_ENABLE, EM_IN, EM_OUT);

	---------- "000"(143 downto 141) + FETCH_DONE(140) + PC_DONE(139) + PC(138 downto 107) + MEMORY_RESULT(106 downto 75) + ALU_RESULT(74 downto 43) + RESULT(42 downto 11) ---------
	---------------------------- Rdst1_Num(10 downto 8) + Rdst2_Num(7 downto 5) + WB(4 downto 0) -------------------------
	MWB: entity work.Reg generic map(144) port map(CLK, RST, FETCH_DONE, MWB_IN, MWB_OUT);






	----------------------------------------------------------> SIGNALS <---------------------------------------------------------
	
	FETCH_ENABLE <= RST OR INT OR MEMORY_DONE;			
	DE_ENABLE <= FETCH_DONE;-- OR MEMORY_DONE;
	EM_ENABLE <= FETCH_DONE;-- OR MEMORY_DONE;
	
	intr <= "00";
end CPU_ARCH;