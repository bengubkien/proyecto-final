library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity conversion_corriente is
	port (
		conv_i_in      : in std_logic_vector(11 downto 0);
		conv_ref_in    : in std_logic_vector(31 downto 0);
		conv_i_out     : out std_logic_vector(31 downto 0);
		conv_i_disp    : out std_logic_vector(15 downto 0);
		conv_ref_disp  : out std_logic_vector(15 downto 0);
		neg_flag       : out std_logic
	);
end conversion_corriente;

architecture behavioral of conversion_corriente is

	signal conv_i_in_unsigned : unsigned(15 downto 0);
	signal to_fixd_out1 : signed(31 downto 0);
	signal b_mul_temp : signed(63 downto 0);
	signal b_out1 : signed(31 downto 0);
	signal add_add_cast : signed(34 downto 0);
	signal add_add_temp : signed(35 downto 0);
	signal add_cast : signed(34 downto 0);
	signal add_out1 : signed(31 downto 0);
	signal scale_i_mul_temp : signed(63 downto 0);
	signal scale_i_out1 : signed(31 downto 0);
	signal to_uint16_out1 : unsigned(15 downto 0);
	signal conv_ref_in_signed : signed(31 downto 0);
	signal scale_ref_mul_temp : signed(63 downto 0);
	signal scale_ref_out1 : unsigned(15 downto 0);
 
begin
	conv_i_in_unsigned <= resize(unsigned(conv_i_in), 16);

	to_fixd_out1 <= signed(conv_i_in_unsigned & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0');

	b_mul_temp <= to_signed( - 1438771739, 32) * to_fixd_out1;
	b_out1 <= b_mul_temp(61 downto 30);

	add_add_cast <= resize(b_out1 & '0' & '0', 35);
	add_add_temp <= (resize(add_add_cast, 36)) + to_signed(1147347742, 36);

	add_cast <= "01111111111111111111111111111111111" when (add_add_temp(35) = '0') and (add_add_temp(34) /= '0') else
	            "10000000000000000000000000000000000" when (add_add_temp(35) = '1') and (add_add_temp(34) /= '1') else
	            add_add_temp(34 downto 0);

	add_out1 <= X"7FFFFFFF" when (add_cast(34) = '0') and (add_cast(33) /= '0') else
	            X"80000000" when (add_cast(34) = '1') and (add_cast(33) /= '1') else
	            add_cast(33 downto 2);

	scale_i_mul_temp <= to_signed(1374389535, 32) * add_out1;
	scale_i_out1 <= resize(scale_i_mul_temp(63 downto 37), 32);

	conv_i_out <= std_logic_vector(scale_i_out1);

	-- Si el número es negativo, lo invierto y activo un flag.
	to_uint16_out1 <= unsigned(add_out1(31 downto 16)) when add_out1(31) = '0' else
	                  resize(unsigned(add_out1(31 downto 16) * to_signed( - 1, 16)), 16);
 
	neg_flag <= '0' when add_out1(31) = '0' else '1';

	conv_i_disp <= std_logic_vector(to_uint16_out1);

	conv_ref_in_signed <= signed(conv_ref_in);

	scale_ref_mul_temp <= to_signed(1677721600, 32) * conv_ref_in_signed;
	scale_ref_out1 <= unsigned(scale_ref_mul_temp(55 downto 40));

	conv_ref_disp <= std_logic_vector(scale_ref_out1);

end behavioral;