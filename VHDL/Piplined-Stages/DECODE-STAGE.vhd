library ieee;
use ieee.std_logic_1164.all;

-- Input bits from IF/ID
--	PC 		(32 bits),	IR 		(32 bits)
--	src1_exist 	(1 bit),	src2_exist 	(1 bit)

-- Input bits from M/WB
--	dst1_num	(3 bits),	dst1_result	(32 bits),	dst1_Enable	(1 bit)
--	dst2_num	(3 bits),	dst2_result	(32 bits),	dst2_Enable	(1 bit)


-- Input bits from others
--	rst		(1 bit),	zero_flag	(1 bit),	
--	interrupt	(1 bit),	hazard_detected	(1 bit)

-- Output bits to ID/IE
--	PC		(32 bits),	jz		(1 bit),	Extend		(32 bits)	
--	Rsrc2 		(32 bits),	Rsrc1 		(32 bits)
--	Rscr2_num 	(3 bits),	Rsrc1_num 	(3 bits)
--	Rdst1_num 	(3 bits),	Rdst2_num 	(3 bits)
--	WB 		(4 bits),	M 		(4 bits),	EX 		(5 bits)

-- Output bits to others
--	jump_cat,	(1 bit),	uncond_jump	(1 bit)
--	ir_hazard	(),		src_hazard	(2 bits)

entity DECODER is
port(	pc_in,ir,dst1_result,dst2_result:		in std_logic_vector(31 downto 0);
	dst1_num,dst2_num:				in std_logic_vector(2 downto 0);
	src1_exist,src2_exist,dst1_en,dst2_en:		in std_logic;
	clk, rst,intr,zero_flag,hazard_detected:	in std_logic;

	pc_out,extend,Rsrc2,Rsrc1:			out std_logic_vector(31 downto 0);
	jz,jump_cat,uncond_jump:			out std_logic;
	src_hazard:					out std_logic_vector(1 downto 0);
	Rsrc1_num,Rsrc2_num,Rdst1_num,Rdst2_num:	out std_logic_vector(2 downto 0);
	wb,m:						out std_logic_vector(3 downto 0);
	ex:						out std_logic_vector(4 downto 0)
);
end DECODER;