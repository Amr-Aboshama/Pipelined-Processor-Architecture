LIBRARY IEEE;

USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity HAZARD_DETECTION_UNIT is
    port (
        -- DE_EX
        INST_DE:   IN  std_logic_vector(163 downto 0) ;
        READ_MEM:   IN  STD_LOGIC;  -- MEM(6)
        FLUSH_WB:   IN  STD_LOGIC;  -- WB(4)            -- NOT NEEDED IF RET & RTI HANDLED HERE
        RDSTNUM_DE:    IN  std_logic_vector(2 downto 0) ;

        -- FE_DE
        INST_FE:   IN  std_logic_vector(71 downto 0) ;
        HAVE_SRC1, HAVE_SRC2:   IN  STD_LOGIC;
        RSRCNUM1_FE, RSRCNUM2_FE:     IN  std_logic_vector(2 downto 0) ;
        PC: IN  UNSIGNED(31 downto 0) ;
        FETCH_DONE: IN STD_LOGIC;

        --  CONTROL SIGNALS INPUT
        EX_SIG_IN:    IN std_logic_vector(5 downto 0) ;
        MEM_SIG_IN:   IN  std_logic_vector(6 downto 0) ;
        WB_SIG_IN:    IN  std_logic_vector(4 downto 0) ;



        --  CONTROL SIGNALS OUTPUT
        EX_SIG_OUT:    OUT std_logic_vector(5 downto 0) ;
        MEM_SIG_OUT:   OUT  std_logic_vector(6 downto 0) ;
        WB_SIG_OUT:    OUT  std_logic_vector(4 downto 0) ;
        
        -- STALL:   OUT STD_LOGIC;
        PC_DONE:    OUT STD_LOGIC;
        PC_OUT: OUT std_logic_vector(31 downto 0);

        STALL:  OUT STD_LOGIC;

        INST_DONE:  OUT STD_LOGIC;
        INST_FE_OUT:    OUT    std_logic_vector(71 downto 0);
        INST_DE_OUT:    OUT    std_logic_vector(163 downto 0)
    ) ;
end HAZARD_DETECTION_UNIT;

architecture HAZARD_DETECTION of HAZARD_DETECTION_UNIT is

    signal LOAD_PREV:       std_logic;
    signal HAZARD_EXIST:    std_logic;
begin

    LOAD_PREV <= READ_MEM AND (NOT FLUSH_WB);
    -- LOAD_PREV <= READ_MEM;       -- HANDLES RET & RTI

    HAZARD_EXIST <= '1' WHEN (LOAD_PREV = '1' AND 
                            ((HAVE_SRC1 = '1' AND RDSTNUM_DE = RSRCNUM1_FE) OR (HAVE_SRC2 = '1' AND RDSTNUM_DE = RSRCNUM2_FE)))
                ELSE '0';
    
    EX_SIG_OUT <= (OTHERS => '0') WHEN HAZARD_EXIST = '1'
                ELSE EX_SIG_IN;

    MEM_SIG_OUT <= (OTHERS => '0') WHEN HAZARD_EXIST = '1'
                ELSE MEM_SIG_IN;

    WB_SIG_OUT <= (OTHERS => '0') WHEN HAZARD_EXIST = '1'
                ELSE WB_SIG_IN;

    STALL <= HAZARD_EXIST;

    PROCESS(HAZARD_EXIST, FETCH_DONE)
        variable HAZARD_LATCH:  INTEGER := 0;
        variable INST_LATCH:  INTEGER := 0;
    begin
        IF(HAZARD_EXIST = '1' AND HAZARD_LATCH = 0) THEN
            HAZARD_LATCH := 1;
            PC_DONE <= '1';
            PC_OUT <= std_logic_vector(PC - TO_UNSIGNED(1,32));
            INST_LATCH := 1;
            INST_FE_OUT <= INST_FE;
            INST_DE_OUT <= INST_DE;
        ELSIF(HAZARD_EXIST = '0' AND HAZARD_LATCH = 1) THEN
            HAZARD_LATCH := 0;
            PC_DONE <= '0';
            INST_LATCH := 0;
            -- STALL <= '0';
        END IF;

        IF(FETCH_DONE'EVENT) THEN
            IF(INST_LATCH = 1)  THEN
                INST_LATCH := 2;
                INST_DONE <= '1';
            ELSE
                INST_DONE <= '0';
            END IF;
        END IF;
    END PROCESS;

end HAZARD_DETECTION ; -- HAZARD_DETECTION