LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity BRANCH_FORWARDING_UNIT is
    GENERIC(DATA_WIDTH: INTEGER := 32);
    port (
            
            SRC1:  IN std_logic_vector(DATA_WIDTH-1 downto 0) ;  -- REGISTER FILE
            RSRCNUM1: IN  std_logic_vector(2 downto 0) ;
            
            ALU_OUT1, ALU_OUT2: IN std_logic_vector(DATA_WIDTH-1 downto 0) ;   -- DE/EX
            RDSTNUM1_DE, RDSTNUM2_DE:   IN  std_logic_vector(2 downto 0) ;
            WRITE_DE:  IN  STD_LOGIC ;  -- WB(2)
            SWAP_DE:  IN  STD_LOGIC ;   -- WB(1)
            ALU_DE:  IN  STD_LOGIC ;    -- WB(0)

            EX1, EX2: IN  std_logic_vector(DATA_WIDTH-1 downto 0) ;      -- EX/MEM
            RDSTNUM1_EX, RDSTNUM2_EX:   IN  std_logic_vector(2 downto 0) ;
            WRITE_EX:  IN  STD_LOGIC ;  -- WB(2)
            SWAP_EX:  IN  STD_LOGIC ;   -- WB(1)
            ALU_EX:  IN  STD_LOGIC ;    -- WB(0)
            
            MEM_RES, ALU_RES, RES: IN  std_logic_vector(DATA_WIDTH-1 downto 0) ;   -- MEM/WB
            RDSTNUM1_MEM, RDSTNUM2_MEM:   IN  std_logic_vector(2 downto 0) ;
            WRITE_MEM:  IN  STD_LOGIC ;  -- WB(2)
            SWAP_MEM:  IN  STD_LOGIC ;   -- WB(1)
            ALU_MEM:  IN  STD_LOGIC;     -- WB(0)

            OUT1: OUT std_logic_vector(DATA_WIDTH-1 downto 0) 
    ) ;
end BRANCH_FORWARDING_UNIT;

architecture FORWARDING of BRANCH_FORWARDING_UNIT is

    SIGNAL SIG_DE:  STD_LOGIC;
    SIGNAL SIG_EX:  STD_LOGIC;
    SIGNAL SIG_MEM: STD_LOGIC;

begin

    SIG_DE <= WRITE_DE AND ALU_DE;
    SIG_EX <= WRITE_EX AND ALU_EX;
    SIG_MEM <= WRITE_MEM AND ALU_MEM;
    
    OUT1 <= ALU_OUT2 WHEN ((SIG_DE AND SWAP_DE) = '1' AND (RSRCNUM1 = RDSTNUM2_DE))
        ELSE ALU_OUT1 WHEN (SIG_DE = '1' AND (RSRCNUM1 = RDSTNUM1_DE))
        ELSE EX2 WHEN ((SIG_EX AND SWAP_EX) = '1' AND (RSRCNUM1 = RDSTNUM2_EX))  
        ELSE EX1 WHEN (SIG_EX  = '1' AND (RSRCNUM1 = RDSTNUM1_EX))              -- HANDLES LDM OPERATION
        ELSE RES WHEN ((SIG_MEM AND SWAP_MEM) = '1' AND (RSRCNUM1 = RDSTNUM2_MEM))
        ELSE ALU_RES WHEN (SIG_MEM  = '1' AND (RSRCNUM1 = RDSTNUM1_MEM))
        ELSE MEM_RES WHEN ((WRITE_MEM AND (NOT ALU_MEM)) = '1' AND (RSRCNUM1 = RDSTNUM1_MEM))
        ELSE SRC1;


end FORWARDING ; -- FORWARDING