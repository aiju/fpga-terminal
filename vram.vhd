library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vram is
	port (
		clk : in std_logic;
		addr1 : in unsigned(11 downto 0);
		we : in std_logic;
		indata : in unsigned(7 downto 0);
		addr2 : in unsigned(11 downto 0);
		outdata : out unsigned(7 downto 0)
	);
end vram;

architecture Behavioral of vram is
	type ram_t is array(0 to 4095) of unsigned(7 downto 0);
	signal ram : ram_t := (others => X"00");
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if we = '1' then
				ram(to_integer(addr1)) <= indata;
			end if;
			outdata <= ram(to_integer(addr2));
		end if;
	end process;
end Behavioral;

