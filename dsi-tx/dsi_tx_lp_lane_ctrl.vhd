library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--MIPI DSI Tx Low Power lane control
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

entity dsi_tx_lp_lane_ctrl is
    Port ( enable : in STD_LOGIC; --Whether or not LP communications are enabled - if unasserted line is 11
           lp00_mode : in STD_LOGIC; --Force 00 state; overrides enable; used at power on
           hs_mode : in STD_LOGIC; --High to enable control from HS PHY; low to use LPDT controller
           hstx_lp_dphy : in STD_LOGIC_VECTOR (1 downto 0); --Lane and tristate control from HS PHY
           hstx_lp_oe : in STD_LOGIC;
           lpdt_lp_dphy : in STD_LOGIC_VECTOR (1 downto 0); --Lane control from LPDT controller
           lp_dphy : inout STD_LOGIC_VECTOR (1 downto 0)); --The LP lane control signals themselves (P, N)
end dsi_tx_lp_lane_ctrl;

architecture Behavioral of dsi_tx_lp_lane_ctrl is

begin
    process(enable, lp00_mode, hs_mode, hstx_lp_dphy, hstx_lp_oe, lpdt_lp_dphy)
    begin
        if lp00_mode = '1' then
            lp_dphy <= "00";
        elsif enable = '0' then
            lp_dphy <= "11";
        else
            if hs_mode = '1' then
                if hstx_lp_oe = '1' then
                    lp_dphy <= hstx_lp_dphy;
                else
                    lp_dphy <= "ZZ";
                end if;
            else
                lp_dphy <= lpdt_lp_dphy;
            end if;
        end if;
    end process;

end Behavioral;
