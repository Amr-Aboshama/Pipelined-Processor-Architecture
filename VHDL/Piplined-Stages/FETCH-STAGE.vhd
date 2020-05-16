library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY FETCH_STAGE IS
    GENERIC(
        INST_WIDTH: INTEGER := 16;
        DATA_WIDTH: INTEGER := 32;
        ADDRESS_WIDTH:  INTEGER := 11
    );
    PORT (
        CLK, RST, ENABLE, INT:    IN  STD_LOGIC;
        WRITE_REG:  OUT STD_LOGIC;
        PC_OUT: OUT UNSIGNED(DATA_WIDTH-1 DOWNTO 0) ;
        MEM_DATA:   IN  UNSIGNED(INST_WIDTH-1 DOWNTO 0);
        MEM_ADD:    OUT UNSIGNED(ADDRESS_WIDTH-1 DOWNTO 0);
        MEM_RD_DONE:     IN  STD_LOGIC;
        MEM_RD_ENABLE:    OUT  STD_LOGIC;
        INST1, INST2:  OUT UNSIGNED(INST_WIDTH-1 DOWNTO 0);
        HAVE_SRC1, HAVE_SRC2: OUT STD_LOGIC;
        MEMORY_CHANGE_PC, BRANCH_CHANGE_PC:  IN STD_LOGIC;
        MEMORY_PC, BRANCH_PC: IN UNSIGNED(DATA_WIDTH-1 DOWNTO 0);
        CHANGE_FLAG:    IN STD_LOGIC;
        FLAG_IN:    IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        FLAG_OUT:    OUT    STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END FETCH_STAGE;

ARCHITECTURE FETCH OF FETCH_STAGE IS
    SIGNAL PC: UNSIGNED(DATA_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL OPCODE: UNSIGNED(4 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL STALL_REG: STD_LOGIC;
BEGIN


    PC_OUT <= PC;
    
    WRITE_REG <= NOT STALL_REG;

    MEM_RD_ENABLE <= '0' WHEN MEM_RD_DONE='1' OR ENABLE ='0' OR MEMORY_CHANGE_PC = '1' OR BRANCH_CHANGE_PC = '1'
                    ELSE '1';

    HAVE_SRC2 <= '1' WHEN   OPCODE(4 DOWNTO 2) = "010"
                        ELSE '0';
                        
    HAVE_SRC1 <= '1' WHEN   (OPCODE(4 DOWNTO 3) = "00" AND ( OPCODE(1) OR (OPCODE(2) XOR OPCODE(0)) ) = '1')   -- B | (A^C)
                        OR  OPCODE(4 DOWNTO 3) = "01"
                        OR  (OPCODE(4 DOWNTO 3) = "10" AND ( (NOT OPCODE(1)) AND (OPCODE(2) OR (NOT OPCODE(0))) ) = '1')   -- !B & (A|!C) 
                        OR  (OPCODE(4 DOWNTO 2) = "110" AND (NOT (OPCODE(1) AND OPCODE(0))) ='1')
                        ELSE '0';


    MAIN: PROCESS( CLK, RST, INT )
    
        VARIABLE COUNTER: INTEGER;
        VARIABLE CHANGE_PC_LATCH: STD_LOGIC := '0';
        VARIABLE CHANGE_FLAG_LATCH: INTEGER := 0;
        VARIABLE NEW_PC_REG: UNSIGNED(DATA_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
        VARIABLE FLAG_OUT_REG:  STD_LOGIC_VECTOR(2 DOWNTO 0);
    BEGIN

        
        IF(RST'EVENT)   THEN
            COUNTER := 0;
        END IF;

        IF(RST'EVENT AND RST='1') THEN
            MEM_ADD <= TO_UNSIGNED(0,ADDRESS_WIDTH);
        ELSIF(INT='1' AND STALL_REG='0') THEN
            MEM_ADD <= TO_UNSIGNED(2,ADDRESS_WIDTH);
        END IF;

        IF(ENABLE='1')  THEN

            IF(RST='1' OR (INT='1' AND STALL_REG='0')) THEN
                STALL_REG <= '1';
                
                INST1 <= (OTHERS=>'0');
                INST2 <= (OTHERS=>'0');
                OPCODE <= (OTHERS=>'0');
                FLAG_OUT <= (OTHERS=>'0');

                IF(FALLING_EDGE(CLK) AND MEM_RD_DONE='1') THEN
                    IF(COUNTER=0)   THEN
                        COUNTER := 1;
                        PC(DATA_WIDTH-1 DOWNTO 16) <= MEM_DATA;
                        
                        IF(RST='1') THEN    MEM_ADD <= TO_UNSIGNED(1,ADDRESS_WIDTH);
                        ELSIF(INT='1') THEN   MEM_ADD <= TO_UNSIGNED(3,ADDRESS_WIDTH);
                        END IF;

                    ELSIF (COUNTER=1)   THEN
                        COUNTER := 2;
                        PC(15 DOWNTO 0) <= MEM_DATA;
                        MEM_ADD <= MEM_DATA(ADDRESS_WIDTH-1 DOWNTO 0);

                    END IF;

                END IF;
            
            ELSE

                --TODO: LOGIC OF PC HERE


                MEM_ADD <= PC(ADDRESS_WIDTH-1 DOWNTO 0); 

                IF(FALLING_EDGE(CLK) AND MEM_RD_DONE='1') THEN
                    STALL_REG <= '1';
                    IF(COUNTER=0)   THEN
                        COUNTER := 1;
                        INST2 <= MEM_DATA;
                        OPCODE <= MEM_DATA(INST_WIDTH-1 DOWNTO INST_WIDTH-5);
                        PC <= PC + TO_UNSIGNED(1,DATA_WIDTH);
                    
                    ELSIF(COUNTER=1)    THEN
                        COUNTER := 0;
                        INST1 <= MEM_DATA;
                        STALL_REG <= '0';
                        FLAG_OUT(3) <= '0';
                        IF(CHANGE_PC_LATCH='1') THEN
                            IF(CHANGE_FLAG_LATCH = 1) THEN
                                CHANGE_FLAG_LATCH := 2;

                            ELSIF(CHANGE_FLAG_LATCH = 2)  THEN
                                CHANGE_FLAG_LATCH := 0;
                                FLAG_OUT <= '1' & FLAG_OUT_REG(2 DOWNTO 0);
                            END IF;
                            PC <= NEW_PC_REG;
                            CHANGE_PC_LATCH := '0';
                            COUNTER:=0;
                        ELSE
                            PC <= PC + TO_UNSIGNED(1,DATA_WIDTH);
                        END IF;
                    END IF;
                    
                END IF;                

                IF(MEMORY_CHANGE_PC = '1' OR BRANCH_CHANGE_PC = '1')   THEN
                    IF(CHANGE_FLAG = '1')   THEN
                        CHANGE_FLAG_LATCH := 1;
                        FLAG_OUT_REG := FLAG_IN(2 DOWNTO 0);
                    END IF;
                    CHANGE_PC_LATCH := '1';
                    IF(MEMORY_CHANGE_PC = '1') THEN
                        NEW_PC_REG := MEMORY_PC;
                    ELSE
                        NEW_PC_REG := BRANCH_PC;
                    END IF;
                END IF;

            END IF;
                
        END IF;

    END PROCESS ;

END FETCH ; -- FETCH