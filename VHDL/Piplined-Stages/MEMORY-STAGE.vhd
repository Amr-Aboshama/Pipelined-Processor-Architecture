LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY MEMORY_STAGE IS 

	 PORT (
     	-- INPUTS FROM MAIN MODULE
     	CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        INTERRUPT : IN STD_LOGIC;
		ENABLE:	IN	STD_LOGIC;
		
        FETCHPC : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        EXECUTEPC : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        SIGNEXTENT : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        ALURESULT : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        
        MEMORYSIGNALS : IN STD_LOGIC_VECTOR (3 DOWNTO 0); -- 1 READ -- 1 WRITE -- 2 MUX SELECTOR
        -- PCORALU : IN STD_LOGIC; 
        GROUP1SELECTOR : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        GROUP2SELECTOR : IN STD_LOGIC;
        
        FLAGREGISTERIN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        
        -- INPUTS FROM DATAMEMORY MODULE
        DATAMEMORYDONEREAD : IN STD_LOGIC;
        DATAMEMORYDONEWRITE : IN STD_LOGIC;
        DATAMEMORYDATAOUT : IN STD_LOGIC_VECTOR (31 DOWNTO 0); 
        
        -- OUTPUTS TO DATAMEMORY MODULE
        DATAMEMORYREAD : OUT STD_LOGIC;
        DATAMEMORYWRITE : OUT STD_LOGIC;
        DATAMEMORYADDRESS : OUT STD_LOGIC_VECTOR (10 DOWNTO 0); -- 31 TO BE CHANGED
        DATAMEMORYDATAIN : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        
        -- OUTPUTS TO MAIN MODULE
        FLAGREGISTEROUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        NEWFLAGDONE : OUT STD_LOGIC;
        NEWPC : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        NEWPCDONE : OUT STD_LOGIC;
		MEMORYSTAGERESULT : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);		
		MEMORY_DONE :	OUT STD_LOGIC
        
     );

END ENTITY;

ARCHITECTURE MEMORYARCH OF MEMORY_STAGE IS 

    SIGNAL STACKPOINTER : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL READLATCH : STD_LOGIC := '0'; 
    SIGNAL WRITELATCH : STD_LOGIC := '0';    
    SIGNAL RETCOUNTER, POPCOUNTER, CALLCOUNTER, PUSHCOUNTER, RSTCOUNTER : INTEGER RANGE 0 TO 1 := 0;
    SIGNAL RTICOUNTER, INTERRUPTCOUNTER: INTEGER RANGE 0 TO 5 := 0; 
	SIGNAL STALL:	STD_LOGIC;
    BEGIN 
    
	MEMORY_DONE <= NOT STALL;


    PROCESS (CLK) IS 

    
    	VARIABLE UPPERMUXOUTPUT : INTEGER RANGE -2 TO 2;
        VARIABLE FIRSTMUXOUTPUT : STD_LOGIC_VECTOR (31 DOWNTO 0);
        VARIABLE SECONDMUXOUTPUT : STD_LOGIC_VECTOR (31 DOWNTO 0);
        VARIABLE ADDOUTPUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE DATAMEMORYDONEREAD_LATCH : STD_LOGIC;
        VARIABLE DATAMEMORYDONEWRITE_LATCH : STD_LOGIC;
        VARIABLE INTERRUPT_LATCH : STD_LOGIC; 
        VARIABLE RESET_LATCH : STD_LOGIC; 
	
        
    	BEGIN
    
    	IF (FALLING_EDGE(CLK)) THEN    
    	
    		-- DEFAULT VALUE FOR NEWPCDONE
            NEWPCDONE <= '0';
            NEWFLAGDONE <= '0';
            DATAMEMORYREAD <= '0';
			DATAMEMORYWRITE <= '0';
			STALL <= '0';
            
            -- HANDLING THE LATCHES FOR RST, INTERRUPT, MEMORYDONEREAD
        	IF (RST = '1') THEN 
            	RESET_LATCH := '1';
			END IF;
			
            IF (INTERRUPT = '1') THEN 
            	INTERRUPT_LATCH := '1';
			END IF; 
			
            IF (DATAMEMORYDONEREAD = '1') THEN 
            	DATAMEMORYDONEREAD_LATCH := '1';
			END IF;  
			
            IF (DATAMEMORYDONEWRITE = '1') THEN 
            	DATAMEMORYDONEWRITE_LATCH := '1';
            END IF;
            
            
            -- HANDLING THE RESET 
            IF (RESET_LATCH = '1' AND RSTCOUNTER = 0) THEN  
            	STACKPOINTER <= "11111111111111111111111111111111"; 
            	DATAMEMORYREAD <= '1';
            	DATAMEMORYADDRESS <= "00000000000"; 
            	RSTCOUNTER <= RSTCOUNTER +1;
            ELSIF (RESET_LATCH = '1' AND RSTCOUNTER = 1 AND DATAMEMORYDONEREAD_LATCH = '1') THEN  
            	NEWPC <= DATAMEMORYDATAOUT;
            	NEWPCDONE <= '1';
            	RSTCOUNTER <= 0; 
				RESET_LATCH := '0';
				DATAMEMORYDONEREAD_LATCH := '0';
            END IF; 
        	
        	
        	-- CONNDITIONS FOR CHANGING THE INCOMMING ADDRESS OF THE MEMORY 
        	IF ((MEMORYSIGNALS(3) = '1' AND READLATCH = '0') OR (MEMORYSIGNALS(2) = '1' AND WRITELATCH = '0') 
        	OR (INTERRUPTCOUNTER = 0 AND INTERRUPT_LATCH = '1') OR (INTERRUPTCOUNTER = 1 AND DATAMEMORYDONEWRITE_LATCH = '1')
        	OR RTICOUNTER = 2) THEN   
        	
            	-- ASSIGN UPPERMUXOUTPUT
            	IF (MEMORYSIGNALS(1 DOWNTO 0) = "00") THEN  -- RET, RTI, POP
              		  UPPERMUXOUTPUT := 2;
           		ELSIF (MEMORYSIGNALS(1 DOWNTO 0) = "01"  OR INTERRUPT_LATCH = '1') THEN -- CALL, PUSH OR INTERRUPT
             	 	  UPPERMUXOUTPUT := -2;
            	ELSIF (MEMORYSIGNALS(1 DOWNTO 0) = "10") THEN -- STD
            		  UPPERMUXOUTPUT := 0;
           		END IF; -- ASSIGN UPPERMUXOUTPUT
             
           	 	-- ASSIGN VALUES TO ADDOUTPUT AND STACKPOINTER REGISTER
            	
                ADDOUTPUT := STD_LOGIC_VECTOR(TO_SIGNED(UPPERMUXOUTPUT+TO_INTEGER(UNSIGNED(STACKPOINTER)), ADDOUTPUT'LENGTH));
                STACKPOINTER <= ADDOUTPUT;
            
            	-- ASSIGN FIRSTMUXOUTPUT
            	IF (MEMORYSIGNALS(1 DOWNTO 0) = "00" ) THEN -- RET, RTI, POP
            		FIRSTMUXOUTPUT := ADDOUTPUT ;
            	ELSIF (MEMORYSIGNALS(1 DOWNTO 0) = "01" OR INTERRUPT_LATCH = '1') THEN -- CALL, PUSH OR INTERRUPT
            		FIRSTMUXOUTPUT := STACKPOINTER; 
            	ELSIF (MEMORYSIGNALS(1 DOWNTO 0) = "10") THEN -- STD
            		FIRSTMUXOUTPUT := SIGNEXTENT;
            	END IF;  -- ASSIGN FIRSTMUXOUTPUT
            
            	--ASSIGNING SECONDMUXOUTPUT
            	IF (RST = '1') THEN
            		SECONDMUXOUTPUT := "11111111111111111111111111111111";
            	ELSE 
            		SECONDMUXOUTPUT := FIRSTMUXOUTPUT; 
            	END IF; --ASSIGNING SECONDMUXOUTPUT     
            	
            END IF; -- CONNDITIONS FOR CHANGING THE INCOMMING ADDRESS OF THE MEMORY   
            	
            
            IF (INTERRUPT_LATCH = '1') THEN  
            	IF (INTERRUPTCOUNTER = 0) THEN     
            		DATAMEMORYWRITE <= '1';
            		DATAMEMORYADDRESS <= SECONDMUXOUTPUT(10 DOWNTO 0);
            		DATAMEMORYDATAIN <= "0000000000000000000000000000" & FLAGREGISTERIN; 
            		INTERRUPTCOUNTER <= INTERRUPTCOUNTER +1;
            	ELSIF (INTERRUPTCOUNTER = 1 AND DATAMEMORYDONEWRITE_LATCH = '1') THEN     
            		DATAMEMORYWRITE <= '1';
            		DATAMEMORYADDRESS <= SECONDMUXOUTPUT(10 DOWNTO 0);
            		DATAMEMORYDATAIN <= FETCHPC;
            		DATAMEMORYDONEWRITE_LATCH := '0';  
            		INTERRUPTCOUNTER <= INTERRUPTCOUNTER +1;
            	ELSIF (INTERRUPTCOUNTER = 2 AND DATAMEMORYDONEWRITE_LATCH = '1') THEN   
            		DATAMEMORYREAD <= '1';
            		DATAMEMORYADDRESS <= "00000000010";  -- ADDRESS OF ISR 
					INTERRUPTCOUNTER <= INTERRUPTCOUNTER +1;
					DATAMEMORYDONEWRITE_LATCH := '0';
            	ELSIF (INTERRUPTCOUNTER = 3 AND DATAMEMORYDONEREAD_LATCH = '1') THEN 
            		INTERRUPTCOUNTER <= INTERRUPTCOUNTER +1;  
            	ELSIF (INTERRUPTCOUNTER = 4 AND DATAMEMORYDONEREAD_LATCH = '1') THEN 
            		NEWPC <= DATAMEMORYDATAOUT;  
            		NEWPCDONE <= '1';
            		DATAMEMORYDONEREAD_LATCH := '0';
            		INTERRUPTCOUNTER <= 0; 
            		INTERRUPT_LATCH := '0';
            	END IF;           
            END IF;
             
			IF(ENABLE = '1') THEN

				STALL <= '1';
				IF(MEMORYSIGNALS(3) = '1') THEN -- MEMORY READ      
					-- FIRST CYCLE FOR EITHER (RET, RTI, POP)
					IF (READLATCH = '0') THEN  -- WHEN COUNTERS = 0 
						DATAMEMORYREAD <= '1';
						DATAMEMORYADDRESS <= SECONDMUXOUTPUT(10 DOWNTO 0); 
						READLATCH <= '1'; 
						IF (GROUP1SELECTOR = "00") THEN   
							RETCOUNTER <= RETCOUNTER +1;
						ELSIF (GROUP1SELECTOR = "01") THEN 
							RTICOUNTER <= RTICOUNTER +1;
						ELSIF (GROUP1SELECTOR = "10") THEN 
							POPCOUNTER <= POPCOUNTER +1;
						END IF;
						
					END IF;  
					
					-- SECOND CYCLE FOR EITHER (RET, RTI)
					IF (((GROUP1SELECTOR = "00" AND RETCOUNTER = 1) OR (GROUP1SELECTOR = "01" AND RTICOUNTER = 1 )) AND DATAMEMORYDONEREAD_LATCH = '1' ) THEN
						NEWPC <= DATAMEMORYDATAOUT;
						NEWPCDONE <= '1';
						DATAMEMORYDONEREAD_LATCH := '0';  
						IF (GROUP1SELECTOR = "00") THEN
							RETCOUNTER <= 0; 
							READLATCH <= '0';
							STALL <= '0'; 
						ELSE
							RTICOUNTER <= RTICOUNTER +1;
						END IF;  
						
					END IF; 
					
					-- SECOND CYCLE FOR POP 
					IF (GROUP1SELECTOR = "10" AND POPCOUNTER = 1 AND DATAMEMORYDONEREAD_LATCH = '1') THEN 
							MEMORYSTAGERESULT <= DATAMEMORYDATAOUT;
							DATAMEMORYDONEREAD_LATCH := '0';
							POPCOUNTER <= 0; 
							READLATCH <= '0';
							STALL <= '0'; 
					END IF;
					
					-- THIRD CYCLE FOR RTI 
					IF (GROUP1SELECTOR = "01" AND RETCOUNTER = 2) THEN  
						DATAMEMORYREAD <= '1';
						DATAMEMORYADDRESS <= SECONDMUXOUTPUT(10 DOWNTO 0); 
						RETCOUNTER <= RETCOUNTER +1;
					END IF; 
					
					-- FOURTH CYCLE FOR RTI 
					IF (GROUP1SELECTOR = "01" AND RETCOUNTER = 3 AND DATAMEMORYDONEREAD_LATCH = '1' ) THEN  
						FLAGREGISTEROUT <= DATAMEMORYDATAOUT(3 DOWNTO 0);
						NEWFLAGDONE <= '1';
						DATAMEMORYDONEREAD_LATCH := '0';
						RTICOUNTER <= 0; 
						READLATCH <= '0';
						STALL <= '0'; 
					END IF;
					
				ELSIF (MEMORYSIGNALS(2) = '1') THEN  -- MEMORY WRITE   
					-- FIRST CYCLE FOR EITHER CALL OR PUSH 
					IF (WRITELATCH = '0') THEN   
						DATAMEMORYWRITE <= '1';
						DATAMEMORYADDRESS <= SECONDMUXOUTPUT(10 DOWNTO 0); 
						WRITELATCH <= '1';
						IF (GROUP2SELECTOR = '0')  THEN  -- CALL 
							DATAMEMORYDATAIN <= EXECUTEPC;
							CALLCOUNTER <= CALLCOUNTER +1;
						ELSE   -- PUSH   
							DATAMEMORYDATAIN <= ALURESULT;
							PUSHCOUNTER <= PUSHCOUNTER +1;
						END IF;
					END IF; -- FIRST CYCLE FOR EITHER CALL OR PUSH 
					
					-- SECOND CYCLE FOR EITHER CALL OR PUSH 
					IF ((CALLCOUNTER = 1 OR PUSHCOUNTER = 1) AND DATAMEMORYDONEWRITE_LATCH = '1') THEN   
						IF (CALLCOUNTER = 1) THEN  
							NEWPC <= ALURESULT;
							NEWPCDONE <= '1'; 
							CALLCOUNTER <= 0;
						ELSE  
							MEMORYSTAGERESULT <= ALURESULT;
							PUSHCOUNTER <= 0;
						END IF; 
						WRITELATCH <= '0';
						DATAMEMORYDONEWRITE_LATCH := '0';
						STALL <= '0'; 
					END IF; -- SECOND CYCLE FOR EITHER CALL OR PUSH 
				
				ELSE				-- NO READ OR WRITE
					STALL <= '0';

				END IF; -- READ OR WRITE
				
			END IF; -- ENABLE
            
        END IF; -- FALLING EDGE

    END PROCESS;
	

END MEMORYARCH;
