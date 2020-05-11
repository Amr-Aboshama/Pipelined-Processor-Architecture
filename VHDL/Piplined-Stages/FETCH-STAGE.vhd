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
    
    WRITE_REG <= (NOT STALL_REG);-- and (NOT CHANGE_PC);

    MEM_RD_ENABLE <= '0' when MEM_RD_DONE='1' or CHANGE_PC = '1'
                    else '1';

    HAVE_SRC2 <= '1' when   OPCODE(4 downto 2) = "010"
                        else '0';
                        
    HAVE_SRC1 <= '1' when   (OPCODE(4 downto 3) = "00" and ( OPCODE(1) or (OPCODE(2) xor OPCODE(0)) ) = '1')   -- B | (A^C)
                        or  OPCODE(4 downto 3) = "01"
                        or  (OPCODE(4 downto 3) = "10" and ( (NOT OPCODE(1)) and (OPCODE(2) or (NOT OPCODE(0))) ) = '1')   -- !B & (A|!C) 
                        or  (OPCODE(4 downto 2) = "110" and (NOT (OPCODE(1) and OPCODE(0))) ='1')
                        else '0';


    MAIN: process( CLK, RST, INT )
    
        variable counter: integer;
        variable change_pc_latch: std_logic := '0';
        variable new_pc_reg: unsigned(DATA_WIDTH-1 downto 0) := (others=>'0');

    begin
        if(ENABLE='1')  then
            

            if(RST'event)   then
                counter := 0;
            end if;

            if(RST'event and RST='1') then
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

                -- if(MEM_RD_DONE='1') then MEM_RD_ENABLE <= '0';
                -- else    MEM_RD_ENABLE <= '1'    end if;
                
                if(falling_edge(CLK) and MEM_RD_DONE='1') then
                    if(counter=0)   then
                        counter := 1;
                        PC(DATA_WIDTH-1 downto 16) <= MEM_DATA;
                        
                        if(RST='1') then    MEM_ADD <= to_unsigned(1,ADDRESS_WIDTH);
                        elsif(INT='1') then   MEM_ADD <= to_unsigned(3,ADDRESS_WIDTH);
                        end if;

                    -- elsif (counter=1) then      -- Because MEM_RD_DONE is high for two cycles
                    --     counter := 2;

                    elsif (counter=1)   then
                        counter := 2;
                        PC(15 downto 0) <= MEM_DATA;
                        MEM_ADD <= MEM_DATA(ADDRESS_WIDTH-1 downto 0);

                    end if;

                    -- counter := counter + 1;
                    -- MEM_RD_ENABLE <= '0';
                end if;
            
            else
                -- MEM_RD_ENABLE <= '1';

                -- if(MEM_RD_DONE='1') then MEM_RD_ENABLE <= '0';
                -- else    MEM_RD_ENABLE <= '1'    end if;

                --TODO: Logic of PC here



                -- if(rising_edge(CLK))  then    
                    MEM_ADD <= PC(ADDRESS_WIDTH-1 downto 0); 
                -- end if;

                if(falling_edge(CLK) and MEM_RD_DONE='1') then
                    -- MEM_ADD <= PC(ADDRESS_WIDTH-1 downto 0);
                    STALL_REG <= '1';
                    if(counter=0)   then
                        counter := 1;
                        INST2 <= MEM_DATA;
                        OPCODE <= MEM_DATA(INST_WIDTH-1 downto INST_WIDTH-5);
                        PC <= PC + to_unsigned(1,DATA_WIDTH);
                    
                    elsif(counter=1)    then
                        counter := 0;
                        INST1 <= MEM_DATA;
                        STALL_REG <= '0';
                        if(change_pc_latch='1') then  
                            PC <= new_pc_reg;
                            change_pc_latch := '0';
                            counter:=0;
                        else
                            PC <= PC + to_unsigned(1,DATA_WIDTH);
                        end if;
                    end if;
                    
                    -- MEM_RD_ENABLE <= '0';
                    -- counter := counter + 1;
                end if;                

                if(CHANGE_PC='1')   then
                    change_pc_latch := '1';
                    new_pc_reg := NEW_PC;
                end if;

            end if;
                

        end if;

    end process ;

    


end FETCH ; -- FETCH