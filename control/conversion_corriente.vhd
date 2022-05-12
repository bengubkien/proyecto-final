LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY conversion_corriente IS
  PORT( conv_i_in                         :   IN    std_logic_vector(11 DOWNTO 0);
        conv_ref_in                       :   IN    std_logic_vector(31 DOWNTO 0);
        conv_i_out                        :   OUT   std_logic_vector(31 DOWNTO 0);
        conv_i_disp                       :   OUT   std_logic_vector(15 DOWNTO 0);
        conv_ref_disp                     :   OUT   std_logic_vector(15 DOWNTO 0);
		neg_flag       : out std_logic
        );
END conversion_corriente;


ARCHITECTURE rtl OF conversion_corriente IS

     SIGNAL conv_i_in_unsigned               : unsigned(11 DOWNTO 0);
  SIGNAL to_fixd_out1                     : signed(31 DOWNTO 0);
  SIGNAL b_mul_temp                       : signed(63 DOWNTO 0);
  SIGNAL b_out1                           : signed(31 DOWNTO 0);
  SIGNAL add_1                            : signed(35 DOWNTO 0);
  SIGNAL add_out1                         : signed(31 DOWNTO 0);
  SIGNAL scale_i_mul_temp                 : signed(63 DOWNTO 0);
  SIGNAL scale_i_out1                     : signed(31 DOWNTO 0);
  SIGNAL to_uint16_out1                   : unsigned(15 DOWNTO 0);
  SIGNAL conv_ref_in_signed               : signed(31 DOWNTO 0);
  SIGNAL scale_ref_mul_temp               : signed(63 DOWNTO 0);
  SIGNAL scale_ref_out1                   : unsigned(15 DOWNTO 0);

BEGIN
  conv_i_in_unsigned <= unsigned(conv_i_in);

  to_fixd_out1 <= signed(resize(conv_i_in_unsigned & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 32));

  b_mul_temp <= to_signed(-1438771739, 32) * to_fixd_out1;
  b_out1 <= b_mul_temp(61 DOWNTO 30);

  add_1 <= signed'(X"088C6463A");
  add_out1 <= b_out1 + add_1(34 DOWNTO 3);

  scale_i_mul_temp <= to_signed(1374389535, 32) * add_out1;
  scale_i_out1 <= resize(scale_i_mul_temp(63 DOWNTO 37), 32);

  conv_i_out <= std_logic_vector(scale_i_out1);

  to_uint16_out1 <= unsigned(add_out1(31 downto 16)) when add_out1(31) = '0' else
	                  unsigned(-add_out1(31 downto 16));

  neg_flag <= add_out1(31);

  conv_i_disp <= std_logic_vector(to_uint16_out1);

  conv_ref_in_signed <= signed(conv_ref_in);

  scale_ref_mul_temp <= to_signed(1677721600, 32) * conv_ref_in_signed;
  scale_ref_out1 <= unsigned(scale_ref_mul_temp(55 DOWNTO 40));

  conv_ref_disp <= std_logic_vector(scale_ref_out1);

END rtl;

