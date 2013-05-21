library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_MISC.ALL;

entity ps2 is
	port (
		clk : in std_logic;
		outdata : out unsigned(7 downto 0);
		send : out std_logic := '0';
		ready, ps2c, ps2d : in std_logic
	);
end ps2;

architecture Behavioral of ps2 is
constant timelimit : integer := 3000;
type state_t is (PS2WAITLO, PS2WAITHI, WAITREADYHI, WAITREADYLO);
type table_t is array (127 downto 0) of unsigned(15 downto 0);
constant keys : table_t := (
	16#0E# => X"7E60",
	16#16# => X"2131",
	16#1E# => X"4032",
	16#26# => X"2333",
	16#25# => X"2434",
	16#2E# => X"2535",
	16#36# => X"5E36",
	16#3D# => X"2637",
	16#3E# => X"2A38",
	16#46# => X"2839",
	16#45# => X"2930",
	16#4E# => X"5F2D",
	16#55# => X"2B3D",
	16#5D# => X"7C5C",
	16#66# => X"0808",
	
	16#0D# => X"0909",
	16#15# => X"5171",
	16#1D# => X"5777",
	16#24# => X"4565",
	16#2D# => X"5272",
	16#2C# => X"5474",
	16#35# => X"5979",
	16#3C# => X"5575",
	16#43# => X"4969",
	16#44# => X"4F6F",
	16#4D# => X"5070",
	16#54# => X"7B5B",
	16#5B# => X"7D5D",
	16#5A# => X"0D0D",
	
	16#1C# => X"4161",
	16#1B# => X"5373",
	16#23# => X"4464",
	16#2B# => X"4666",
	16#34# => X"4767",
	16#33# => X"4868",
	16#3B# => X"4A6A",
	16#42# => X"4B6B",
	16#4B# => X"4C6C",
	16#4C# => X"3A3B",
	16#52# => X"2227",

	16#1A# => X"5A7A",
	16#22# => X"5878",
	16#21# => X"4363",
	16#2A# => X"5676",
	16#32# => X"4262",
	16#31# => X"4E6E",
	16#3A# => X"4D6D",
	16#41# => X"3C2C",
	16#49# => X"3E2E",
	16#4A# => X"3F2F",
	
	16#29# => X"2020",
	16#76# => X"1B1B",
	others => X"0000"
);
signal release, shift, ctrl : std_logic := '0';
signal state : state_t := PS2WAITLO;
signal counter : unsigned(11 downto 0) := (others => '0');
signal bits : unsigned(10 downto 0);
signal nbit : unsigned(3 downto 0) := X"0";
signal pclk, pdata, pclk1, pdata1 : std_logic;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			pclk1 <= ps2c;
			pclk <= pclk1;
			pdata1 <= ps2d;
			pdata <= pdata1;
		end if;
	end process;
	process(clk)
	variable c, scan : unsigned(7 downto 0);
	begin
		if rising_edge(clk) then
			case state is
			when PS2WAITLO =>
				if pclk = '0' then
					bits(to_integer(nbit)) <= pdata;
					counter <= (others => '0');
					nbit <= nbit + 1;
					state <= PS2WAITHI;
				else
					if counter >= timelimit then
						counter <= (others => '0');
						nbit <= (others => '0');
					else
						counter <= counter + 1;
					end if;
				end if;
			when PS2WAITHI =>
				if pclk = '1' then
					counter <= (others => '0');
					if nbit = X"B" then
						nbit <= X"0";
						if bits(0) /= '0' or bits(10) /= '1' or xor_reduce(std_logic_vector(bits)) /= '0' then
							state <= PS2WAITLO;
						else
							state <= WAITREADYHI;
						end if;
					else
						state <= PS2WAITLO;
					end if;
				else
					if counter >= timelimit then
						counter <= (others => '0');
						nbit <= (others => '0');
						state <= PS2WAITLO;
					else
						counter <= counter + 1;
					end if;
				end if;
			when WAITREADYHI =>
				if ready = '1' then
					state <= PS2WAITLO;
					scan := bits(8 downto 1);
					if release /= '0' then
						if scan = x"12" or scan = x"59" then
							shift <= '0';
						end if;
						if scan = x"14" then
							ctrl <= '0';
						end if;
						if scan /= x"E0" then
							release <= '0';
						end if;
					elsif scan = x"F0" then
						release <= '1';
					elsif scan = x"12" or scan = x"59" then
						shift <= '1';
					elsif scan = x"14" then
						ctrl <= '1';
					elsif bits(8) = '0' then
						if shift = '1' then
							c := resize(keys(to_integer(scan)) srl 8, 8);
						else
							c := resize(keys(to_integer(scan)), 8);
						end if;
						if ctrl = '1' then
							c := c and X"1F";
						end if;
						if c /= 0 then
							outdata(7 downto 0) <= c;
							send <= '1';
							state <= WAITREADYLO;
						end if;
					end if;
				end if;
			when WAITREADYLO =>
				if ready = '0' then
					send <= '0';
					state <= PS2WAITLO;
				end if;
			end case;
		end if;
	end process;
end Behavioral;

