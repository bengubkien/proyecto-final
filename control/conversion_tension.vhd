LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY conversion_tension IS
  PORT( conv_u_in                         :   IN    std_logic_vector(11 DOWNTO 0);
        conv_ref_in                       :   IN    std_logic_vector(31 DOWNTO 0);
        conv_u_out                        :   OUT   std_logic_vector(31 DOWNTO 0);
        conv_u_disp                       :   OUT   std_logic_vector(15 DOWNTO 0);
        conv_ref_disp                     :   OUT   std_logic_vector(15 DOWNTO 0)
        );
END conversion_tension;


ARCHITECTURE rtl OF conversion_tension IS

     SIGNAL conv_u_in_unsigned               : unsigned(11 DOWNTO 0);
  SIGNAL to_fixd_out1                     : signed(31 DOWNTO 0);
  SIGNAL b_mul_temp                       : signed(63 DOWNTO 0);
  SIGNAL b_out1                           : signed(31 DOWNTO 0);
  SIGNAL add_1                            : signed(43 DOWNTO 0);
  SIGNAL add_out1                         : signed(31 DOWNTO 0);
  SIGNAL scale_u_mul_temp                 : signed(63 DOWNTO 0);
  SIGNAL scale_u_out1                     : signed(31 DOWNTO 0);
  SIGNAL to_uint16_out1                   : unsigned(15 DOWNTO 0);
  SIGNAL conv_ref_in_signed               : signed(31 DOWNTO 0);
  SIGNAL scale_ref_mul_temp               : signed(63 DOWNTO 0);
  SIGNAL scale_ref_out1                   : unsigned(15 DOWNTO 0);

BEGIN
  conv_u_in_unsigned <= unsigned(conv_u_in);

  to_fixd_out1 <= signed(resize(conv_u_in_unsigned & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 32));

  b_mul_temp <= to_signed(1308756400, 32) * to_fixd_out1;
  b_out1 <= b_mul_temp(61 DOWNTO 30);

  add_1 <= to_signed(1779164807, 44);
  add_out1 <= b_out1 + add_1(42 DOWNTO 11);

  scale_u_mul_temp <= to_signed(1374389535, 32) * add_out1;
  scale_u_out1 <= resize(scale_u_mul_temp(63 DOWNTO 37), 32);

  conv_u_out <= std_logic_vector(scale_u_out1);

  to_uint16_out1 <= unsigned(add_out1(31 DOWNTO 16));

  conv_u_disp <= std_logic_vector(to_uint16_out1);

  conv_ref_in_signed <= signed(conv_ref_in);

  scale_ref_mul_temp <= to_signed(1677721600, 32) * conv_ref_in_signed;
  scale_ref_out1 <= unsigned(scale_ref_mul_temp(55 DOWNTO 40));

  conv_ref_disp <= std_logic_vector(scale_ref_out1);

END rtl;
