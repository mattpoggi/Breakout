LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Breakout_CONTROL IS
PORT(   
		clk		: IN STD_LOGIC;
		cheat: IN STD_LOGIC;
		
		keyboardData: IN STD_LOGIC_VECTOR (7 downto 0);
		goingReady: IN STD_LOGIC;
		movepadRight: OUT STD_LOGIC;
		movepadLeft: OUT STD_LOGIC;
		moveBall: OUT STD_LOGIC;
		enable: OUT STD_LOGIC;
		boot: OUT STD_LOGIC;
		pauseBlinking: OUT STD_LOGIC;
		readyBlinking: OUT STD_LOGIC;
		forceNextLevel: OUT STD_LOGIC);
end  Breakout_CONTROL;

ARCHITECTURE behavior of  Breakout_CONTROL IS

BEGIN
	
	
PROCESS(clk)

constant BOOTSTRAP: STD_LOGIC_VECTOR (1 downto 0):="00";
constant PLAYING: STD_LOGIC_VECTOR (1 downto 0):="01";
constant PAUSED: STD_LOGIC_VECTOR (1 downto 0):="11";
constant READY: STD_LOGIC_VECTOR (1 downto 0):="10";

variable state: STD_LOGIC_VECTOR (1 downto 0):=BOOTSTRAP;
variable cheating: STD_LOGIC:='0';



constant padSpeed: integer range 0 to 10000000:=75000;	--MAX 10000000 più grande è, più lenta va.
constant ballSpeed: integer range 0 to 10000000:=200000; --MAX 10000000 più grande è, più lenta va.

variable cntpadSpeed: integer range 0 to 10000000;
variable cntBallSpeed: integer range 0 to 10000000;
variable start: std_logic:='0';

constant keyRESET: std_logic_vector(7 downto 0):="00101101";
constant keyPLAY: std_logic_vector(7 downto 0):="00101001";
constant keyPAUSE: std_logic_vector(7 downto 0):="01001101";
constant keyRIGHT: std_logic_vector(7 downto 0):="01110100";
constant keyLEFT: std_logic_vector(7 downto 0):="01101011";

variable nextLevel: STD_LOGIC:='0';


BEGIN
IF rising_edge(clk) THEN
	
	
	if(cheating='0' AND cheat='0') THEN
		cheating:='1';
		nextLevel:='1';
	ELSE	nextLevel:='0';	
	END IF;
	
	if(cheating='1' AND cheat='1') THEN
		cheating:='0';
	END IF;
	
	case state IS
		when BOOTSTRAP => 
			boot<='1';
			IF(keyboardData=keyPLAY) THEN
				state:=PLAYING;
				boot<='0';
				enable<='1';
			END IF;
		
		when PLAYING =>
			IF(cntpadSpeed = padSpeed)THEN
				cntpadSpeed:=0;
				case keyboardData is
					when keyRIGHT => movepadRight<='0'; movepadLeft<='1';
					when keyLEFT => movepadRight<='1'; movepadLeft<='0';
					when others => movepadRight<='1'; movepadLeft<='1';
				end case;	
			ELSE
				cntpadSpeed:=cntpadSpeed+1;
				movepadRight<='1';
				movepadLeft<='1';
			END IF;		
			IF(cntBallSpeed = ballSpeed) THEN
				cntBallSpeed:=0;
				moveBall<='1';
			ELSE
				cntBallSpeed:=cntBallSpeed+1;
				moveBall<='0';
			END IF;
				
			IF(keyboardData=keyRESET) THEN
				enable<='0';
				boot<='1';
				state:=BOOTSTRAP;
			END IF;
			IF(keyboardData=keyPAUSE) THEN
				enable<='0';
				state:=PAUSED;
			END IF;	
			
			IF (goingReady='1') THEN state:=READY; END IF;
			
		when PAUSED =>
			IF(keyboardData=keyRESET) THEN
				enable<='0';
				boot<='1';
				state:=BOOTSTRAP;
			END IF;
			IF(keyboardData=keyPLAY) THEN
				enable<='1';
				state:=PLAYING;
				boot<='0';
			END IF;	
			IF (goingReady='1') THEN state:=READY; END IF;
			
		when READY => 
			enable<='0';
			IF(keyboardData=keyPLAY) THEN
				state:=PLAYING;
				boot<='0';
				enable<='1';
			END IF;
			IF(keyboardData=keyRESET) THEN
				enable<='0';
				boot<='1';
				state:=BOOTSTRAP;
			END IF;
	END case;
	
	pauseBlinking <= state(1) AND state(0);
	readyBlinking <= NOT state(0) AND NOT nextLevel;
	forceNextLevel<= nextLevel;

	END IF;
	
END PROCESS;
END behavior;