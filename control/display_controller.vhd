library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity display is
	port (
		clk : in std_logic;	
		btn_next : in std_logic;
		btn_prev : in std_logic;
		ref_u : in std_logic_vector(15 downto 0);
		ref_i : in std_logic_vector(15 downto 0);
		corriente : in std_logic_vector(15 downto 0);
		tension : in std_logic_vector(15 downto 0);
		anodes : out std_logic_vector(3 downto 0);
		cathodes : out std_logic_vector(7 downto 0)
	);
end display;

architecture behavioral of display is

	signal btns_reg : std_logic_vector(1 downto 0);
	signal btns_display_reg : unsigned(1 downto 0);
	signal display_dot_reg : std_logic;
	signal dot_reg : std_logic;
	signal unit_reg : std_logic;
	signal displayed_number_u : std_logic_vector(15 downto 0);
	signal displayed_number_ref_u : std_logic_vector(15 downto 0);
	signal displayed_number_ref_i : std_logic_vector(15 downto 0);
	signal displayed_number_i : std_logic_vector(15 downto 0);
	signal displayed_number : std_logic_vector(15 downto 0);
	signal led_bcd : std_logic_vector(3 downto 0);
	signal refresh_counter : std_logic_vector(19 downto 0);
	signal led_en_cnt : std_logic_vector(1 downto 0);
	signal update_counter : std_logic_vector(24 downto 0);
	signal update_en_cnt : std_logic;
	
	-- Count      0 -> 1 -> 2 -> 3
	-- Activates LED1 LED2 LED3 LED4

	component binary_bcd is
		port (
			clk, rst : in std_logic;
			binary : in std_logic_vector(15 downto 0);
			displayed_number : out std_logic_vector(15 downto 0)
		);
	end component;
 
begin

	process (led_bcd, dot_reg)
	begin
		case led_bcd is
			when "0000" => cathodes <= "11000000"; -- "0" 
			when "0001" => cathodes <= "11111001"; -- "1"
			when "0010" => cathodes <= "10100100"; -- "2"
			when "0011" => cathodes <= "10110000"; -- "3"
			when "0100" => cathodes <= "10011001"; -- "4"
			when "0101" => cathodes <= "10010010"; -- "5"
			when "0110" => cathodes <= "10000010"; -- "6"
			when "0111" => cathodes <= "11111000"; -- "7"
			when "1000" => cathodes <= "10000000"; -- "8" 
			when "1001" => cathodes <= "10010000"; -- "9"
			when "1010" => cathodes <= "11000001"; -- U
			when "1011" => cathodes <= "10001000"; -- A
			when others => cathodes <= (others => '1');
		end case;
		
		if(dot_reg = '1') then
			cathodes(7) <= '0';
		end if;
		
	end process;

	led_clk_div_proc : process (clk)
	begin
		if (rising_edge(clk)) then
			refresh_counter <= refresh_counter + 1; -- Periodo de refresco de 100e6/2^20 = 95Hz
		end if;
	end process;
	
	led_en_cnt <= refresh_counter(19 downto 18);
	
	binary_bcd_ref_u : binary_bcd
	port map(
		clk => clk, 
		rst => '0', 
		binary => ref_u, 
		displayed_number => displayed_number_ref_u
	);
	
	binary_bcd_ref_i : binary_bcd
	port map(
		clk => clk, 
		rst => '0', 
		binary => ref_i, 
		displayed_number => displayed_number_ref_i
	);
	
	binary_bcd_tension : binary_bcd
	port map(
		clk => clk, 
		rst => '0', 
		binary => tension, 
		displayed_number => displayed_number_u
	);
	
	binary_bcd_corriente : binary_bcd
	port map(
		clk => clk, 
		rst => '0', 
		binary => corriente, 
		displayed_number => displayed_number_i
	);
	
	led_en_proc : process(led_en_cnt)
	begin
		case led_en_cnt is
			when "00" => 
				anodes <= "0111";
				-- Activo solamente el primer LED
				led_bcd <= displayed_number(15 downto 12);
				-- El primer dígito en hexadecimal
				dot_reg <= '0';
			when "01" => 
				anodes <= "1011";
				-- Activo solamente el segundo LED
				led_bcd <= displayed_number(11 downto 8);
				-- El segundo dígito en hexadecimal
				dot_reg <= '1';
			when "10" => 
				anodes <= "1101";
				-- Activo solamente el tercer LED
				led_bcd <= displayed_number(7 downto 4);
				-- El tercer dígito en hexadecimal
				dot_reg <= '0';
			when "11" => 
				anodes <= "1110";
				-- Activo solamente el cuarto LED
				led_bcd(3 downto 1) <= "101";
				led_bcd(0) <= unit_reg;
				-- El cuarto dígito en hexadecimal
				dot_reg <= display_dot_reg;
			when others => null;
		end case;
	end process;
	
	btns_reg_proc : process(clk) -- Proceso de registro de flanco de un botón.
	begin
		if rising_edge(clk) then
			btns_reg(0) <= btn_next;
			btns_reg(1) <= btn_prev;
		end if;
	end process;
	
	btns_proc : process(clk)	-- Proceso de adición o substracción de la referencia.
	begin
		if rising_edge(clk) then
			if ((btn_next and not btns_reg(0)) = '1') then
--				if (btns_display_reg = "11") then
--					btns_display_reg <= "00";
--				else
					btns_display_reg <= btns_display_reg + "01";
--				end if;
			elsif ((btn_prev and not btns_reg(1)) = '1') then
--				if (btns_display_reg = "00") then
--					btns_display_reg <= "10";
--				else
					btns_display_reg <= btns_display_reg - "01";
--				end if;
			end if;
		end if;
	end process;
	
	display_clk_div_proc : process (clk)	-- Proceso de actualización de los datos en display.
	begin
		if (rising_edge(clk)) then
			update_counter <= update_counter + 1; -- Periodo de refresco de 100e6/2^20 = 95Hz
		end if;
	end process;
	
	update_en_cnt <= '1' when update_counter = x"1FFFFFF" else '0';
	
	display_select_proc : process(clk)	-- Proceso de selección de referencia o medición en display.
	begin
		if rising_edge(clk) then
			if (btns_display_reg = "00" and update_en_cnt = '1') then
				displayed_number <= displayed_number_ref_u;
				unit_reg <= '0';
				display_dot_reg <= '1';
			elsif (btns_display_reg = "01" and update_en_cnt = '1') then
				displayed_number <= displayed_number_u;
				unit_reg <= '0';
				display_dot_reg <= '0';
			elsif (btns_display_reg = "10" and update_en_cnt = '1') then
				displayed_number <= displayed_number_ref_i;				
				unit_reg <= '1';
				display_dot_reg <= '1';
			elsif (btns_display_reg = "11" and update_en_cnt = '1') then
				displayed_number <= displayed_number_i;				
				unit_reg <= '1';
				display_dot_reg <= '0';
			end if;
		end if;
	end process;		

end behavioral;