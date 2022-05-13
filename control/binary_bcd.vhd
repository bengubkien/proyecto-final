library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity binary_bcd is
	generic (
		n : positive := 16
	);
	port (
		clk, rst          : in std_logic;
		binary            : in std_logic_vector(n - 1 downto 0);
		displayed_number  : out std_logic_vector(15 downto 0)
	);
end binary_bcd;

architecture behaviour of binary_bcd is
	type states is (start, shift, done);
	signal state, state_next : states;

	signal binary_sgn, binary_next : std_logic_vector(n - 1 downto 0);
	signal bcds, bcds_reg, bcds_next : std_logic_vector(19 downto 0);
	signal bcds_out_reg, bcds_out_reg_next : std_logic_vector(19 downto 0);
	signal shift_counter, shift_counter_next : natural range 0 to n;
begin
	process (clk, rst)
	begin
		if rst = '1' then
			binary_sgn <= (others => '0');
			bcds <= (others => '0');
			state <= start;
			bcds_out_reg <= (others => '0');
			shift_counter <= 0;
		elsif falling_edge(clk) then
			binary_sgn <= binary_next;
			bcds <= bcds_next;
			state <= state_next;
			bcds_out_reg <= bcds_out_reg_next;
			shift_counter <= shift_counter_next;
		end if;
	end process;

	convert : 
	process (state, binary_sgn, binary, bcds, bcds_reg, shift_counter)
		begin
			state_next <= state;
			bcds_next <= bcds;
			binary_next <= binary_sgn;
			shift_counter_next <= shift_counter;

			case state is
				when start => 
					state_next <= shift;
					binary_next <= binary;
					bcds_next <= (others => '0');
					shift_counter_next <= 0;
				when shift => 
					if shift_counter = N then
						state_next <= done;
					else
						binary_next <= binary_sgn(n - 2 downto 0) & 'L';
						bcds_next <= bcds_reg(18 downto 0) & binary_sgn(n - 1);
						shift_counter_next <= shift_counter + 1;
					end if;
				when done => 
					state_next <= start;
			end case;
		end process;
 
		bcds_reg(19 downto 16) <= bcds(19 downto 16) + 3 when bcds(19 downto 16) > 4 else
		                          bcds(19 downto 16);
		bcds_reg(15 downto 12) <= bcds(15 downto 12) + 3 when bcds(15 downto 12) > 4 else
		                          bcds(15 downto 12);
		bcds_reg(11 downto 8) <= bcds(11 downto 8) + 3 when bcds(11 downto 8) > 4 else
		                         bcds(11 downto 8);
		bcds_reg(7 downto 4) <= bcds(7 downto 4) + 3 when bcds(7 downto 4) > 4 else
		                        bcds(7 downto 4);
		bcds_reg(3 downto 0) <= bcds(3 downto 0) + 3 when bcds(3 downto 0) > 4 else
		                        bcds(3 downto 0);

		bcds_out_reg_next <= bcds when state = done else
		                     bcds_out_reg;
 
		displayed_number <= bcds_out_reg(15 downto 0);

end behaviour;