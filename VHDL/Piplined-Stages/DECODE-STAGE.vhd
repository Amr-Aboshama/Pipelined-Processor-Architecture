library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Input bits from IF/ID
--	ir 		(32 bits),	pc 		(32 bits)	
--	src1_exist 	(1 bit),	src2_exist 	(1 bit)

-- Input bits from M/WB
--	dst1_num	(3 bits),	dst1_result	(32 bits),	dst1_Enable	(1 bit)
--	dst2_num	(3 bits),	dst2_result	(32 bits),	dst2_Enable	(1 bit)


-- Input bits from others
--	rst		(1 bit),	flag_reg	(4 bit),	
--	interrupt	(1 bit),	hazard_detected	(1 bit)

-- Output bits to ID/IE
--	ext		(32 bits)	
--	Rsrc2 		(32 bits),	Rsrc1 		(32 bits)
--	Rscr2_num 	(3 bits),	Rsrc1_num 	(3 bits)
--	Rdst_num 	(3 bits),
--	WB 		(5 bits),	M 		(4 bits),	EX 		(6 bits)

-- Output bits to others
--	jump_cat,	(1 bit),	uncond_jump	(1 bit)

entity decode_stage is
port(	ir,pc,dst1_result,dst2_result:			in std_logic_vector(31 downto 0);
	dst1_num,dst2_num:				in std_logic_vector(2 downto 0);
	dst1_en,dst2_en:				in std_logic;
	clk, rst,hazard_detected:			in std_logic;
	intr:						in std_logic_vector(1 downto 0);
	flag_reg:					in std_logic_vector(3 downto 0);

	ext,Rsrc2,Rsrc1:				out std_logic_vector(31 downto 0);
	jump_cat,uncond_jump:				out std_logic;
	Rsrc1_num,Rsrc2_num,Rdst_num:			out std_logic_vector(2 downto 0);
	m:						out std_logic_vector(3 downto 0);
	wb:						out std_logic_vector(4 downto 0);
	ex:						out std_logic_vector(5 downto 0)
);
end decode_stage;

architecture decode of decode_stage is
	signal Rsrc1_temp: std_logic_vector(31 downto 0);
	signal R0,R1,R2,R3,R4,R5,R6,R7: std_logic_vector(31 downto 0);
	signal R0_in,R1_in,R2_in,R3_in,R4_in,R5_in,R6_in,R7_in: std_logic_vector(31 downto 0);
	signal en0,en1,en2,en3,en4,en5,en6,en7: std_logic;

	constant ZERO : std_logic_vector(31 downto 0) := (others => '0');
begin

--    	ex <= 	"100000" when 	ir(31 downto 27) = "00100"	else	--IN
--		"000001" when 	ir(31 downto 27) = "00001"	else	--NOT
--		"000010" when 	ir(31 downto 27) = "00010"	else	--INC
--		"000011" when	ir(31 downto 27) = "00011"	else	--DEC
--
--		"001000" when	ir(31 downto 27) = "01000"	else	--AND
--		"001001" when	ir(31 downto 27) = "01001"	else	--OR
--		"001010" when	ir(31 downto 27) = "01010"	else	--ADD
--		"001011" when 	ir(31 downto 27) = "01011"	else	--SUB
--		"001101" when	ir(31 downto 27) = "01101"	else 	--IADD
--		"001110" when 	ir(31 downto 27) = "01110"	else	--SHL
--		"001111" when	ir(31 downto 27) = "01111"	else	--SHR
--
--		"010000" when	ir(31 downto 27) = "11000"	else	--JZ
--		"000000";
--
----------------------------------- Decoding Circuit ----------------------------------------------
	ex(5) <= 	  '1' when ir(31 downto 27) = "00100"				else	--IN
			  '0';

	ex(4 downto 0) <= "10000" when ir(31 downto 27) = "11000"			else	--JZ
			  ir(31 downto 27) when 
			  (ir(31 downto 30) = "01" and ir(29 downto 27) /= "100") or 	 	--AND - OR - ADD - SUB - IADD - SHL - SHR
			  (ir(31 downto 29) = "000" and ((ir(28) or ir(27))='1')) 	else 	--NOT - INC - DEC
			  "00000";

 	m <= 	"0101" when 	ir(31 downto 27) = "10000" or 		--PUSH
				ir(31 downto 27) = "11010" 	else	--CALL
		"1000" when 	ir(31 downto 27) = "10001" or 		--POP
				ir(31 downto 27) = "11011" or 		--RET
				ir(31 downto 27) = "11100"	else	--RTI
		"0111" when 	ir(31 downto 27) = "10101"	else	--STD
		"1011" when	ir(31 downto 27) = "10110"	else	--LDD
		"0011" when	ir(31 downto 27) = "10111"	else	--LDM
		"0000";
	
	wb <=	"00111" when	ir(31 downto 27) = "01100"	else	--SWAP
		"00101" when	(ir(31 downto 30) = "00" and 
				  ir(28 downto 27) /= "00") or		--NOT - INC - DEC - IN 
				(ir(31 downto 30) = "01" and 
				  ir(29 downto 27) /= "100" )	else	--AND - OR - ADD - SUB - IADD - SHL - SHR
		"00100" when	ir(31 downto 27) = "10001" or		--POP
				ir(31 downto 27) = "10110"	else	--LDD
		"00001" when	ir(31 downto 27) = "10111"	else	--LDM
		"01000" when	ir(31 downto 27) = "11000"	else	--JZ
		"11000" when	ir(31 downto 30) = "11" and 
				ir(29 downto 27) /= "000"	else	--JMP - CALL - RET - RTI
		"00000";
		
	ext <=	std_logic_vector(resize(signed(ir(15 downto 0)), 32))  when 		--Immediate
			(ir(31 downto 29) = "011" and ((ir(28) or ir(27))='1')) or	--IADD - SHL - SHR
			ir(31 downto 27) = "10111"	else				--LDM
		std_logic_vector(resize(signed(ir(19 downto 0)), 32))  when			--EA 
			ir(31 downto 27) = "10101" or ir(31 downto 27) = "10110" else	--STD - LDD
		zero;

	jump_cat <=	'1' when ir(31 downto 30) = "11" else	--JZ - JMP - CALL - RET - RTI
			'0';

	uncond_jump <=	'0' when ir(29 downto 27) = "000" else	--JZ
			'1';

---------------------------------- Register File -----------------------------------------------------------
	u0: entity work.Reg port map(clk,rst,en0,R0_in,R0);
	u1: entity work.Reg port map(clk,rst,en1,R1_in,R1);
	u2: entity work.Reg port map(clk,rst,en2,R2_in,R2);
	u3: entity work.Reg port map(clk,rst,en3,R3_in,R3);
	u4: entity work.Reg port map(clk,rst,en4,R4_in,R4);
	u5: entity work.Reg port map(clk,rst,en5,R5_in,R5);
	u6: entity work.Reg port map(clk,rst,en6,R6_in,R6);
	u7: entity work.Reg port map(clk,rst,en7,R7_in,R7);


	Rdst_num  <= ir(26 downto 24);
	Rsrc1_num <= ir(23 downto 21);
	Rsrc2_num <= ir(20 downto 18);
	
	Rsrc1_temp <= 	R0 when ir(23 downto 21) = "000" else
			R1 when ir(23 downto 21) = "001" else
			R2 when ir(23 downto 21) = "010" else
			R3 when ir(23 downto 21) = "011" else
			R4 when ir(23 downto 21) = "100" else
			R5 when ir(23 downto 21) = "101" else
			R6 when ir(23 downto 21) = "110" else
			R7;

	Rsrc2 <= 	R0 when ir(20 downto 18) = "000" else
			R1 when ir(20 downto 18) = "001" else
			R2 when ir(20 downto 18) = "010" else
			R3 when ir(20 downto 18) = "011" else
			R4 when ir(20 downto 18) = "100" else
			R5 when ir(20 downto 18) = "101" else
			R6 when ir(20 downto 18) = "110" else
			R7;
------- to handle interrupt -------
	Rsrc1 <=	Rsrc1_temp 	when intr = "00" else
			zero(27 downto 0) & flag_reg 	when intr = "01" else
			pc 		when intr = "10" else
			zero; 
			

	R0_in <= 	dst1_result when dst1_num = "000" else
			dst2_result when dst2_num = "000" else
			(others => '0');

	R1_in <= 	dst1_result when dst1_num = "001" else
			dst2_result when dst2_num = "001" else
			(others => '0');

	R2_in <= 	dst1_result when dst1_num = "010" else
			dst2_result when dst2_num = "010" else
			(others => '0');

	R3_in <= 	dst1_result when dst1_num = "011" else
			dst2_result when dst2_num = "011" else
			(others => '0');

	R4_in <= 	dst1_result when dst1_num = "100" else
			dst2_result when dst2_num = "100" else
			(others => '0');

	R5_in <= 	dst1_result when dst1_num = "101" else
			dst2_result when dst2_num = "101" else
			(others => '0');

	R6_in <= 	dst1_result when dst1_num = "110" else
			dst2_result when dst2_num = "110" else
			(others => '0');

	R7_in <= 	dst1_result when dst1_num = "111" else
			dst2_result when dst2_num = "111" else
			(others => '0');

	en0 <=		'1' when (dst1_num = "000" and dst1_en = '1') or
				 (dst2_num = "000" and dst2_en = '1') else
			'0';
	
	en1 <=		'1' when (dst1_num = "001" and dst1_en = '1') or
				 (dst2_num = "001" and dst2_en = '1') else
			'0';

	en2 <=		'1' when (dst1_num = "010" and dst1_en = '1') or
				 (dst2_num = "010" and dst2_en = '1') else
			'0';

	en3 <=		'1' when (dst1_num = "011" and dst1_en = '1') or
				 (dst2_num = "011" and dst2_en = '1') else
			'0';

	en4 <=		'1' when (dst1_num = "100" and dst1_en = '1') or
				 (dst2_num = "100" and dst2_en = '1') else
			'0';

	en5 <=		'1' when (dst1_num = "101" and dst1_en = '1') or
				 (dst2_num = "101" and dst2_en = '1') else
			'0';

	en6 <=		'1' when (dst1_num = "110" and dst1_en = '1') or
				 (dst2_num = "110" and dst2_en = '1') else
			'0';

	en7 <=		'1' when (dst1_num = "111" and dst1_en = '1') or
				 (dst2_num = "111" and dst2_en = '1') else
			'0';

end decode;