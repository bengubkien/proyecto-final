library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_divider is
port(
clk : in std_logic;
clk_div : out std_logic
);
end clock_divider;

architecture behavioral of clock_divider is

signal clk_div_sgn : std_logic := '0';
signal clk_cnt : integer := 0;

begin

	clock_div_proc : process (clk)
	begin
		if rising_edge(clk) then -- 100MHz/2/381 = 131kHz
			clk_cnt <= clk_cnt + 1;
			if (clk_cnt) = 381 then
				clk_div_sgn <= not clk_div_sgn;
				clk_cnt <= + 1;
			end if;
		end if;
	end process;
	
	clk_div <= clk_div_sgn;

end behavioral;

