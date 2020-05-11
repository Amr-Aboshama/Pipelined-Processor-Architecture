LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY CACHE IS 
  GENERIC (DATASIZE : INTEGER := 16);
  PORT (
      -- INPUTS 
  	  CLK : IN STD_LOGIC;
      INDEX : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
      DISPLACEMENT : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
      CONTROLLERDATAIN : IN STD_LOGIC_VECTOR (DATASIZE-1 DOWNTO 0);
      RAMDATAIN : IN STD_LOGIC_VECTOR (127 DOWNTO 0);
      CACHEREAD : IN STD_LOGIC;
      CACHEWRITE : IN STD_LOGIC;
      MEMORYREAD : IN STD_LOGIC;
      MEMORYWRITE : IN STD_LOGIC;
      
      -- OUTPUTS
      DATAOUT : OUT STD_LOGIC_VECTOR(DATASIZE-1 DOWNTO 0);
      MEMORYOUT : OUT STD_LOGIC_VECTOR (127 DOWNTO 0);
      DONEMEMORYREAD : OUT STD_LOGIC;
      DONEMEMORYWRITE : OUT STD_LOGIC;
      DONEREADSIGNAL : OUT STD_LOGIC;
      DONEWRITESIGNAL : OUT STD_LOGIC
  
  );
END ENTITY; 

ARCHITECTURE CACHEARCH OF CACHE IS 
  TYPE CACHETYPE IS ARRAY (31 DOWNTO 0) OF STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL CACHEDATA : CACHETYPE;
  
  BEGIN
  PROCESS (CLK) IS
 
    VARIABLE RIGHT_INDEX : INTEGER RANGE 0 TO 255; 
    VARIABLE LEFT_INDEX : INTEGER RANGE 0 TO 255;
    
    BEGIN
    IF (RISING_EDGE(CLK)) THEN 
        -- DEFAULT VALUE FOR OUTPUT SIGNALS
    	DONEREADSIGNAL <= '0';
      	DONEWRITESIGNAL <= '0';
      	DONEMEMORYWRITE <= '0';
        DONEMEMORYREAD <= '0';
        
        
        LEFT_INDEX := DATASIZE - 1 + (TO_INTEGER(UNSIGNED(DISPLACEMENT))*DATASIZE) ;
      	IF (LEFT_INDEX-DATASIZE+1 = 0 ) THEN 
       		 RIGHT_INDEX := 0;
      	ELSE 
       		 RIGHT_INDEX := LEFT_INDEX-DATASIZE+1;
      	END IF; -- LEFT INDEX
        
        IF (CACHEREAD = '1') THEN 
            DATAOUT <= CACHEDATA(TO_INTEGER(UNSIGNED(INDEX)))(LEFT_INDEX DOWNTO RIGHT_INDEX);
            DONEREADSIGNAL <= '1';
        ELSIF (CACHEWRITE = '1') THEN 
            CACHEDATA(TO_INTEGER(UNSIGNED(INDEX)))(LEFT_INDEX DOWNTO RIGHT_INDEX)<= CONTROLLERDATAIN;
            DONEWRITESIGNAL <= '1';
        ELSIF (MEMORYREAD = '1') THEN 
            CACHEDATA(TO_INTEGER(UNSIGNED(INDEX)))<= RAMDATAIN;
            DONEMEMORYREAD <= '1';
        ELSIF (MEMORYWRITE = '1') THEN 
            MEMORYOUT <= CACHEDATA(TO_INTEGER(UNSIGNED(INDEX)));
            DONEMEMORYWRITE <= '1';
        ELSE
            DATAOUT <= (OTHERS=>'Z');
          
        END IF; -- IF COND. ON INPUT SIGNALS 
        
    END IF; -- FALLING EDGE
    
  END PROCESS;
    
  
END CACHEARCH;
