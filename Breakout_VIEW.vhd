LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Breakout_VIEW IS
PORT(   
		clk		: IN STD_LOGIC;	
		obstacles: IN STD_LOGIC_VECTOR(0 to 120);
		fixed: IN STD_LOGIC_VECTOR(0 to 120);
		ballPositionX: IN INTEGER range 0 to 1000;
		ballPositionY: IN INTEGER range 0 to 500;
		padLEdge: IN INTEGER range 0 to 1000;
		padREdge: IN INTEGER range 0 to 1000;
		padUEdge: IN INTEGER range 0 to 1000;
		padDEdge: IN INTEGER range 0 to 1000;
		level: IN INTEGER range 0 to 10;
		lives: IN INTEGER range 0 to 10;
		northBorder: IN INTEGER range 0 to 500;
		southBorder: IN INTEGER range 0 to 500;
		westBorder: IN INTEGER range 0 to 1000;
		eastBorder: IN INTEGER range 0 to 1000;
		
		bootstrap: IN STD_LOGIC;
		pauseBlinking: IN STD_LOGIC;
		readyBlinking: IN STD_LOGIC;
		victory: IN STD_LOGIC;
		
		hsync,
		vsync		: OUT STD_LOGIC;
		red, 
		green,
		blue		: out std_logic_vector(3 downto 0);
				
	leds1 : out std_logic_vector(6 downto 0); -- uscita 7 bit x 7 segmenti
	leds2 : out std_logic_vector(6 downto 0); -- uscita 7 bit x 7 segmenti
	leds3 : out std_logic_vector(6 downto 0); -- uscita 7 bit x 7 segmenti
	leds4 : out std_logic_vector(6 downto 0)); -- uscita 7 bit x 7 segmenti		
		
end  Breakout_VIEW;

ARCHITECTURE behavior of  Breakout_VIEW IS
		
BEGIN	
	
PROCESS(clk)

variable cntScrittaLampeggiante: integer range 0 to 16000000;
variable scrittaLampeggia: STD_LOGIC:='0';

constant writeCoords: integer range 0 to 500:=300;

constant Pause_p_Coords: integer range 0 to 1000:=300;
constant Pause_a_Coords: integer range 0 to 1000:=306;
constant Pause_u_Coords: integer range 0 to 1000:=312;
constant Pause_s_Coords: integer range 0 to 1000:=318;
constant Pause_e_Coords: integer range 0 to 1000:=324;

constant Ready_r_Coords: integer range 0 to 1000:=300;
constant Ready_e_Coords: integer range 0 to 1000:=306;
constant Ready_a_Coords: integer range 0 to 1000:=312;
constant Ready_d_Coords: integer range 0 to 1000:=318;
constant Ready_y_Coords: integer range 0 to 1000:=324;
constant Ready_Q_Coords: integer range 0 to 1000:=330;

constant gameOver_g_Coords: integer range 0 to 1000:=282;
constant gameOver_a_Coords: integer range 0 to 1000:=288;
constant gameOver_m_Coords: integer range 0 to 1000:=294;
constant gameOver_e_Coords: integer range 0 to 1000:=300;
constant gameOver_o_Coords: integer range 0 to 1000:=312;
constant gameOver_v_Coords: integer range 0 to 1000:=318;
constant gameOver_e2_Coords: integer range 0 to 1000:=324;
constant gameOver_r_Coords: integer range 0 to 1000:=330;

constant youWin_y_Coords: integer range 0 to 1000:=288;
constant youWin_o_Coords: integer range 0 to 1000:=294;
constant youWin_u_Coords: integer range 0 to 1000:=300;
constant youWin_w_Coords: integer range 0 to 1000:=312;
constant youWin_i_Coords: integer range 0 to 1000:=318;
constant youWin_n_Coords: integer range 0 to 1000:=324;
constant youWin_e_Coords: integer range 0 to 1000:=330;		

-- bordo schermo
variable leftBorder:integer range 0 to 1000;
variable rightBorder:integer range 0 to 1000;
variable upBorder: integer range 0 to 500;	
variable downBorder: integer range 0 to 500;	

variable h_sync: STD_LOGIC;
variable v_sync: STD_LOGIC;
			--Video Enables
variable 	video_en	: STD_LOGIC; 
variable	horizontal_en	: STD_LOGIC;
variable	vertical_en	: STD_LOGIC;
			-- segnali colori RGB a 4 bit
variable	red_signal		: std_logic_vector(3 downto 0); 
variable	green_signal	: std_logic_vector(3 downto 0);
variable	blue_signal		: std_logic_vector(3 downto 0);
			--Sync Counters
variable 	h_cnt: integer range 0 to 1000;
variable	v_cnt : integer range 0 to 500;


BEGIN
IF rising_edge(clk) THEN
	
		IF (bootstrap='1') THEN	--reset
			leds1<="0000000";
			leds2<="0000000";
			leds3<="0000000";
			leds4<="0000000";	
			upBorder:= northBorder;
			downBorder:= southBorder;
			leftBorder:= westBorder;
			rightBorder:= eastBorder;
		END IF;

		--Horizontal Sync
		
			--Reset Horizontal Counter	(resettato al valore 799, anzich� 640, per rispettare i tempi di Front Porch)
			-- Infatti (799-639)/25000000 = 3.6 us = 3.8(a)+1.9(b)+0.6(d)	
		IF (h_cnt = 799) THEN
				h_cnt := 0;
			ELSE
				h_cnt := h_cnt + 1;
		END IF;

			--Sfondo
		IF (v_cnt >= 0) AND (v_cnt <= 479) THEN
			red_signal:= "0000";		
			green_signal:= "0000";
			blue_signal:= "0000";
		END IF;

	--pad drawing
		--clear screen
--		IF (v_cnt >= 430) AND (v_cnt <= 440) AND (h_cnt >= padLEdge-1) AND (h_cnt <= padLEdge) THEN
--			red_signal(3) := '0';		red_signal(2) := '0';		red_signal(1) := '0';		red_signal(0) := '0';		
--			green_signal(3) := '0'; 	green_signal(2) := '0'; 	green_signal(1) := '0'; 	green_signal(0) := '0';
--			blue_signal(3) := '0';	blue_signal(2) := '0';	blue_signal(1) := '0';	blue_signal(0) := '0';	
--		END IF;
		
		
		-- fine clear screen	
		--pad

		IF (v_cnt >= 430) AND (v_cnt <= 440) AND (h_cnt >= padLEdge) AND (h_cnt <= padREdge) THEN
			red_signal:= "0000";
			green_signal:= "0000";
			blue_signal:= "1111";
		END IF;
		
		
	-- fine pad drawing			

	-- ball drawing

				IF (v_cnt = ballPositionY OR v_cnt = ballPositionY+11) AND (h_cnt >= ballPositionX-6-2 AND h_cnt <= ballPositionX-6+1) THEN
					red_signal:= "1000";		
					green_signal:= "1000";
					blue_signal:= "0000";
				END IF;
				
				IF (v_cnt = ballPositionY+1 OR v_cnt = ballPositionY+10) AND (h_cnt = ballPositionX-6-4 OR h_cnt = ballPositionX-6+3) THEN
					red_signal:= "1000";		
					green_signal:= "1000";
					blue_signal:= "0000";		
				END IF;	
				IF (v_cnt = ballPositionY+1 OR v_cnt = ballPositionY+10) AND (h_cnt = ballPositionX-6-3 OR h_cnt = ballPositionX-6+2) THEN
					red_signal:= "1000";		
					green_signal:= "1000";
					blue_signal:= "0000";		
				END IF;	
					
				IF (v_cnt = ballPositionY+2 OR v_cnt = ballPositionY+3 OR v_cnt = ballPositionY+9 OR v_cnt = ballPositionY+8) AND ((h_cnt = ballPositionX-6-5) OR (h_cnt = ballPositionX-6+4)) THEN
					red_signal:= "1000";		
					green_signal:= "1000";
					blue_signal:= "0000";					
				END IF;	
				
				IF (v_cnt >= ballPositionY+4 AND v_cnt <= ballPositionY+7) AND (h_cnt = ballPositionX-6-6 OR h_cnt = ballPositionX-6+5) THEN
					red_signal:= "1000";		
					green_signal:= "1000";
					blue_signal:= "0000";				
				END IF;	
				--
				
				
				
				
				IF (v_cnt = ballPositionY+1 OR v_cnt = ballPositionY+10) AND (h_cnt >= ballPositionX-6-2 AND h_cnt <= ballPositionX-6+1) THEN
					red_signal:= "1001";		
					green_signal:= "1001";
					blue_signal:= "0001";				
				END IF;
				
				IF (v_cnt = ballPositionY+2 OR v_cnt = ballPositionY+9) AND (h_cnt >= ballPositionX-6-4 AND h_cnt <= ballPositionX-6+3) THEN
					red_signal:= "1001";		
					green_signal:= "1001";
					blue_signal:= "0001";	
				END IF;	
					
				IF (v_cnt = ballPositionY+3 OR v_cnt = ballPositionY+8) AND (h_cnt = ballPositionX-6-4 OR h_cnt = ballPositionX-6+3 OR h_cnt = ballPositionX-6-3 OR h_cnt = ballPositionX-6+2) THEN
					red_signal:= "1001";		
					green_signal:= "1001";
					blue_signal:= "0001";	
				END IF;	
				
				IF (v_cnt >= ballPositionY+4 AND v_cnt <= ballPositionY+7) AND (h_cnt = ballPositionX-6-5 OR h_cnt = ballPositionX-6+4 OR h_cnt = ballPositionX-6-4 OR h_cnt = ballPositionX-6+3) THEN
					red_signal:= "1001";		
					green_signal:= "1001";
					blue_signal:= "0001";				
				END IF;	
				--
			
			
			
			
				IF (v_cnt = ballPositionY+3 OR v_cnt = ballPositionY+8) AND (h_cnt >= ballPositionX-6-2 AND h_cnt <= ballPositionX-6+1 ) THEN
					red_signal:= "1010";		
					green_signal:= "1010";
					blue_signal:= "0010";					
				END IF;	
				
				IF (v_cnt = ballPositionY+4 OR v_cnt = ballPositionY+7) AND (h_cnt = ballPositionX-6-3 OR h_cnt = ballPositionX-6-2 OR h_cnt = ballPositionX-6+1 OR h_cnt = ballPositionX-6+2) THEN
										red_signal:= "1010";		
					green_signal:= "1010";
					blue_signal:= "0010";			
				END IF;	
				IF (v_cnt = ballPositionY+5 OR v_cnt = ballPositionY+6) AND (h_cnt = ballPositionX-6-3 OR h_cnt = ballPositionX-6+2) THEN
										red_signal:= "1010";		
					green_signal:= "1010";
					blue_signal:= "0010";						
				END IF;	
				--
			
				IF (v_cnt = ballPositionY+4 OR v_cnt = ballPositionY+7) AND (h_cnt = ballPositionX-6-1 OR h_cnt = ballPositionX-6) THEN
					red_signal:= "1010";		
					green_signal:= "1010";
					blue_signal:= "0010";	
				END IF;	
				IF (v_cnt = ballPositionY+5 OR v_cnt = ballPositionY+6) AND (h_cnt = ballPositionX-6-2 OR h_cnt = ballPositionX-6+1) THEN
					red_signal:= "1010";		
					green_signal:= "1010";
					blue_signal:= "0010";		
				END IF;	
				--
			
			
				IF (v_cnt = ballPositionY+5 OR v_cnt = ballPositionY+6) AND (h_cnt = ballPositionX-6-1 OR h_cnt = ballPositionX-6) THEN
					red_signal:= "1100";		
					green_signal:= "1100";
					blue_signal:= "0100";		
				END IF;			
				IF (v_cnt = ballPositionY+5) AND (h_cnt = ballPositionX-6) THEN
					red_signal:= "1100";		
					green_signal:= "1100";
					blue_signal:= "0100";		
				END IF;				
				
-- fine ball drawing				
		IF (readyBlinking='1' and victory='0') THEN
			IF(cntScrittaLampeggiante = 10000000)THEN	
				cntScrittaLampeggiante := 0;
				scrittaLampeggia :=NOT scrittaLampeggia;
			ELSE	
				cntScrittaLampeggiante := cntScrittaLampeggiante  + 1;
			END IF;
			IF(scrittaLampeggia='1') THEN
		--READY draw
			--R
			IF ((v_cnt >= writeCoords AND v_cnt<=310) AND ((h_cnt = Ready_r_Coords))) OR
				((v_cnt = writeCoords OR v_cnt = writeCoords+5  OR v_cnt = writeCoords+7 ) AND ((h_cnt = Ready_r_Coords+1))) OR
				((v_cnt = writeCoords OR v_cnt = writeCoords+5  OR v_cnt = writeCoords+8 ) AND ((h_cnt = Ready_r_Coords+2))) OR
				((v_cnt = writeCoords OR v_cnt = writeCoords+4  OR v_cnt = writeCoords+9 ) AND ((h_cnt = Ready_r_Coords+3))) OR
				((v_cnt = writeCoords+1 OR v_cnt = writeCoords+2 OR v_cnt = writeCoords+3  OR v_cnt = 310 ) AND ((h_cnt = Ready_r_Coords+4))) THEN	
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
				END IF;			
			-- fine R

			--E
				IF (((v_cnt = writeCoords OR v_cnt = 310)) AND ((h_cnt >= Ready_e_Coords) AND (h_cnt <= Ready_e_Coords+4))) OR
				(((v_cnt = writeCoords+5)) AND ((h_cnt >= Ready_e_Coords) AND (h_cnt <= Ready_e_Coords+3))) OR
				(((h_cnt = Ready_e_Coords)) AND ((v_cnt >= writeCoords) AND (v_cnt <= 310))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";		
				END IF;
			-- fine E

			--A
				IF (((v_cnt = writeCoords OR v_cnt = writeCoords+5)) AND ((h_cnt >= Ready_a_Coords+1) AND (h_cnt <= Ready_a_Coords+3))) OR
				(((h_cnt = Ready_a_Coords OR h_cnt = Ready_a_Coords+4)) AND ((v_cnt >= writeCoords+1) AND (v_cnt <= 310))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";					
				END IF;

			-- fine A

			--D
				IF (((v_cnt = writeCoords OR v_cnt = 310)) AND ((h_cnt >= Ready_d_Coords) AND (h_cnt <= Ready_d_Coords+3))) OR 
					(((h_cnt = Ready_d_Coords)) AND ((v_cnt >= writeCoords) AND (v_cnt <= 310))) OR
					(((h_cnt = Ready_d_Coords+4)) AND ((v_cnt >= writeCoords+1) AND (v_cnt <= writeCoords+9)))THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
				END IF;
			-- fine D

			--Y
				IF (((v_cnt = writeCoords)) AND ((h_cnt = Ready_y_Coords) OR (h_cnt = Ready_y_Coords+4))) OR
				(((v_cnt = writeCoords+1)) AND ((h_cnt = Ready_y_Coords+1) OR (h_cnt = Ready_y_Coords+3)))OR 
				(((h_cnt = Ready_y_Coords+2)) AND ((v_cnt >= writeCoords+2) AND (v_cnt <= 310)))THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";			
				END IF;
			-- fine Y
			
			--?
				IF (((v_cnt = writeCoords)) AND ((h_cnt >= Ready_Q_Coords+1 AND h_cnt<=Ready_Q_Coords+3))) OR (h_cnt = Ready_Q_Coords+3 AND (v_cnt=writeCoords+9 OR v_cnt=writeCoords+7 OR v_cnt=writeCoords+6)) OR
				(h_cnt = Ready_Q_Coords AND (v_cnt=writeCoords+1 OR v_cnt=writeCoords+2)) OR (h_cnt = Ready_Q_Coords+3 AND (v_cnt=writeCoords+4 OR v_cnt=writeCoords+5)) OR 
				(h_cnt = Ready_Q_Coords+4 AND (v_cnt>=writeCoords+1 AND v_cnt<=writeCoords+3)) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";		
				END IF;
			-- fine ?			
			END IF;

			-- fine READY draw
			END IF;
			
				
		if(pauseBlinking='1' and victory='0') THEN
			IF(cntScrittaLampeggiante = 10000000)THEN	
				cntScrittaLampeggiante := 0;
				scrittaLampeggia :=NOT scrittaLampeggia;
			ELSE	
				cntScrittaLampeggiante := cntScrittaLampeggiante  + 1;
			END IF;
			IF(scrittaLampeggia='1') THEN
			--PAUSE draw
			--P
				IF (((v_cnt = writeCoords)) AND ((h_cnt >= Pause_p_Coords) AND (h_cnt <= Pause_p_Coords+3))) OR
					(((h_cnt = Pause_p_Coords)) AND ((v_cnt >= writeCoords) AND (v_cnt <= writeCoords+10))) OR
					(((v_cnt >= writeCoords+1) AND (v_cnt <=writeCoords+2 )) AND ((h_cnt = Pause_p_Coords+4))) OR
					((v_cnt = writeCoords+3) AND ((h_cnt = Pause_p_Coords+3))) OR
					((v_cnt = writeCoords+4) AND ((h_cnt >= Pause_p_Coords+1)AND (h_cnt <= Pause_p_Coords+2)))	
				  THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
				END IF;			
			-- fine P
			--A
				IF (((v_cnt = writeCoords OR v_cnt = writeCoords+5)) AND ((h_cnt >= Pause_a_Coords+1) AND (h_cnt <= Pause_a_Coords+3))) OR
				(((h_cnt = Pause_a_Coords OR h_cnt = Pause_a_Coords+4)) AND ((v_cnt >= writeCoords+1) AND (v_cnt <= writeCoords+10))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";				
				END IF;

			-- fine A
			--U
				IF (((v_cnt = writeCoords+10)) AND ((h_cnt >= Pause_u_Coords+1) AND (h_cnt <= Pause_u_Coords+3))) OR
				(((h_cnt = Pause_u_Coords OR h_cnt = Pause_u_Coords+4)) AND ((v_cnt >= writeCoords) AND (v_cnt <= writeCoords+9))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
				END IF;
			-- fine U		
			--S
				IF (((v_cnt = writeCoords OR v_cnt = writeCoords+5 OR v_cnt =writeCoords+10)) AND ((h_cnt >= Pause_s_Coords+1) AND (h_cnt <= Pause_s_Coords+3))) OR
					(((v_cnt >= writeCoords+1 AND v_cnt<=writeCoords+4) OR v_cnt =writeCoords+9) AND (h_cnt = Pause_s_Coords)) OR
					(((v_cnt >= writeCoords+6 AND v_cnt<=writeCoords+9) OR v_cnt = writeCoords+1) AND (h_cnt = Pause_s_Coords+4))THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";		
				END IF;
			-- fine S
			--E
				IF (((v_cnt = writeCoords OR v_cnt = writeCoords+10)) AND ((h_cnt >= Pause_e_Coords) AND (h_cnt <= Pause_e_Coords+4))) OR
				(((v_cnt = writeCoords+5)) AND ((h_cnt >= Pause_e_Coords) AND (h_cnt <= Pause_e_Coords+3))) OR
				(((h_cnt = Pause_e_Coords)) AND ((v_cnt >= writeCoords) AND (v_cnt <= writeCoords+10))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";			
				END IF;
			-- fine E
			END IF;
		-- fine PAUSE draw
		
		END IF;
	

		
		
-----------------------------------------------------------------------TESTI

		IF(lives=0) THEN
		-- GAME OVER draw
		--G
			IF (((v_cnt = writeCoords OR v_cnt = 310)) AND ((h_cnt >= gameOver_g_Coords+1) AND (h_cnt <= gameOver_g_Coords+3))) OR
				(((h_cnt = gameOver_g_Coords+4 )) AND ((v_cnt = writeCoords+1) OR (v_cnt = writeCoords+9) OR (v_cnt = writeCoords+8) OR (v_cnt = writeCoords+7))) OR
				(((h_cnt = gameOver_g_Coords )) AND ((v_cnt >= writeCoords+1) AND (v_cnt <= writeCoords+9))) OR
				(((v_cnt = writeCoords+7 )) AND ((h_cnt >= gameOver_g_Coords+2) AND (h_cnt <= gameOver_g_Coords+4))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";		
			END IF;
		-- fine G
		--A
			IF (((v_cnt = writeCoords OR v_cnt = writeCoords+5)) AND ((h_cnt >= gameOver_a_Coords+1) AND (h_cnt <= gameOver_a_Coords+3))) OR
			(((h_cnt = gameOver_a_Coords OR h_cnt = gameOver_a_Coords+4)) AND ((v_cnt >= writeCoords+1) AND (v_cnt <= 310))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
			END IF;
		-- fine A
		--M
			IF (((h_cnt = gameOver_m_Coords OR h_cnt = gameOver_m_Coords+4)) AND ((v_cnt >= writeCoords) AND (v_cnt <= 310))) OR
			(((h_cnt = gameOver_m_Coords+1 OR h_cnt = gameOver_m_Coords+3) AND (v_cnt >= writeCoords+1) AND (v_cnt <= writeCoords+2)) )OR
			((h_cnt = gameOver_m_Coords+2) AND (v_cnt >= writeCoords+2) AND (v_cnt <= writeCoords+3)) OR 
			((h_cnt = gameOver_m_Coords+2) AND (v_cnt >= writeCoords+2) AND (v_cnt <= writeCoords+3)) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";			
			END IF;
		-- fine M
		--E
			IF (((v_cnt = writeCoords OR v_cnt = 310)) AND ((h_cnt >= gameOver_e_Coords) AND (h_cnt <= gameOver_e_Coords+4))) OR
			(((v_cnt = writeCoords+5)) AND ((h_cnt >= gameOver_e_Coords) AND (h_cnt <= gameOver_e_Coords+3)))OR 
			(((h_cnt = gameOver_e_Coords)) AND ((v_cnt >= writeCoords) AND (v_cnt <= 310)))THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
			END IF;
		-- fine E
		--0
			IF (((v_cnt = writeCoords OR v_cnt = 310)) AND ((h_cnt >= gameOver_o_Coords+1) AND (h_cnt <= gameOver_o_Coords+3))) OR
				(((h_cnt = gameOver_o_Coords OR h_cnt = gameOver_o_Coords+4)) AND ((v_cnt >= writeCoords+1) AND (v_cnt <= writeCoords+9))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";		
			END IF;
		-- fine 0
		--V
			IF ((v_cnt >= writeCoords AND v_cnt <= writeCoords+5) AND ((h_cnt = gameOver_v_Coords) OR (h_cnt = gameOver_v_Coords+4))) OR
				((v_cnt >= writeCoords+5 AND v_cnt <= writeCoords+7) AND ((h_cnt = gameOver_v_Coords+1) OR (h_cnt = gameOver_v_Coords+3))) OR 
				((v_cnt >= writeCoords+8 AND v_cnt <= 310) AND ((h_cnt = gameOver_v_Coords+2))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
			END IF;
		-- fine V
		--E
			IF (((v_cnt = writeCoords OR v_cnt = 310)) AND ((h_cnt >= gameOver_e2_Coords) AND (h_cnt <= gameOver_e2_Coords+4))) OR
			(((v_cnt = writeCoords+5)) AND ((h_cnt >= gameOver_e2_Coords) AND (h_cnt <= gameOver_e2_Coords+3))) OR
			(((h_cnt = gameOver_e2_Coords)) AND ((v_cnt >= writeCoords) AND (v_cnt <= 310))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";		
			END IF;
		-- fine E
		--R
			IF ((v_cnt >= writeCoords AND v_cnt<=310) AND ((h_cnt = gameOver_r_Coords))) OR
				((v_cnt = writeCoords OR v_cnt = writeCoords+5  OR v_cnt = writeCoords+7 ) AND ((h_cnt = gameOver_r_Coords+1))) OR
				((v_cnt = writeCoords OR v_cnt = writeCoords+5  OR v_cnt = writeCoords+8 ) AND ((h_cnt = gameOver_r_Coords+2))) OR
				((v_cnt = writeCoords OR v_cnt = writeCoords+4  OR v_cnt = writeCoords+9 ) AND ((h_cnt = gameOver_r_Coords+3))) OR
				((v_cnt = writeCoords+1 OR v_cnt = writeCoords+2 OR v_cnt = writeCoords+3  OR v_cnt = 310 ) AND ((h_cnt = gameOver_r_Coords+4))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
			END IF;
		-- fine R

		-- fine GAME OVER draw
		END IF;
		-- You Win
			IF(victory='1' and not (lives=0)) THEN
			--Y
				IF (((v_cnt = writeCoords)) AND ((h_cnt = youWin_y_Coords) OR (h_cnt = youWin_y_Coords+4))) OR
				(((v_cnt = writeCoords+1)) AND ((h_cnt = youWin_y_Coords+1) OR (h_cnt = youWin_y_Coords+3)))OR 
				(((h_cnt = youWin_y_Coords+2)) AND ((v_cnt >= writeCoords+2) AND (v_cnt <= 310)))THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
				END IF;
			-- fine Y			
		--0
			IF (((v_cnt = writeCoords OR v_cnt = 310)) AND ((h_cnt >= youWin_o_Coords+1) AND (h_cnt <= youWin_o_Coords+3))) OR
				(((h_cnt = youWin_o_Coords OR h_cnt = youWin_o_Coords+4)) AND ((v_cnt >= writeCoords+1) AND (v_cnt <= writeCoords+9))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";		
			END IF;
		-- fine 0			
			--U
				IF (((v_cnt = 310)) AND ((h_cnt >= youWin_u_Coords+1) AND (h_cnt <= youWin_u_Coords+3))) OR 
				(((h_cnt = youWin_u_Coords OR h_cnt = youWin_u_Coords+4)) AND ((v_cnt >= writeCoords) AND (v_cnt <= writeCoords+9))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";			
				END IF;
			-- fine U		
			--W
				IF (((h_cnt = youWin_w_Coords OR h_cnt = youWin_w_Coords+4)) AND ((v_cnt >= writeCoords) AND (v_cnt <= writeCoords+9))) OR
					(((h_cnt = youWin_w_Coords+1 OR h_cnt = youWin_w_Coords+3)) AND ((v_cnt = 310)))OR 
					(((h_cnt = youWin_w_Coords+2)) AND ((v_cnt >= writeCoords+6) AND v_cnt<=writeCoords+9))THEN
						red_signal:= "0000";		
						green_signal:= "1000";
						blue_signal:= "1000";	
				END IF;

			-- fine W	
			--I
				IF (((v_cnt = writeCoords OR v_cnt = 310)) AND ((h_cnt >= youWin_i_Coords+1) AND (h_cnt <= youWin_i_Coords+3))) OR
					(((h_cnt = youWin_i_Coords+2)) AND ((v_cnt >= writeCoords) AND (v_cnt <= 310))) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
				END IF;
			-- fine I	
			--N
				IF (((h_cnt = youWin_n_Coords OR h_cnt = youWin_n_Coords+4)) AND ((v_cnt >=writeCoords) AND (v_cnt <= 310))) OR
					((h_cnt = youWin_n_Coords+1) AND (v_cnt >= writeCoords+1) AND (v_cnt <= writeCoords+2)) OR
					(((h_cnt = youWin_n_Coords+2) AND (v_cnt >= writeCoords+3) AND (v_cnt <= writeCoords+4))) OR
					((h_cnt = youWin_n_Coords+3) AND (v_cnt >= writeCoords+5) AND (v_cnt <= writeCoords+6)) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
				END IF;
			-- fine N			
			--!
				IF (((v_cnt >= writeCoords AND v_cnt<writeCoords+8)) AND ((h_cnt = youWin_e_Coords+3) )) OR
					(((v_cnt = 310)) AND ((h_cnt = youWin_e_Coords+3) )) THEN
					red_signal:= "0000";		
					green_signal:= "1000";
					blue_signal:= "1000";	
				END IF;
			-- fine !
							
			END IF;
		--You Win
	
-------------------------------------------------------------------------FINE TESTI		


--
----LEFT
--				IF ((h_cnt >= leftBorder-10 AND h_cnt <= leftBorder-8)  AND (v_cnt >= upBorder-10 AND v_cnt <= downBorder+10)) THEN
--								red_signal:= "0000";
--								green_signal:= "0000";
--								blue_signal:= "1111";		
--				END IF;
--				IF ((h_cnt >= leftBorder-2 AND h_cnt <= leftBorder)  AND (v_cnt >= upBorder-2 AND v_cnt <= downBorder+2)) THEN
--								red_signal:= "0000";
--								green_signal:= "0000";
--								blue_signal:= "1111";					
--				END IF;
--				-- fine LEFT
--				
--				
--				-- RIGHT
--				IF ((h_cnt >= rightBorder+8 AND h_cnt <= rightBorder+10)  AND (v_cnt >= upBorder-10 AND v_cnt <= downBorder+10)) THEN
--								red_signal:= "0000";
--								green_signal:= "0000";
--								blue_signal:= "1111";		
--				END IF;
--				IF ((h_cnt >= rightBorder AND h_cnt <= rightBorder+2)  AND (v_cnt >= upBorder-2 AND v_cnt <= downBorder+2)) THEN
--								red_signal:= "0000";
--								green_signal:= "0000";
--								blue_signal:= "1111";					
--				END IF;
--				-- fine RIGHT
--				
--				-- UP				
--				IF ((h_cnt >= leftBorder-10 AND h_cnt <= rightBorder+10)  AND (v_cnt >= upBorder-10 AND v_cnt <= upBorder-8)) THEN
--								red_signal:= "0000";
--								green_signal:= "0000";
--								blue_signal:= "1111";		
--				END IF;
--				IF ((h_cnt >= leftBorder-2 AND h_cnt <= rightBorder+2)  AND (v_cnt >= upBorder-2 AND v_cnt <= upBorder)) THEN
--								red_signal:= "0000";
--								green_signal:= "0000";
--								blue_signal:= "1111";					
--				END IF;
--				-- fine UP
--
--				--DOWN
--				IF ((h_cnt >= leftBorder-10 AND h_cnt <= rightBorder+10)  AND (v_cnt >= downBorder+10 AND v_cnt <= downBorder+8)) THEN
--								red_signal:= "0000";
--								green_signal:= "0000";
--								blue_signal:= "1111";		
--				END IF;
--				IF ((h_cnt >= leftBorder-2 AND h_cnt <= rightBorder+2)  AND (v_cnt >= downBorder+2 AND v_cnt <= downBorder)) THEN
--								red_signal:= "0000";
--								green_signal:= "0000";
--								blue_signal:= "1111";					
--				END IF;
--				-- fine DOWN
	

---BORDO SCHERMO
				--LEFT
				IF ((h_cnt = leftBorder-10)  AND ((v_cnt >= upBorder-4) AND (v_cnt <= downBorder+4))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";	
				END IF;
				IF ((h_cnt = leftBorder-9)  AND ((v_cnt >= upBorder-6) AND (v_cnt <= downBorder+6))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";				
				END IF;
				IF ((h_cnt = leftBorder-8)  AND ((v_cnt >= upBorder-7) AND (v_cnt <= downBorder+7))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";			
				END IF;
				IF ((h_cnt = leftBorder-7)  AND ((v_cnt >= upBorder-5) AND (v_cnt <= downBorder+5))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";			
				END IF;
				IF ((h_cnt = leftBorder-6)  AND ((v_cnt >= upBorder-5) AND (v_cnt <= downBorder+5))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";			
				END IF;
				IF ((h_cnt = leftBorder-5)  AND ((v_cnt >= upBorder-4) AND (v_cnt <= downBorder+4))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";			
				END IF;
				IF ((h_cnt = leftBorder-4)  AND ((v_cnt >= upBorder-3) AND (v_cnt <= downBorder+3))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";			
				END IF;
				IF ((h_cnt = leftBorder-3)  AND ((v_cnt >= upBorder-2) AND (v_cnt <= downBorder+2))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";			
				END IF;
				IF ((h_cnt = leftBorder-2)  AND ((v_cnt >= upBorder-1) AND (v_cnt <= downBorder+1))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";		
				END IF;
				IF ((h_cnt = leftBorder-1)  AND ((v_cnt >= upBorder) AND (v_cnt <= downBorder))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";		
				END IF;
				IF ((h_cnt = leftBorder)  AND ((v_cnt >= upBorder) AND (v_cnt <= downBorder))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";		
				END IF;
				-- fine LEFT
				
				
				-- RIGHT
				IF ((h_cnt = RightBorder)  AND ((v_cnt >= upBorder-4) AND (v_cnt <= downBorder+4))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";	
				END IF;
				IF ((h_cnt = RightBorder-1)  AND ((v_cnt >= upBorder-6) AND (v_cnt <= downBorder+6))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";				
				END IF;
				IF ((h_cnt = RightBorder-2)  AND ((v_cnt >= upBorder-7) AND (v_cnt <= downBorder+7))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";						
				END IF;--
				IF ((h_cnt = RightBorder-3)  AND ((v_cnt >= upBorder-5) AND (v_cnt <= downBorder+5))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";			
				END IF;
				IF ((h_cnt = RightBorder-4)  AND ((v_cnt >= upBorder-6) AND (v_cnt <= downBorder+6))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";			
				END IF;
				IF ((h_cnt = RightBorder-5)  AND ((v_cnt >= upBorder-5) AND (v_cnt <= downBorder+5))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";				
				END IF;
				IF ((h_cnt = RightBorder-6)  AND ((v_cnt >= upBorder-4) AND (v_cnt <= downBorder+4))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";				
				END IF;
				IF ((h_cnt = RightBorder-7)  AND ((v_cnt >= upBorder-3) AND (v_cnt <= downBorder+3))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";				
				END IF;
				IF ((h_cnt = RightBorder-8)  AND ((v_cnt >= upBorder-2) AND (v_cnt <= downBorder+2))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";			
				END IF;
				IF ((h_cnt = RightBorder-9)  AND ((v_cnt >= upBorder-1) AND (v_cnt <= downBorder+1))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";	
				END IF;
				IF ((h_cnt = RightBorder-10)  AND ((v_cnt >= upBorder) AND (v_cnt <= downBorder))) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					
				END IF;
				-- fine RIGHT
				
				-- UP				
				IF ((v_cnt = upBorder-10 )) AND ((h_cnt >= leftBorder-4) AND (h_cnt <= rightBorder-6)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";			
				END IF;
				IF ((v_cnt = upBorder-9 )) AND ((h_cnt >= leftBorder-6) AND (h_cnt <= rightBorder-4)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = upBorder-8 )) AND ((h_cnt >= leftBorder-7) AND (h_cnt <= rightBorder-3)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = upBorder-7 )) AND ((h_cnt >= leftBorder-8) AND (h_cnt <= rightBorder-3)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = upBorder-6 )) AND ((h_cnt >= leftBorder-7) AND (h_cnt <= rightBorder-3)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = upBorder-5 )) AND ((h_cnt >= leftBorder-5) AND (h_cnt <= rightBorder-6)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = upBorder-4 )) AND ((h_cnt >= leftBorder-4) AND (h_cnt <= rightBorder-7)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = upBorder-3 )) AND ((h_cnt >= leftBorder-3) AND (h_cnt <= rightBorder-8)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = upBorder-2 )) AND ((h_cnt >= leftBorder-2) AND (h_cnt <= rightBorder-9)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = upBorder-1 )) AND ((h_cnt >= leftBorder-1) AND (h_cnt <= rightBorder-10)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = upBorder )) AND ((h_cnt >= leftBorder) AND (h_cnt <= rightBorder-10)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				-- fine UP

				--DOWN
				IF ((v_cnt = downBorder+10)) AND ((h_cnt >= leftBorder-4) AND (h_cnt <= rightBorder-6)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = downBorder+9 )) AND ((h_cnt >= leftBorder-6) AND (h_cnt <= rightBorder-4)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = downBorder+8 )) AND ((h_cnt >= leftBorder-7) AND (h_cnt <= rightBorder-3)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = downBorder+7 )) AND ((h_cnt >= leftBorder-8) AND (h_cnt <= rightBorder-3)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = downBorder+6 )) AND ((h_cnt >= leftBorder-7) AND (h_cnt <= rightBorder-3)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = downBorder+5 )) AND ((h_cnt >= leftBorder-5) AND (h_cnt <= rightBorder-6)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = downBorder+4 )) AND ((h_cnt >= leftBorder-4) AND (h_cnt <= rightBorder-7)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = downBorder+3 )) AND ((h_cnt >= leftBorder-3) AND (h_cnt <= rightBorder-8)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = downBorder+2 )) AND ((h_cnt >= leftBorder-2) AND (h_cnt <= rightBorder-9)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = downBorder+1 )) AND ((h_cnt >= leftBorder-1) AND (h_cnt <= rightBorder-10)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				IF ((v_cnt = downBorder )) AND ((h_cnt >= leftBorder) AND (h_cnt <= rightBorder-10)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";					END IF;
				-- fine DOWN

--- fine BORDO SCHERMO

--obstacles drawing
		FOR I IN 0 to 120 LOOP
			IF (obstacles(i) = '1') THEN
				IF(fixed(i)='1') THEN
					IF (	(v_cnt >= 1+upBorder+10*(i  /  11)+1) AND (v_cnt <= 1+upBorder+10*(i  /  11)+9) AND (h_cnt >= 1+leftBorder+50*(i mod 11)+1) AND (h_cnt <= 1+leftBorder+50*(i mod 11)+48)) THEN
								red_signal:= "0000";
								green_signal:= "0000";
								blue_signal:= "1111";		
					END IF;	
				ELSIF ((v_cnt >= 1+upBorder+10*(i  /  11)+1) AND (v_cnt <= 1+upBorder+10*(i  /  11)+9) AND (h_cnt >= 1+leftBorder+50*(i mod 11)+1) AND (h_cnt <= 1+leftBorder+50*(i mod 11)+48))  THEN
					IF(i mod 2= 0) THEN
					case level is
						when 1 =>   	
								red_signal:= "1000";		
								green_signal:= "0000";
								blue_signal:= "0000";	
						when 2 =>   	
								red_signal:= "0000";		
								green_signal:= "1000";
								blue_signal:= "0000";	
						when 3 =>   	
								red_signal:= "1100";		
								green_signal:= "0110";
								blue_signal:= "0010";
						when others =>	red_signal(3) := '1';		red_signal(2) := '0';		red_signal(1) := '0';		red_signal(0) := '0';		
										green_signal(3) := '0';	green_signal(2) := '0';	green_signal(1) := '0';	green_signal(0) := '0';
										blue_signal(3) := '1';	blue_signal(2) := '0';	blue_signal(1) := '0';	blue_signal(0) := '0';				
						end case;							
					ELSE
					case level is
						when 1 =>   	
								red_signal:= "1000";		
								green_signal:= "1000";
								blue_signal:= "0000";
						when 2 =>   	
								red_signal:= "0000";		
								green_signal:= "1000";
								blue_signal:= "1000";	
						when 3 =>   	
								red_signal:= "1000";		
								green_signal:= "0000";
								blue_signal:= "1000";	
						when others =>   	
								red_signal:= "1111";		
								green_signal:= "1111";
								blue_signal:= "1111";				
						end case;			
					END IF;
				END IF;
			END IF;
		END LOOP;		
-- fine obstacles drawing		

			--Generazione segnale hsync (rispettando la specifica temporale di avere un ritardo "a" di 3.8 us fra un segnale e l'altro)
			--Infatti (659-639)/25000000 = 0.6 us, ossia il tempo di Front Porch "d". (755-659)/25000000 = 3.8, ossia il tempo "a"
		IF (h_cnt <= 755) AND (h_cnt >= 659) THEN
			h_sync := '0';
		ELSE
			h_sync := '1';
		END IF;
		
		--Vertical Sync

			--Reset Vertical Counter. Non ci si ferma a 480 per rispettare le specifiche temporali
			--Infatti (524-479)= 45 = 2(a)+33(b)+10(d) righe
		IF (v_cnt >= 524) AND (h_cnt >= 699) THEN
			v_cnt := 0;
		ELSIF (h_cnt = 699) THEN
			v_cnt := v_cnt + 1;
		END IF;
		
			--Generazione segnale vsync (rispettando la specifica temporale di avere un ritardo "a" di due volte il tempo di riga us fra un segnale e l'altro)
		IF (v_cnt = 490 OR v_cnt = 491) THEN
			v_sync := '0';	
			
		ELSE
			v_sync := '1';
		END IF;
		
			--Generazione Horizontal Data Enable (dati di riga validi, ossia nel range orizzontale 0-639)
		IF (h_cnt <= 639) THEN
			horizontal_en := '1';
		ELSE
			horizontal_en := '0';
		END IF;
		
			--Generazione Vertical Data Enable (dati di riga validi, ossia nel range verticale 0-479)
		IF (v_cnt <= 479) THEN
			vertical_en := '1';
		ELSE
			vertical_en := '0';
		END IF;
		
			video_en := horizontal_en AND vertical_en;

		
	-- Assegnamento segnali fisici a VGA
	red(0)		<= red_signal(0) AND video_en;
	green(0)  	<= green_signal(0) AND video_en;
	blue(0)		<= blue_signal(0) AND video_en;
	red(1)		<= red_signal(1) AND video_en;
	green(1)  	<= green_signal(1) AND video_en;
	blue(1)		<= blue_signal(1) AND video_en;
	red(2)		<= red_signal(2) AND video_en;
	green(2)    <= green_signal(2) AND video_en;
	blue(2)		<= blue_signal(2) AND video_en;
	red(3)		<= red_signal(3) AND video_en;
	green(3) 	<= green_signal(3) AND video_en;
	blue(3)		<= blue_signal(3) AND video_en;
	hsync		<= h_sync;
	vsync		<= v_sync;

	leds2 <= not"1000000";
	leds4 <= not"0111000";
			case level is
					when 1 => leds3 <= not"0000110";
					when 2 => leds3 <= not"1011011";
					when 3 => leds3 <= not"1001111";
					when others => NULL;
				end case;
				
			case lives is
					when 0 => leds1 <= not"0111111";
					when 1 => leds1 <= not"0000110"; 
					when 2 => leds1 <= not"1011011";
					when 3 => leds1 <= not"1001111"; 
					when others => NULL;
				end case;
END IF;
END PROCESS;
END behavior;