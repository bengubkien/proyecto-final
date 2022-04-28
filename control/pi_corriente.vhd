LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;


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

ARCHITECTURE rtl OF pi_corriente IS

     SIGNAL ref_in_signed                    : signed(31 DOWNTO 0);
  SIGNAL corriente_in_signed              : signed(31 DOWNTO 0);
  SIGNAL error_out1                       : signed(31 DOWNTO 0);
  SIGNAL k_p_mul_temp                     : signed(63 DOWNTO 0);
  SIGNAL k_p_out1                         : signed(31 DOWNTO 0);
  SIGNAL k_i_mul_temp                     : signed(63 DOWNTO 0);
  SIGNAL k_i_out1                         : signed(31 DOWNTO 0);
  SIGNAL i_add_out1                       : signed(31 DOWNTO 0);
  SIGNAL integrator_out1                  : signed(31 DOWNTO 0) := to_signed(0, 32);
  SIGNAL clamping_out1                    : signed(31 DOWNTO 0);
  SIGNAL pi_add_out1                      : signed(32 DOWNTO 0);
  SIGNAL dtc_out                          : unsigned(11 DOWNTO 0);
  SIGNAL saturation_out1                  : unsigned(11 DOWNTO 0);

BEGIN
  ref_in_signed <= signed(ref_in_pi_u) when switch_i_ref = '0' else signed(ref_in_i);

  corriente_in_signed <= signed(corriente_in);

  error_out1 <= ref_in_signed - corriente_in_signed;

  k_p_mul_temp <= to_signed(1288175616, 32) * error_out1;
  k_p_out1 <= k_p_mul_temp(53 DOWNTO 22);

  k_i_mul_temp <= to_signed(1099243192, 32) * error_out1;
  k_i_out1 <= k_i_mul_temp(59 DOWNTO 28)  when integrator_rst = '0' else
          to_signed(0, 32);

  integrator_process : PROCESS (clk)
  BEGIN
    if integrator_rst = '0' then
      integrator_out1 <= to_signed(0, 32);
    end if;
    IF rising_edge(clk) THEN
      integrator_out1 <= i_add_out1;
    END IF;
  END PROCESS integrator_process;


  
  clamping_out1 <= to_signed(214695936, 32) WHEN integrator_out1 > to_signed(214695936, 32) ELSE
      to_signed(0, 32) WHEN integrator_out1 < to_signed(0, 32) ELSE
      integrator_out1  when integrator_rst = '0' else
          to_signed(0, 32);

  i_add_out1 <= k_i_out1 + clamping_out1  when integrator_rst = '0' else
          to_signed(0, 32);

  pi_add_out1 <= (resize(k_p_out1, 33)) + (resize(i_add_out1, 33));

  
  dtc_out <= "111111111111" WHEN (pi_add_out1(32) = '0') AND (pi_add_out1(31 DOWNTO 28) /= "0000") ELSE
      "000000000000" WHEN pi_add_out1(32) = '1' ELSE
      unsigned(pi_add_out1(27 DOWNTO 16));

  
  saturation_out1 <= to_unsigned(16#E66#, 12) WHEN dtc_out > to_unsigned(16#E66#, 12) ELSE
      dtc_out;

  pi_out <= std_logic_vector(saturation_out1);

END rtl;