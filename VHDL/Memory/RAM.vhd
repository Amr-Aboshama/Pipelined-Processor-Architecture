-- Code your design here
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY RAM IS
  GENERIC (ADDRESSWIDTH : INTEGER := 11; 
           RAMWIDTH : INTEGER := 16;
           RAMHEIGHT : INTEGER := 2048);
  PORT(
    CLK : IN STD_LOGIC;
    MEMREAD : IN STD_LOGIC;
    MEMWRITE : IN STD_LOGIC;
    ADDRESS : IN STD_LOGIC_VECTOR(ADDRESSWIDTH-1 DOWNTO 0);
    DATAIN : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
    DATAOUT : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
    READYSIGNAL : OUT STD_LOGIC
  );
END ENTITY RAM;

ARCHITECTURE RAMARCH OF RAM IS 
  TYPE MEMORYTYPE IS ARRAY (RAMHEIGHT-1 DOWNTO 0) OF STD_LOGIC_VECTOR (RAMWIDTH-1 DOWNTO 0);
  SIGNAL MEMORY : MEMORYTYPE;
  SIGNAL COUNTERWRITE : INTEGER RANGE 0 TO 3 := 0;
  SIGNAL COUNTERREAD : INTEGER RANGE 0 TO 3 := 0;
  SIGNAL OUTBUFFER : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL OUT1, OUT2 , OUT3, OUT4, OUT5, OUT6, OUT7, OUT8 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL INBUFFER : STD_LOGIC_VECTOR(127 DOWNTO 0);
  SIGNAL R_LATCH,W_LATCH : STD_LOGIC := '0';
  BEGIN


  PROCESS (CLK) IS
  --VARIABLE ADDRESSNUM : INTEGER RANGE 0 TO 2048 := TO_INTEGER(UNSIGNED(ADDRESS));
  BEGIN
    IF (FALLING_EDGE(CLK)) THEN
	IF (MEMWRITE = '1' OR W_LATCH = '1') THEN
		IF (COUNTERWRITE = 0)THEN
		INBUFFER <= DATAIN;
		COUNTERWRITE <= COUNTERWRITE +1;
		W_LATCH <= '1';
		ELSIF (COUNTERWRITE = 1) THEN
		MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))) <= INBUFFER(15 DOWNTO 0);
        	MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+1) <= INBUFFER(31 DOWNTO 16);
		MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+2) <= INBUFFER(47 DOWNTO 32);
		COUNTERWRITE <= COUNTERWRITE +1;
		ELSIF (COUNTERWRITE = 2) THEN
		MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+3) <= INBUFFER(63 DOWNTO 48);
		MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+4) <= INBUFFER(79 DOWNTO 64);
		MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+5) <= INBUFFER(95 DOWNTO 80);
		COUNTERWRITE <= COUNTERWRITE +1;
		ELSE 
		MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+6) <= INBUFFER(111 DOWNTO 96);
		MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+7) <= INBUFFER(127 DOWNTO 112);
		COUNTERWRITE <= 0;
		W_LATCH <= '0';
		END IF;
	ELSIF (MEMREAD = '1' OR R_LATCH = '1') THEN
		IF (COUNTERREAD = 0) THEN
		OUTBUFFER(15 DOWNTO 0) <= MEMORY(TO_INTEGER(UNSIGNED(ADDRESS)));
		OUTBUFFER(31 DOWNTO 16) <= MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+1);
		OUTBUFFER(47 DOWNTO 32) <= MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+2);
		COUNTERREAD <= COUNTERREAD +1;
		R_LATCH <= '1';
		ELSIF (COUNTERREAD = 1) THEN
		OUTBUFFER(63 DOWNTO 48) <= MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+3);
		OUTBUFFER(79 DOWNTO 64) <= MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+4);
		OUTBUFFER(95 DOWNTO 80) <= MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+5);
		COUNTERREAD <= COUNTERREAD +1;
		ELSIF (COUNTERREAD = 2) THEN
		OUTBUFFER(111 DOWNTO 96) <= MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+6);
		OUTBUFFER(127 DOWNTO 112) <= MEMORY(TO_INTEGER(UNSIGNED(ADDRESS))+7);
		COUNTERREAD <= COUNTERREAD +1;
		ELSE
		DATAOUT <= OUTBUFFER;
		COUNTERREAD <= 0;
		R_LATCH <= '0';
		END IF;
	END IF;
	
  	
    END IF;
  END PROCESS;


END RAMARCH;


