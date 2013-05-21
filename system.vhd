library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity system is
	port (
		clk, rx, reset, ps2c, ps2d : in std_logic;
		vgar, vgag, vgab, vgahs, vgavs, tx: out std_logic;
		sw : in unsigned(7 downto 0);
		seg : out unsigned(7 downto 0);
		an : out unsigned(3 downto 0)
	);
end system;

architecture Behavioral of system is
	signal vgaclk, video, col, send, ready, recved, recvack : std_logic;
	signal x, y : unsigned(9 downto 0);
	signal curx, cury, scry : unsigned(6 downto 0);
	signal ramwaddr, ramraddr : unsigned(11 downto 0);
	signal ramidata, ramodata, outdata, indata : unsigned(7 downto 0);
	signal ramwe : std_logic;
	signal baud : unsigned(15 downto 0);
begin
	process(clk)
	begin
		if rising_edge(clk) then
			vgaclk <= not vgaclk;
		end if;
	end process;
	vgar <= col;
	vgag <= col;
	vgab <= col;
	vga0: entity work.vga port map (vgaclk, video, vgahs, vgavs, x, y);
	chargen0: entity work.chargen port map (clk, video, x, y, curx, cury, scry, col, ramraddr, ramodata);
	vram0: entity work.vram port map (clk, ramwaddr, ramwe, ramidata, ramraddr, ramodata);
	uart0: entity work.uart port map (clk, rx, tx, outdata, send, ready, indata, recved, recvack, sw);
	disp0: entity work.disp port map (clk, indata, recved, recvack, curx, cury, scry, ramwaddr, ramwe, reset, ramidata);
	ps20 : entity work.ps2 port map (clk, outdata, send, ready, ps2c, ps2d);
	baud <= resize(sw, 16);
	hexdisp0: entity work.hexdisp port map(clk, an, seg, baud);
end Behavioral;

