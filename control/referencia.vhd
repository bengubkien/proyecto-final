library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity referencia is
	port (
		clk : in std_logic;
		btn_add : in std_logic;
		btn_sub : in std_logic;
		ref_type : in std_logic;
		ref_u_out : out std_logic_vector(31 downto 0);
		ref_i_out : out std_logic_vector(31 downto 0)
	);
end referencia;

architecture behavioral of referencia is

	signal ref_u : signed(31 downto 0) := x"000F0000";		-- Inicialización en 10V
	signal ref_i : signed(31 downto 0) := (others => '0');
	signal btns_reg : std_logic_vector(1 downto 0);

begin

	btns_reg_proc : process (clk) -- Proceso de registro de flanco de un botón
	begin
		if rising_edge(clk) then
			btns_reg(0) <= btn_add;
			btns_reg(1) <= btn_sub;
		end if;
	end process;

	ref_btn_proc : process (clk)	-- Proceso de adición o substracción de la referencia
	begin
		if rising_edge(clk) then
			if ((btn_add and not btns_reg(0)) = '1') then
				if ref_type = '0' then
					ref_u <= ref_u + x"00010000";	-- +1V
				else
					ref_i <= ref_i + x"00002000";  -- +0.125A
				end if;
			elsif ((btn_sub and not btns_reg(1)) = '1') then
				if ref_type = '0' then
					ref_u <= ref_u - x"00010000";	-- +1V
				else
					ref_i <= ref_i - x"00002000";  -- +0.125A
				end if;
			end if;
		end if;
	end process;
		
	-- Saturación de ambas referencias en 0V y 0A
	ref_u_out <= std_logic_vector(ref_u) when ref_u >= 0 else (others => '0');
	ref_i_out <= std_logic_vector(ref_i) when ref_i >= 0 else (others => '0');
	
end behavioral;