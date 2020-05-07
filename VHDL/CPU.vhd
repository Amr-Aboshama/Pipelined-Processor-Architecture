library ieee ;
use ieee.std_logic_1164.all;

entity cpu is
	port(	clk,rst,intr: 	in std_logic
	    
	);
end cpu;

architecture cpu_arch of cpu is
	signal FD_en,DE_en: std_logic;
	signal FD_in,FD_out: std_logic_vector(65 downto 0);
	signal DE_in,DE_out: std_logic_vector(151 downto 0);
begin
	---------- PC(32 bits) + IR(32 bits) + src_exist(2 bits) ---------
	FD: entity work.Reg generic map(66) port map(clk,rst,FD_en,FD_in,FD_out);

	------ PC(32 bits) + EXT(32 bits) + Rsrc1(32 bits) + Rsrc2(32 bits) + Rsrc1_num(3 bits) -------------------
	------ + Rsrc2_num(3 bits) + Rdst_num(3 bits) + EX(6 bits) + M(4 bits) + WB(5 bits) --------------------------
	DE: entity work.Reg generic map(152) port map(clk,rst,DE_en,DE_in,DE_out);

end cpu_arch;
