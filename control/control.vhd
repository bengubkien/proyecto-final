library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity control is
	port (
		clk                                          : in std_logic;
		pwm_rst, integrator_u_rst, integrator_i_rst, adc_rst  : in std_logic;
		switch_i_ref                                 : in std_logic;
		sdata_1, sdata_2                             : in std_logic;
		sda, scl									: inout std_logic;
		btn_add, btn_sub, btn_next, btn_prev         : in std_logic;
		anodes                                       : out std_logic_vector (3 downto 0);
		cathodes                                     : out std_logic_vector(7 downto 0);
		d                                            : out std_logic;
		d_n                                          : out std_logic;
		sclk, cs                                     : out std_logic;
		neg_flag                                      : out std_logic
	);
end control;

architecture structural of control is

	signal clk_ad1 : std_logic;
	signal clk_ad2 : std_logic;

	signal data_1 : std_logic_vector (15 downto 0);
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

	component clock_divider is
		generic(div    : in          integer);
		port (
			clk      : in std_logic;
			clk_div  : out std_logic
		);
	end component;

	component ad1_controller is
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

	component pmodAD2_ctrl is
		generic(pmod_config : in          std_logic_vector(7 downto 0));
    Port ( 
	 mainClk	: in		STD_LOGIC;
           SDA_mst	: inout	STD_LOGIC;
			  test : out std_logic;
           SCL_mst	: inout	STD_LOGIC;
           wData0		: out		STD_LOGIC_VECTOR (15 downto 0);
           rst			: in		STD_LOGIC);
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

begin
	clk_div_ad1 : clock_divider
	generic map(
		div => 80
	)
	port map(
		clk      => clk, 
		clk_div  => clk_ad1
	);

	clk_div_ad2 : clock_divider
	generic map(
		div => 930
	)
	port map(
		clk      => clk, 
		clk_div  => clk_ad2
	);

	ad1 : ad1_controller
	port map(
		clk      => clk, 
		rst      => '0', 
		sdata_1  => sdata_1, 
		sdata_2  => sdata_2, 
		sclk     => sclk, 
		cs       => cs, 
		data_1   => open, -- Tensión
		data_2   => data_2, -- Corriente
		start    => clk_ad1, 
		done     => open
	);

	ad2 : pmodAD2_ctrl
	generic map(pmod_config => "00010000")
	port map(
	
	mainClk => clk,
		SDA_mst => sda,
		SCL_mst => scl,
		wData0 => data_1,
		rst => adc_rst
		);

	fir_corriente : filtro_corriente
	port map(
		clk                   => clk_ad2, 
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
		conv_u_in      => data_1(11 downto 0), 
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
		clk             => clk_ad2, 
		integrator_rst  => integrator_u_rst, 
		ref_in          => ref_u, 
		tension_in      => tension_pi, 
		pi_out          => pi_u_out
	);

	pi_i : pi_corriente
	port map(
		clk             => clk_ad2, 
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

	d <= pwm_out;
	d_n <= pwm_n_out;
end architecture;