library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pi_tension is
	port (
		clk            : in  std_logic;
		integrator_rst : in  std_logic;
		ref_in         : in  std_logic_vector(31 downto 0);
		tension_in     : in  std_logic_vector(31 downto 0);
		pi_out         : out std_logic_vector(31 downto 0)
	);
end pi_tension;

architecture rtl of pi_tension is

	signal ref_in_signed : signed(31 downto 0);
	signal tension_in_signed : signed(31 downto 0);
	signal error_sub_temp : signed(32 downto 0);
	signal error_out1 : signed(31 downto 0);
	signal k_p_mul_temp : signed(63 downto 0);
	signal k_p_out1 : signed(31 downto 0);
	signal k_i_mul_temp : signed(63 downto 0);
	signal k_i_out1 : signed(31 downto 0);
	signal clamping_out1 : signed(31 downto 0);
	signal integrator_out1 : signed(31 downto 0) := to_signed(0, 32);
	signal i_add_add_temp : signed(34 downto 0);
	signal i_add_out1 : signed(31 downto 0);
	signal add_out_add_temp : signed(42 downto 0);
	signal add_out_out1 : signed(31 downto 0);
	signal saturation_out1 : signed(31 downto 0);

begin
	ref_in_signed <= signed(ref_in);

	tension_in_signed <= signed(tension_in);

	error_sub_temp <= (resize(ref_in_signed, 33)) - (resize(tension_in_signed, 33));
	error_out1 <= error_sub_temp(23 downto 0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0';

	k_p_mul_temp <= to_signed(1374389535, 32) * error_out1;
	k_p_out1 <= resize(k_p_mul_temp(63 downto 45), 32);

	k_i_mul_temp <= to_signed(1125899907, 32) * error_out1;
	k_i_out1 <= resize(k_i_mul_temp(63 downto 46), 32);

	integrator_process : process (clk)
	begin
		if rising_edge(clk) then
			integrator_out1 <= clamping_out1;
		end if;
	end process;

	i_add_add_temp <= (resize(k_i_out1 & '0' & '0', 35)) + (resize(integrator_out1, 35));

	i_add_out1 <= i_add_add_temp(31 downto 0) when integrator_rst = '0' else to_signed(0, 32);
    
	clamping_out1 <= to_signed(671088640, 32) when i_add_out1 > to_signed(671088640, 32) else
		to_signed(0, 32) when i_add_out1 < to_signed(0, 32) else
		i_add_out1;

	add_out_add_temp <= (resize(k_p_out1 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 43)) + (resize(clamping_out1, 43));

	add_out_out1 <= add_out_add_temp(41 downto 10);

	saturation_out1 <= to_signed(655360, 32) when add_out_out1 > to_signed(655360, 32) else to_signed(0, 32) when add_out_out1 < to_signed(0, 32) else add_out_out1;

	pi_out <= std_logic_vector(saturation_out1);

end rtl;