
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SEVEN_SEG is
	port(
		clk: in std_logic;
		input: in unsigned (31 downto 0);
		seg: out std_logic_vector(6 downto 0);
		an: out std_logic_vector(3 downto 0)
	    );
end SEVEN_SEG;

architecture rtl of SEVEN_SEG is

	constant ACTIVE: std_logic := '1';
	constant TERMINAL_VALUE_COUNT: integer := 100000000;
	constant TERMINAL_VALUE_SCAN: integer := 100000;

	signal reset: std_logic;
	signal currentNumber: std_logic;
	signal timerEnable: std_logic;
	signal sevenSegEnable: std_logic;
begin

	SEVENSEG: process(clk, reset)
	variable anode: unsigned(1 downto 0);
	variable digit03, digit02, digit01, digit00: unsigned(7 downto 0);
	variable displaydigit: unsigned(7 downto 0);
	variable counter: integer range 0 to TERMINAL_VALUE_SCAN;
	begin
		if(reset = ACTIVE) then
			counter := 0;
			sevenSegEnable <= not ACTIVE;
		elsif(rising_edge(clk)) then
			if(counter = TERMINAL_VALUE_SCAN) then
				counter := 0;
				sevenSegEnable <= ACTIVE;
			else
				counter := counter + 1;
				sevenSegEnable <= not ACTIVE;
			end if;

			if(sevenSegEnable = ACTIVE) then
				digit03 := input(31 downto 24);
				digit02 := input(23 downto 16);
				digit01 := input(15 downto 8);
				digit00 := input(7 downto 0);

				anode := anode + 1;

				case anode is
					when "00" => 
						an <= "1110";
						displaydigit := digit00;
					when "01" => 
						an <= "1101";
						displaydigit := digit01;
					when "10" =>
						an <= "1011";
						displaydigit := digit02;
					when "11" =>
						an <= "0111";
						displaydigit := digit03;
					when others =>
						an <= "0111";
						displaydigit := digit00;
				end case;

				if(anode = "11" and digit03 = 0) then
					seg <= "1111111";
				elsif(anode = "10" and digit03 = 0 and digit02 = 0) then
					seg <= "1111111";
				elsif(anode = "01" and digit03 = 0 and digit02 = 0 and digit01 = 0) then
					seg <= "1111111";
				else
					case displaydigit is
						when X"23" => seg <= "0100100"; --Z
						when X"22" => seg <= "0010001"; --Y
						when X"21" => seg <= "0001000"; --X
						when X"20" => seg <= "0000000"; --W
						when X"1F" => seg <= "0000000"; --V
						when X"1E" => seg <= "1000001"; --U
						when X"1D" => seg <= "0000111"; --t
						when X"1C" => seg <= "0100000"; --s
						when X"1B" => seg <= "0101111"; --r
						when X"1A" => seg <= "0011000"; --q
						when X"19" => seg <= "0001100"; --p
						when X"18" => seg <= "0100011"; --o
						when X"17" => seg <= "0101011"; --n
						when X"16" => seg <= "0000000"; --M
						when X"15" => seg <= "1000111"; --L
						when X"14" => seg <= "0000000"; --K
						when X"13" => seg <= "1100001"; --J
						when X"12" => seg <= "1111001"; --I
						when X"11" => seg <= "0001011"; --h
						when X"10" => seg <= "0010000"; --g
						when X"0F" => seg <= "0001110"; --F
						when X"0E" => seg <= "0000110"; --E
						when X"0D" => seg <= "0100001"; --d
						when X"0C" => seg <= "1000110"; --c
						when X"0B" => seg <= "0000011"; --b
						when X"0A" => seg <= "0001000"; --A
						when X"09" => seg <= "0010000"; --9
						when X"08" => seg <= "0000000"; --8
						when X"07" => seg <= "1011000"; --7
						when X"06" => seg <= "0000010"; --6
						when X"05" => seg <= "0100100"; --5
						when X"04" => seg <= "0100010"; --4
						when X"03" => seg <= "0011001"; --3
						when X"02" => seg <= "0100100"; --2
						when X"01" => seg <= "1111001"; --1
						when X"00" => seg <= "1000000"; --0
						when others => seg <= "1111111";
					end case;
				end if;


			end if;

		end if;


end rtl;
