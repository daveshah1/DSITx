library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--MIPI DSI Tx DCS command prepender
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This module prepends the DCS command byte to a streaming 32-bit payload,
--and shifts out 32 bits of data every cycle. It is required in command mode
--DSI to prepend the command; like write memory or wire memory continue


entity dsi_tx_prepend_dcs_cmd is
    Port ( clock : in STD_LOGIC; --word clock
           first_word : in STD_LOGIC; --assert when first word to add command byte at start
           cmd_in : in STD_LOGIC_VECTOR (7 downto 0); --command byte to prepend
           data_in : in STD_LOGIC_VECTOR (31 downto 0); --streaming payload data in
           payload_out : out STD_LOGIC_VECTOR (31 downto 0)); --streaming payload data out
end dsi_tx_prepend_dcs_cmd;

architecture Behavioral of dsi_tx_prepend_dcs_cmd is
signal remainder_r : std_logic_vector(7 downto 0);
signal payload_r : std_logic_vector(31 downto 0);
signal remainder_q : std_logic_vector(7 downto 0);
signal payload_q : std_logic_vector(31 downto 0);
begin
    process(first_word, cmd_in, data_in, remainder_q)
    begin
        if first_word = '1' then
            payload_r <= data_in(23 downto 0) & cmd_in;
        else
            payload_r <= data_in(23 downto 0) & remainder_q;
        end if;
        remainder_r <= data_in(31 downto 24);
    end process;

    process(clock)
    begin
        if rising_edge(clock) then
            payload_q <= payload_r;
            remainder_q <= remainder_r;
        end if;
    end process;

    payload_out <= payload_q;
end Behavioral;
