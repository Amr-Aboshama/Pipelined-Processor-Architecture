library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_decode is
end testbench_decode;

architecture decode_testbench of testbench_decode is

	signal dst1_en,dst2_en,jump_cat,uncond_jump,clk, rst,hazard_detected:	std_logic;
	signal intr:								std_logic_vector(1 downto 0);
	signal dst1_num,dst2_num,Rsrc1_num,Rsrc2_num,Rdst_num:			std_logic_vector(2 downto 0);
	signal flag_reg,m:							std_logic_vector(3 downto 0);
	signal wb:								std_logic_vector(4 downto 0);
	signal ex:								std_logic_vector(5 downto 0);
	signal ir,pc,dst1_result,dst2_result,ext,Rsrc2,Rsrc1:			std_logic_vector(31 downto 0);

	--constant half_clk_period : integer := 50;

begin
	u0: entity work.decode_stage port map(ir,pc,dst1_result,dst2_result,dst1_num,dst2_num,dst1_en,dst2_en,clk, rst,hazard_detected,intr,flag_reg,ext,Rsrc2,Rsrc1,jump_cat,uncond_jump,Rsrc1_num,Rsrc2_num,Rdst_num,m,wb,ex);

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
	
	--------- Test NOP ----------
	ir <= (others => '0');

	wait for 100 ns;
	
	assert (ex="000000") 	report "NOP Failed for EX" 		severity error;
	assert (m="0000") 	report "NOP Failed for MEM" 		severity error;	
	assert (wb="00000") 	report "NOP Failed for WB" 		severity error;	

	--------- Test NOT Rdst ----------
	ir <= (others => '0');
	ir(31 downto 27) <= "00001";

	wait for 100 ns;
	
	assert (ex="000001") 	report "NOT Rdst Failed for EX" 	severity error;
	assert (m="0000") 	report "NOT Rdst Failed for MEM" 	severity error;	
	assert (wb="00101") 	report "NOT Rdst Failed for WB" 	severity error;	
	assert (Rdst_num="000") report "NOT Rdst Failed for Rdst_num" 	severity error;	
	assert (Rsrc1_num="000")report "NOT Rdst Failed for Rsrc1_num" 	severity error;
		
	wait;
	end process;

end decode_testbench;