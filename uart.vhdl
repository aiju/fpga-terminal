library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use std.textio.all;

entity uart is
	Port(
		clk : in std_logic;
		rx : in std_logic;
		tx : out std_logic := '1';
		outdata : in unsigned(7 downto 0);
		send : in std_logic;
		ready : out std_logic;
		indata : out unsigned(7 downto 0);
		recved : out std_logic := '0';
		recvack : in std_logic;
		sw : in unsigned(7 downto 0)
	);
end uart;


architecture behavioral of uart is
	constant clk_freq : integer := 50000000;
	signal counter : unsigned(12 downto 0) := (others => '0');
	signal rxcounter : unsigned(15 downto 0);
	signal baudce : std_logic := '0';
	signal rx1, rx2 : std_logic;
	signal count_max : unsigned(12 downto 0);
	signal state, rxstate : unsigned(3 downto 0) := X"F";
	signal sendbuf, recvbuf : unsigned(7 downto 0);
begin
	count_max <= to_unsigned(clk_freq / 115200, 13) * sw;
	process(clk)
	begin
		if rising_edge(clk) then
			if counter = count_max - 1 then
				baudce <= '1';
				counter <= to_unsigned(0, 13);
			else
				baudce <= '0';
				counter <= counter + 1;
			end if;
		end if;
	end process;

	ready <= '1' when state = X"F" else '0';
	process(clk)
	begin
		if rising_edge(clk) then
			case state is 
			when X"F" =>
				tx <= '1';
				if send = '1' then
					sendbuf <= outdata;
					state <= X"0";
				else
					state <= X"F";
				end if;
			when X"0" =>
				if baudce = '1' then
					tx <= '0';
					state <= X"1";
				end if;
			when X"9" =>
				if baudce = '1' then
					tx <= '1';
					state <= X"F";
				end if;
			when others =>
				if baudce = '1' then
					tx <= sendbuf(to_integer(state) - 1);
					state <= state + 1;
				end if;
			end case;
		end if;
	end process;
	
	process(clk)
	begin
		if rising_edge(clk) then
			rx1 <= rx;
			rx2 <= rx1;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if recvack = '1' then
				recved <= '0';
			end if;
			case rxstate is
			when X"F" =>
				if rx2 = '0' then
					rxcounter <= resize(count_max, 16) / 2;
					rxstate <= X"0";
				else
					rxstate <= X"F";
				end if;
			when X"0" =>
				if rxcounter = to_unsigned(0, 16) then
					rxcounter <= resize(count_max, 16);
					rxstate <= X"1";
				else
					rxcounter <= rxcounter - 1;
					rxstate <= X"0";
				end if;
			when X"9" =>
				if rxcounter = to_unsigned(0, 16) then
					indata <= recvbuf;
					recved <= '1';
					rxstate <= X"F";
				else
					rxcounter <= rxcounter - 1;
					rxstate <= X"9";
				end if;
			when others =>
				if rxcounter = to_unsigned(0, 16) then
					rxcounter <= resize(count_max, 16);
					recvbuf(to_integer(rxstate) - 1) <= rx2;
					rxstate <= rxstate + 1;
				else
					rxcounter <= rxcounter - 1;
				end if;
			end case;
		end if;
	end process;
end architecture;
