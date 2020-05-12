LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY EXECUTE_STAGE IS
    PORT(
        --INPUTS
        Rsrc1,Rsrc2,EXT_IN                          : IN STD_LOGIC_VECTOR (31 DOWNTO 0);    --PC MAYBE CANCELLED
        Rsrc1_num,Rsrc2_num,Rdst1_INnum,Rdst2_INnum : IN STD_LOGIC_VECTOR (2 DOWNTO 0);     
        WB_IN                                       : IN STD_LOGIC_VECTOR (4 DOWNTO 0);     --NEEDED
        --M_IN                                        : IN STD_LOGIC_VECTOR (3 DOWNTO 0);     --MAY BE CANCELLED
        EX_IN                                       : IN STD_LOGIC_VECTOR (5 DOWNTO 0);     
        RESET,INTERRUPT,JZ                          : IN STD_LOGIC;                         --ALL MAYBE CANCELLED
        INPUT_PORT                                  : IN STD_LOGIC_VECTOR (31 DOWNTO 0);   

        --OUTPUTS 
        OUTPUT_PORT                                 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        Rdst1_OUTnum,Rdst2_OUTnum                   : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        FLAG_REG                                    : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        ALU_RESULT,RESULT                           : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)   --EXT_OUT MAYBE CANCELLED
        --WB_OUT                                      : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);    --MAYBE CANCELLED
        --M_OUT                                       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)     --MAYBE CANCELLED
    );
END EXECUTE_STAGE;

ARCHITECTURE EXECUTE_FUNC OF EXECUTE_STAGE IS
    --======================================================================================================================================================
    --------------------------------------------------------------COMPONENTS--------------------------------------------------------------------------------
    --======================================================================================================================================================

    COMPONENT ALU IS
        GENERIC (N : INTEGER := 32);
        PORT(
            OPERAND1,OPERAND2       : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
            SEL                     : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            COUT,NEG_FLAG,ZERO_FLAG : OUT STD_LOGIC;
            RESULT                  : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0)
        );
    END COMPONENT;    

    --======================================================================================================================================================
    --------------------------------------------------------------INTERNAL SIGNALS--------------------------------------------------------------------------
    --======================================================================================================================================================

    SIGNAL ALU_OP1,ALU_OP2,ALU_RESULT_INTERNAL  : STD_LOGIC_VECTOR(31 DOWNTO 0);                           --ALU OPERANDS
    SIGNAL Z,N,C                                : STD_LOGIC;                                               --FLAGS
    SIGNAL SEL                                  : STD_LOGIC_VECTOR(3 DOWNTO 0);                            --ALU SELECTORS

    --======================================================================================================================================================

BEGIN
    --======================================================================================================================================================
    --------------------------------------------------------------ALU---------------------------------------------------------------------------------------
    --======================================================================================================================================================
    --FLAGS:
    FLAG_REG(3) <= '0';
    FLAG_REG(2) <= '0' WHEN RESET ='1'
            ELSE C;
    FLAG_REG(1) <= '0' WHEN RESET ='1'
            ELSE N;
    FLAG_REG(0) <= '0' WHEN RESET ='1'
            ELSE Z;

    --SELECTORS:
    SEL <= "1010" WHEN RESET ='1'
            ELSE EX_IN(3 DOWNTO 0);

    --ALU COMPONENT:
    ALU_COMP: ALU GENERIC MAP (32) PORT MAP (ALU_OP1,ALU_OP2,SEL,C,N,Z,ALU_RESULT_INTERNAL);

    --SET OPERANDS::
    ALU_OP1 <= (0 =>'1' , OTHERS => '0') WHEN RESET = '1' 
            ELSE Rsrc1;

    ALU_OP2 <= (OTHERS => '0') WHEN RESET ='1' 
            --1101:IADD     --1110:SHL      --1111:SHR      --0000:LDM
            ELSE EXT_IN        WHEN EX_IN(3 DOWNTO 0) = "1101" OR EX_IN(3 DOWNTO 0) = "1110" OR EX_IN(3 DOWNTO 0) = "1111" OR EX_IN(3 DOWNTO 0) ="0000"
            ELSE Rsrc2;


    --======================================================================================================================================================
    --------------------------------------------------------------SPECIAL CASES-----------------------------------------------------------------------------
    --======================================================================================================================================================
    
    --OUTPUT INSTRUCTION::
    OUTPUT_PORT <= (OTHERS => '0') WHEN RESET = '1'                             --RESET
            ELSE   Rsrc1           WHEN EX_IN(4) = '1';                         --OUTPUT INSTRUCTION

    --SWAP INSTRUCTION::
    Rdst1_OUTnum <= (OTHERS => '0') WHEN RESET ='1'
            ELSE Rsrc2_num          WHEN WB_IN(2 DOWNTO 1) = "11";
    Rdst2_OUTnum <= (OTHERS => '0') WHEN RESET ='1'
            ELSE Rsrc1_num          WHEN WB_IN(2 DOWNTO 1) = "11";
    RESULT <= (OTHERS => '0')       WHEN RESET ='1' 
            ELSE Rsrc2              WHEN WB_IN(2 DOWNTO 1) = "11";
    

    --
    ALU_RESULT <= (OTHERS => '0') WHEN RESET ='1' 
            ELSE INPUT_PORT       WHEN EX_IN(5) ='1'
            ELSE ALU_RESULT_INTERNAL;



END EXECUTE_FUNC;