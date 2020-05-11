library ieee;
use ieee.std_logic_1164.all;

-- Input bits from M/WB
--	mem_result_in 	(32 bits)
--	alu_result 	(32 bits),	dst1_num_in 	(3 bit)
--	result		(32 bits),	dst2_num_in	(3 bit)
--	wb		(5 bits)

-- Output bits to Register File in Decode_Stage
--	dst1_result	(32 bits),	dst1_num	(3 bits),	dst1_en	(1 bit)
--	dst2_result	(32 bits),	dst2_num	(3 bits),	dst2_en	(1 bit)

-- Output bits to Fetch_Stage
--	mem_result 	(32 bits)

-- Output bits to Forwarding_Unit
--	dst1_num_fr 	(3 bits),	dst2_num_fr 	(3 bits)

entity write_back_stage is
port(	mem_result_in,alu_result,result:		in std_logic_vector(31 downto 0);
	wb:						in std_logic_vector(4 downto 0);
	dst1_num_in,dst2_num_in:			in std_logic_vector(2 downto 0);

	dst1_result,dst2_result,mem_result:		out std_logic_vector(31 downto 0);
	dst1_en,dst2_en:				out std_logic;
	dst1_num,dst2_num,dst1_num_fr,dst2_num_fr:	out std_logic_vector(2 downto 0)
);
end write_back_stage;

architecture write_back of write_back_stage is
begin
	-------- Output to Register File in Decode_Stage -----------
	dst1_num 	<=	dst1_num_in;
	dst2_num 	<=	dst2_num_in;
	
	dst1_en 	<=	wb(2);
	dst2_en	<=	wb(1);
	
	dst1_result	<=	mem_result_in when wb(0)='0' else
				alu_result;
	dst2_result	<=	result;

	----------------- Output to Fetch_Stage --------------------
	mem_result	<=	mem_result_in;

	--------------- Output to Forwarding_Unit ------------------
	dst1_num_fr	<=	dst1_num_in;
	dst2_num_fr	<=	dst2_num_in;
	
end architecture;