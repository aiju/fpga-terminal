library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

use work.const.all;

entity chargen is
	port (
		clk, video : in std_logic;
		x, y : in unsigned(9 downto 0);
		curx, cury, scry : in unsigned(6 downto 0);
		col : out std_logic;
		ramaddr : out unsigned(11 downto 0);
		ramdata : in unsigned(7 downto 0)
	);
end chargen;

architecture Behavioral of chargen is
	signal romaddr : unsigned(11 downto 0);
	signal romdata : unsigned(7 downto 0);
	signal cur : std_logic;
begin
	
	cur <= '1' when (x srl 3) = curx and (y srl 4) = cury else '0';
	process(clk)
	variable yp, yq : unsigned(6 downto 0);
	begin
		if rising_edge(clk) then
			yp := resize((y srl 4) + scry,7);
			if yp >= buflines then
				yq := yp - buflines;
			else
				yq := yp;
			end if;
			ramaddr <= (resize(yq,12) sll 6) + (resize(yq,12) sll 4) + ((x+2) srl 3);
			romaddr <= (resize(ramdata, 12) sll 4) + y(3 downto 0);
			if video = '1' then	
				col <= cur xor romdata(7 - to_integer(x(2 downto 0)));
			else
				col <= '0';
			end if;
		end if;
	end process;
	crom0: entity work.crom port map (clk, romaddr, romdata);
end Behavioral;

