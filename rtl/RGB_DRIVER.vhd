
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
	constant ACTIVE: std_logic := '1';
	constant numLEDS: integer range 1 to 8 := 8;
	signal currentState: std_logic_vector(24*numLEDS-1 downto 0);

begin

	RGB_SIGNAL_PUSH: process(reset, clock)
	variable index: integer;
	variable cycles: integer;
	variable termValue: integer;
	begin
		if(currentState /= rgbIn or reset = ACTIVE) then
			termValue := 0;
			cycles := 0;
			index := 0;
			rgbOut <= not ACTIVE;
			currentState <= rgbIn;
		elsif(rising_edge(clock)) then
			if(index <= 24*numLEDS-1) then
				if(currentState(index) = ACTIVE) then
					termValue := 80;
				else
					termValue := 40;
				end if;
				
				if(cycles /= 120) then
					cycles := cycles + 1;
					if(cycles <= termValue) then
						rgbOut <= ACTIVE;
					else
						rgbOut <= not ACTIVE;
					end if;
				else
					cycles := 0;
					index := index + 1;
				end if;
			end if;
		end if;
	end process RGB_SIGNAL_PUSH;

end rgbArch;
