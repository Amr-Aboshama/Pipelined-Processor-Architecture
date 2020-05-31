LIBRARY IEEE;

USE IEEE.STD_LOGIC_1164.ALL;

entity HAZARD_DETECTION_UNIT is
    port (
        -- DE_EX
        READ_MEM:   IN  STD_LOGIC;  -- MEM(6)
        FLUSH_WB:   IN  STD_LOGIC;  -- WB(4)            -- NOT NEEDED IF RET & RTI HANDLED HERE
        RDSTNUM_DE:    IN  std_logic_vector(2 downto 0) ;

        -- FE_DE
        HAVE_SRC1, HAVE_SRC2:   IN  STD_LOGIC;
        RSRCNUM1_FE, RSRCNUM2_FE:     IN  std_logic_vector(2 downto 0) ;

        --  CONTROL SIGNALS INPUT
        EX_SIG_IN:    IN std_logic_vector(5 downto 0) ;
        MEM_SIG_IN:   IN  std_logic_vector(6 downto 0) ;
        WB_SIG_IN:    IN  std_logic_vector(4 downto 0) ;



        --  CONTROL SIGNALS OUTPUT
        EX_SIG_OUT:    OUT std_logic_vector(5 downto 0) ;
        MEM_SIG_OUT:   OUT  std_logic_vector(6 downto 0) ;
        WB_SIG_OUT:    OUT  std_logic_vector(4 downto 0) ;
        
        STALL:   OUT STD_LOGIC

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

end HAZARD_DETECTION ; -- HAZARD_DETECTION