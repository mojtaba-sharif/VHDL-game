----------------------------------------------------------------------------------
-- Moving Square Demonstration 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_Square is
  port ( CLK_50MHz		: in std_logic;
         input : in std_logic_vector(2 downto 0);
			level : out integer ;
			gameTimeHigh : out integer;
			gameTimeLow : out integer;
			gameTimeMin : out integer;
			lose_signal : out std_logic;
			RESET				: in std_logic;
			ColorOut			: out std_logic_vector(11 downto 0); -- RED & GREEN & BLUE
			SQUAREWIDTH		: in std_logic_vector(7 downto 0);
			ScanlineX		: in std_logic_vector(10 downto 0);
			ScanlineY		: in std_logic_vector(10 downto 0)
  );
end VGA_Square;

architecture Behavioral of VGA_Square is
  --//square
  signal ColorOutput: std_logic_vector(11 downto 0);
  
  signal SquareX: std_logic_vector(9 downto 0) := "0000001110";  
  signal SquareY: std_logic_vector(9 downto 0) := "0000010111";  
  signal SquareXMoveDir, SquareYMoveDir: std_logic := '0';
  --constant SquareWidth: std_logic_vector(4 downto 0) := "11001";
  constant SquareXmin: std_logic_vector(9 downto 0) := "0000000001";
  signal SquareXmax: std_logic_vector(9 downto 0); -- := "1010000000"-SquareWidth;
  constant SquareYmin: std_logic_vector(9 downto 0) := "0000000001";
  
  signal SquareYmax: std_logic_vector(9 downto 0); -- := "0111100000"-SquareWidth;
  signal ColorSelect: std_logic_vector(2 downto 0) := "001";
  signal Prescaler: std_logic_vector(30 downto 0) := (others => '0');
  signal LoseSignal , loseSig : std_logic := '0';
  --//board
  signal counter1 : integer range 0 to 320001 := 0 ;--right side move botton debounce  counter
  signal counter2 : integer range 0 to 320001 := 0 ;--left side move botton debounce  counter
  signal boardX: std_logic_vector(9 downto 0) := "0101000000";  
  signal boardY: std_logic_vector(9 downto 0) := "0000000001";  
  constant boardWidth: std_logic_vector(5 downto 0) := "100011";-- width = 35
  constant boardTop: std_logic_vector(1 downto 0) := "11"; -- board Hight
  constant boardXmin: std_logic_vector(9 downto 0) := "0000000001";
  signal boardXmax: std_logic_vector(9 downto 0); -- := "1010000000"-SquareWidth;
  constant boardYmin: std_logic_vector(9 downto 0) := "0000000001";
  signal boardYmax: std_logic_vector(9 downto 0); -- := "0111100000"-SquareWidth;
  
  signal game_timer_HNum, game_timer_LNum ,game_timer_min : integer range 0 to 16 := 0;
  signal counter_50Hz , counter_50Hz_2,counter_1 : integer range 0 to 50000000 := 0;
  signal new_speed :  integer range 1000 to 500001:= 500000; -- start with 100ms refresh speed
signal level_counter: integer range 1 to 127 := 1;  
signal  l_counter : integer range 0 to 16 := 0;  
signal gameS : integer:=0;
signal game_enable : std_logic:='0';
signal timer_15_sec : integer range 0 to 16 := 0 ;

begin

--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
     game_starter : process (input , clk_50mhz )   -- game enable
	                begin
					     if reset = '1' then
						    game_enable <= '0';
							gameS <= 0;
					     elsif rising_edge(CLK_50MHz) then
						  if input = "110" then
						    if gameS > 0 then
							   game_enable <= '1' ;
							else
							   gameS <= GameS + 1 ;
							end if;
						  else
						  null;
						  end if;
						 else
						 null;
						 end if;
					end process;
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
					

     process (CLK_50MHz , reset , game_enable , loseSignal)  -- timer of game
	 begin
	    if reset = '1' then
		  counter_50hz <= 0;
		  game_timer_LNum <= 0;
		  game_timer_HNum <= 0;
		  game_timer_min <= 0;
		  l_counter <= 0;
		  level_counter <= 1 ;
	 else
	  if game_enable = '0' then
		  counter_50hz <= 0;
		  game_timer_LNum <= 0;
		  game_timer_HNum <= 0;
		  game_timer_min <= 0;
	  else
	 if loseSignal = '1' then
	      counter_50hz <= 0;
		  
		 elsif rising_edge(CLK_50MHz) then
		  if counter_50hz = 50000000 then
		     counter_50hz <= 0 ;
			game_timer_LNum <= game_timer_LNum + 1;
			l_counter <= l_counter + 1 ;
		   else
		     counter_50hz <= counter_50hz + 1;
		   end if;
			
		  if l_counter = 15 then
			  level_counter <= level_counter + 1 ;
			  l_counter <= 0;
			end if;
			
		  if (game_timer_LNum = 10) then 
		     game_timer_LNum <= 0 ;
			 game_timer_HNum <= game_timer_HNum + 1 ;
		   end if;
			
		  if (game_timer_HNum = 6) then 
		     game_timer_HNum <= 0;
			 game_timer_min <= game_timer_min + 1 ;
			 end if;
			 
		  if (game_timer_min = 10) then 
             game_timer_min <= 0;
			 end if;
		   end if; 
		 end if;	  
	  end if;
	 end process;
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////

process (level_counter)  --- speed creator
begin
if rising_edge(clk_50MHz) then

  case level_counter is
  when 1 =>
  new_speed <= 400000; -- 6 ms
   when 2 =>
  new_speed <= 350000;   -- 5ms
     when 3 =>
  new_speed <= 300000; -- 4 ms
     when 4 =>
  new_speed <= 250000;  --3ms
     when 5 =>
  new_speed <= 200000; -- 2ms
     when 6 =>
  new_speed <= 150000;--1ms
     when 7 =>
  new_speed <= 100000;
     when 8 =>
  new_speed <= 50000;
  when others =>
   null;
  end case;
  end if;
end process;
	

					  
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
   
	PrescalerCounter: process(CLK_50Mhz, RESET, boardX , game_enable , loseSignal )--new_speed
	begin
	 if RESET = '1' then
			Prescaler <= (others => '0');
			SquareX <= "0111000101";
			SquareY <= "0001100010";
			SquareXMoveDir <= '0';
			SquareYMoveDir <= '0';
			ColorSelect <= "001";
			
	else
	    if game_enable = '0' then
			Prescaler <= (others => '0');
			SquareX <= "0111000101";
			SquareY <= "0001100010";
			SquareXMoveDir <= '0';
			SquareYMoveDir <= '0';
			ColorSelect <= "001";		
		else
		if loseSignal = '1' then
	    SquareX <= SquareX;
		SquareY <= SquareY;
		SquareXMoveDir <= SquareXMoveDir;
		SquareYMoveDir <= SquareYMoveDir;
		ColorSelect <= ColorSelect;

		 elsif rising_edge(CLK_50Mhz) then
			Prescaler <= Prescaler + 1;
			if Prescaler = new_speed then  -- Activated at new_speed declerated time :  ....
				if SquareXMoveDir = '0' then
					if SquareX < SquareXmax then
						SquareX <= SquareX + 1;
					else
						SquareXMoveDir <= '1';
						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
					end if;
				else
					if SquareX > SquareXmin then
						SquareX <= SquareX - 1;
					else
						SquareXMoveDir <= '0';
						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
					end if;	 
				end if;
		  
				if SquareYMoveDir = '0' then   --Y direction
					if SquareY < SquareYmax then
						SquareY <= SquareY + 1;
					else
						SquareYMoveDir <= '1';
						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
					end if;
				else
					if SquareY > boardTop then
					SquareY <= SquareY - 1;
					elsif squareY = boardTop then
						if ( (SquareX + SQUAREWIDTH) >= boardX  and  (boardX + boardWidth) >= SquareX) then
						SquareYMoveDir <= '0';
						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
					    else
						SquareY <= SquareY - 1;
						end if;
					elsif (squareY < 3) then
						    LoseSig <= '1';
					end if;	 
				end if;		  
			
				Prescaler <= (others => '0');
			   end if;
		    end if;--3	
		end if;--2
	end if;--1
		
	end process PrescalerCounter;
	
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////

    
    process(CLK_50Mhz , input , reset , game_enable , loseSignal , boardX , boardY  )-- input(0) go right /// input(1) go left
    begin
        if RESET = '1' then
			counter1 <= 0;
			counter2 <= 0;
			boardX <= "0001000101";
			boardY <= "0000000001";

     else
	   if game_enable = '0' then
			counter1 <= 0;
			counter2 <= 0;
			boardX <= "0001000101";
			boardY <= "0000000001";		
		else
        if loseSignal = '1'  then
	           boardX <= boardX;
	            boardY <= boardY;
	            counter1 <= 0;
	           counter2 <= 0;
		  elsif rising_edge(CLK_50Mhz) then
		    if input = "101" then
			   counter1 <= counter1 + 1;
			   if counter1 = 320000 then
			    if boardx < boardXMax then
				   boardx <= boardX + 1;
				   counter1 <= 0;
				 else
				   boardx <= boardX;
				 end if;
			   counter1 <= 0;
			   end if;
			elsif input = "011" then
			   counter2 <= counter2 + 1;
			   if counter2 = 320000 then
			    if boardx > boardXMin then
				   boardx <= boardX - 1;
				   counter2 <= 0;
				 else
				   boardx <= boardX;
				 end if;
			   counter2 <= 0;
			   end if;				   
		  end if;	
       end if;		  
	  end if;
end if;	
end process;
	
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
	
 process (clk_50MHz , reset ,loseSig )
               begin 
				 if reset = '1' then
				   loseSignal <= '0' ;
				 elsif rising_edge(clk_50MHz)then
				   loseSignal <= loseSig;
				  end if;  
end process;

--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////				

	
		
   ColorOutput <=   "111100000000" when ColorSelect(0) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
					else	"000011110000" when ColorSelect(1) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
					else	"000000001111" when ColorSelect(2) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
				   else	"000011110000" when (ColorSelect(0) = '1' or ColorSelect(1) = '1' or ColorSelect(2) = '1') AND ScanlineX >= boardX AND ScanlineY >= boardY AND ScanlineX < boardX + boardWidth AND ScanlineY < boardY + boardTop
					else	"111111111111";

--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////

	ColorOut <= ColorOutput;

--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
	
	SquareXmax <= "1010000000"-SquareWidth; -- (640 - SquareWidth)
	
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********////////////
--********////////////************//////////////***********/////////////

	SquareYmax <= "0111100000"-SquareWidth;	-- (480 - SquareWidth)

--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
	
	boardXmax <= "1010000000"-boardWidth; -- (640 - boardWidth)

--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
	
	level <= level_counter;
	gameTimeLow <= game_timer_HNum;
	gameTimeHigh <= game_timer_LNum;
	gameTimeMin <= game_timer_min;
	lose_signal <= loseSignal;

--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
--********////////////************//////////////***********/////////////
	
end Behavioral;



------------------------------------------------------------------------------------
---- Moving Square Demonstration 
------------------------------------------------------------------------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
--entity VGA_Square is
--  port ( CLK_50MHz		: in std_logic;
--			RESET				: in std_logic;
--			ColorOut			: out std_logic_vector(11 downto 0); -- RED & GREEN & BLUE
--			SQUAREWIDTH		: in std_logic_vector(7 downto 0);
--			ScanlineX		: in std_logic_vector(10 downto 0);
--			ScanlineY		: in std_logic_vector(10 downto 0)
--  );
--end VGA_Square;
--
--architecture Behavioral of VGA_Square is
--  
--  signal ColorOutput: std_logic_vector(11 downto 0);
--  
--  signal SquareX: std_logic_vector(9 downto 0) := "0000001110";  
--  signal SquareY: std_logic_vector(9 downto 0) := "0000010111";  
--  signal SquareXMoveDir, SquareYMoveDir: std_logic := '0';
--  --constant SquareWidth: std_logic_vector(4 downto 0) := "11001";
--  constant SquareXmin: std_logic_vector(9 downto 0) := "0000000001";
--  signal SquareXmax: std_logic_vector(9 downto 0); -- := "1010000000"-SquareWidth;
--  constant SquareYmin: std_logic_vector(9 downto 0) := "0000000001";
--  signal SquareYmax: std_logic_vector(9 downto 0); -- := "0111100000"-SquareWidth;
--  signal ColorSelect: std_logic_vector(2 downto 0) := "001";
--  signal Prescaler: std_logic_vector(30 downto 0) := (others => '0');
--
--begin
--
--	PrescalerCounter: process(CLK_50Mhz, RESET)
--	begin
--		if RESET = '1' then
--			Prescaler <= (others => '0');
--			SquareX <= "0111000101";
--			SquareY <= "0001100010";
--			SquareXMoveDir <= '0';
--			SquareYMoveDir <= '0';
--			ColorSelect <= "001";
--		elsif rising_edge(CLK_50Mhz) then
--			Prescaler <= Prescaler + 1;	 
--			if Prescaler = "11000011010100000" then  -- Activated every 0,002 sec (2 msec)
--				if SquareXMoveDir = '0' then
--					if SquareX < SquareXmax then
--						SquareX <= SquareX + 1;
--					else
--						SquareXMoveDir <= '1';
--						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
--					end if;
--				else
--					if SquareX > SquareXmin then
--						SquareX <= SquareX - 1;
--					else
--						SquareXMoveDir <= '0';
--						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
--					end if;	 
--				end if;
--		  
--				if SquareYMoveDir = '0' then
--					if SquareY < SquareYmax then
--						SquareY <= SquareY + 1;
--					else
--						SquareYMoveDir <= '1';
--						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
--					end if;
--				else
--					if SquareY > SquareYmin then
--						SquareY <= SquareY - 1;
--					else
--						SquareYMoveDir <= '0';
--						ColorSelect <= ColorSelect(1 downto 0) & ColorSelect(2);
--					end if;	 
--				end if;		  
--			
--				Prescaler <= (others => '0');
--			end if;
--		end if;
--	end process PrescalerCounter; 
--
--	ColorOutput <=		"111100000000" when ColorSelect(0) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
--					else	"000011110000" when ColorSelect(1) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
--					else	"000000001111" when ColorSelect(2) = '1' AND ScanlineX >= SquareX AND ScanlineY >= SquareY AND ScanlineX < SquareX+SquareWidth AND ScanlineY < SquareY+SquareWidth 
--					else	"111111111111";
--
--	ColorOut <= ColorOutput;
--	
--	SquareXmax <= "1010000000"-SquareWidth; -- (640 - SquareWidth)
--	SquareYmax <= "0111100000"-SquareWidth;	-- (480 - SquareWidth)
--end Behavioral;

