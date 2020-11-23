
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP_MODULE is
	port(
		 clk:	in std_logic;
		 btnC:	in std_logic;
		 btnU:	in std_logic;
		 btnD:	in std_logic;
		 btnL:	in std_logic;
		 btnR:	in std_logic;
		 sw:	in std_logic_vector(15 downto 0);
		 seg:	in std_logic_vector(6 downto 0);
		 an:	in std_logic_vector(3 downto 0);
		 JB:	in std_logic_vector(0 downto 0)

	    );
end TOP_MODULE;

architecture topArch of TOP_MODULE is

	constant ACTIVE: std_logic := '1';
	constant numLEDS: integer range 1 to 8 := 8;
	constant red:		std_logic_vector(23 downto 0) := X"00FF00";
	constant orange:	std_logic_vector(23 downto 0) := X"003366";
	constant yellow:	std_logic_vector(23 downto 0) := X"00FFFF";
	constant green:		std_logic_vector(23 downto 0) := X"0000FF";
	constant teal:		std_logic_vector(23 downto 0) := X"FF00FF";
	constant blue:		std_logic_vector(23 downto 0) := X"FF0000";
	constant purple:	std_logic_vector(23 downto 0) := X"993200";
	constant pink:		std_logic_vector(23 downto 0) := X"FFFF00";
	constant magenta:	std_logic_vector(23 downto 0) := X"FEFF00";	
	constant blank:		std_logic_vector(23 downto 0) := X"000000";


	signal numACTIVELEDS: integer range 1 to 8 := 1;
	signal reset: std_logic;
	signal color: std_logic_vector(23 downto 0);
	signal previewcolor: std_logic_vector(23 downto 0);
	signal previewenable: std_logic := '0';
	signal rgbSignal: std_logic_vector(24*numLEDS-1 downto 0);
	signal rgbBuild: std_logic_vector(24*numLEDS-1 downto 0);
	signal rgbFade: unsigned(23 downto 0);
	signal buttonarrayin: std_logic_vector(3 downto 0);
	signal colorselect: integer range 0 to 7 := 0;
	signal limiter: std_logic := '0';
	signal colortext: unsigned(31 downto 0);
	signal ledposition: integer range 1 to 8 := 1;
	signal customlights: std_logic_vector(191 downto 0) := (others=>'0');


	component RGB_DRIVER is
		port(
			clock: in std_logic;
			reset: in std_logic;
			rgbIn: in std_logic_vector(24*numLEDS-1 downto 0);
			rgbOut: out std_logic
		    );
	end component;

	component DEBOUNCE4 is
		port(
			inp: in std_logic_vector(3 downto 0);
			clk: in std_logic;
			reset: in std_logic;
			outp: out std_logic_vector(3 downto 0)
		    );
	end component;

	component SEVEN_SEG is
		port(
			clk: in std_logic;
			input: in unsigned(31 downto 0);
			seg: out std_logic_vector(6 downto 0);
			an: out std_logic_vector(3 downto 0)
		    );
	end component;

begin
	reset <= btnC;
	buttonarrayin <= btnL & btnR & btnD & btnU;
	numACTIVELEDS <= to_integer(unsigned(sw(3 downto 0)));

	LIMIT_1_PRESS: process(clk, reset)
	begin
		if(buttonarrayout = "0000" and limiter = not ACTIVE) then
			limiter <= ACTIVE;
		end if;

		if(reset = ACTIVE) then
			colorselect <= 0;
			limiter <= not ACTIVE;
		elsif(rising_edge(clk)) then
			if(buttonarrayout = "0001" and limiter = ACTIVE) then
				colorselect <= colorselect + 1;
				limiter <= not ACTIVE;
			elsif(buttonarrayout = "0010" and limiter = ACTIVE) then
				colorselect <= colorselect - 1;
				limiter <= not ACTIVE;
			elsif(buttonarrayout = "1000" and limiter = ACTIVE) then
				ledposition <= ledposition + 1;
				limiter <= not ACTIVE;
			elsif(buttonarrayout = "0100" and limiter = ACTIVE) then
				ledposition <= ledposition - 1;
				limiter <= not ACTIVE;
			end if;
		end if;
	end process LIMIT_1_PRESS;

	COLOR_SELECT: process (clk, reset)
	begin
		if(reset = ACTIVE) then
			colorselect <= 0;
		elsif(rising_edge(clk)) then
			case colorselect is
				when 0 =>
					previewcolor <= red;
					colortext <= X"241B0E0D";
				when 1 =>
					previewcolor <= orange;
					colortext <= X"181B1710";
				when 2 =>
					previewcolor <= yellow;
					colortext <= X"220E1518";
				when 3 =>
					previewcolor <= green;
					colortext <= X"24101B17";
				when 4 =>
					previewcolor <= teal;
					colortext <= X"1D0E0A15";
				when 5 =>
					previewcolor <= blue;
					colortext <= X"0B151E0E";
				when 6 =>
					previewcolor <= purple;
					colortext <= X"191E1B19";
				when 7 =>
					previewcolor <= magenta;
					colortext <= X"170E1817";
				when others  =>
					previewcolor <= blank;
			end case;

			if(sw(14) = ACTIVE) then
				colortext <= X"0F0A0D0E";
			end if;
		end if;
	end process COLOR_SELECT;

	RGB_FADE: process(clk, reset)
	variable count3: integer := 0;
	variable colorcycle: integer := 0;
	begin
		if(rising_edge(clk)) then
			if(count3 = 10000000) then
				if(colorcycle = 0) then
					rgbFade <= unsigned(color);
					colorcycle := 1;
				elsif(colorcycle = 1) then
					if(rgbFade > 1) then
						rgbFade <= rgbFade/2 - 4;
					elsif(rgbFade = 0) then
						colorcycle := 0;
					else
						colorcycle := 0;
					end if;
				end if;
			count3 := 0;
			else
				count3 := count3 + 1;
			end if;
		end if;
	end process RGB_FADE;

	LIGHT_NUMACTIVELEDS: process(clk, reset)
	variable count: integer range 1 to numLEDS+1 := 1;
	variable count2: integer range 0 to 100000000 := 0;
	variable outputcolor: std_logic_vector(23 downto 0);
	variable currentcolor: std_logic_vector(23 downto 0);
	begin
		if(reset = ACTIVE) then
			count := 1;
			count2 := 0;
			color <= previewcolor; -- no mode switches active
		elsif(rising_edge(clk)) then
			if(sw(15) = not ACTIVE and sw(14) = not ACTIVE and sw(13) = not ACTIVE) then
				if(previewcolor /= color) then
					outputcolor := previewcolor;
				else
					outputcolor := color;
				end if;

				if(count <= numACTIVELEDS) then
					rgbBuild((24*count)-1 downto 24*(count-1)) <= outputcolor;
					count := count + 1;
				elsif(count > numACTIVELEDS and count <= numLEDS) then
					rgbBuild((24*count)-1 downto 24*(count-1)) <= blank;
					count := count + 1;
				elsif(count > numLEDS) then
					rgbSignal <= rgbBuild;
					count := 1;
				end if;
			elsif(sw(15) = not ACTIVE and sw(14) = ACTIVE and sw(13) = not ACTIVE) then
				outputcolor := std_logic_vector(rgbFade);
				if(count <= numACTIVELEDS) then
					rgbBuild((24*count)-1 downto 24*(count-1)) <= outputcolor;
					count := count + 1;
				elsif(count > numACTIVELEDS and count <= numLEDS) then
					rgbBuild((24*count)-1 downto 24*(count-1)) <= blank;
					count := count + 1;
				elsif(count > numLEDS) then
					rgbSignal <= rgbBuild;
					count := 1;
				end if;
			
			elsif(sw(15) = ACTIVE and sw(14) = not ACTIVE and sw(13) = not ACTIVE) then
				if(count = 1) then
					if(count2 < 5000000) then
						count2 := count2 + 1;
						previewenable <= not ACTIVE;
					else
						previewenable <= ACTIVE;
						count2 := 0;
					end if;
					if(previewenable = ACTIVE) then
						if(rgbSignal(23 downto 0) /= previewcolor) then
							rgbSignal(23 downto 0) <= previewcolor;
							count := count + 1;
						elsif(rgbSignal(23 downto 0) = previewcolor) then
							rgbSignal(23 downto 0) <= blank;
							count := count + 1;
						end if;
					end if;
				end if;
				if(count <= numACTIVELEDS) then
					rgbBuild((24*count)-1 downto 24*(count-1)) <= outputcolor;
					count := count + 1;
					rgbBuild(23 downto 0) <= blank;
				elsif(count > numACTIVELEDS and count <= numLEDS) then
					rgbBuild((24*count)-1 downto 24*(count-1)) <= blank;
					count := count + 1;
				elsif(count > numLEDS) then
					rgbSignal <= rgbBuild((24*numLEDS)-1 downto 24) & rgbSignal(23 downto 0);
					count := 1;
				end if;
			elsif(sw(15) = not ACTIVE and sw(14) = not ACTIVE and sw(13) =  ACTIVE) then
				rgbSignal <= customlights;

				if(count2 < 50000000) then
					count2 := count2 + 1;
					previewenable <= not ACTIVE;
				else
					previewenable <= ACTIVE;
					count2 := 0;
				end if;
				if(previewenable = ACTIVE) then
					if(customlights(ledposition*24-1 downto ledposition*24-24) /= previewcolor) then
						customlights(ledposition*24-1 downto ledposition*24-24) <= previewcolor;
					elsif(customlights(ledposition*24-1 downto ledposition*24-24) = previewcolor) then
						customlights(ledposition*24-1 downto ledposition*24-24) <= blank;
					end if;
				end if;
				-- rgbSignal <= customlights;
			end if;
		end if;
	end process LIGHT_NUMACTIVELEDS;

	MY_RGB_DRIVER: RGB_DRIVER port map(
		clock => clk,
		reset => btnC,
		rgbIn => rgbSignal,
		rgbOut => JA
	);

	MY_DEBOUNCE4: DEBOUNCE4 port map(
		inp => buttonarrayin,
		clk => clk,
		reset => btnC,
		outp => buttonarrayout
	);

	MY_SEVEN_SEG: SEVEN_SEG port map(
		clk => clk;
		input => colortext;
		seg => seg;
		an => an
	);


end topArch;