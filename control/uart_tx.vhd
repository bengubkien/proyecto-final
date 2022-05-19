library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
	port (
		clk    : in std_logic;
		start  : in std_logic;
		busy   : out std_logic;
		data   : in std_logic_vector(7 downto 0);
		tx     : out std_logic
	);
end uart_tx;

architecture behavioral of uart_tx is
	signal prescaler : integer range 0 to 868 := 0;
	signal index : integer range 0 to 9 := 0;
	signal data_sgn : std_logic_vector(9 downto 0);
	signal tx_flag : std_logic := '0';
 
begin
	tx_proc : process (clk)
	begin
		if rising_edge(clk) then
			if (tx_flag = '0' and start = '1') then
				tx_flag <= '1';
				busy <= '1';
				data_sgn(0) <= '0';
				data_sgn(9) <= '1';
				data_sgn(8 downto 1) <= data;
			end if;
			if (tx_flag = '1') then
				if (prescaler < 867) then
					prescaler <= prescaler + 1;
				else
					prescaler <= 0;
				end if;
 
				if (prescaler = 433) then
					tx <= data_sgn(index);
					if (index < 9) then
						index <= index + 1;
					else
						tx_flag <= '0';
						busy <= '0';
						index <= 0;
					end if;
				end if;
			end if;
		end if;
	end process;
end behavioral;