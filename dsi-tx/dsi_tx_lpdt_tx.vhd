library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--MIPI DSI Low Power Data Transfer Tx controller
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

entity dsi_tx_lpdt_tx is
    Port ( bit_clk_2x : in STD_LOGIC; --2x bit clock (64x word clock)
           word_ce : in std_logic; --pulses once per word
           lpdt_sot : in STD_LOGIC; --start of transmit
           lpdt_data : in STD_LOGIC_VECTOR (31 downto 0); --data to transmit, LSByte first
           lpdt_enable : in STD_LOGIC_VECTOR (3 downto 0); --data enable per byte
           lpdt_eot : in std_logic_vector(3 downto 0); --end of transmit per byte
           lp_dphy : out STD_LOGIC_VECTOR (1 downto 0)); --Dp Dn
end dsi_tx_lpdt_tx;

architecture Behavioral of dsi_tx_lpdt_tx is
signal last_word_clk : std_logic := '0';
signal bit_count : unsigned(5 downto 0);
signal int_sot : std_logic;
signal int_data : std_logic_vector(31 downto 0);
signal int_enable : std_logic_vector(3 downto 0);
signal int_eot : std_logic_vector(3 downto 0);

begin
    process(bit_clk_2x)
    begin
        if rising_edge(bit_clk_2x) then
            if word_ce = '1' then
                bit_count <= "000000";
                int_sot <= lpdt_sot;
                int_data <= lpdt_data;
                int_enable <= lpdt_enable;
                int_eot <= lpdt_eot;
            else
                bit_count <= bit_count + 1;
            end if;
         end if;
    end process;

    process(bit_count, int_sot, int_data, int_enable)
    variable current_word : integer range 0 to 3;
    begin
        current_word := to_integer(bit_count(5 downto 4));
        if int_sot = '1' then
            case to_integer(bit_count) is --escape mode entry and LPDT command
              when 0 to 43 =>
                  lp_dphy <= "11";
              when 44 =>
                  lp_dphy <= "10";
              when 45 =>
                  lp_dphy <= "00";
              when 46 =>
                  lp_dphy <= "01";
              when 47 =>
                  lp_dphy <= "00";
              when 48 =>
                  lp_dphy <= "10";
              when 49 =>
                  lp_dphy <= "00";
              when 50 =>
                  lp_dphy <= "10";
              when 51 =>
                  lp_dphy <= "00";
              when 52 =>
                  lp_dphy <= "10";
              when 53 =>
                  lp_dphy <= "00";
              when 54 =>
                  lp_dphy <= "01";
              when 55 =>
                  lp_dphy <= "00";
              when 56 =>
                  lp_dphy <= "01";
              when 57 =>
                  lp_dphy <= "00";
              when 58 =>
                  lp_dphy <= "01";
              when 59 =>
                  lp_dphy <= "00";
              when 60 =>
                  lp_dphy <= "01";
              when 61 =>
                  lp_dphy <= "00";
              when 62 =>
                  lp_dphy <= "10";
              when 63 =>
                  lp_dphy <= "00";
              when others =>
                  lp_dphy <= "11";
            end case;
        elsif int_enable(current_word) = '1' then --output data for current word
            lp_dphy(1) <= (not bit_count(0)) and int_data((current_word * 8) + (to_integer(bit_count(3 downto 1))));
            lp_dphy(0) <= (not bit_count(0)) and not int_data((current_word * 8) + (to_integer(bit_count(3 downto 1))));
        elsif ((current_word = 0) and (int_eot = "1111"))
           or ((current_word = 1) and (int_eot = "1110"))
           or ((current_word = 2) and (int_eot = "1100"))
           or ((current_word = 3) and (int_eot = "1000")) then ---exit escape
           case to_integer(bit_count(3 downto 0)) is
            when 0 =>
                lp_dphy <= "10";
            when 1 =>
                lp_dphy <= "11";
            when others =>
                lp_dphy <= "11";
           end case;
        else
            lp_dphy <= "11";
        end if;
    end process;
end Behavioral;
