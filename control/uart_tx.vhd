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
	signal prescaler : integer range 0 to 3999 := 0;
	signal index : integer range 0 to 159 := 0;
	signal data_sgn : std_logic_vector(159 downto 0);
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
				data_sgn(80) <= '0';
				data_sgn(89) <= '1';
				data_sgn(90) <= '0';
				data_sgn(99) <= '1';
				data_sgn(100) <= '0';
				data_sgn(109) <= '1';
				data_sgn(110) <= '0';
				data_sgn(119) <= '1';
				data_sgn(120) <= '0';
				data_sgn(129) <= '1';
				data_sgn(130) <= '0';
				data_sgn(139) <= '1';
				data_sgn(140) <= '0';
				data_sgn(149) <= '1';
				data_sgn(150) <= '0';
				data_sgn(159) <= '1';
				
				data_sgn(8 downto 1) <= x"F" & data(3 downto 0);
				data_sgn(18 downto 11) <= x"E" & data(7 downto 4);
				data_sgn(28 downto 21) <= x"D" & data(11 downto 8);
				data_sgn(38 downto 31) <= x"C" & data(15 downto 12);
				
				data_sgn(48 downto 41) <= x"B" & data(19 downto 16);
				data_sgn(58 downto 51) <= x"A" & data(23 downto 20);
				data_sgn(68 downto 61) <= x"9" & data(27 downto 24);
				data_sgn(78 downto 71) <= x"8" & data(31 downto 28);
			
				data_sgn(88 downto 81) <= x"7" & data(35 downto 32);
				data_sgn(98 downto 91) <= x"6" & data(39 downto 36);
				data_sgn(108 downto 101) <= x"5" & data(43 downto 40);
				data_sgn(118 downto 111) <= x"4" & data(47 downto 44);
				
				data_sgn(128 downto 121) <= x"3" & data(51 downto 48);
				data_sgn(138 downto 131) <= x"2" & data(55 downto 52);
				data_sgn(148 downto 141) <= x"1" & data(59 downto 56);
				data_sgn(158 downto 151) <= x"0" & data(63 downto 60);
			end if;
			if (tx_flag = '1') then
				if (prescaler < 3999) then
					prescaler <= prescaler + 1;
				else
					prescaler <= 0;
				end if;
 
				if (prescaler = 1999) then
					tx <= data_sgn(index);
					if (index < 159) then
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