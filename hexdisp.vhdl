library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity hexdisp is
	port (
		clk : in std_logic;
		anodes : out unsigned(3 downto 0);
		cathodes : out unsigned(7 downto 0);
		input : in unsigned(15 downto 0)
	);
end hexdisp;

architecture Behavioral of hexdisp is
	type chars_t is array(15 downto 0) of unsigned(7 downto 0);
	signal counter : unsigned(11 downto 0) := (others => '0');
	signal inp : unsigned(3 downto 0);
	constant chars : chars_t := (
		0 => "11000000",
		1 => "11111001",
		2 => "10100100",
		3 => "10110000",
		4 => "10011001",
		5 => "10010010",
		6 => "10000010",
		7 => "11111000",
		8 => "10000000",
		9 => "10010000",
		10 => "10001000",
		11 => "10000011",
		12 => "11000110",
		13 => "10100001",
		14 => "10000110",
		15 => "10001110"
	);
begin
	process(clk)
	begin
		if rising_edge(clk) then
			counter <= counter + 1;
		end if;
	end process;
	anodes(0) <= '0' when counter(11 downto 10) = "00" else '1';
	anodes(1) <= '0' when counter(11 downto 10) = "01" else '1';
	anodes(2) <= '0' when counter(11 downto 10) = "10" else '1';
	anodes(3) <= '0' when counter(11 downto 10) = "11" else '1';
	inp <= input(4 * to_integer(counter(11 downto 10)) + 3 downto 4 * to_integer(counter(11 downto 10)));
	cathodes <= chars(to_integer(inp));
end Behavioral;