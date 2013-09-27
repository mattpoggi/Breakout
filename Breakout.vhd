LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Breakout is
    port(
		clk_50Mhz		: IN  STD_LOGIC;
		cheatKey			: IN  STD_LOGIC;
		PS2_CLK			: IN  STD_LOGIC;
		PS2_DAT			: IN  STD_LOGIC;
			
		hsync,
		vsync			: OUT  STD_LOGIC;		
		red, 
		green,
		blue			: OUT STD_LOGIC_VECTOR(3 downto 0);				
		leds1 			: OUT STD_LOGIC_VECTOR(6 downto 0); 
		leds2 			: OUT STD_LOGIC_VECTOR(6 downto 0);
		leds3 			: OUT STD_LOGIC_VECTOR(6 downto 0); 
		leds4 			: OUT STD_LOGIC_VECTOR(6 downto 0)
		);
end Breakout;

architecture Behavioral of Breakout is
			
	component Breakout_CLKGENERATOR is
	port(
		clock		: IN  STD_LOGIC;
		clock_mezzi	: OUT STD_LOGIC
		);
	end component;

	component Breakout_KEYBOARD is
	port(
		clk		: IN  STD_LOGIC;
		keyboardClock	: IN STD_LOGIC;
		keyboardData	: IN STD_LOGIC;
		keyCode		: OUT STD_LOGIC_VECTOR(7 downto 0)
		);
	end component;

	component Breakout_CONTROL is
	port(
		clk			: IN STD_LOGIC;
		cheat			: IN STD_LOGIC;
		
		keyboardData		: IN STD_LOGIC_VECTOR (7 downto 0);
		goingReady		: IN STD_LOGIC;
		movepadRight		: OUT STD_LOGIC;
		movepadLeft		: OUT STD_LOGIC;
		moveBall		: OUT STD_LOGIC;
		enable			: OUT STD_LOGIC;
		boot			: OUT STD_LOGIC;
		pauseBlinking		: OUT STD_LOGIC;
		readyBlinking		: OUT STD_LOGIC;
		forceNextLevel		: OUT STD_LOGIC
		);
	end component;

	component Breakout_DATA is
	port(
		clk			: IN STD_LOGIC;
		padGoRight		: IN STD_LOGIC;
		padGoLeft		: IN STD_LOGIC;
		moveBall		: IN STD_LOGIC;
		enable			: IN STD_LOGIC;
		bootstrap		: IN STD_LOGIC;
		forceNextLevel		: IN STD_LOGIC;

		obstacles		: OUT STD_LOGIC_VECTOR(0 to 120);
		fixed			: OUT STD_LOGIC_VECTOR(0 to 120);
		ballPositionX		: OUT INTEGER range 0 to 1000;
		ballPositionY		: OUT INTEGER range 0 to 500;
		padLEdge		: OUT INTEGER range 0 to 1000;
		padREdge		: OUT INTEGER range 0 to 1000;
		padUEdge		: OUT INTEGER range 0 to 1000;
		padDEdge		: OUT INTEGER range 0 to 1000;
		level			: OUT INTEGER range 0 to 10;
		lives			: OUT INTEGER range 0 to 10;
		northBorder		: OUT INTEGER range 0 to 500;
		southBorder		: OUT INTEGER range 0 to 500;
		westBorder		: OUT INTEGER range 0 to 1000;
		eastBorder		: OUT INTEGER range 0 to 1000;
		goingReady		: OUT STD_LOGIC;
		victory			: OUT STD_LOGIC
		);
	end component;

	component Breakout_VIEW is
	port(
		clk			: IN STD_LOGIC;
		
		obstacles		: IN STD_LOGIC_VECTOR(0 to 120);
		fixed			: IN STD_LOGIC_VECTOR(0 to 120);
		ballPositionX		: IN INTEGER range 0 to 1000;
		ballPositionY		: IN INTEGER range 0 to 500;
		padLEdge		: IN INTEGER range 0 to 1000;
		padREdge		: IN INTEGER range 0 to 1000;
		padUEdge		: IN INTEGER range 0 to 1000;
		padDEdge		: IN INTEGER range 0 to 1000;
		level			: IN INTEGER range 0 to 10;
		lives			: IN INTEGER range 0 to 10;
		northBorder		: IN INTEGER range 0 to 500;
		southBorder		: IN INTEGER range 0 to 500;
		westBorder		: IN INTEGER range 0 to 1000;
		eastBorder		: IN INTEGER range 0 to 1000;

		bootstrap		: IN STD_LOGIC;
		pauseBlinking		: IN STD_LOGIC;
		readyBlinking		: IN STD_LOGIC;
		victory			: IN STD_LOGIC;
		
		hsync,
		vsync			: OUT STD_LOGIC;
		red, 
		green,
		blue			: OUT STD_LOGIC_VECTOR(3 downto 0);	
				
		leds1 			: OUT STD_LOGIC_VECTOR(6 downto 0); 
		leds2 			: out STD_LOGIC_VECTOR(6 downto 0); 
		leds3 			: out STD_LOGIC_VECTOR(6 downto 0); 
		leds4 			: out STD_LOGIC_VECTOR(6 downto 0) 	
		);
	end component;

signal clock_25Mhz: STD_LOGIC;
signal keyCode: STD_LOGIC_VECTOR(7 downto 0);			
signal goingReady: STD_LOGIC;
signal movepadRight: STD_LOGIC;
signal movepadLeft: STD_LOGIC;
signal moveBall: STD_LOGIC;
signal enable: STD_LOGIC;
signal boot: STD_LOGIC;
signal pauseBlinking: STD_LOGIC;
signal readyBlinking: STD_LOGIC;
signal forceNextLevel: STD_LOGIC;
signal obstacles: STD_LOGIC_VECTOR(0 to 120);
signal fixed: STD_LOGIC_VECTOR(0 to 120);
signal ballPositionX: INTEGER range 0 to 1000;
signal ballPositionY: INTEGER range 0 to 500;
signal padLEdge: INTEGER range 0 to 1000;
signal padREdge: INTEGER range 0 to 1000;
signal padUEdge: INTEGER range 0 to 1000;
signal padDEdge: INTEGER range 0 to 1000;
signal level: INTEGER range 0 to 10;
signal lives: INTEGER range 0 to 10;
signal northBorder: INTEGER range 0 to 500;
signal southBorder: INTEGER range 0 to 500;
signal westBorder: INTEGER range 0 to 1000;
signal eastBorder: INTEGER range 0 to 1000;
signal victory: STD_LOGIC;

BEGIN

ClockGenerator: Breakout_CLKGENERATOR
	port map(
		clock		=> clk_50Mhz,
		clock_mezzi 	=> clock_25Mhz
		);

KeyboardController: Breakout_KEYBOARD
	port map(
		clk		=> clock_25Mhz,
		keyboardClock	=> PS2_CLK,
		keyboardData	=> PS2_DAT,	
		keyCode		=> keyCode		
		);

ControlUnit: Breakout_CONTROL
	port map(
		clk		=> clock_25Mhz,
		cheat		=> cheatKey,
		
		keyboardData	=> keyCode,	
		goingReady	=> goingReady, 
		movepadRight	=> movepadRight,
		movepadLeft	=> movepadLeft,	
		moveBall	=> moveBall,
		enable		=> enable,		
		boot		=> boot,		
		pauseBlinking	=> pauseBlinking,	
		readyBlinking	=> readyBlinking,	
		forceNextLevel	=> forceNextLevel	
		);

Datapath: Breakout_DATA
	port map(
		clk		=> clock_25Mhz,
		padGoRight	=> movepadRight,
		padGoLeft	=> movepadLeft,
		moveBall	=> moveBall,
		enable		=> enable,
		bootstrap	=> boot,
		forceNextLevel	=> forceNextLevel,

		obstacles	=> obstacles,
		fixed		=> fixed,	
		ballPositionX	=> ballPositionX,
		ballPositionY	=> ballPositionY,
		padLEdge	=> padLEdge,
		padREdge	=> padREdge,
		level		=> level,
		lives		=> lives,
		northBorder	=> northBorder,
		southBorder	=> southBorder,
		westBorder	=> westBorder,
		eastBorder	=> eastBorder,
		goingReady	=> goingReady,
		victory		=> victory	
		);

View: Breakout_VIEW
	port map(
		clk		=> clock_25Mhz,

		obstacles	=> obstacles,
		fixed		=> fixed,	
		ballPositionX	=>ballPositionX,
		ballPositionY	=> ballPositionY,
		padLEdge	=> padLEdge,
		padREdge	=> padREdge,
		padUEdge	=> padUEdge,
		padDEdge	=> padDEdge,
		level		=> level,
		lives		=> lives,
		northBorder	=> northBorder,
		southBorder	=> southBorder,
		westBorder	=> westBorder,
		eastBorder	=> eastBorder,

		bootstrap	=> boot,
		pauseBlinking	=> pauseBlinking,
		readyBlinking	=> readyBlinking,
		victory		=> victory,
		
		hsync		=> hsync,		
		vsync		=> vsync,		
		red			=> red,	
		green		=> green,		
		blue		=> blue,		
		
				
		leds1		=> leds1,		
		leds2 		=> leds2,
		leds3 		=> leds3, 
		leds4 		=> leds4 
		);



end Behavioral;