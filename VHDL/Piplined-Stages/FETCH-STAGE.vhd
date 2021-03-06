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
        MEMORY_CHANGE_PC, BRANCH_CHANGE_PC, STALL_CHANGE_PC:  IN STD_LOGIC;
        MEMORY_PC, BRANCH_PC, STALL_PC: IN UNSIGNED(DATA_WIDTH-1 DOWNTO 0);
        CHANGE_FLAG:    IN STD_LOGIC;
        FLAG_IN:    IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        FLAG_OUT:    OUT    STD_LOGIC_VECTOR(3 DOWNTO 0);

        STORE_PC:   OUT STD_LOGIC;
        MEMORY_PC_OUT:     OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0)
    );
END FETCH_STAGE;

ARCHITECTURE FETCH OF FETCH_STAGE IS
    SIGNAL PC: UNSIGNED(DATA_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL OPCODE: UNSIGNED(4 DOWNTO 0) := (OTHERS=>'0');
    SIGNAL STALL_REG: STD_LOGIC;
BEGIN


    PC_OUT <= PC;
    
    WRITE_REG <= NOT STALL_REG;

    -- MEM_RD_ENABLE <= '0' WHEN MEM_RD_DONE='1' OR ENABLE ='0' OR MEMORY_CHANGE_PC = '1' OR BRANCH_CHANGE_PC = '1'
    --                 ELSE '1';

    MEM_RD_ENABLE <= '1';

    HAVE_SRC2 <= '1' WHEN   OPCODE(4 DOWNTO 2) = "010"
                        ELSE '0';
                        
    HAVE_SRC1 <= '1' WHEN   (OPCODE(4 DOWNTO 3) = "00" AND ( OPCODE(1) OR (OPCODE(2) XOR OPCODE(0)) ) = '1')   -- B | (A^C)
                        OR  OPCODE(4 DOWNTO 3) = "01"
                        OR  (OPCODE(4 DOWNTO 3) = "10" AND ( (NOT OPCODE(1)) AND (OPCODE(2) OR (NOT OPCODE(0))) ) = '1')   -- !B & (A|!C) 
                        OR  (OPCODE(4 DOWNTO 2) = "110" AND (NOT (OPCODE(1) AND OPCODE(0))) ='1')
                        ELSE '0';


    MAIN: PROCESS( CLK, RST, INT, MEM_RD_DONE)
    
        VARIABLE COUNTER: INTEGER := 0;
        VARIABLE CHANGE_PC_LATCH: INTEGER := 0;
        VARIABLE CHANGE_FLAG_LATCH: INTEGER := 0;
        VARIABLE NEW_PC_REG: UNSIGNED(DATA_WIDTH-1 DOWNTO 0) := (OTHERS=>'0');
        VARIABLE FLAG_OUT_REG:  STD_LOGIC_VECTOR(2 DOWNTO 0);
        VARIABLE TMP:   UNSIGNED(31 DOWNTO 0);
        VARIABLE RST_LATCH: STD_LOGIC := '0';
        VARIABLE INT_LATCH: INTEGER := 0;
    BEGIN

        
        -- IF(RST'EVENT)   THEN
        --     COUNTER := 0;
        -- END IF;

        IF(RST'EVENT AND RST='1') THEN
            RST_LATCH := '1';
            MEM_ADD <= TO_UNSIGNED(0,ADDRESS_WIDTH);
        ELSIF(INT = '1') THEN
            INT_LATCH := 1;
        END IF;

        IF(INT_LATCH = 3 AND RISING_EDGE(CLK))   THEN
            INT_LATCH := 4;
            STORE_PC <= '0';
        END IF;

        
        IF((MEMORY_CHANGE_PC = '1' OR BRANCH_CHANGE_PC = '1' OR STALL_CHANGE_PC = '1') AND CHANGE_PC_LATCH = 0)   THEN
            CHANGE_PC_LATCH := 1;
        END IF;

        IF(CHANGE_PC_LATCH = 1) THEN
            IF(STALL_CHANGE_PC = '1')   THEN
                NEW_PC_REG := STALL_PC;
            ELSIF(MEMORY_CHANGE_PC = '1') THEN
                NEW_PC_REG := MEMORY_PC;
            ELSIF(BRANCH_CHANGE_PC = '1')   THEN
                NEW_PC_REG := BRANCH_PC;
        END IF;

        END IF;

        IF(CHANGE_FLAG = '1' AND CHANGE_FLAG_LATCH = 0)   THEN
            CHANGE_FLAG_LATCH := 1;
        END IF;

        IF(CHANGE_FLAG_LATCH = 1)   THEN
            FLAG_OUT_REG := FLAG_IN(2 DOWNTO 0);
        END IF;

        IF(ENABLE='1')  THEN

            IF(RST_LATCH = '1' OR INT_LATCH = 4) THEN
                STALL_REG <= '1';
                
                INST1 <= (OTHERS=>'0');
                INST2 <= (OTHERS=>'0');
                OPCODE <= (OTHERS=>'0');
                FLAG_OUT <= (OTHERS=>'0');

                IF(COUNTER = 2) THEN
                    RST_LATCH := '0';
                    INT_LATCH := 0;          
                    COUNTER := 0;
                END IF;

                IF(FALLING_EDGE(CLK) AND MEM_RD_DONE = '1') THEN
                    IF((COUNTER=1 AND RST_LATCH = '1') OR (COUNTER=0 AND INT_LATCH = 4))   THEN
                        PC(DATA_WIDTH-1 DOWNTO 16) <= MEM_DATA;
                    -- ELSIF (COUNTER=1)   THEN
                    --     PC(15 DOWNTO 0) <= MEM_DATA;
                    END IF;
                END IF;

                IF(RISING_EDGE(MEM_RD_DONE)) THEN
                    IF(COUNTER=0)   THEN
                        COUNTER := 1;
                        -- PC(DATA_WIDTH-1 DOWNTO 16) <= MEM_DATA;
                        
                        IF(RST_LATCH = '1') THEN    MEM_ADD <= TO_UNSIGNED(1,ADDRESS_WIDTH);
                        ELSIF(INT_LATCH = 4) THEN   MEM_ADD <= TO_UNSIGNED(3,ADDRESS_WIDTH);
                        END IF;

                    ELSIF (COUNTER=1)   THEN
                        COUNTER := 2;
                        PC(15 DOWNTO 0) <= MEM_DATA;
                        MEM_ADD <= MEM_DATA(ADDRESS_WIDTH-1 DOWNTO 0);
                        -- RST_LATCH := '0';
                    END IF;

                END IF;
            
            ELSE

                --TODO: LOGIC OF PC HERE
                IF(RISING_EDGE(CLK))    THEN
                    IF(INT_LATCH = 2 AND STALL_REG = '0')   THEN
                        INT_LATCH := 3;
                    END IF;
                    STALL_REG <= '1';
                END IF;

                IF(RISING_EDGE(MEM_RD_DONE))    THEN
                    IF(COUNTER=0)   THEN
                        TMP := PC + TO_UNSIGNED(1,DATA_WIDTH);
                        PC <= TMP;
                        MEM_ADD <= TMP(ADDRESS_WIDTH-1 DOWNTO 0);
                    
                    ELSIF(COUNTER=1)    THEN
                        IF(INT_LATCH = 1)   THEN
                            INT_LATCH := 2;
                            STORE_PC <= '1';
                            MEMORY_PC_OUT <= STD_LOGIC_VECTOR(PC+TO_UNSIGNED(1,DATA_WIDTH));
                        END IF;

                        
                        FLAG_OUT(3) <= '0';
                        IF(CHANGE_PC_LATCH=1) THEN
                            IF(CHANGE_FLAG_LATCH = 1) THEN
                                CHANGE_FLAG_LATCH := 2;

                            ELSIF(CHANGE_FLAG_LATCH = 2)  THEN
                                CHANGE_FLAG_LATCH := 0;
                                FLAG_OUT <= '1' & FLAG_OUT_REG(2 DOWNTO 0);
                            END IF;
                            
                            TMP := NEW_PC_REG;
                            PC <= TMP;
                            MEM_ADD <= TMP(ADDRESS_WIDTH-1 DOWNTO 0);
                            CHANGE_PC_LATCH := 2;
                        ELSE
                            TMP := PC + TO_UNSIGNED(1,DATA_WIDTH);
                            PC <= TMP;
                            MEM_ADD <= TMP(ADDRESS_WIDTH-1 DOWNTO 0);
                            IF(CHANGE_PC_LATCH = 2) THEN
                                CHANGE_PC_LATCH := 0;
                            END IF;
                        END IF;
                    END IF;
                END IF;

                IF(FALLING_EDGE(CLK) AND MEM_RD_DONE = '1') THEN
                    IF(COUNTER=0)   THEN
                        COUNTER := 1;
                        INST2 <= MEM_DATA;
                        OPCODE <= MEM_DATA(INST_WIDTH-1 DOWNTO INST_WIDTH-5);
                    
                    ELSIF(COUNTER=1)    THEN
                        COUNTER := 0;
                        INST1 <= MEM_DATA;
                        STALL_REG <= '0';
                        IF(INT_LATCH = 2)   THEN
                            INT_LATCH := 3;
                        END IF;
                    END IF;
                END IF;

                IF(INT_LATCH = 2)    THEN
                    MEM_ADD <= TO_UNSIGNED(2,ADDRESS_WIDTH);
                END IF; 

            END IF;
                
        END IF;

    END PROCESS ;

END FETCH ; -- FETCH