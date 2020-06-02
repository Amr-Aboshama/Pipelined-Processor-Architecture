LIBRARY IEEE ;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity FLUSHING_UNIT is
    port (
        -- FE/DE
        FETCH_DONE: IN  STD_LOGIC;
        
        -- DE/EX
        BRANCH_EX: IN  STD_LOGIC;          -- WB(3)
        
        -- EX/MEM
        BRANCH_MEM: IN  STD_LOGIC;          -- WB(3)
        EXTRAFLUSH_MEM:    IN STD_LOGIC;   -- WB
        
        -- MEM/WB
        BRANCH_WB: IN  STD_LOGIC;          -- WB(3)
        EXTRAFLUSH_WB:    IN STD_LOGIC;   -- WB

        FLUSH:  OUT STD_LOGIC
    ) ;
end FLUSHING_UNIT;

architecture FLUSHING of FLUSHING_UNIT is
begin

    FLUSH <= FETCH_DONE AND (BRANCH_EX OR (BRANCH_MEM AND EXTRAFLUSH_MEM) OR (BRANCH_WB AND EXTRAFLUSH_WB));

end FLUSHING ; -- FLUSHING