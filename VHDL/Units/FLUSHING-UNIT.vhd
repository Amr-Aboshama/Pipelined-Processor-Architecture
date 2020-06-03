LIBRARY IEEE ;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity FLUSHING_UNIT is
    port (
        -- FE/DE
        BRANCH_CHANGE: IN  STD_LOGIC;
        
        -- DE/EX
        BRANCH_EX: IN  STD_LOGIC;          -- WB(3)
        EXTRAFLUSH_EX:  IN  STD_LOGIC;     -- MEM(6)
        
        -- EX/MEM
        BRANCH_MEM: IN  STD_LOGIC;          -- WB(3)
        EXTRAFLUSH_MEM:    IN STD_LOGIC;   -- MEM(6)

        FLUSH:  OUT STD_LOGIC
    ) ;
end FLUSHING_UNIT;

architecture FLUSHING of FLUSHING_UNIT is
begin

    FLUSH <= ((BRANCH_CHANGE OR EXTRAFLUSH_EX) AND BRANCH_EX) OR (BRANCH_MEM AND EXTRAFLUSH_MEM);

end FLUSHING ; -- FLUSHING