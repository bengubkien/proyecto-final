library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity adc_controller is
	port (
		clk      : in std_logic;
		rst      : in std_logic;

		sdata_1  : in std_logic;
		sdata_2  : in std_logic;
		sclk     : out std_logic;
		cs       : out std_logic;

		data_1   : out std_logic_vector(11 downto 0);
		data_2   : out std_logic_vector(11 downto 0);
		start    : in std_logic;
		done     : out std_logic
	);

end adc_controller;

architecture behavioral of adc_controller is

	--------------------------------------------------------------------------------
	-- SEALES
	--
	-- Las siguientes seales son utilizadas:
	--
	-- current_state: Estado actual de la mquina de estados del controlador
	--
	-- next_state : Siguiente estado de la mquina de estados del controlador
	--
	-- aux_1 : Vector auxiliar que almacena los 16 bits provenientes del primer ADC del Pmod
	--
	-- aux_2 : Vector auxiliar que almacena los 16 bits provenientes del segundo ADC del Pmod
	--
	-- data_1 : Vector que almacena los 12 bits de datos del primer ADC del Pmod
	--
	-- data_2 : Vector que almacena los 12 bits de datos del segundo ADC del Pmod
	--
	-- clk_div : Seal de 100MHz/8 = 12MHz que se utiliza como reloj para el Pmod
	--
	-- clk_counter : Contador utilizado para el divisor de frecuencias
	--
	-- shift_cnt : Contador utilizado para shiftear los bits de los ADC a "aux_1" y "aux_2"
	--
	-- en_shift_cnt : Seal utilizada como enable para shiftear los bits de los ADC a "aux_1" y "aux_2".
	--
	-- en_load : Seal utilizada como enable para cargar los 12 bits de datos a "data_1" y "data_2"
	--------------------------------------------------------------------------------

	type states is (idle, 
	shift, 
	sync);

	signal current_state : states;
	signal next_state : states;

	signal aux_1 : std_logic_vector(15 downto 0) := (others => '0');
	signal aux_2 : std_logic_vector(15 downto 0) := (others => '0');
	signal data_sgn_1 : std_logic_vector(11 downto 0) := x"000";
	signal data_sgn_2 : std_logic_vector(11 downto 0) := x"000";
	signal clk_div : std_logic;
	signal clk_cnt : integer := 1;
	signal shift_cnt : std_logic_vector(3 downto 0) := x"0";
	signal en_shift_cnt : std_logic;
	signal en_load : std_logic;
	signal test_sgn : std_logic := '0';

begin
	--------------------------------------------------------------------------------
	-- CLK_DIV_PROC
	--
	-- Proceso que genera un reloj de 12MHz para los ADC del Pmod.
	--------------------------------------------------------------------------------

	clk_div_proc : process (rst, clk)
	begin
		if rst = '1' then
			clk_cnt <= 1;
		elsif rising_edge(clk) then
			clk_cnt <= clk_cnt + 1;
			if (clk_cnt = 4) then -- 100MHz/2/4 = 12MHz
				clk_div <= not clk_div;
				clk_cnt <= 1;
			end if;
		end if;
	end process;

	sclk <= clk_div;

	--------------------------------------------------------------------------------
	-- REG_SHIFT_PROC
 
	-- Debido a que cada ADC produce 16 bits, en donde los cuatro MSB son ceros
	-- y los otros 12 bits son los datos, se almacenan todos los bits temporalmente
	-- en "aux_1" y "aux_2" cuando "en_shift_cnt" est activo.
	-- Cuando se activa "en_load", los 12 bits de datos de ambos ADC son
	-- almacenados en otros dos vectores "data_sgn_1" y "data_sgn_2".
	-- "shift_cnt" es un contador de 4 bits utilizado para shiftear 16 veces (una
	-- vez por cada ciclo de reloj) a los registros auxiliares.
	--------------------------------------------------------------------------------
 
	reg_shift_proc : process (clk_div, en_load, en_shift_cnt)
	begin
		if rising_edge(clk_div) then
			if (en_shift_cnt = '1') then
				aux_1 <= aux_1(14 downto 0) & sdata_1;
				aux_2 <= aux_2(14 downto 0) & sdata_2;
				shift_cnt <= shift_cnt + '1';
			elsif (en_load = '1') then
				test_sgn <= not test_sgn; 
				shift_cnt <= "0000"; -- Contador de 4 bits utilizado para shiftear 16 veces.
				data_sgn_1 <= aux_1(11 downto 0);
				data_sgn_2 <= aux_2(11 downto 0);
			end if;
		end if;
	end process;
 
	data_1 <= data_sgn_1;
	data_2 <= data_sgn_2;
 
	---------------------------------------------------------------------------------
	--
	-- MQUINA DE ESTADOS
	--
	-- Mquina de estados que posee 3 estados:
	--
	-- IDLE: No hace nada.
	--
	-- SHIFT: Capta los datos de los dos ADC del Pmod y los almacena en registros auxiliares
	-- de 16 bits.
	--
	-- SYNC: Copia los 12 bits de datos captados de ambos ADC de los registros auxiliares a
	-- los puertos de salida correspondientes.
	--
	-- Es importante aclarar que ambos ADC empiezan su proceso de muestreo en un flanco
	-- descendiente de Chip Select. Por lo tanto "IDLE" y "SYNC" ponen "CS" en alto, y
	-- "SHIFT" en bajo.
	--
	-----------------------------------------------------------------------------------

	-----------------------------------------------------------------------------------
	--
	-- SYNC_PROC
	--
	-- Proceso en donde los estados son cambiados sincrnicamente.
	--
	-----------------------------------------------------------------------------------
 
	sync_proc : process (clk_div, rst)
	begin
		if rising_edge(clk_div) then
			if (rst = '1') then
				current_state <= idle;
			else
				current_state <= next_state;
			end if;
		end if;
	end process;

	-----------------------------------------------------------------------------------
	--
	-- OUTPUT_DECODE_PROC
	--
	-- Proceso en donde se generan asincrnicamente las seales de salida basadas
	-- solamente en el estado actual.
	--
	-----------------------------------------------------------------------------------
 
	output_decode_proc : process (current_state)
	begin
		if current_state = idle then
			en_shift_cnt <= '0';
			done <= '1';
			cs <= '1';
			en_load <= '0';
		elsif current_state = shift then
			en_shift_cnt <= '1';
			done <= '0';
			cs <= '0';
			en_load <= '0';
		else --if current_state = sync then
			en_shift_cnt <= '0';
			done <= '0';
			cs <= '1';
			en_load <= '1';
		end if;
	end process;

	----------------------------------------------------------------------------------
	--
	-- NEXT_STATE_DECODE_PROC
	--
	-- Proceso en el cual se decide el prximo estado dependiendo del estado actual y
	-- las seales de entrada.
	--
	-----------------------------------------------------------------------------------
 
	next_state_decode_proc : process (current_state, start, shift_cnt)
	begin
		next_state <= current_state; -- La mquina tiende a quedarse en el estado actual

		case (current_state) is
			when idle => 
				if start = '1' then
					next_state <= shift;
				end if;
			when shift => 
				if shift_cnt = x"E" then
					next_state <= sync;
				end if;
			when sync => 
				if start = '0' then
					next_state <= idle;
				end if;
			when others => 
				next_state <= idle;
		end case;
	end process;
	
end behavioral;