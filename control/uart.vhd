library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
	port (
		clk  : in std_logic;
		data : in std_logic_vector(63 downto 0);
		tx   : out std_logic
	);
end uart;

architecture structural of uart is

	signal tx_data : std_logic_vector(63 downto 0);
	signal tx_start : std_logic := '0';
	signal tx_busy : std_logic;

	component uart_tx
		port (
			clk    : in std_logic;
			start  : in std_logic;
			busy   : out std_logic;
			data   : in std_logic_vector(63 downto 0);
			tx     : out std_logic
		);
	end component;
 
begin
	data_tx : uart_tx
	port map(
		clk, tx_start, 
		tx_busy, tx_data, 
		tx
	);

	tx_proc : process (clk)
	begin
		if rising_edge(clk) then
			if tx_busy = '0' then
				tx_data <= data;
				tx_start <= '1';
			else
				tx_start <= '0';
			end if;
		end if;
	end process;
end structural;