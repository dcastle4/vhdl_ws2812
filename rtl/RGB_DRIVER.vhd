--*********************************************************************
--*
--* Name: RGB_DRIVER
--* Designer: Daniel Castle (RGB data trigger added by Brad Jackson)
--*
--* Description: This RGB serializer/driver takes RGB data (formatted
--*		 as Green->Red->Blue) and serializes them according to
--*		 the format specified by the WS2812 datasheet, as
--*		 shown below:
--*
--*		 Sending a zero:
--*		   400ns	 800ns
--*	High	  ________		   
--*	Low	 |	  |________________
--*
--*		 Sending a one:
--*		        800ns	     400ns
--*	High	  ________________		   
--*	Low	 |	          |________
--*
--*
--*********************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity RGB_DRIVER is
	port(
		clock: in std_logic;
		reset: in std_logic;
		rgbIn: in std_logic_vector;
		rgbOut: out std_logic
	    );
end RGB_DRIVER;

architecture rgbArch of RGB_DRIVER is

	----active/numLEDS declarations--------------------------CONSTANTS
	constant ACTIVE: std_logic := '1';
	constant numLEDS: integer range 1 to 8 := 8;
        
	----currentState to store current RGB data-----------------SIGNALS
	signal currentState: std_logic_vector(24*numLEDS-1 downto 0);

begin

	--============================================================================
	--  Main Process
	--============================================================================

	RGB_SIGNAL_PUSH: process(reset, clock, rgbIn)

	variable index: integer;
	variable cycles: integer;
	variable termValue: integer;

	begin

		if(rgbIn /= currentState or reset = ACTIVE) then
			termValue := 0;
			cycles := 0;
			index := 0;
			rgbOut <= not ACTIVE;
			currentState <= rgbIn;

		elsif(rising_edge(clock)) then

			if(index <= 24*numLEDS-1) then

				if(currentState(index) = ACTIVE) then
					-- if current bit is active, go high for 80 cycles
					-- 80 cycles = 800ns
					termValue := 80;

				else
					-- if current bit is not active, go high for 40 cycles
					-- 40 cycles = 400ns
					termValue := 40;

				end if;

				-- count up to 120 cycles
				-- 120 cycles = 1200ns
				if(cycles /= 120) then

					cycles := cycles + 1;

					-- rgbOut is active until it reaches termValue
					if(cycles <= termValue) then

						rgbOut <= ACTIVE;
				
					else
					-- rgbOut goes low for the rest of the cycles
						rgbOut <= not ACTIVE;
				
					end if;
				else
					-- reset cycles count back to zero
					cycles := 0;
					-- increment index to next bit 
					index := index + 1;

				end if;

			end if;

		end if;

	end process RGB_SIGNAL_PUSH;

end rgbArch;
