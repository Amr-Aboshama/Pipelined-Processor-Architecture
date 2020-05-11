LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
LIBRARY WORK;

ENTITY MEMORYMODULE IS 
	GENERIC (DATASIZE : INTEGER := 16);
    PORT (
    	-- INPUTS
    	M_CLK : IN STD_LOGIC;
        M_READ : IN STD_LOGIC;
        M_WRITE : IN STD_LOGIC;
    	M_DATAIN : IN STD_LOGIC_VECTOR (DATASIZE-1 DOWNTO 0);
        M_ADDRESS : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        -- OUTPUTS
	    M_DONEREAD : OUT STD_LOGIC;
	    M_DONEWRITE : OUT STD_LOGIC;
        M_DATAOUT : OUT STD_LOGIC_VECTOR (DATASIZE-1 DOWNTO 0)
        
    );
END ENTITY;

ARCHITECTURE MEMORYMODULEARCH OF MEMORYMODULE IS 

	 -- INPUT SIGNALS TO RAM  
    --   SIGNAL RAM_CLK : STD_LOGIC;
      SIGNAL CONTROLLER_MEMREAD : STD_LOGIC;
      SIGNAL CONTROLLER_MEMWRITE :  STD_LOGIC;
      SIGNAL CONTROLLER_ADDRESSOUT : STD_LOGIC_VECTOR(11-1 DOWNTO 0);
      SIGNAL CACHE_MEMORYOUT :  STD_LOGIC_VECTOR(127 DOWNTO 0);
      
      -- OUTPUT SIGNALS FROM RAM 
      SIGNAL RAM_DATAOUT : STD_LOGIC_VECTOR(127 DOWNTO 0);
      SIGNAL RAM_READYSIGNAL :  STD_LOGIC;
      SIGNAL RAM_DONEWRITING :  STD_LOGIC;
      
      -- INPUT SIGNALS TO CACHE
  	  SIGNAL CACHE_CLK : STD_LOGIC;
      SIGNAL CONTROLLER_INDEX :  STD_LOGIC_VECTOR (4 DOWNTO 0);
      SIGNAL CONTROLLER_DISPLACEMENT : STD_LOGIC_VECTOR (2 DOWNTO 0);
      SIGNAL CONTROLLER_CONTROLLERDATAOUT :  STD_LOGIC_VECTOR (DATASIZE-1 DOWNTO 0);
    --   SIGNAL RAM_DATAOUT :  STD_LOGIC_VECTOR (127 DOWNTO 0);
      SIGNAL CONTROLLER_CACHEREAD : STD_LOGIC;
      SIGNAL CONTROLLER_CACHEWRITE : STD_LOGIC;
      SIGNAL CONTROLLER_CACHEFROMMEMREAD : STD_LOGIC;
      SIGNAL CONTROLLER_CACHETOMEMWRITE : STD_LOGIC;
      
      -- OUTPUT SIGNALS FROM CACHE
      SIGNAL CACHE_DONEMEMORYREAD : STD_LOGIC;
      SIGNAL CACHE_DONEMEMORYWRITE : STD_LOGIC;

	BEGIN
    CONTROLLER_U : ENTITY WORK.CACHECONTROLLER GENERIC MAP (DATASIZE) PORT MAP (M_CLK, M_ADDRESS, M_DATAIN, M_READ, M_WRITE, RAM_READYSIGNAL,RAM_DONEWRITING, CACHE_DONEMEMORYREAD, CACHE_DONEMEMORYWRITE, CONTROLLER_MEMREAD, CONTROLLER_MEMWRITE,CONTROLLER_ADDRESSOUT, CONTROLLER_CACHEREAD, CONTROLLER_CACHEWRITE, CONTROLLER_CACHETOMEMWRITE, CONTROLLER_CACHEFROMMEMREAD, CONTROLLER_INDEX, CONTROLLER_DISPLACEMENT, CONTROLLER_CONTROLLERDATAOUT );

    CACHE_U : ENTITY WORK.CACHE GENERIC MAP (DATASIZE) PORT MAP (M_CLK, CONTROLLER_INDEX, CONTROLLER_DISPLACEMENT, CONTROLLER_CONTROLLERDATAOUT, RAM_DATAOUT, CONTROLLER_CACHEREAD, CONTROLLER_CACHEWRITE,CONTROLLER_CACHEFROMMEMREAD, CONTROLLER_CACHETOMEMWRITE, M_DATAOUT, CACHE_MEMORYOUT, CACHE_DONEMEMORYREAD, CACHE_DONEMEMORYWRITE, M_DONEREAD, M_DONEWRITE );
    
    RAM_U : ENTITY WORK.RAM PORT MAP (M_CLK, CONTROLLER_MEMREAD, CONTROLLER_MEMWRITE, CONTROLLER_ADDRESSOUT, CACHE_MEMORYOUT,  RAM_DATAOUT, RAM_READYSIGNAL,RAM_DONEWRITING );




END MEMORYMODULEARCH;