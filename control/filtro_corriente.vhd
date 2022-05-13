library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Filtro pasa-bajos de primer orden con frecuencia de corte de 1.5kHz

entity filtro_corriente is
	port (
		clk                  : in std_logic;
		filtro_corriente_in   : in std_logic_vector(11 downto 0);
		filtro_corriente_out  : out std_logic_vector(11 downto 0)
	);
end filtro_corriente;

architecture rtl of filtro_corriente is

	signal filtro_corriente_in_unsigned : unsigned(11 downto 0);
	signal k_0_mul_temp : unsigned(23 downto 0);
	signal k_0_out1 : signed(31 downto 0);
	signal delay_out1 : signed(31 downto 0) := to_signed(0, 32);
	signal k_1_mul_temp : signed(63 downto 0);
	signal k_1_out1 : signed(31 downto 0);
	signal add_out1 : signed(31 downto 0);
	signal conversion_out_out1 : unsigned(11 downto 0);

begin
	filtro_corriente_in_unsigned <= unsigned(filtro_corriente_in);

	k_0_mul_temp <= to_unsigned(16#F71#, 12) * filtro_corriente_in_unsigned;
	k_0_out1 <= signed(resize(k_0_mul_temp(23 downto 2), 32));

	k_1_mul_temp <= to_signed(2115099595, 32) * delay_out1;
	k_1_out1 <= k_1_mul_temp(62 downto 31);

	add_out1 <= k_0_out1 + k_1_out1;

	delay_process : process (clk)
	begin
		if rising_edge(clk) then
			delay_out1 <= add_out1;
		end if;
	end process delay_process;
	
	conversion_out_out1 <= unsigned(delay_out1(27 downto 16));

	filtro_corriente_out <= std_logic_vector(conversion_out_out1);

end rtl;