LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY ALU IS
    GENERIC (N : INTEGER := 32);
    PORT(
        OPERAND1,OPERAND2       : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
        SEL                     : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        COUT,NEG_FLAG,ZERO_FLAG : OUT STD_LOGIC;
        RESULT                  : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0)
    );
END ALU;

ARCHITECTURE ALU_FUNC OF ALU IS
    --======================================================================================================================================================
    --------------------------------------------------------------INTERNAL SIGNALS--------------------------------------------------------------------------
    --======================================================================================================================================================

    SIGNAL ARITHMETIC_RESULT  : STD_LOGIC_VECTOR(N DOWNTO 0);                             --result in case of **ARITHMETIC** operations
    SIGNAL LOGIC_RESULT       : STD_LOGIC_VECTOR(N-1 DOWNTO 0);                           --result in case of **LOGIC or SHIFTING** operations
    SIGNAL OUTPUT_RESULT      : STD_LOGIC_VECTOR(N-1 DOWNTO 0);                           --the **FINAL** output

    --======================================================================================================================================================

BEGIN
    --======================================================================================================================================================
    --------------------------------------------------------------ARITHMETIC OPERATIONS---------------------------------------------------------------------
    --======================================================================================================================================================

    ARITHMETIC_RESULT <= STD_LOGIC_VECTOR(UNSIGNED('0' & OPERAND1)-1)                              WHEN SEL = "0011"                       --DECREMENT
                    ELSE STD_LOGIC_VECTOR(UNSIGNED('0' & OPERAND1)+1)                              WHEN SEL = "0010"                       --INCREMENT
                    ELSE STD_LOGIC_VECTOR(UNSIGNED('0' & OPERAND1) - UNSIGNED('0' & OPERAND2))     WHEN SEL = "1011"                       --SUBTRACT
                    ELSE STD_LOGIC_VECTOR(UNSIGNED('0' & OPERAND1) + UNSIGNED('0' & OPERAND2))     WHEN SEL = "1010" OR SEL = "1101";      --ADD OR IADD

    --======================================================================================================================================================
    --------------------------------------------------------------SHIFTING OPERATIONS-----------------------------------------------------------------------
    --======================================================================================================================================================

    LOGIC_RESULT <=  STD_LOGIC_VECTOR(shift_right(UNSIGNED(OPERAND1),to_integer(UNSIGNED(OPERAND2))))    WHEN SEL = "1111"                 --SHR
                ELSE STD_LOGIC_VECTOR(shift_left(UNSIGNED(OPERAND1),to_integer(UNSIGNED(OPERAND2))))     WHEN SEL = "1110"                 --SHL
    
    --======================================================================================================================================================
    --------------------------------------------------------------LOGIC OPERATIONS--------------------------------------------------------------------------
    --======================================================================================================================================================

                ELSE   (NOT OPERAND1)                                                                     WHEN SEL = "0001"                --NOT
                ELSE   (OPERAND1 OR OPERAND2)                                                             WHEN SEL = "1001"                --OR
                ELSE   (OPERAND1 AND OPERAND2)                                                            WHEN SEL = "1000";               --AND

    --======================================================================================================================================================
    --------------------------------------------------------------SETTING RESULT----------------------------------------------------------------------------
    --======================================================================================================================================================

    OUTPUT_RESULT <= OPERAND1       WHEN SEL ="0000"                                                                --CASE: IDLE "PASS OPERAND1"
                ELSE LOGIC_RESULT   WHEN SEL="1111" OR SEL="1110" OR SEL = "0001" OR SEL = "1001" OR SEL = "1000"   --CASE: LOGIC OR SHIFTING OPERATION
                ELSE ARITHMETIC_RESULT(N-1 DOWNTO 0);                                                               --CASE: ARITHMETIC OPERATION

    RESULT <= OUTPUT_RESULT;            --THE PHYSICAL OUTPUT

    --======================================================================================================================================================
    --------------------------------------------------------------SETTING FLAGS-----------------------------------------------------------------------------
    --======================================================================================================================================================

    --CARRY_FLAG:       "COUT"
    -- DON'T CHANGE IN CASE OF LOGIC OPERATIONS
    COUT <=  ARITHMETIC_RESULT(N)                           WHEN SEL = "0011" OR SEL = "0010" OR SEL = "1011" OR SEL = "1010" OR SEL = "1101"  --ARITHMATIC
        ELSE OPERAND1(to_integer(unsigned(OPERAND2))-1)     WHEN SEL = "1111"                                                                  --SHR
        ELSE OPERAND1(N-to_integer(unsigned(OPERAND2)))     WHEN SEL = "1110";                                                                 --SHL

    --ZERO_FLAG:        "ZERO_FLAG"
    --DON'T CHANGE IN CASE OF IDLE
    ZERO_FLAG <= '1'         WHEN OUTPUT_RESULT(N-1 DOWNTO 0) =  X"00000000" AND SEL /="0000"       --CASE: RESULT  = 0 && !IDLE
            ELSE '0'         WHEN OUTPUT_RESULT(N-1 DOWNTO 0) /= X"00000000" AND SEL /="0000";      --CASE: RESULT != 0 && !IDLE

    --NEGATIVE_FLAGE:       "NEG_FLAG"
    --DON'T CHANGE IN CASE OF IDLE
    NEG_FLAG <= OUTPUT_RESULT(N-1) WHEN SEL /="0000";                                               --CASE: !IDLE

    --======================================================================================================================================================

END ALU_FUNC;