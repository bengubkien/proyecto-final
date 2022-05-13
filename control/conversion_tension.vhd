library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Conversión de valor de tensión medido desde el ADC a valor real de tensión de salida

entity conversion_tension is
	port (
		conv_u_in      : in std_logic_vector(11 downto 0); -- Medición del ADC
		conv_ref_in    : in std_logic_vector(31 downto 0); -- Referencia de tensión
		conv_u_out     : out std_logic_vector(31 downto 0); -- Valor real de tensión de salida
		conv_u_disp    : out std_logic_vector(15 downto 0); -- Valor real ingresado al display
		conv_ref_disp  : out std_logic_vector(15 downto 0) -- Valor de referencia ingresado al display
	);
end conversion_tension;
architecture behavioral of conversion_tension is

	signal conv_u_in_unsigned : unsigned(11 downto 0);
	signal to_fixd_out1 : signed(31 downto 0);
	signal b_mul_temp : signed(63 downto 0);
	signal b_out1 : signed(31 downto 0);
	signal add_1 : signed(45 downto 0);
	signal add_out1 : signed(31 downto 0);
	signal scale_u_mul_temp : signed(63 downto 0);
	signal scale_u_out1 : signed(31 downto 0);
	signal to_uint16_out1 : unsigned(15 downto 0);
	signal conv_ref_in_signed : signed(31 downto 0);
	signal scale_ref_mul_temp : signed(63 downto 0);
	signal scale_ref_out1 : unsigned(15 downto 0);

begin
	conv_u_in_unsigned <= unsigned(conv_u_in);

	to_fixd_out1 <= signed(resize(conv_u_in_unsigned & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 32));

	b_mul_temp <= to_signed(1205904856, 32) * to_fixd_out1;
	b_out1 <= b_mul_temp(59 downto 28);

	add_1 <= to_signed(1444171747, 46);
	add_out1 <= b_out1 + add_1(44 downto 13);

	scale_u_mul_temp <= to_signed(1374389535, 32) * add_out1;
	scale_u_out1 <= resize(scale_u_mul_temp(63 downto 37), 32);

	conv_u_out <= std_logic_vector(scale_u_out1);

	to_uint16_out1 <= unsigned(add_out1(31 downto 16));

	conv_u_disp <= std_logic_vector(to_uint16_out1);

	conv_ref_in_signed <= signed(conv_ref_in);

	scale_ref_mul_temp <= to_signed(1677721600, 32) * conv_ref_in_signed;
	scale_ref_out1 <= unsigned(scale_ref_mul_temp(55 downto 40));

	conv_ref_disp <= std_logic_vector(scale_ref_out1);

end behavioral;