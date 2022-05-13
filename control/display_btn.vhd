library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Componente que controla los botones y los display 7 segmentos

-- Posee un controlador propio del display y un debouncer para cada botón

entity btn_display is
	port (
		clk                : in std_logic;
		btn_add            : in std_logic;
		btn_sub            : in std_logic;
		btn_next           : in std_logic;
		btn_prev           : in std_logic;
		ref_u              : in std_logic_vector(15 downto 0);
		ref_i              : in std_logic_vector(15 downto 0);
		corriente          : in std_logic_vector(15 downto 0);
		tension            : in std_logic_vector(15 downto 0);
		anodes             : out std_logic_vector (3 downto 0);
		cathodes           : out std_logic_vector(7 downto 0);
		btn_add_debounced  : out std_logic;
		btn_sub_debounced  : out std_logic
	);
end btn_display;

architecture structural of btn_display is

	component display is
		port (
			clk        : in std_logic;
			ref_u      : in std_logic_vector (15 downto 0);
			ref_i      : in std_logic_vector (15 downto 0);
			corriente  : in std_logic_vector (15 downto 0);
			tension    : in std_logic_vector (15 downto 0);
			btn_next   : in std_logic;
			btn_prev   : in std_logic;
			anodes     : out std_logic_vector (3 downto 0);
			cathodes   : out std_logic_vector (7 downto 0)
		);
	end component;

	component button_debouncer is
		port (
			clk      : in std_logic;
			btn_in   : in std_logic;
			btn_out  : out std_logic
		);
	end component;

	signal btn_add_debounced_sgn : std_logic;
	signal btn_sub_debounced_sgn : std_logic;
	signal btn_next_debounced_sgn : std_logic;
	signal btn_prev_debounced_sgn : std_logic;
 
begin
	display_controller : display
	port map(
		clk        => clk, 
		ref_u      => ref_u, 
		ref_i      => ref_i, 
		corriente  => corriente, 
		tension    => tension, 
		btn_next   => btn_next_debounced_sgn, 
		btn_prev   => btn_prev_debounced_sgn, 
		anodes     => anodes, 
		cathodes   => cathodes
	);
 
	btn_add_debouncer : button_debouncer
	port map(
		clk      => clk, 
		btn_in   => btn_add, 
		btn_out  => btn_add_debounced_sgn
	);
 
	btn_sub_debouncer : button_debouncer
	port map(
		clk      => clk, 
		btn_in   => btn_sub, 
		btn_out  => btn_sub_debounced_sgn
	);
 
	btn_next_debouncer : button_debouncer
	port map(
		clk      => clk, 
		btn_in   => btn_next, 
		btn_out  => btn_next_debounced_sgn
	);
 
	btn_prev_debouncer : button_debouncer
	port map(
		clk      => clk, 
		btn_in   => btn_prev, 
		btn_out  => btn_prev_debounced_sgn
	);
 
	btn_add_debounced <= btn_add_debounced_sgn;
	btn_sub_debounced <= btn_sub_debounced_sgn;

end structural;