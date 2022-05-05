------------------------------------------------------------------------
--	pmodAD2_ctrl.vhd  -- Frame for TWI system for PmodAD2 controller
------------------------------------------------------------------------
-- Author: Luke Renaud 
--	Copyright 2011 Digilent, Inc.
------------------------------------------------------------------------
-- Module description
--		This module takes in the standard system clock interfaces, and
--		uses them to control the five transfer TWI sequence for interf-
--		acing with the PmodAD2. The TWI interface itself is handled by
--		a module writen by an Digilent Romaina.
--	
--		To interface with the module, the address and data is provided
--		and the STB line is brought high for at least one full
--		TWI clock pulse. The done signal is brought high by the module
--		when the system is ready for the next byte of a multibyte transfer
--		or when it's time to force a new transfer. Keep STB or MSG high
--		to continue transfering data, bring them low if you want the
--		system to stop transmitting. More details can be found in the TWICtl
--		file itself.
--
--		In this use, I write the configuration to the device, force a new
--		transfer and then perform a dual read operation to bring in the
--		value that the PmodAD2 has sampled from the PmodDA1.
--
--  Inputs:
--		mainClk		50MHz System Clock for the TWI module
--		SDA_mst		Inout for TWI Data pin
--		rst			Main reset control
--
--  Outputs:
--		wData0		Returned Analog Value
--		SCL_mst		TWI Clock
--
------------------------------------------------------------------------
-- Revision History:
--
--	6/2/2011(Luke Renaud): created
--
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

entity pmodAD2_ctrl is
    generic(pmod_config     : in          std_logic_vector(7 downto 0));
    Port (mainClk	        : in		  STD_LOGIC;
          SDA_mst	        : inout	      STD_LOGIC;
          SCL_mst	        : inout	      STD_LOGIC;  
			 test : out std_logic;
          wData0		    : out		  STD_LOGIC_VECTOR (15 downto 0);
          rst			    : in		  STD_LOGIC;
          output_ready_p    : out         STD_LOGIC);
end pmodAD2_ctrl;

architecture Behavioral of pmodAD2_ctrl is

	------------------------------------------------------------------------
	-- Component Declarations
	------------------------------------------------------------------------
	component TWICtl is
		generic (CLOCKFREQ : natural:=100); -- input CLK frequency in MHz
		Port (	MSG_I			: in	STD_LOGIC; --new message
					STB_I		: in	STD_LOGIC; --strobe
					A_I			: in	STD_LOGIC_VECTOR (7 downto 0); --address input bus
					D_I			: in	STD_LOGIC_VECTOR (7 downto 0); --data input bus
					D_O			: out	STD_LOGIC_VECTOR (7 downto 0); --data output bus
					DONE_O		: out	STD_LOGIC; --done status signal
					ERR_O		: out	STD_LOGIC; --error status
					CLK			: in	std_logic;	-- Input Clock
					SRST		: in	std_logic; -- Reset

					SDA			: inout	std_logic; --TWI SDA
					SCL			: inout	std_logic); --TWI SCL
	end component;

	------------------------------------------------------------------------
	-- General control and timing signals
	------------------------------------------------------------------------
	signal fMessage		: STD_LOGIC;
	signal internal_rst : std_logic;
	signal fDoTransmit	: STD_LOGIC;
	signal fDoRead		: STD_LOGIC;
	signal currentAddr	: STD_LOGIC_VECTOR(7 downto 0);
	signal fDone		: STD_LOGIC;
	       
	constant addrAD2	: STD_LOGIC_VECTOR(6 downto 0) := "0101001";
--	constant writeCfg	: STD_LOGIC_VECTOR(7 downto 0) := "11110000";
	--constant writeCfg	: STD_LOGIC_VECTOR(7 downto 0) := "00011100";
	
	signal waitCount : integer := 0;
    signal output_ready : STD_LOGIC;
	type	state_AD2_reader is (stDone, stWait1, stWait2, stGo, stConfig, stRead1, stRead1cont, stRead2, stop,next_wait);
	signal stMain : state_AD2_reader;

	------------------------------------------------------------------------
	-- Data path signals
	------------------------------------------------------------------------
	signal curResponse	: STD_LOGIC_VECTOR(7 downto 0);
    signal reg_output_data, output_data, output_data_in : std_logic_vector(15 downto 0);


    attribute mark_debug : string;
    attribute keep       : string;
    
--    attribute mark_debug of fDone : signal is "true";
----    attribute mark_debug of currentAddr : signal is "true";
--    attribute mark_debug of stMain : signal is "true";
--    attribute mark_debug of fMessage : signal is "true";
--    attribute mark_debug of fDoTransmit : signal is "true";
----    attribute mark_debug of MainClk: signal is "true";
--    attribute mark_debug of output_ready: signal is "true";
--    attribute mark_debug of curResponse: signal is "true";
--    attribute mark_debug of wData0: signal is "true";


------------------------------------------------------------------------
-- Implementation
------------------------------------------------------------------------

begin
output_ready_p<=output_ready;
wdata0<=reg_output_data;
	-- Tie together the bus
	I2CBus: TWICtl
		generic map (CLOCKFREQ =>100) -- System clock in MHz
		Port Map (
		MSG_I =>		fMessage,
		STB_I =>		fDoTransmit,
		A_I =>			currentAddr, -- Address with read/write bit
		--D_I =>			writeCfg, -- The one and only output byte
		D_I   =>        pmod_config,
		D_O =>			curResponse,
		DONE_O =>		fDone,
		ERR_O =>			open,
		CLK =>			mainClk,
		SRST =>			internal_rst,
		SDA =>			SDA_mst,
		SCL =>			SCL_mst);
	-- The address is constant except for the read flag
	currentAddr <= addrAD2(6 downto 0) & fDoRead; -- The address register is the address with the read/write bit
	-- The read flag is set when we aren't writing the config state.
	with stMain select
		fDoRead <=	'0' when stConfig,
						'0' when stGo,
						'1' when others;
	with stMain select
        internal_rst <= '1' when stWait1,
                        '0' when others;					
    with stMain select
        output_data_in <= output_data when stop,
                          reg_output_data when others;
output_reg_proc: process(mainClk, rst)
begin
    if rst='1' then
        reg_output_data<="0000000000000000";
    elsif rising_edge(mainClk) then
        reg_output_data<=output_data_in;
    end if;
end process output_reg_proc;
	
	
process(mainClk)
begin   
		if rising_edge(mainClk) then
			if (rst = '1') then
				stMain <= stWait1;
				fDoTransmit <= '0';
				fMessage <= '0';
				waitCount <= 0;
				output_ready<='0';
				output_data<="0000000000000000";
			else
				case stMain is
					-- When the TWI controller we're using is brought out of a reset state
					-- it requires a great deal of time to startup and make sure that the line
					-- we're trying to use is indeed idle. This routine waits for it because it
					-- does not contain a line ready type signal to let us start using it.
					when stWait1 =>
						waitCount <= waitCount + 1;
						fDoTransmit <= '0';
                        fMessage <= '0';
                        output_ready<='0';
						if (waitCount >= 1000) then
							stMain <= stWait2;
						else
							stMain <= stWait1;
						end if;					 
					when stWait2=>
					    waitCount <= waitCount + 1;
                        fDoTransmit <= '0';
                        fMessage <= '0';
                        output_ready<='0';
                        if (waitCount >= 5000) then
                            stMain <= stGo;
                        else
                        stMain <= stWait2;
                        end if;
                        -- Pulse the transmit lines for the first TX packet.
					when stGo =>
					    waitCount<=0;
						fDoTransmit <= '1';
						fMessage <= '0';
						stMain <= stConfig;
						output_ready<='0';

					when stConfig =>
						fMessage <= '0';
						fDoTransmit <= '0';
						output_ready<='0';
						-- Hold the configuration state until we're done sending.
						if (fDone = '1') then
							-- Send the proper pins high for the state change
							stMain <= stRead1;
						else
							-- Force the pins low now that we're actually in the state.
							fMessage <= '0';
							stMain <= stConfig;
						end if;		
-- This state manages setting the device to read the 16-bits
-- from the PmodAD2. The first byte (MSB) is read in this state
-- then the I2C controller will inidicate fDone. Once this happens
-- we pulse the transmit line to tell the controller we want to
-- move onto getting the next byte.
					when stRead1 =>
						fMessage <= '1';
						fDoTransmit <= '1';
						output_ready<='0';
						if (fDone = '1') then
							-- Send the proper pins high for the state change
							stMain <= stRead2;
							output_data(15 downto 8) <= curResponse;
						else
							-- Force the pins low now that we're actually in the state.
							stMain <= stRead1;
						end if;                    
					when stRead1cont =>
                            fMessage <= '0';
                            fDoTransmit <= '1';
                            output_ready<='0';
                            if (fDone = '1') then
                                -- Send the proper pins high for the state change
                                stMain <= stRead2;
                                output_data(15 downto 8) <= curResponse;
                            else
                                -- Force the pins low now that we're actually in the state.
                                stMain <= stRead1cont;
                            end if;
					-- This state manages recieving the second byte from the PmodAD2 over the
					-- I2C line. To do this the transmit message line is pulsed high for a
					-- moment to indicate that we keep transmitting on the same packet stream.
					when stRead2 =>
						-- Keep the fDoTransmit pin asserted to indicate multibyte transmit.
						fDoTransmit <= '1';
						fMessage <= '0';
						output_ready<='0';
						if (fDone = '1') then						    
							stMain <= stop;
							output_data(7 downto 0) <= curResponse;
						else
							stMain <= stRead2;
						end if;
					when Stop =>
                         stMain <= stRead1cont;
                         output_ready<='1';
                                    
                    when others =>
						-- TX pins stay low once we're done
						fDoTransmit <= '0';
						fMessage <= '0';
						stMain <= stGo;
						output_ready<='0';
				end case;
			end if;
		end if;			
	end process;
	
	
test <= output_ready;
	
end Behavioral;