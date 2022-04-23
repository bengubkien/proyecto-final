library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity filtro_corriente is
	port (
		clk : in std_logic;
		filtro_corriente_in : in std_logic_vector(11 downto 0);
		filtro_corriente_out : out std_logic_vector(11 downto 0)
	);
end filtro_corriente;

architecture behavioral of filtro_corriente is

	signal filtro_corriente_in_unsigned : unsigned(15 downto 0);
	signal conversion_in_out1 : signed(31 downto 0);
	signal k_0_mul_temp : signed(63 downto 0);
	signal k_0_out1 : signed(31 downto 0);
	signal x_n_1_out1 : signed(32 downto 0) := to_signed(0, 33);
	signal k_1_mul_temp : signed(65 downto 0);
	signal k_1_out1 : signed(31 downto 0);
	signal add_out1 : signed(32 downto 0);
	signal conversion_out_out1 : unsigned(15 downto 0);

begin
	filtro_corriente_in_unsigned <= resize(unsigned(filtro_corriente_in), 16);

	conversion_in_out1 <= signed(filtro_corriente_in_unsigned & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0');

	k_0_mul_temp <= to_signed(1839373002, 32) * conversion_in_out1;
	k_0_out1 <= resize(k_0_mul_temp(63 downto 37), 32);

	k_1_mul_temp <= signed'("011111100100100101110111010000101") * x_n_1_out1;
	k_1_out1 <= k_1_mul_temp(63 downto 32);

	add_out1 <= (resize(k_0_out1, 33)) + (resize(k_1_out1, 33));

	x_n_1_process : process (clk)
	begin
		if rising_edge(clk) then
			x_n_1_out1 <= add_out1;
		end if;
	end process x_n_1_process;

	conversion_out_out1 <= unsigned(x_n_1_out1(31 downto 16));

	filtro_corriente_out <= std_logic_vector(resize(conversion_out_out1, 12));

end behavioral;