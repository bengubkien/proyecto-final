LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY filtro_corriente IS
  PORT( clk                               :   IN    std_logic;
        filtro_corriente_in               :   IN    std_logic_vector(11 DOWNTO 0);
        filtro_corriente_out              :   OUT   std_logic_vector(11 DOWNTO 0)
        );
END filtro_corriente;


ARCHITECTURE rtl OF filtro_corriente IS

     SIGNAL filtro_corriente_in_unsigned     : unsigned(11 DOWNTO 0);
  SIGNAL k_0_mul_temp                     : unsigned(23 DOWNTO 0);
  SIGNAL k_0_out1                         : signed(31 DOWNTO 0);
  SIGNAL x_n_1_out1                       : signed(32 DOWNTO 0) := to_signed(0, 33);
  SIGNAL k_1_mul_temp                     : signed(65 DOWNTO 0);
  SIGNAL k_1_out1                         : signed(31 DOWNTO 0);
  SIGNAL add_out1                         : signed(32 DOWNTO 0);
  SIGNAL conversion_out_out1              : unsigned(11 DOWNTO 0);

BEGIN
  filtro_corriente_in_unsigned <= unsigned(filtro_corriente_in);

  k_0_mul_temp <= to_unsigned(16#C10#, 12) * filtro_corriente_in_unsigned;
  k_0_out1 <= signed(resize(k_0_mul_temp & '0', 32));

  k_1_mul_temp <= signed'("011100111110111110101110011110010") * x_n_1_out1;
  k_1_out1 <= k_1_mul_temp(63 DOWNTO 32);

  add_out1 <= (resize(k_0_out1, 33)) + (resize(k_1_out1, 33));

  x_n_1_process : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      x_n_1_out1 <= add_out1;
    END IF;
  END PROCESS x_n_1_process;


  conversion_out_out1 <= unsigned(x_n_1_out1(27 DOWNTO 16));

  filtro_corriente_out <= std_logic_vector(conversion_out_out1);

END rtl;