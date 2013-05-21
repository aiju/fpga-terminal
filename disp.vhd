library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.const.all;

entity disp is
	port (
		clk : in std_logic;
		indata : in unsigned(7 downto 0);
		recved : in std_logic;
		recvack : out std_logic := '0';
		ocurx, ocury, oscry : out unsigned(6 downto 0);
		ramwaddr : out unsigned(11 downto 0);
		ramwe : out std_logic := '0';
		reset : in std_logic;
		ramdata : out unsigned(7 downto 0)
	);
end disp;

architecture Behavioral of disp is
	type state_t is (RECVWAIT, RECVDONE);
	signal state : state_t := RECVWAIT;
	signal data : unsigned(7 downto 0);
	signal clstart, clend : unsigned(11 downto 0) := "000000000000";
	signal curx, cury, scry : unsigned(6 downto 0) := "0000000";
	signal oreset : std_logic;
begin
	ocurx <= curx;
	ocury <= cury;
	oscry <= scry;
	process(clk)
	variable yp, yq : unsigned(6 downto 0);
	variable newline : std_logic;
	begin
		if rising_edge(clk) then
			case state is
				when RECVWAIT =>
					if clstart < clend then
						ramwaddr <= clstart;
						ramdata <= X"00";
						ramwe <= '1';
						clstart <= clstart + 1;
					elsif reset = '1' and oreset = '0' then
						curx <= to_unsigned(0, 7);
						cury <= to_unsigned(0, 7);
						scry <= to_unsigned(0, 7);
						clstart <= to_unsigned(0, 12);
						clend <= to_unsigned(4095, 12);
					elsif recved = '1' then
						data <= indata;
						recvack <= '1';
						state <= RECVDONE;
						ramwe <= '0';
					else
						ramwe <= '0';
					end if;
					oreset <= reset;
				when RECVDONE =>
					if recved = '0' then
						state <= RECVWAIT;
						recvack <= '0';
						newline := '0';
						case data is
						when X"08" =>
							if curx /= 0 then
								yp := resize(cury + scry,7);
								if yp >= buflines then
									yq := yp - buflines;
								else
									yq := yp;
								end if;
								ramwaddr <= (resize(yq,12) sll 6) + (resize(yq,12) sll 4) + curx - 1;
								ramdata <= X"00";
								ramwe <= '1';
								curx <= curx - 1;
							end if;
						when X"09" =>
							if curx + 8 >= cols then
								curx <= ((curx + 8) and "1111000") - cols;
								newline := '1';
							else
								curx <= (curx + 8) and "1111000";
							end if;
						when X"0A" =>
							newline := '1';
						when X"0C" =>
							curx <= to_unsigned(0, 7);
							cury <= to_unsigned(0, 7);
							scry <= to_unsigned(0, 7);
							clstart <= to_unsigned(0, 12);
							clend <= to_unsigned(4095, 12);
						when X"0D" =>
							curx <= to_unsigned(0, 7);
						when others =>
							yp := resize(cury + scry,7);
							if yp >= buflines then
								yq := yp - buflines;
							else
								yq := yp;
							end if;
							ramwaddr <= (resize(yq,12) sll 6) + (resize(yq,12) sll 4) + curx;
							ramdata <= data;
							ramwe <= '1';
							if curx /= cols - 1 then
								curx <= curx + 1;
							else
								curx <= to_unsigned(0, 7);
								newline := '1';
							end if;
						end case;
						if newline = '1' then
							if cury /= lines - 1 then
								cury <= cury + 1;
							else
								clstart <= (resize(scry, 12) sll 6) + (resize(scry, 12) sll 4);
								clend <= (resize(scry+1, 12) sll 6) + (resize(scry+1, 12) sll 4);
								if scry /= buflines - 1 then
									scry <= scry + 1;
								else
									scry <= to_unsigned(0, 7);
								end if;
							end if;
						end if;
					end if;
			end case;
		end if;
	end process;
end Behavioral;

