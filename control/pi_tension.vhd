--library IEEE;
--use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
--
--entity pi_tension is
--	port (
--		clk            : in  std_logic;
--		integrator_rst : in  std_logic;
--		ref_in         : in  std_logic_vector(31 downto 0);
--		tension_in     : in  std_logic_vector(31 downto 0);
--		pi_out         : out std_logic_vector(31 downto 0)
--	);
--end pi_tension;
--
--architecture rtl of pi_tension is
--
--	signal ref_in_signed : signed(31 downto 0);
--	signal tension_in_signed : signed(31 downto 0);
--	signal error_sub_temp : signed(32 downto 0);
--	signal error_out1 : signed(31 downto 0);
--	signal k_p_mul_temp : signed(63 downto 0);
--	signal k_p_out1 : signed(31 downto 0);
--	signal k_i_mul_temp : signed(63 downto 0);
--	signal k_i_out1 : signed(31 downto 0);
--	signal clamping_out1 : signed(31 downto 0);
--	signal integrator_out1 : signed(31 downto 0) := to_signed(0, 32);
--	signal i_add_add_temp : signed(34 downto 0);
--	signal i_add_out1 : signed(31 downto 0);
--	signal add_out_add_temp : signed(42 downto 0);
--	signal add_out_out1 : signed(31 downto 0);
--	signal saturation_out1 : signed(31 downto 0);
--
--begin
--	ref_in_signed <= signed(ref_in);
--
--	tension_in_signed <= signed(tension_in);
--
--	error_sub_temp <= (resize(ref_in_signed, 33)) - (resize(tension_in_signed, 33));
--	error_out1 <= error_sub_temp(23 downto 0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0';
--
--	k_p_mul_temp <= to_signed(1374389535, 32) * error_out1;
--	k_p_out1 <= resize(k_p_mul_temp(63 downto 45), 32);
--
--	k_i_mul_temp <= to_signed(1125899907, 32) * error_out1;
--	k_i_out1 <= resize(k_i_mul_temp(63 downto 46), 32);
--
--	integrator_process : process (clk)
--	begin
--		if rising_edge(clk) then
--			integrator_out1 <= clamping_out1;
--		end if;
--	end process;
--
--	i_add_add_temp <= (resize(k_i_out1 & '0' & '0', 35)) + (resize(integrator_out1, 35));
--
--	i_add_out1 <= i_add_add_temp(31 downto 0) when integrator_rst = '0' else to_signed(0, 32);
--    
--	clamping_out1 <= to_signed(671088640, 32) when i_add_out1 > to_signed(671088640, 32) else
--		to_signed(0, 32) when i_add_out1 < to_signed(0, 32) else
--		i_add_out1;
--
--	add_out_add_temp <= (resize(k_p_out1 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 43)) + (resize(clamping_out1, 43));
--
--	add_out_out1 <= add_out_add_temp(41 downto 10);
--
--	saturation_out1 <= to_signed(655360, 32) when add_out_out1 > to_signed(655360, 32) else to_signed(0, 32) when add_out_out1 < to_signed(0, 32) else add_out_out1;
--
--	pi_out <= std_logic_vector(saturation_out1);
--
--end rtl;
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY pi_tension IS
  PORT( clk                               :   IN    std_logic;
integrator_rst : in  std_logic;
        ref_in                            :   IN    std_logic_vector(31 DOWNTO 0);
        tension_in                        :   IN    std_logic_vector(31 DOWNTO 0);
        pi_out                            :   OUT   std_logic_vector(31 DOWNTO 0)
        );
END pi_tension;


ARCHITECTURE rtl OF pi_tension IS

     SIGNAL ref_in_signed                    : signed(31 DOWNTO 0);
  SIGNAL tension_in_signed                : signed(31 DOWNTO 0);
  SIGNAL error_sub_temp                   : signed(32 DOWNTO 0);
  SIGNAL error_out1                       : signed(63 DOWNTO 0);
  SIGNAL k_p_cast                         : signed(127 DOWNTO 0);
  SIGNAL k_p_out1                         : signed(31 DOWNTO 0);
  SIGNAL k_i_mul_temp                     : signed(127 DOWNTO 0);
  SIGNAL k_i_out1                         : signed(63 DOWNTO 0);
  SIGNAL clamping_out1                    : signed(63 DOWNTO 0);
  SIGNAL integrator_out1                  : signed(63 DOWNTO 0) := to_signed(0, 64);
  SIGNAL i_add_out1                       : signed(63 DOWNTO 0);
  SIGNAL add_out_add_temp                 : signed(64 DOWNTO 0);
  SIGNAL add_out_out1                     : signed(31 DOWNTO 0);
  SIGNAL saturation_out1                  : signed(31 DOWNTO 0);

BEGIN
  ref_in_signed <= signed(ref_in);

  tension_in_signed <= signed(tension_in);

  error_sub_temp <= (resize(ref_in_signed, 33)) - (resize(tension_in_signed, 33));
  error_out1 <= resize(error_sub_temp & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 64);

  k_p_cast <= resize(error_out1 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 128);
  k_p_out1 <= k_p_cast(116 DOWNTO 85);

  k_i_mul_temp <= signed'(X"44B82FA09B5A5400") * error_out1;
  k_i_out1 <= resize(k_i_mul_temp(127 DOWNTO 88), 64);

  integrator_process : PROCESS (clk)
  BEGIN
    IF rising_edge(clk) THEN
      integrator_out1 <= clamping_out1;
    END IF;
  END PROCESS integrator_process;


  i_add_out1 <= k_i_out1 + integrator_out1  when integrator_rst = '0' else to_signed(0, 64);

  
  clamping_out1 <= signed'(X"00000A0000000000") WHEN i_add_out1 > signed'(X"00000A0000000000") ELSE
      to_signed(0, 64) WHEN i_add_out1 < to_signed(0, 64) ELSE
      i_add_out1;

  add_out_add_temp <= (resize(k_p_out1 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 65)) + (resize(clamping_out1, 65));
  add_out_out1 <= add_out_add_temp(55 DOWNTO 24);

  
  saturation_out1 <= to_signed(655360, 32) WHEN add_out_out1 > to_signed(655360, 32) ELSE
      to_signed(0, 32) WHEN add_out_out1 < to_signed(0, 32) ELSE
      add_out_out1;

  pi_out <= std_logic_vector(saturation_out1);

END rtl;
