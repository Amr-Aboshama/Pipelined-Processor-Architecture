library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FETCH_STAGE is
    generic(
        INST_WIDTH: integer := 16;
        DATA_WIDTH: integer := 32;
        ADDRESS_WIDTH:  integer := 11
    );
    port (
        CLK, RST, ENABLE, INT:    IN  std_logic;
        WRITE_REG:  OUT std_logic;
        PC_OUT: OUT unsigned(DATA_WIDTH-1 downto 0) ;
        MEM_DATA:   IN  unsigned(INST_WIDTH-1 downto 0);
        MEM_ADD:    OUT unsigned(ADDRESS_WIDTH-1 downto 0);
        MEM_RD_DONE:     IN  std_logic;
        MEM_RD_ENABLE:    OUT  std_logic;
        INST1, INST2:  OUT unsigned(INST_WIDTH-1 downto 0);
        HAVE_SRC1, HAVE_SRC2: OUT std_logic;
        CHANGE_PC:  IN std_logic;
        NEW_PC: IN unsigned(DATA_WIDTH-1 downto 0)
    );
end FETCH_STAGE;

architecture FETCH of FETCH_STAGE is
    signal PC: unsigned(DATA_WIDTH-1 downto 0) := (others=>'0');
    signal OPCODE: unsigned(4 downto 0) := (others=>'0');
    signal STALL_REG: std_logic;
begin


    PC_OUT <= PC;
    HAVE_SRC2 <= '1' when   OPCODE(4 downto 2) = "010"
                        else '0';
                        
    HAVE_SRC1 <= '1' when   (OPCODE(4 downto 3) = "00" and ( OPCODE(1) or (OPCODE(2) xor OPCODE(0)) ) = '1')   -- B | (A^C)
                        or  OPCODE(4 downto 3) = "01"
                        or  (OPCODE(4 downto 3) = "10" and ( (NOT OPCODE(1)) and (OPCODE(2) or (NOT OPCODE(0))) ) = '1')   -- !B & (A|!C) 
                        or  (OPCODE(4 downto 2) = "110" and (NOT (OPCODE(1) and OPCODE(0))) ='1')
                        else '0';

    WRITE_REG <= NOT STALL_REG;

    MAIN: process( CLK, RST, INT )
    
        variable counter: integer;

    begin
        if(ENABLE='1')  then
            

            if(RST'event) then
                counter := 0;
                MEM_ADD <= to_unsigned(0,ADDRESS_WIDTH);
            elsif(INT='1' and STALL_REG='0') then
                -- counter := 0;
                MEM_ADD <= to_unsigned(2,ADDRESS_WIDTH);
            end if;

            
            if(RST='1' or (INT='1' and STALL_REG='0')) then
                STALL_REG <= '1';
                
                INST1 <= (others=>'0');
                INST2 <= (others=>'0');
                OPCODE <= (others=>'0');
                MEM_RD_ENABLE <= '1';
                
                if(falling_edge(CLK) and MEM_RD_DONE='1') then
                    if(counter=0)   then
                        counter := 1;
                        PC(DATA_WIDTH-1 downto 16) <= MEM_DATA;
                        
                        if(RST='1') then    MEM_ADD <= to_unsigned(1,ADDRESS_WIDTH);
                        elsif(INT='1') then   MEM_ADD <= to_unsigned(3,ADDRESS_WIDTH);
                        end if;

                    else
                        counter := 0;
                        PC(15 downto 0) <= MEM_DATA;

                    end if;

                    MEM_RD_ENABLE <= '0';
                end if;
            
            else
                MEM_RD_ENABLE <= '1';

                --TODO: Logic of PC here



                MEM_ADD <= PC(ADDRESS_WIDTH-1 downto 0);
                
                if(falling_edge(CLK) and MEM_RD_DONE='1') then
                    STALL_REG <= '1';
                    if(counter=0)   then
                        counter := 1;
                        INST2 <= MEM_DATA;
                        OPCODE <= MEM_DATA(INST_WIDTH-1 downto INST_WIDTH-5);
                    else
                        counter := 0;
                        INST1 <= MEM_DATA;
                        STALL_REG <= '0';
                    end if;

                    MEM_RD_ENABLE <= '0';
                    
                    PC <= PC + to_unsigned(1,DATA_WIDTH);
                end if;
                
                if(CHANGE_PC='1') then  PC <= NEW_PC;   end if;

            end if;
                

        end if;

    end process ;

    


end FETCH ; -- FETCH