library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity control is
	port (
		clk                                          : in std_logic;							
		pwm_rst, integrator_i_rst, switch_i_ref      : in std_logic;
		sdata_1, sdata_2                             : in std_logic;
		btn_add, btn_sub, btn_next, btn_prev         : in std_logic;
		anodes                                       : out std_logic_vector (3 downto 0);
		cathodes                                     : out std_logic_vector(7 downto 0);
		d, d_n                                       : out std_logic;
		sclk, cs                                     : out std_logic;
		uart_tx                                       : out std_logic;
		neg_flag                                      : out std_logic
	);
end control;

architecture structural of control is

	signal clk_sample : std_logic;

	signal data_1 : std_logic_vector (11 downto 0);
	signal data_2 : std_logic_vector (11 downto 0);

	signal data_2_filtered : std_logic_vector (11 downto 0);

	signal tension_pi : std_logic_vector (31 downto 0);
	signal tension_display : std_logic_vector (15 downto 0);

	signal corriente_pi : std_logic_vector (31 downto 0);
	signal corriente_display : std_logic_vector (15 downto 0);

	signal ref_u : std_logic_vector (31 downto 0);
	signal ref_i : std_logic_vector (31 downto 0);
	signal ref_u_display : std_logic_vector (15 downto 0);
	signal ref_i_display : std_logic_vector (15 downto 0);

	signal pi_u_out : std_logic_vector (31 downto 0);
	signal pi_i_out : std_logic_vector (11 downto 0);

	signal btn_add_debounced : std_logic;
	signal btn_sub_debounced : std_logic;

	signal pwm_out : std_logic;
	signal pwm_n_out : std_logic;
	
	signal uart_data : std_logic_vector(0 to 63);

	component clock_divider is
		port (
			clk      : in std_logic;
			clk_div  : out std_logic
		);
	end component;

	component adc_controller is
		port (
			clk      : in std_logic;
			rst      : in std_logic;
			sdata_1  : in std_logic;
			sdata_2  : in std_logic;
			start    : in std_logic;

			sclk     : out std_logic;
			cs       : out std_logic;
			data_1   : out std_logic_vector(11 downto 0);
			data_2   : out std_logic_vector(11 downto 0);
			done     : out std_logic
		);
	end component;

	component pwm_controller is
		port (
			clk         : in std_logic;
			rst         : in std_logic;
			duty_cycle  : in std_logic_vector(11 downto 0);
			pwm_out     : out std_logic;
			pwm_n_out   : out std_logic
		);
	end component;

	component filtro_corriente is
		port (
			clk                   : in std_logic;
			filtro_corriente_in   : in std_logic_vector(11 downto 0);
			filtro_corriente_out  : out std_logic_vector(11 downto 0)
		);
	end component;

	component referencia is
		port (
			clk        : in std_logic;
			btn_add    : in std_logic;
			btn_sub    : in std_logic;
			ref_type   : in std_logic;
			ref_u_out  : out std_logic_vector(31 downto 0);
			ref_i_out  : out std_logic_vector(31 downto 0)
		);
	end component;

	component conversion_corriente is 
		port (
			conv_i_in      : in std_logic_vector(11 downto 0);
			conv_ref_in    : in std_logic_vector(31 downto 0);
			conv_i_out     : out std_logic_vector(31 downto 0);
			conv_i_disp    : out std_logic_vector(15 downto 0);
			conv_ref_disp  : out std_logic_vector(15 downto 0);
			neg_flag       : out std_logic
		);
	end component;
 
	component conversion_tension is
		port (
			conv_u_in      : in std_logic_vector(11 downto 0);
			conv_ref_in    : in std_logic_vector(31 downto 0);
			conv_u_out     : out std_logic_vector(31 downto 0);
			conv_u_disp    : out std_logic_vector(15 downto 0);
			conv_ref_disp  : out std_logic_vector(15 downto 0)
		);
	end component;

	component pi_tension is
		port (
			clk             : in std_logic;
			integrator_rst  : in std_logic;
			ref_in          : in std_logic_vector(31 downto 0);
			tension_in      : in std_logic_vector(31 downto 0);
			pi_out          : out std_logic_vector(31 downto 0)
		);
	end component;

	component pi_corriente is
		port (
			clk             : in std_logic;
			integrator_rst  : in std_logic;
			switch_i_ref    : in std_logic;
			ref_in_pi_u     : in std_logic_vector(31 downto 0);
			ref_in_i        : in std_logic_vector(31 downto 0);
			corriente_in    : in std_logic_vector(31 downto 0);
			pi_out          : out std_logic_vector(11 downto 0)
		);
	end component;

	component btn_display is
		port (
			clk                : in std_logic;
			btn_add            : in std_logic;
			btn_sub            : in std_logic;
			btn_next           : in std_logic;
			btn_prev           : in std_logic;
			ref_u              : in std_logic_vector (15 downto 0);
			ref_i              : in std_logic_vector (15 downto 0);
			corriente          : in std_logic_vector (15 downto 0);
			tension            : in std_logic_vector (15 downto 0);
			btn_add_debounced  : out std_logic;
			btn_sub_debounced  : out std_logic;
			anodes             : out std_logic_vector (3 downto 0);
			cathodes           : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component uart is
		port (
			clk  : in std_logic;
			data : in std_logic_vector(63 downto 0);
			tx  : out std_logic
		);
	end component;
			

begin
	clk_sample_divider : clock_divider
	port map(
		clk      => clk, 
		clk_div  => clk_sample
	);

	adc : adc_controller
	port map(
		clk      => clk, 
		rst      => '0', 
		sdata_1  => sdata_1, 
		sdata_2  => sdata_2, 
		sclk     => sclk, 
		cs       => cs, 
		data_1   => data_1, -- Tensión
		data_2   => data_2, -- Corriente
		start    => clk_sample, 
		done     => open
	);

	fir_corriente : filtro_corriente
	port map(
		clk                   => clk_sample, 
		filtro_corriente_in   => data_2, 
		filtro_corriente_out  => data_2_filtered
	);

	ref : referencia
	port map(
		clk        => clk, 
		btn_add    => btn_add_debounced, 
		ref_type   => switch_i_ref, 
		btn_sub    => btn_sub_debounced, 
		ref_u_out  => ref_u, 
		ref_i_out  => ref_i
	);

	conv_tension : conversion_tension
	port map(
		conv_u_in      => data_1, 
		conv_ref_in    => ref_u, 
		conv_u_out     => tension_pi, 
		conv_u_disp    => tension_display, 
		conv_ref_disp  => ref_u_display
	);
 
	conv_corriente : conversion_corriente
	port map(
		conv_i_in      => data_2_filtered, 
		conv_ref_in    => ref_i, 
		conv_i_out     => corriente_pi, 
		conv_i_disp    => corriente_display, 
		conv_ref_disp  => ref_i_display, 
		neg_flag       => neg_flag 
	);
 
	pi_u : pi_tension
	port map(
		clk             => clk_sample, 
		integrator_rst  => switch_i_ref, 
		ref_in          => ref_u, 
		tension_in      => tension_pi, 
		pi_out          => pi_u_out
	);

	pi_i : pi_corriente
	port map(
		clk             => clk_sample, 
		integrator_rst  => integrator_i_rst, 
		switch_i_ref    => switch_i_ref, 
		ref_in_pi_u     => pi_u_out, 
		ref_in_i        => ref_i, 
		corriente_in    => corriente_pi, 
		pi_out          => pi_i_out
	);

	pwm : pwm_controller
	port map(
		clk         => clk, 
		rst         => pwm_rst, 
		duty_cycle  => pi_i_out, 
		pwm_out     => pwm_out, 
		pwm_n_out   => pwm_n_out
	);

	btn_display_controller : btn_display
	port map(
		clk                => clk, 
		btn_add            => btn_add, 
		btn_sub            => btn_sub, 
		btn_next           => btn_next, 
		btn_prev           => btn_prev, 
		ref_u              => ref_u_display, 
		ref_i              => ref_i_display, 
		corriente          => corriente_display, 
		tension            => tension_display, 
		btn_add_debounced  => btn_add_debounced, 
		btn_sub_debounced  => btn_sub_debounced, 
		anodes             => anodes, 
		cathodes           => cathodes
	);
	
	
	datos_uart : uart
	port map(
		clk => clk,
		data => x"FEDCBA9876543210",
		tx  => uart_tx
	);

	d <= pwm_out;
	d_n <= pwm_n_out;
end architecture;