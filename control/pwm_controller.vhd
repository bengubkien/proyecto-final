library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pwm_controller is
	generic (
		sys_clk : integer := 100_000_000;
		pwm_freq : integer := 20_000;
		bits_resolution : integer := 12
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		duty_cycle : in std_logic_vector(bits_resolution - 1 downto 0);
		pwm_out : out std_logic;
		pwm_n_out : out std_logic
	);
end pwm_controller;

architecture behavioral of pwm_controller is

	constant period : integer := sys_clk/pwm_freq;
	signal count : integer range 0 to period - 1 := 0;
	signal half_duty_new : integer range 0 to period/2 := 0;
	signal half_duty : integer range 0 to period/2;
	
begin

	process (clk, rst)
	begin
		if (rst = '1') then
			count <= 0;
			pwm_out <= '0';
			pwm_n_out <= '0';
		elsif rising_edge(clk) then
			half_duty_new <= conv_integer(duty_cycle) * period/(2 ** bits_resolution)/2;
			if (count = period - 1) then
				count <= 0;
				half_duty <= half_duty_new;
			else
				count <= count + 1;
			end if;
			if (count = half_duty) then
				pwm_out <= '0';
				pwm_n_out <= '1';
			elsif (count = period - half_duty) then
				pwm_out <= '1';
				pwm_n_out <= '0';
			end if;
		end if;
	end process;
	
end behavioral;