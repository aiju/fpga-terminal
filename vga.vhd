library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga is
	port (
		clk : in std_logic;
		von, hs, vs : out std_logic;
		x, y : out unsigned(9 downto 0)
	);
end vga;

architecture Behavioral of vga is
	constant hpulse : integer := 96;
	constant hback : integer := 48;
	constant hfront : integer := 16;
	constant hdisplay : integer := 640;
	constant hfull : integer := hpulse+hback+hfront+hdisplay;
	constant vpulse : integer := 2;
	constant vback : integer := 29;
	constant vfront : integer := 10;
	constant vdisplay : integer := 480;
	constant vfull : integer := vpulse+vback+vfront+vdisplay;
	signal hcount : unsigned(9 downto 0) := (others => '0');
	signal vcount : unsigned(9 downto 0) := (others => '0');
begin
	process (clk)
	begin
		if rising_edge(clk) then
			if hcount = hfull - 1 then
				hcount <= to_unsigned(0,10);
				if vcount = vfull - 1 then
					vcount <= to_unsigned(0,10);
				else
					vcount <= vcount + 1;
				end if;
			else
				hcount <= hcount + 1;
			end if;
		end if;
	end process;

	hs <= '0' when hcount < hpulse else '1';
	vs <= '0' when vcount < vpulse else '1';
	von <= '1' when vcount >= (vpulse+vback) and vcount < (vfull-vfront) and hcount >= (hpulse+hback) and hcount < (hfull-hfront) else '0';
	x <= hcount - (hpulse+hback);
	y <= vcount - (vpulse+vback);
end Behavioral;

