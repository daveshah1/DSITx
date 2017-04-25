library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--MIPI DSI Tx Low Speed Word Clock Divider
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This takes the 2x bit clock in and asserts CE every 64 cycles to create
--a word clock enable

entity dsi_tx_wordclk_div is
    port ( bitclk_2x_in : in STD_LOGIC;
           enable : in STD_LOGIC;
           reset : in STD_LOGIC;
           word_ce : out STD_LOGIC);
end dsi_tx_wordclk_div;

architecture Behavioral of dsi_tx_wordclk_div is
    signal count : unsigned(5 downto 0);
begin
    process(bitclk_2x_in, reset)
    begin
        if reset = '1' then
            count <= (others => '0');
        elsif rising_edge(bitclk_2x_in) then
            if enable = '1' then
                count <= count + 1;
            end if;
        end if;
    end process;
    word_ce <= '1' when count = 63 else '0';
end Behavioral;
