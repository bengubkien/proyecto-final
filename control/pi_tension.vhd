library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pi_tension is
	port (
		clk             : in std_logic;
		integrator_rst  : in std_logic;
		ref_in          : in std_logic_vector(31 downto 0);
		tension_in      : in std_logic_vector(31 downto 0);
		pi_out          : out std_logic_vector(31 downto 0)
	);
end pi_tension;
architecture rtl of pi_tension is

	signal ref_in_signed : signed(31 downto 0);
	signal tension_in_signed : signed(31 downto 0);
	signal error_sub_temp : signed(31 downto 0);
	signal error_out1 : signed(31 downto 0);
	signal k_p_mul_temp : signed(63 downto 0);
	signal k_p_out1 : signed(31 downto 0);
	signal k_i_mul_temp : signed(63 downto 0);
	signal k_i_out1 : signed(31 downto 0);
	signal i_add_out1 : signed(31 downto 0);
	signal integrator_out1 : signed(31 downto 0) := to_signed(0, 32);
	signal clamping_out1 : signed(31 downto 0);
	signal pi_add_out1 : signed(31 downto 0);
	signal saturation_out1 : signed(31 downto 0);

begin
	ref_in_signed <= signed(ref_in);

	tension_in_signed <= signed(tension_in);

	error_sub_temp <= ref_in_signed - tension_in_signed;
	error_out1 <= error_sub_temp(21 downto 0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0';

	k_p_mul_temp <= to_signed(1374389535, 32) * error_out1;
	k_p_out1 <= resize(k_p_mul_temp(63 downto 37), 32);

	k_i_mul_temp <= to_signed(1125899907, 32) * error_out1;
	k_i_out1 <= resize(k_i_mul_temp(63 downto 46), 32) when integrator_rst = '0' else
	            to_signed(0, 32);

	integrator_process : process (clk)
	begin
		if rising_edge(clk) then
			integrator_out1 <= i_add_out1;
		end if;
	end process integrator_process;
 
	clamping_out1 <= to_signed(1006632960, 32) when integrator_out1 > to_signed(1006632960, 32) else
	                 to_signed(0, 32) when integrator_out1 < to_signed(0, 32) else
	                 integrator_out1 when integrator_rst = '0' else
	                 to_signed(0, 32);

	i_add_out1 <= k_i_out1 + clamping_out1;

	pi_add_out1 <= k_p_out1 + i_add_out1;

	saturation_out1 <= to_signed(1006632960, 32) when pi_add_out1 > to_signed(1006632960, 32) else
	                   to_signed(0, 32) when pi_add_out1 < to_signed(0, 32) else
	                   pi_add_out1;

	pi_out <= std_logic_vector(saturation_out1);

end rtl;