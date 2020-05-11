LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY CACHECONTROLLER IS 
  GENERIC (DATASIZE : INTEGER := 16);
  PORT (
    -- INPUTS FROM MAIN MODULE
  	CLK : IN STD_LOGIC;
    ADDRESSIN : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
    DATAIN :  IN STD_LOGIC_VECTOR (DATASIZE-1 DOWNTO 0);
    READSIGNAL : IN STD_LOGIC;
    WRITESIGNAL : IN STD_LOGIC;
    -- INPUTS FROM RAM
    MEMORYREADY : IN STD_LOGIC;
    MEMORYDONEWRITING : IN STD_LOGIC;
    -- INPUTS FROM CACHE
    CACHEDONEMEMORYREAD :IN STD_LOGIC;
    CACHEDONEMEMORYWRITE :IN STD_LOGIC;
    -- OUTPUTS TO RAM
    MEMREAD : OUT STD_LOGIC;
    MEMWRITE : OUT STD_LOGIC;
    ADDRESSOUT : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
    -- OUTPUTS TO CACHE  
    CACHEREAD : OUT STD_LOGIC;
    CACHEWRITE : OUT STD_LOGIC;
    CACHETOMEMWRITE : OUT STD_LOGIC;
    CACHEFROMMEMREAD : OUT STD_LOGIC;
    INDEX : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
    DISPLACEMENT : OUT STD_LOGIC_VECTOR (2 DOWNTO 0 );
    CONTROLLERDATAOUT : OUT STD_LOGIC_VECTOR (DATASIZE-1 DOWNTO 0)   
  );
  
END ENTITY CACHECONTROLLER;  


ARCHITECTURE CONTROLLERARCH OF CACHECONTROLLER IS 

	-- COMPLEMENTARY CACHE TABLE
	TYPE TAGSTYPE IS ARRAY (31 DOWNTO 0) OF STD_LOGIC_VECTOR (2 DOWNTO 0);
  	TYPE DISPLACEMENTTYPE IS ARRAY (31 DOWNTO 0) OF STD_LOGIC_VECTOR (2 DOWNTO 0);
  	SIGNAL TAGS : TAGSTYPE;
  	SIGNAL DISP : DISPLACEMENTTYPE;
    SIGNAL VALID : STD_LOGIC_VECTOR(31 DOWNTO 0);
  	SIGNAL DIRTY: STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- SELF LATCH FOR READ AND WRITE SIGNALS
    SIGNAL WRITESELFLATCH : STD_LOGIC := '0';
  	SIGNAL READSELFLATCH : STD_LOGIC := '0';
    -- REGISTERS TO KEEP ADDRESS AND DATA WHEN READ/ WRITE = 1
    SIGNAL ADDRESSBUFFER : STD_LOGIC_VECTOR (10 DOWNTO 0);
  	SIGNAL DATAINBUFFER : STD_LOGIC_VECTOR (DATASIZE-1 DOWNTO 0);
    -- COUNTERS  // RANGES WILL CHANGE
    SIGNAL COUNTERWRITE0 : INTEGER RANGE 0 TO 5 := 0;
	SIGNAL COUNTERWRITE1 : INTEGER RANGE 0 TO 9 := 0;
    SIGNAL COUNTERREAD0 : INTEGER RANGE 0 TO 5 :=0;
    SIGNAL COUNTERREAD1 : INTEGER RANGE 0 TO 5 :=0;
    -- DIRTYBIT KEYS 
    SIGNAL DIRTYTRIGGER1 : STD_LOGIC := '0';
  	SIGNAL DIRTYTRIGGER2 : STD_LOGIC := '0';
    
    BEGIN
    
    

  	PROCESS (CLK) IS
		
        BEGIN
        
        IF (READSIGNAL = '1' OR WRITESIGNAL = '1') THEN
          ADDRESSBUFFER <= ADDRESSIN;
          DATAINBUFFER <= DATAIN;
        END IF; -- IF EITHER READ OR WRITE UPDATE ADDRESSBUFFER AND DATAINBUFFER
      
        IF ( FALLING_EDGE(CLK)) THEN
        	-- DEFAULT VALUE FOR OUTPUT SIGALS
            MEMREAD <= '0';
            MEMWRITE <= '0';
            CACHEREAD <= '0';
            CACHEWRITE <= '0';
            CACHETOMEMWRITE <= '0';
    		CACHEFROMMEMREAD <= '0';
            
            IF (READSIGNAL = '1' OR READSELFLATCH = '1') THEN  -- IF READ IS REQUESTED
            	IF (VALID(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) = '1' AND TAGS(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) = ADDRESSBUFFER(10 DOWNTO 8)) THEN  -- IF READ HIT
                	INDEX <= ADDRESSBUFFER(7 DOWNTO 3);
                    DISPLACEMENT <= ADDRESSBUFFER(2 DOWNTO 0);
                    CACHEREAD <= '1';
                ELSE  -- IF READ MISS
                    IF (DIRTY(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) = '1' AND DIRTYTRIGGER1 = '0') THEN -- DIRTY BIT SET
                      IF (COUNTERREAD0 = 0) THEN -- WRITE TO MEMORY (CACHE TO MEMORY)
                        CACHETOMEMWRITE <= '1';
                        INDEX <= ADDRESSBUFFER(7 DOWNTO 3);
                        MEMWRITE <= '1';
                        ADDRESSOUT <= TAGS(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) & ADDRESSBUFFER(7 DOWNTO 3) & "000";
                        READSELFLATCH <= '1';
                        COUNTERREAD0 <= COUNTERREAD0 +1;
                      ELSIF (COUNTERREAD0 = 1 AND CACHEDONEMEMORYWRITE = '1') THEN -- CACHE FINISHED WRITING INTO RAM
                        DIRTYTRIGGER1 <= '1';
                        COUNTERREAD0 <= 0;
              	      END IF; -- END IF COUNTERREAD0
                      
                      
                    ELSIF (DIRTY(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) /= '1' AND DIRTYTRIGGER1 = '1') THEN -- NOT DIRTY
                    	IF ( COUNTERREAD1 = 0) THEN -- WRITE TO CACHE (MEMORY TO CACHE)
                          MEMREAD <= '1';
                          ADDRESSOUT <= ADDRESSBUFFER(10 DOWNTO 3) & "000";
                          COUNTERREAD1 <= COUNTERREAD1 +1;
                          READSELFLATCH <= '1';
                  	ELSIF (COUNTERREAD1 = 1 AND MEMORYREADY = '1') THEN -- LET THE CACHE READ THE DATA FROM RAM
                          CACHEFROMMEMREAD <= '1';
                          COUNTERREAD1 <= COUNTERREAD1 +1;
                          INDEX <= ADDRESSBUFFER(7 DOWNTO 3);
                        ELSIF (COUNTERREAD1 = 2 AND CACHEDONEMEMORYREAD = '1' ) THEN -- LET THE CACHE OUTPUT THE REQUIRED DATA
                          CACHEREAD <= '1';
                          INDEX <= ADDRESSBUFFER(7 DOWNTO 3);
                          DISPLACEMENT <= ADDRESSBUFFER(2 DOWNTO 0);
                          TAGS(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) <= ADDRESSBUFFER(10 DOWNTO 8);
                          DISP(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) <= ADDRESSBUFFER(2 DOWNTO 0);
                          DIRTY(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) <= '0';
                          VALID(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) <= '1';
                          READSELFLATCH <= '0';
                          DIRTYTRIGGER1 <= '0';
                          COUNTERREAD1 <= 0;
                        END IF; -- COUNTERREAD1 IF     
                    
                    END IF; -- IF DIRTY OR NOT
            	END IF; -- HIT OR MISS 

            ELSIF (WRITESIGNAL = '1' OR WRITESELFLATCH = '1') THEN -- IF WRITE IS REQUESTED 
            	IF (VALID(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) = '1' AND TAGS(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) = ADDRESSBUFFER(10 DOWNTO 8) ) THEN -- WRITE AND HIT 
                	CACHEWRITE <= '1';
                  	INDEX <= ADDRESSBUFFER(7 DOWNTO 3);
        			DISPLACEMENT <= ADDRESSBUFFER(2 DOWNTO 0);
        			CONTROLLERDATAOUT <= DATAINBUFFER;
                    DISP(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) <= ADDRESSBUFFER(2 DOWNTO 0);
      				DIRTY(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) <= '1';
        			VALID(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) <= '1';
                ELSE -- WRITE AND MISS 
                    IF (DIRTY(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) = '1' AND DIRTYTRIGGER2 = '0') THEN -- DIRTY BIT IS SET 
                    	IF(COUNTERWRITE0 = 0) THEN -- WRITE TO MEMORY (CACHE TO MEMORY)
                        	CACHETOMEMWRITE <= '1';
                            INDEX <= ADDRESSBUFFER(7 DOWNTO 3);
                            MEMWRITE <= '1';
                            ADDRESSOUT <= TAGS(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) & ADDRESSBUFFER(7 DOWNTO 3) & "000";
                    		WRITESELFLATCH <= '1';
                            COUNTERWRITE0 <= COUNTERWRITE0 +1;
                        ELSIF (COUNTERWRITE0 = 1 AND CACHEDONEMEMORYWRITE = '1') THEN --
                            DIRTYTRIGGER2 <= '1';
                            COUNTERWRITE0 <= 0;
                        END IF; -- IF FOR COUNTERWRITE0
                    ELSIF (DIRTY(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) /= '1' OR DIRTYTRIGGER2 = '1') THEN-- DIRTYBIT IS NOT SET
                    	IF (COUNTERWRITE1 = 0) THEN  --WRITE TO CACHE (MEMORY TO CACHE)
                            MEMREAD <= '1';
                            ADDRESSOUT <= ADDRESSIN(10 DOWNTO 3) & "000";
                            WRITESELFLATCH <= '1';
                            COUNTERWRITE1 <= COUNTERWRITE1 +1;
                        ELSIF ( COUNTERWRITE1 = 1 AND MEMORYREADY = '1') THEN  -- LET THE CACHE READ THE DATA
                        	CACHEFROMMEMREAD <= '1';
                          COUNTERWRITE1 <= COUNTERWRITE1 +1;
                          INDEX <= ADDRESSBUFFER(7 DOWNTO 3);

                        -- ELSIF (COUNTERWRITE1 = 2)  THEN                      
                        --   COUNTERWRITE1 <= COUNTERWRITE1 +1;

                        ELSIF ( COUNTERWRITE1 = 2 AND CACHEDONEMEMORYREAD = '1') THEN -- WRITE INTO CACHE THE NEW DATAIN
                            CACHEWRITE <= '1';
                            CONTROLLERDATAOUT <= DATAINBUFFER;
                            INDEX <= ADDRESSBUFFER(7 DOWNTO 3);
                            DISPLACEMENT <= ADDRESSBUFFER(2 DOWNTO 0);
                            TAGS(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) <= ADDRESSBUFFER(10 DOWNTO 8);
                            DISP(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) <= ADDRESSBUFFER(2 DOWNTO 0);
                            VALID(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) <= '1';
                            DIRTY(TO_INTEGER(UNSIGNED(ADDRESSBUFFER(7 DOWNTO 3)))) <= '1';
                            WRITESELFLATCH <= '0';
                        	DIRTYTRIGGER2 <= '0';
                            COUNTERWRITE1 <= 0;
                       END IF; -- IF FOR COUNTERWRITE1
                       
                 END IF; -- DIRTY BIT   
		END IF; -- HIT OR MISS 
            END IF; -- READ OR WRITE
            
            
        END IF; -- FALLING EDGE
      
    END PROCESS;  

END CONTROLLERARCH;
