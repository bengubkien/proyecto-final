library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pi_corriente is
	port (
		clk             : in std_logic;
		integrator_rst  : in std_logic; 
		switch_i_ref	: in std_logic;
		ref_in_pi_u         : in std_logic_vector(31 downto 0);
		ref_in_i         : in std_logic_vector(31 downto 0);
		corriente_in    : in std_logic_vector(31 downto 0);
		pi_out          : out std_logic_vector(11 downto 0)
	);
end pi_corriente;

architecture behavioral of pi_corriente is

	signal ref_in_signed : signed(31 downto 0);
	signal corriente_in_signed : signed(31 downto 0);
	signal error : signed(31 downto 0);
	signal k_p_mul_temp : signed(63 downto 0);
	signal k_p_out : signed(31 downto 0);
	signal k_i_mul_temp : signed(63 downto 0);
	signal k_i_out : signed(31 downto 0);
	signal i_add_out : signed(31 downto 0);
	signal integrator_out : signed(31 downto 0) := to_signed(0, 32);
	signal clamping_out : signed(31 downto 0);
	signal add_out_out : signed(31 downto 0);
	signal dtc_out : unsigned(11 downto 0);
	signal saturation_out : unsigned(11 downto 0);

begin
	ref_in_signed <= signed(ref_in_pi_u) when switch_i_ref = '0' else signed(ref_in_i);

	corriente_in_signed <= signed(corriente_in);

	error <= ref_in_signed - corriente_in_signed;

--	k_p_mul_temp <= to_signed(1374053990, 32) * error;
--	k_p_out <= k_p_mul_temp(56 downto 25);
	
	k_p_mul_temp <= to_signed(1717567488, 32) * error;			-- k_p = 0.05
	k_p_out <= k_p_mul_temp(54 DOWNTO 23);

--	k_p_mul_temp <= to_signed(1288175616, 32) * error;			-- k_p = 0.075
--	k_p_out <= k_p_mul_temp(53 DOWNTO 22);

--	k_i_mul_temp <= to_signed(1407031286, 32) * error;
--	k_i_out <= resize(k_i_mul_temp(63 DOWNTO 33), 32) when integrator_rst = '0' else
--	           to_signed(0, 32);

	k_i_mul_temp <= to_signed(1407031286, 32) * error;
	k_i_out <= k_i_mul_temp(63 DOWNTO 32) when integrator_rst = '0' else
				  to_signed(0, 32);
--				  
-- k_i_mul_temp <= to_signed(1407031286, 32) * error;
--	k_i_out <= k_i_mul_temp(62 DOWNTO 31) when integrator_rst = '0' else
--				  to_signed(0, 32);

	
--  k_p_mul_temp <= to_signed(1717567488, 32) * error;
--  k_p_out <= k_p_mul_temp(53 DOWNTO 22);
--
--  k_i_mul_temp <= to_signed(2110546929, 32) * error;
--  k_i_out <= k_i_mul_temp(63 DOWNTO 32) when integrator_rst = '0' else
--				  to_signed(0, 32);
			
	integrator_process : process (clk)
	begin
		if integrator_rst = '0' then
			integrator_out <= to_signed(0, 32);
		end if;
		if rising_edge(clk) then
			integrator_out <= i_add_out;
		end if;
	end process integrator_process;
 
	clamping_out <= to_signed(241532928, 32) when integrator_out > to_signed(241532928, 32) else
	                 to_signed(0, 32) when integrator_out < to_signed(0, 32) else
	                 integrator_out;

	i_add_out <= k_i_out + clamping_out when integrator_rst = '0' else to_signed(0, 32);

	add_out_out <= k_p_out + i_add_out;

 
	dtc_out <= "111111111111" when (add_out_out(31) = '0') and (add_out_out(30 downto 28) /= "000") else
	           "000000000000" when add_out_out(31) = '1' else
	           unsigned(add_out_out(27 downto 16));

 
	saturation_out <= to_unsigned(16#E66#, 12) when dtc_out > to_unsigned(16#E66#, 12) else
	                   dtc_out;

	pi_out <= std_logic_vector(saturation_out);

end behavioral;