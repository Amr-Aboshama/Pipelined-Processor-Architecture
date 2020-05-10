library ieee;
use ieee.std_logic_1164.all;

-- Input bits from M/WB
--	mem_result_in 	(32 bits)
--	alu_result 	(32 bits),	Rdst1_num_in 	(3 bit)
--	result		(32 bits),	Rdst2_num_in	(3 bit)
--	wb		(5 bits)

-- Output bits to Decode_Stage
--	Rdst1_result	(32 bits),	Rdst1_num	(3 bits),	Enable_Rdst1	(1 bit)
--	Rdst2_result	(32 bits),	Rdst2_num	(3 bits),	Enable_Rdst2	(1 bit)

-- Output bits to Fetch_Stage
--	mem_result 	(32 bits)

-- Output bits to Forwarding_Unit
--	Rdst1_num_fr 	(3 bits)

entity write_back_stage is
port(	mem_result_in,alu_result,result:		in std_logic_vector(31 downto 0);
	wb:						in std_logic_vector(4 downto 0);
	Rdst1_num_in,Rdst2_num_in:			in std_logic_vector(2 downto 0);

	Rdst1_result,Rdst2_result,mem_result:		out std_logic_vector(31 downto 0);
	Enable_Rdst1,Enable_Rdst2:			out std_logic;
	Rdst1_num,Rdst2_num,Rdst1_num_fr:			out std_logic_vector(2 downto 0)
);
end write_back_stage;

architecture write_back of write_back_stage is
begin

end architecture;