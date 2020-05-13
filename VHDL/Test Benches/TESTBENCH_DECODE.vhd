library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_decode is
end testbench_decode;

architecture decode_testbench of testbench_decode is

	signal dst1_en,dst2_en,jump_cat,uncond_jump,clk, rst,hazard_detected,jz:	std_logic;
	signal intr:									std_logic_vector(1 downto 0);
	signal dst1_num,dst2_num,Rsrc1_num,Rsrc2_num,Rdst_num:				std_logic_vector(2 downto 0);
	signal flag_reg,m:								std_logic_vector(3 downto 0);
	signal wb:									std_logic_vector(4 downto 0);
	signal ex:									std_logic_vector(5 downto 0);
	signal ir,pc,dst1_result,dst2_result,ext,Rsrc2,Rsrc1:				std_logic_vector(31 downto 0);

	--constant half_clk_period : integer := 50;

begin
	u0: entity work.decode_stage port map(clk, rst,pc,ir,dst1_result,dst2_result,dst1_num,dst2_num,dst1_en,dst2_en,hazard_detected,intr,flag_reg,ext,Rsrc2,Rsrc1,jump_cat,uncond_jump,jz,Rsrc1_num,Rsrc2_num,Rdst_num,m,wb,ex);

	--------------- process for the clock signal ---------------------
    	process
    	begin
 		clk <= '0';
 		wait for 50 ns;
		clk <= '1';
		wait for 50 ns;
    	end process;

	--------------- process for testing ---------------------
	process	
    	begin								
	
	--------------------------------- One Operand ---------------------------------
	--------- Test NOP ----------
	ir <= (others => '0');

	wait for 2 ns;
	
	assert (ex="000000") 	report "NOP Failed for EX" 					severity error;
	assert (m="0000") 	report "NOP Failed for MEM" 					severity error;	
	assert (wb="00000") 	report "NOP Failed for WB" 					severity error;	
	assert (jump_cat ='0') 	report "NOP Failed for JUMP_CATEGORY" 				severity error;	
	--assert (uncond_jump='0')report "NOP Failed for UNCONDITIONAL_JUMP" 			severity error;	

	--------- Test NOT Rdst ----------
	ir <= (others => '0');
	ir(31 downto 27) <= "00001";

	wait for 2 ns;
	
	assert (ex="000001") 	report "NOT Rdst Failed for EX" 				severity error;
	assert (m="0000") 	report "NOT Rdst Failed for MEM" 				severity error;	
	assert (wb="00101") 	report "NOT Rdst Failed for WB" 				severity error;	
	assert (Rdst_num="000") report "NOT Rdst Failed for Rdst_num" 				severity error;	
	assert (Rsrc1_num="000")report "NOT Rdst Failed for Rsrc1_num" 				severity error;
	assert (jump_cat ='0') 	report "NOT Rdst Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "NOT Rdst Failed for UNCONDITIONAL_JUMP" 		severity error;	

	--------- Test INC Rdst ----------
	ir <= (others => '0');
	ir(31 downto 21) <= "00010001001";

	wait for 2 ns;
	
	assert (ex="000010") 	report "INC Rdst Failed for EX" 				severity error;
	assert (m="0000") 	report "INC Rdst Failed for MEM" 				severity error;	
	assert (wb="00101") 	report "INC Rdst Failed for WB" 				severity error;	
	assert (Rdst_num="001") report "INC Rdst Failed for Rdst_num" 				severity error;	
	assert (Rsrc1_num="001")report "INC Rdst Failed for Rsrc1_num" 				severity error;
	assert (jump_cat ='0') 	report "INC Rdst Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "INC Rdst Failed for UNCONDITIONAL_JUMP" 		severity error;
		
	--------- Test DEC Rdst ----------
	ir <= (others => '0');
	ir(31 downto 21) <= "00011010010";

	wait for 2 ns;
	
	assert (ex="000011") 	report "DEC Rdst Failed for EX" 				severity error;
	assert (m="0000") 	report "DEC Rdst Failed for MEM" 				severity error;	
	assert (wb="00101") 	report "DEC Rdst Failed for WB" 				severity error;	
	assert (Rdst_num="010") report "DEC Rdst Failed for Rdst_num" 				severity error;	
	assert (Rsrc1_num="010")report "DEC Rdst Failed for Rsrc1_num" 				severity error;
	assert (jump_cat ='0') 	report "DEC Rdst Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "DEC Rdst Failed for UNCONDITIONAL_JUMP" 		severity error;

	--------- Test OUT Rdst ----------
	ir <= (others => '0');
	ir(31 downto 21) <= "00100000011";

	wait for 2 ns;
	
	assert (ex="010000") 	report "OUT Rdst Failed for EX" 				severity error;
	assert (m="0000") 	report "OUT Rdst Failed for MEM" 				severity error;	
	assert (wb="00000") 	report "OUT Rdst Failed for WB" 				severity error;	
	assert (Rsrc1_num="011")report "OUT Rdst Failed for Rsrc1_num" 				severity error;
	assert (jump_cat ='0') 	report "OUT Rdst Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "OUT Rdst Failed for UNCONDITIONAL_JUMP" 		severity error;

	--------- Test IN Rdst ----------
	ir <= (others => '0');
	ir(31 downto 21) <= "00101100000";

	wait for 2 ns;
	
	assert (ex="100000") 	report "IN Rdst Failed for EX" 					severity error;
	assert (m="0000") 	report "IN Rdst Failed for MEM" 				severity error;	
	assert (wb="00101") 	report "IN Rdst Failed for WB" 					severity error;	
	assert (Rdst_num="100")	report "IN Rdst Failed for Rdst_num" 				severity error;
	assert (jump_cat ='0') 	report "IN Rdst Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "IN Rdst Failed for UNCONDITIONAL_JUMP" 			severity error;
	
	--------------------------------- Two Operands ---------------------------------
	--------- Test AND Rsrc1,Rsrc2,Rdst ----------
	ir <= (others => '0');
	ir(31 downto 18) <= "01000101110111";

	wait for 2 ns;
	
	assert (ex="001000") 	report "AND Rsrc1,Rsrc2,Rdst Failed for EX" 			severity error;
	assert (m="0000") 	report "AND Rsrc1,Rsrc2,Rdst Failed for MEM" 			severity error;	
	assert (wb="00101") 	report "AND Rsrc1,Rsrc2,Rdst Failed for WB" 			severity error;	
	assert (Rsrc1_num="110")report "AND Rsrc1,Rsrc2,Rdst Failed for Rsrc1_num" 		severity error;
	assert (Rsrc2_num="111")report "AND Rsrc1,Rsrc2,Rdst Failed for Rsrc2_num" 		severity error;
	assert (Rdst_num="101")	report "AND Rsrc1,Rsrc2,Rdst Failed for Rdst_num" 		severity error;
	assert (jump_cat ='0') 	report "AND Rsrc1,Rsrc2,Rdst Failed for JUMP_CATEGORY" 		severity error;	
	--assert (uncond_jump='0')report "AND Rsrc1,Rsrc2,Rdst Failed for UNCONDITIONAL_JUMP" 	severity error;

	--------- Test OR Rsrc1,Rsrc2,Rdst ----------
	ir <= (others => '0');
	ir(31 downto 18) <= "01001000110111";

	wait for 2 ns;
	
	assert (ex="001001") 	report "OR Rsrc1,Rsrc2,Rdst Failed for EX" 			severity error;
	assert (m="0000") 	report "OR Rsrc1,Rsrc2,Rdst Failed for MEM" 			severity error;	
	assert (wb="00101") 	report "OR Rsrc1,Rsrc2,Rdst Failed for WB" 			severity error;	
	assert (Rsrc1_num="110")report "OR Rsrc1,Rsrc2,Rdst Failed for Rsrc1_num" 		severity error;
	assert (Rsrc2_num="111")report "OR Rsrc1,Rsrc2,Rdst Failed for Rsrc2_num" 		severity error;
	assert (Rdst_num="000")	report "OR Rsrc1,Rsrc2,Rdst Failed for Rdst_num" 		severity error;
	assert (jump_cat ='0') 	report "OR Rsrc1,Rsrc2,Rdst Failed for JUMP_CATEGORY" 		severity error;	
	--assert (uncond_jump='0')report "OR Rsrc1,Rsrc2,Rdst Failed for UNCONDITIONAL_JUMP" 	severity error;

	--------- Test ADD Rsrc1,Rsrc2,Rdst ----------
	ir <= (others => '0');
	ir(31 downto 18) <= "01010000110010";

	wait for 2 ns;
	
	assert (ex="001010") 	report "ADD Rsrc1,Rsrc2,Rdst Failed for EX" 			severity error;
	assert (m="0000") 	report "ADD Rsrc1,Rsrc2,Rdst Failed for MEM" 			severity error;	
	assert (wb="00101") 	report "ADD Rsrc1,Rsrc2,Rdst Failed for WB" 			severity error;	
	assert (Rsrc1_num="110")report "ADD Rsrc1,Rsrc2,Rdst Failed for Rsrc1_num" 		severity error;
	assert (Rsrc2_num="010")report "ADD Rsrc1,Rsrc2,Rdst Failed for Rsrc2_num" 		severity error;
	assert (Rdst_num="000")	report "ADD Rsrc1,Rsrc2,Rdst Failed for Rdst_num" 		severity error;
	assert (jump_cat ='0') 	report "ADD Rsrc1,Rsrc2,Rdst Failed for JUMP_CATEGORY" 		severity error;	
	--assert (uncond_jump='0')report "ADD Rsrc1,Rsrc2,Rdst Failed for UNCONDITIONAL_JUMP" 	severity error;

	--------- Test SUB Rsrc1,Rsrc2,Rdst ----------
	ir <= (others => '0');
	ir(31 downto 18) <= "01011000001010";

	wait for 2 ns;
	
	assert (ex="001011") 	report "SUB Rsrc1,Rsrc2,Rdst Failed for EX" 			severity error;
	assert (m="0000") 	report "SUB Rsrc1,Rsrc2,Rdst Failed for MEM" 			severity error;	
	assert (wb="00101") 	report "SUB Rsrc1,Rsrc2,Rdst Failed for WB" 			severity error;	
	assert (Rsrc1_num="001")report "SUB Rsrc1,Rsrc2,Rdst Failed for Rsrc1_num" 		severity error;
	assert (Rsrc2_num="010")report "SUB Rsrc1,Rsrc2,Rdst Failed for Rsrc2_num" 		severity error;
	assert (Rdst_num="000")	report "SUB Rsrc1,Rsrc2,Rdst Failed for Rdst_num" 		severity error;
	assert (jump_cat ='0') 	report "SUB Rsrc1,Rsrc2,Rdst Failed for JUMP_CATEGORY" 		severity error;	
	--assert (uncond_jump='0')report "SUB Rsrc1,Rsrc2,Rdst Failed for UNCONDITIONAL_JUMP" 	severity error;

	--------- Test SWAP Rsrc1,Rsrc2 ----------
	ir <= (others => '0');
	ir(31 downto 18) <= "01100000111000";

	wait for 2 ns;
	
	assert (ex="000100") 	report "SWAP Rsrc1,Rsrc2 Failed for EX" 			severity error;
	assert (m="0000") 	report "SWAP Rsrc1,Rsrc2 Failed for MEM" 			severity error;	
	assert (wb="00111") 	report "SWAP Rsrc1,Rsrc2 Failed for WB" 			severity error;	
	assert (Rsrc1_num="111")report "SWAP Rsrc1,Rsrc2 Failed for Rsrc1_num" 			severity error;
	assert (Rsrc2_num="000")report "SWAP Rsrc1,Rsrc2 Failed for Rsrc2_num" 			severity error;
	assert (jump_cat ='0') 	report "SWAP Rsrc1,Rsrc2 Failed for JUMP_CATEGORY" 		severity error;	
	--assert (uncond_jump='0')report "SWAP Rsrc1,Rsrc2 Failed for UNCONDITIONAL_JUMP" 	severity error;

	--------- Test IADD Rsrc1,Rdst,Imm ----------
	ir(31 downto 16) <= "0110100011100000";
	ir(15 downto 0) <= "1011010111110010";

	wait for 2 ns;
	
	assert (ex="001101") 	report "IADD Rsrc1,Rdst,Imm Failed for EX" 			severity error;
	assert (m="0000") 	report "IADD Rsrc1,Rdst,Imm Failed for MEM" 			severity error;	
	assert (wb="00101") 	report "IADD Rsrc1,Rdst,Imm Failed for WB" 			severity error;	
	assert (Rsrc1_num="111")report "IADD Rsrc1,Rdst,Imm Failed for Rsrc1_num" 		severity error;
	assert (Rdst_num="000")	report "IADD Rsrc1,Rdst,Imm Failed for Rdst_num" 		severity error;
	assert (ext = std_logic_vector(resize(signed(ir(15 downto 0)), 32)))
				report "IADD Rsrc1,Rdst,Imm Failed for EXT" 			severity error;
	assert (jump_cat ='0') 	report "IADD Rsrc1,Rdst,Imm Failed for JUMP_CATEGORY" 		severity error;	
	--assert (uncond_jump='0')report "IADD Rsrc1,Rdst,Imm Failed for UNCONDITIONAL_JUMP" 	severity error;

	--------- Test SHL Rsrc,Imm ----------
	ir(31 downto 16) <= "0111011111100000";
	ir(15 downto 0) <= "0011010111110010";

	wait for 2 ns;
	
	assert (ex="001110") 	report "SHL Rsrc,Imm Failed for EX" 				severity error;
	assert (m="0000") 	report "SHL Rsrc,Imm Failed for MEM" 				severity error;	
	assert (wb="00101") 	report "SHL Rsrc,Imm Failed for WB" 				severity error;	
	assert (Rsrc1_num="111")report "SHL Rsrc,Imm Failed for Rsrc1_num" 			severity error;
	assert (Rdst_num="111")	report "SHL Rsrc,Imm Failed for Rdst_num" 			severity error;
	assert (ext = std_logic_vector(resize(signed(ir(15 downto 0)), 32)))
				report "SHL Rsrc,Imm Failed for EXT" 				severity error;
	assert (jump_cat ='0') 	report "SHL Rsrc,Imm Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "SHL Rsrc,Imm Failed for UNCONDITIONAL_JUMP" 		severity error;


	--------- Test SHR Rsrc,Imm ----------
	ir(31 downto 16) <= "0111100100100000";
	ir(15 downto 0) <= "1011010110010010";

	wait for 2 ns;
	
	assert (ex="001111") 	report "SHR Rsrc,Imm Failed for EX" 				severity error;
	assert (m="0000") 	report "SHR Rsrc,Imm Failed for MEM" 				severity error;	
	assert (wb="00101") 	report "SHR Rsrc,Imm Failed for WB" 				severity error;	
	assert (Rsrc1_num="001")report "SHR Rsrc,Imm Failed for Rsrc1_num" 			severity error;
	assert (Rdst_num="001")	report "SHR Rsrc,Imm Failed for Rdst_num" 			severity error;
	assert (ext = std_logic_vector(resize(signed(ir(15 downto 0)), 32)))
				report "SHR Rsrc,Imm Failed for EXT" 				severity error;
	assert (jump_cat ='0') 	report "SHR Rsrc,Imm Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "SHR Rsrc,Imm Failed for UNCONDITIONAL_JUMP" 		severity error;

	--------------------------------- Memory Operations ---------------------------------
	--------- Test PUSH Rdst ----------
	ir <= (others => '0');
	ir(31 downto 21) <= "10000000001";
	
	wait for 2 ns;
	
	assert (ex="000100") 	report "PUSH Rdst Failed for EX" 				severity error;
	assert (m="0101") 	report "PUSH Rdst Failed for MEM" 				severity error;	
	assert (wb="00000") 	report "PUSH Rdst Failed for WB" 				severity error;	
	assert (Rsrc1_num="001")report "PUSH Rdst Failed for Rsrc1_num" 			severity error;
	assert (jump_cat ='0') 	report "PUSH Rdst Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "PUSH Rdst Failed for UNCONDITIONAL_JUMP" 		severity error;

	--------- Test POP Rdst ----------
	ir <= (others => '0');
	ir(31 downto 21) <= "10001000001";
	
	wait for 2 ns;
	
	assert (ex="000000") 	report "POP Rdst Failed for EX" 				severity error;
	assert (m="1000") 	report "POP Rdst Failed for MEM" 				severity error;	
	assert (wb="00100") 	report "POP Rdst Failed for WB" 				severity error;	
	assert (Rsrc1_num="001")report "POP Rdst Failed for Rsrc1_num" 				severity error;
	assert (jump_cat ='0') 	report "POP Rdst Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "POP Rdst Failed for UNCONDITIONAL_JUMP" 		severity error;

	--------- Test STD Rsrc,EA ----------
	ir(31 downto 20) <= "101010000010";
	ir(19 downto 0)  <= "10100011001101011011";
	
	wait for 2 ns;
	
	assert (ex="000100") 	report "STD Rsrc,EA Failed for EX" 				severity error;
	assert (m="0111") 	report "STD Rsrc,EA Failed for MEM" 				severity error;	
	assert (wb="00000") 	report "STD Rsrc,EA Failed for WB" 				severity error;	
	assert (Rsrc1_num="001")report "STD Rsrc,EA Failed for Rsrc1_num" 			severity error;
	assert (ext = std_logic_vector(resize(signed(ir(19 downto 0)), 32)))
				report "STD Rsrc,EA Failed for EXT" 				severity error;
	assert (jump_cat ='0') 	report "STD Rsrc,EA Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "STD Rsrc,EA Failed for UNCONDITIONAL_JUMP" 		severity error;

	--------- Test LDD Rsrc,EA ----------
	ir(31 downto 20) <= "101100000010";
	ir(19 downto 0)  <= "10100011001101011011";
	
	wait for 2 ns;
	
	assert (ex="000000") 	report "LDD Rsrc,EA Failed for EX" 				severity error;
	assert (m="1011") 	report "LDD Rsrc,EA Failed for MEM" 				severity error;	
	assert (wb="00100") 	report "LDD Rsrc,EA Failed for WB" 				severity error;	
	assert (Rdst_num="000")report "LDD Rsrc,EA Failed for Rsrc1_num" 			severity error;
	assert (ext = std_logic_vector(resize(signed(ir(19 downto 0)), 32)))
				report "LDD Rsrc,EA Failed for EXT" 				severity error;
	assert (jump_cat ='0') 	report "LDD Rsrc,EA Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "LDD Rsrc,EA Failed for UNCONDITIONAL_JUMP" 		severity error;

	--------- Test LDM Rdst,Imm ----------
	ir(31 downto 16) <= "1011100100100000";
	ir(15 downto 0)  <= "1010001101011011";
	
	wait for 2 ns;
	
	assert (ex="000000") 	report "LDM Rdst,Imm Failed for EX" 				severity error;
	assert (m="0011") 	report "LDM Rdst,Imm Failed for MEM" 				severity error;	
	assert (wb="00001") 	report "LDM Rdst,Imm Failed for WB" 				severity error;	
	assert (Rdst_num="001") report "LDM Rdst,Imm Failed for Rsrc1_num" 			severity error;
	assert (ext = std_logic_vector(resize(signed(ir(15 downto 0)), 32)))
				report "LDM Rdst,Imm Failed for EXT" 				severity error;
	assert (jump_cat ='0') 	report "LDM Rsrc,EA Failed for JUMP_CATEGORY" 			severity error;	
	--assert (uncond_jump='0')report "LDM Rsrc,EA Failed for UNCONDITIONAL_JUMP" 		severity error;

	--------------------------------- Branch Operations ---------------------------------
	--------- Test JZ Rdst ----------
	ir <= (others => '0');
	ir(31 downto 21) <= "11000000001";
	
	wait for 2 ns;
	
	assert (ex="000100") 	report "JZ Rdst Failed for EX" 					severity error;
	assert (m="0000") 	report "JZ Rdst Failed for MEM" 				severity error;	
	assert (wb="01000") 	report "JZ Rdst Failed for WB" 					severity error;	
	assert (Rsrc1_num="001")report "JZ Rdst Failed for Rsrc1_num" 				severity error;
	assert (jump_cat = '1') report "JZ Rdst Failed for JUMP_CATEGORY" 			severity error;	
	assert (uncond_jump='0')report "JZ Rdst Failed for UNCONDITIONAL_JUMP" 			severity error;

	--------- Test JMP Rdst ----------
	ir <= (others => '0');
	ir(31 downto 21) <= "11001000001";
	
	wait for 2 ns;
	
	assert (ex="000100") 	report "JMP Rdst Failed for EX" 				severity error;
	assert (m="0000") 	report "JMP Rdst Failed for MEM" 				severity error;	
	assert (wb="11000") 	report "JMP Rdst Failed for WB" 				severity error;	
	assert (Rsrc1_num="001")report "JMP Rdst Failed for Rsrc1_num" 				severity error;
	assert (jump_cat='1') 	report "JMP Rdst Failed for JUMP_CATEGORY" 			severity error;	
	assert (uncond_jump='1')report "JMP Rdst Failed for UNCONDITIONAL_JUMP" 		severity error;

	--------- Test CALL Rdst ----------
	ir <= (others => '0');
	ir(31 downto 21) <= "11010000001";
	
	wait for 2 ns;
	
	assert (ex="000100") 	report "CALL Rdst Failed for EX" 				severity error;
	assert (m="0101") 	report "CALL Rdst Failed for MEM" 				severity error;	
	assert (wb="11000") 	report "CALL Rdst Failed for WB" 				severity error;	
	assert (Rsrc1_num="001")report "CALL Rdst Failed for Rsrc1_num" 			severity error;
	assert (jump_cat='1') 	report "CALL Rdst Failed for JUMP_CATEGORY" 			severity error;	
	assert (uncond_jump='1')report "CALL Rdst Failed for UNCONDITIONAL_JUMP" 		severity error;

	--------- Test RET ----------
	ir <= (others => '0');
	ir(31 downto 27) <= "11011";
	
	wait for 2 ns;
	
	assert (ex="000000") 	report "RET Failed for EX" 					severity error;
	assert (m="1000") 	report "RET Failed for MEM" 					severity error;	
	assert (wb="11000") 	report "RET Failed for WB" 					severity error;	
	assert (jump_cat='1') 	report "RET Failed for JUMP_CATEGORY" 				severity error;	
	assert (uncond_jump='1')report "RET Failed for UNCONDITIONAL_JUMP" 			severity error;

	--------- Test RTI ----------
	ir <= (others => '0');
	ir(31 downto 27) <= "11100";
	
	wait for 2 ns;
	
	assert (ex="000000") 	report "RTI Failed for EX" 					severity error;
	assert (m="1000") 	report "RTI Failed for MEM" 					severity error;	
	assert (wb="11000") 	report "RTI Failed for WB" 					severity error;	
	assert (jump_cat='1') 	report "RTI Failed for JUMP_CATEGORY" 				severity error;	
	assert (uncond_jump='1')report "RTI Failed for UNCONDITIONAL_JUMP" 			severity error;

	--------------------------------- Register File ---------------------------------
	--------- Load Values in R0 and R1 ----------
	dst1_num 	<= "000";
	dst1_result	<= std_logic_vector(to_signed(50, 32));
	dst1_en		<= '1';

	dst2_num 	<= "001";
	dst2_result	<= std_logic_vector(to_signed(-40, 32));
	dst2_en		<= '1';

	wait for 100 ns;

	--------- Load Value in R2 and keep R1 Value ----------
	dst1_num 	<= "010";
	dst1_result	<= std_logic_vector(to_signed(-14, 32));

	dst2_num 	<= "001";
	dst2_result	<= std_logic_vector(to_signed(60, 32));
	dst2_en		<= '0';

	wait for 100 ns;

	--------- Load Values in R3 to R7 and keep R0 to R2 Values ----------
	dst1_num 	<= "011";
	dst1_result	<= std_logic_vector(to_signed(15, 32));

	dst2_num 	<= "100";
	dst2_result	<= std_logic_vector(to_signed(-994, 32));
	dst2_en		<= '1';
	
	wait for 100 ns;

	dst1_num 	<= "101";
	dst1_result	<= std_logic_vector(to_signed(1, 32));

	dst2_num 	<= "110";
	dst2_result	<= std_logic_vector(to_signed(2, 32));

	wait for 100 ns;

	dst1_num 	<= "111";
	dst1_result	<= std_logic_vector(to_signed(11, 32));

	wait for 100 ns;

	dst1_en		<= '0';
	dst2_en		<= '0';	

	--------- Test Values in Registers R0 and R1 ----------
	ir(23 downto 21)<= "000";
	intr 		<= "00";
	
	ir(20 downto 18)<= "001";

	wait for 2 ns;
	
	assert (Rsrc1=std_logic_vector(to_signed(50, 32)))
				report "Keeping Value in R0 Failed" 				severity error;
	assert (Rsrc2=std_logic_vector(to_signed(-40, 32)))
				report "Keeping Value in R1 Failed" 				severity error;

	--------- Test Values in Registers R2 and R3 ----------
	ir(23 downto 21)<= "010";
	intr 		<= "00";
	
	ir(20 downto 18)<= "011";

	wait for 2 ns;

	assert (Rsrc1=std_logic_vector(to_signed(-14, 32)))
				report "Keeping Value in R2 Failed" 				severity error;
	assert (Rsrc2=std_logic_vector(to_signed(15, 32)))
				report "Loading Value in R3 Failed" 				severity error;

	--------- Test Values in Registers R4 and R5 ----------
	ir(23 downto 21)<= "100";
	intr 		<= "00";
	
	ir(20 downto 18)<= "101";

	wait for 2 ns;

	assert (Rsrc1=std_logic_vector(to_signed(-994, 32)))
				report "Loading Value in R4 Failed" 				severity error;
	assert (Rsrc2=std_logic_vector(to_signed(1, 32)))
				report "Loading Value in R5 Failed" 				severity error;

	--------- Test Values in Registers R6 and R7 ----------
	ir(23 downto 21)<= "110";
	intr 		<= "00";
	
	ir(20 downto 18)<= "111";

	wait for 2 ns;

	assert (Rsrc1=std_logic_vector(to_signed(2, 32)))
				report "Loading Value in R6 Failed" 				severity error;
	assert (Rsrc2=std_logic_vector(to_signed(11, 32)))
				report "Loading Value in R7 Failed" 				severity error;

	--------- Test Reset for R3 ----------
	rst 		<= '1';
	ir(23 downto 21)<= "011";
	intr 		<= "00";

	wait for 100 ns;

	assert (Rsrc1=std_logic_vector(to_signed(0, 32)))
				report "Reset Values in Registers Failed" 			severity error;

	wait for 100 ns;
	wait;
	end process;

end decode_testbench;