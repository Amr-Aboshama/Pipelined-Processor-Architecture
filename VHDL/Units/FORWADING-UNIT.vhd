LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity FORWARDING_UNIT is
    GENERIC(DATA_WIDTH: INTEGER := 32);
    port (
            
            SRC1, SRC2: IN std_logic_vector(DATA_WIDTH-1 downto 0) ;   -- DECODE
            RSRCNUM1, RSRCNUM2: IN  std_logic_vector(2 downto 0) ;
            SWAP_DE:    IN STD_LOGIC;

            EX1, EX2: IN  std_logic_vector(DATA_WIDTH-1 downto 0) ;      -- EXECUTE
            RDSTNUM1_EX, RDSTNUM2_EX:   IN  std_logic_vector(2 downto 0) ;
            WRITE_EX:  IN  STD_LOGIC ;  -- WB(2)
            SWAP_EX:  IN  STD_LOGIC ;   -- WB(1)
            ALU_EX:  IN  STD_LOGIC ;    -- WB(0)
            
            ALU_RES, MEM_RES, RES: IN  std_logic_vector(DATA_WIDTH-1 downto 0) ;   -- MEMORY
            RDSTNUM1_MEM, RDSTNUM2_MEM:   IN  std_logic_vector(2 downto 0) ;
            WRITE_MEM:  IN  STD_LOGIC ;  -- WB(2)
            SWAP_MEM:  IN  STD_LOGIC ;   -- WB(1)
            ALU_MEM:  IN  STD_LOGIC;     -- WB(0)

            OUT1, OUT2: OUT std_logic_vector(DATA_WIDTH-1 downto 0) 
    ) ;
end FORWARDING_UNIT;

architecture FORWARDING of FORWARDING_UNIT is

    SIGNAL SIG_EX:  STD_LOGIC;
    SIGNAL SIG_MEM: STD_LOGIC;

begin

    SIG_EX <= WRITE_EX AND ALU_EX;
    SIG_MEM <= WRITE_MEM AND ALU_MEM;
    
    OUT1 <= EX2 WHEN ((SIG_EX AND SWAP_EX) = '1' AND (RSRCNUM1 = RDSTNUM2_EX))  
        ELSE EX1 WHEN (SIG_EX  = '1' AND (RSRCNUM1 = RDSTNUM1_EX))              -- HANDLES LDM OPERATION
        ELSE RES WHEN ((SIG_MEM AND SWAP_MEM) = '1' AND (RSRCNUM1 = RDSTNUM2_MEM))
        ELSE ALU_RES WHEN (SIG_MEM  = '1' AND (RSRCNUM1 = RDSTNUM1_MEM))
        ELSE MEM_RES WHEN ((WRITE_MEM AND (NOT ALU_MEM)) = '1' AND (RSRCNUM1 = RDSTNUM1_MEM))
        ELSE SRC1;



    OUT2 <= EX2 WHEN ((SIG_EX AND SWAP_EX) = '1' AND (RSRCNUM2 = RDSTNUM2_EX) AND SWAP_DE = '1')
    ELSE EX1 WHEN (SIG_EX  = '1' AND (RSRCNUM2 = RDSTNUM1_EX) AND SWAP_DE = '1')              -- HANDLES LDM OPERATION
    ELSE RES WHEN ((SIG_MEM AND SWAP_MEM) = '1' AND (RSRCNUM2 = RDSTNUM2_MEM) AND SWAP_DE = '1')
    ELSE ALU_RES WHEN (SIG_MEM  = '1' AND (RSRCNUM2 = RDSTNUM1_MEM) AND SWAP_DE = '1')
    ELSE MEM_RES WHEN ((WRITE_MEM AND (NOT ALU_MEM)) = '1' AND (RSRCNUM2 = RDSTNUM1_MEM) AND SWAP_DE = '1')
    ELSE SRC2;

end FORWARDING ; -- FORWARDING