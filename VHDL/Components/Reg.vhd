library ieee ;
use ieee.std_logic_1164.all;

entity reg is
	generic(n: natural :=32);
	port(	clk,rst,en: 	in std_logic;
		I:		in std_logic_vector(n-1 downto 0);
		Q:		out std_logic_vector(n-1 downto 0)
);
end reg;

architecture arch of reg is

    signal Q_tmp: std_logic_vector(n-1 downto 0);

begin

    process(clk, rst)
    begin
	if rst = '1' then 
            Q_tmp <= (others => '0');
	elsif (clk='1' and clk'event) then
	    if en = '1' then
		Q_tmp <= I; 
	    end if;
	end if;
    end process;

    Q <= Q_tmp;

end arch;
