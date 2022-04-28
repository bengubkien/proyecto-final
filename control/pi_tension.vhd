LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY pi_tension IS
  PORT( clk                               :   IN    std_logic;
		  integrator_rst : in std_logic;
        ref_in                            :   IN    std_logic_vector(31 DOWNTO 0);
        tension_in                        :   IN    std_logic_vector(31 DOWNTO 0);
        pi_out                            :   OUT   std_logic_vector(31 DOWNTO 0)
        );
END pi_tension;


ARCHITECTURE rtl OF pi_tension IS

     SIGNAL ref_in_signed                    : signed(31 DOWNTO 0);
  SIGNAL tension_in_signed                : signed(31 DOWNTO 0);
  SIGNAL error_out1                       : signed(31 DOWNTO 0);
  SIGNAL k_p_mul_temp                     : signed(63 DOWNTO 0);
  SIGNAL k_p_out1                         : signed(31 DOWNTO 0);
  SIGNAL k_i_mul_temp                     : signed(63 DOWNTO 0);
  SIGNAL k_i_out1                         : signed(31 DOWNTO 0);
  SIGNAL i_add_out1                       : signed(31 DOWNTO 0);
  SIGNAL integrator_out1                  : signed(31 DOWNTO 0) := to_signed(0, 32);
  SIGNAL clamping_out1                    : signed(31 DOWNTO 0);
  SIGNAL pi_add_out1                      : signed(31 DOWNTO 0);
  SIGNAL saturation_out1                  : signed(31 DOWNTO 0);

BEGIN
  ref_in_signed <= signed(ref_in);

  tension_in_signed <= signed(tension_in);

  error_out1 <= ref_in_signed - tension_in_signed;

  k_p_mul_temp <= to_signed(1717986918, 32) * error_out1;
  k_p_out1 <= resize(k_p_mul_temp(63 DOWNTO 36), 32);

  k_i_mul_temp <= to_signed(1099511628, 32) * error_out1;
  k_i_out1 <= resize(k_i_mul_temp(63 DOWNTO 42), 32)  when integrator_rst = '0' else
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


  
  clamping_out1 <= to_signed(983040, 32) WHEN integrator_out1 > to_signed(983040, 32) ELSE
      to_signed(0, 32) WHEN integrator_out1 < to_signed(0, 32) ELSE
      integrator_out1 when integrator_rst = '0' else
             to_signed(0, 32); 

  i_add_out1 <= k_i_out1 + clamping_out1  when integrator_rst = '0' else
             to_signed(0, 32);

  pi_add_out1 <= k_p_out1 + i_add_out1;

  
  saturation_out1 <= to_signed(983040, 32) WHEN pi_add_out1 > to_signed(983040, 32) ELSE
      to_signed(0, 32) WHEN pi_add_out1 < to_signed(0, 32) ELSE
      pi_add_out1 ;

  pi_out <= std_logic_vector(saturation_out1);

END rtl;