library ieee;
use ieee.std_logic_1164.all;

-- Input bits from IF/ID
--	IR 		(32 bits),	src1_exist 	(1 bit),	src2_exist 	(1 bit)

-- Input bits from M/WB
--	dst1_num	(3 bits),	dst1_result	(32 bits),	dst1_Enable	(1 bit)
--	dst2_num	(3 bits),	dst2_result	(32 bits),	dst2_Enable	(1 bit)


-- Input bits from others
--	rst		(1 bit),	zero_flag	(1 bit),	
--	interrupt	(1 bit),	hazard_detected	(1 bit)

-- Output bits to ID/IE
--	Extend		(32 bits)	
--	Rsrc2 		(32 bits),	Rsrc1 		(32 bits)
--	Rscr2_num 	(3 bits),	Rsrc1_num 	(3 bits)
--	Rdst1_num 	(3 bits),	Rdst2_num 	(3 bits)
--	WB 		(5 bits),	M 		(4 bits),	EX 		(6 bits)

-- Output bits to others
--	jump_cat,	(1 bit),	uncond_jump	(1 bit)
--	ir_hazard	(),		src_hazard	(2 bits)

entity decode_stage is
port(	ir,dst1_result,dst2_result:			in std_logic_vector(31 downto 0);
	dst1_num,dst2_num:				in std_logic_vector(2 downto 0);
	enable,src1_exist,src2_exist,dst1_en,dst2_en:	in std_logic;
	clk, rst,intr,zero_flag,hazard_detected:	in std_logic;

	extend,Rsrc2,Rsrc1:				out std_logic_vector(31 downto 0);
	jump_cat,uncond_jump:			out std_logic;
	src_hazard:					out std_logic_vector(1 downto 0);
	Rsrc1_num,Rsrc2_num,Rdst1_num,Rdst2_num:	out std_logic_vector(2 downto 0);
	m:						out std_logic_vector(3 downto 0);
	wb:						out std_logic_vector(4 downto 0);
	ex:						out std_logic_vector(5 downto 0)
);
end decode_stage;

architecture decode of decode_stage is
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
	ex(5) <= 	  '1' when ir(31 downto 27) = "00100"				else	--IN
			  '0';

	ex(4 downto 0) <= "10000" when ir(31 downto 27) = "11000"			else	--JZ
			  ir(31 downto 27) when 
			  (ir(31 downto 30) = "01" and ir(29 downto 27) /= "100") or 	 	--AND, OR, ADD, SUB, IADD, SHL or SHR
			  (ir(31 downto 30) = "00" and ((ir(29) xor ir(28))='1') and 
			  				((ir(29) xor ir(28))='1')) 	else 	--NOT, INC or DEC
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
		"00101" when	( ir(31 downto 30) = "00" and 
				  ir(28 downto 27) /= "00" ) or		--NOT or INC or DEC or IN 
				( ir(31 downto 30) = "01" and 
				  ir(29 downto 27) /= "100" )	else	--AND or OR or ADD or SUB or IADD or SHL or SHR
		"00100" when	ir(31 downto 27) = "10001" or		--POP
				ir(31 downto 27) = "10110"	else	--LDD
		"00001" when	ir(31 downto 27) = "10111"	else	--LDM
		"01000" when	ir(31 downto 27) = "11000"	else	--JZ
		"11000" when	ir(31 downto 30) = "11" and 
				ir(29 downto 27) /= "000"	else	--JMP or CALL or RET or RTI
		"00000";
		

end decode;
