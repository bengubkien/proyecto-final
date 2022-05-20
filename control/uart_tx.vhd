library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
	port (
		clk    : in std_logic;
		start  : in std_logic;
		busy   : out std_logic;
		data   : in std_logic_vector(63 downto 0);
		tx     : out std_logic
	);
end uart_tx;

architecture behavioral of uart_tx is
	signal prescaler : integer range 0 to 868 := 0;
	signal index : integer range 0 to 79 := 0;
	signal data_sgn : std_logic_vector(79 downto 0);
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
				data_sgn(10) <= '0';
				data_sgn(19) <= '1';
				data_sgn(20) <= '0';
				data_sgn(29) <= '1';
				data_sgn(30) <= '0';
				data_sgn(39) <= '1';
				data_sgn(40) <= '0';
				data_sgn(49) <= '1';
				data_sgn(50) <= '0';
				data_sgn(59) <= '1';
				data_sgn(60) <= '0';
				data_sgn(69) <= '1';
				data_sgn(70) <= '0';
				data_sgn(79) <= '1';
				
				data_sgn(8 downto 1) <= data(31 downto 24);
				data_sgn(18 downto 11) <= data(23 downto 16);
				data_sgn(28 downto 21) <= data(15 downto 8);
				data_sgn(38 downto 31) <= data(7 downto 0);
				
				data_sgn(48 downto 41) <= data(63 downto 56);
				data_sgn(58 downto 51) <= data(55 downto 48);
				data_sgn(68 downto 61) <= data(47 downto 40);
				data_sgn(78 downto 71) <= data(39 downto 32);
			end if;
			if (tx_flag = '1') then
				if (prescaler < 867) then
					prescaler <= prescaler + 1;
				else
					prescaler <= 0;
				end if;
 
				if (prescaler = 433) then
					tx <= data_sgn(index);
					if (index < 79) then
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