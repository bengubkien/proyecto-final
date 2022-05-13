library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Conversión de valor de tensión medido desde el ADC a valor real de corriente de entrada

entity conversion_corriente is
	port (
		conv_i_in      : in std_logic_vector(11 downto 0); -- Medición del ADC
		conv_ref_in    : in std_logic_vector(31 downto 0); -- Referencia de corriente
		conv_i_out     : out std_logic_vector(31 downto 0); -- Valor real de corriente de entrada
		conv_i_disp    : out std_logic_vector(15 downto 0); -- Valor real ingresado al display
		conv_ref_disp  : out std_logic_vector(15 downto 0); -- Valor de referencia ingresado al display
		neg_flag       : out std_logic
	);
end conversion_corriente;
architecture rtl of conversion_corriente is

	signal conv_i_in_unsigned : unsigned(11 downto 0);
	signal to_fixd_out1 : signed(31 downto 0);
	signal b_mul_temp : signed(63 downto 0);
	signal b_out1 : signed(31 downto 0);
	signal add_1 : signed(35 downto 0);
	signal add_out1 : signed(31 downto 0);
	signal scale_i_mul_temp : signed(63 downto 0);
	signal scale_i_out1 : signed(31 downto 0);
	signal to_uint16_out1 : unsigned(15 downto 0);
	signal conv_ref_in_signed : signed(31 downto 0);
	signal scale_ref_mul_temp : signed(63 downto 0);
	signal scale_ref_out1 : unsigned(15 downto 0);

begin
	conv_i_in_unsigned <= unsigned(conv_i_in);

	to_fixd_out1 <= signed(resize(conv_i_in_unsigned & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 32));

	b_mul_temp <= to_signed( - 1438771739, 32) * to_fixd_out1;
	b_out1 <= b_mul_temp(61 downto 30);

	add_1 <= signed'(X"088C6463A");
	add_out1 <= b_out1 + add_1(34 downto 3);

	scale_i_mul_temp <= to_signed(1374389535, 32) * add_out1;
	scale_i_out1 <= resize(scale_i_mul_temp(63 downto 37), 32);

	conv_i_out <= std_logic_vector(scale_i_out1);


	-- Si la corriente de entrada es negativa, niego el valor para pasárselo al display
	to_uint16_out1 <= unsigned(add_out1(31 downto 16)) when add_out1(31) = '0' else
	                  unsigned( - add_out1(31 downto 16));

	-- Y activo un led para avisar que el valor es negativo
	neg_flag <= add_out1(31);

	conv_i_disp <= std_logic_vector(to_uint16_out1);

	conv_ref_in_signed <= signed(conv_ref_in);

	scale_ref_mul_temp <= to_signed(1677721600, 32) * conv_ref_in_signed;
	scale_ref_out1 <= unsigned(scale_ref_mul_temp(55 downto 40));

	conv_ref_disp <= std_logic_vector(scale_ref_out1);

end rtl;