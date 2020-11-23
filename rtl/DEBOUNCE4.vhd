
library ieee;
use ieee.std_logic_1164.all;

entity DEBOUNCE4 is
	port(
		inp: in std_logic_vector(3 downto 0);
		clk: in std_logic;
		reset: in std_logic;
		outp: out std_logic_vector(3 downto 0)
	    );
end DEBOUNCE4;

architecture rtl of DEBOUNCE4 is
	constant ACTIVE: std_logic := '1';
	constant cycles: integer := 580000;
	signal enable: std_logic;
	signal delay1, delay2, delay3: std_logic_vector(3 downto 0) := "0000";
	signal startover: std_logic := '0';

begin
	
	process(clk, reset)
	variable count: integer range 0 to cycles := 0;
	begin
		if(reset = ACTIVE) then
			delay1 <= "0000";
			delay2 <= "0000";
			delay3 <= "0000";
		elsif(rising_edge(clk)) then
			if(count = cycles) then
				enable <= ACTIVE;
				count := 0;
			else
				enable <= not ACTIVE;
				count := count + 1;
			end if;

			if(enable = ACTIVE) then
				delay1 <= inp;
				delay2 <= delay1;
				delay3 <= delay2;
			end if;

		end if;
	end process;

	outp <= delay1 and delay2 and delay3;

end rtl;
