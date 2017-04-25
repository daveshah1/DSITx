library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

--MIPI DSI Tx Clock Lane PHY
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This outputs the high speed clock when required; and also supports forcing
--the clock lane to various states during parts of the init sequence

entity dsi_tx_clock_phy is
    Port ( hs_clock_in : in STD_LOGIC; --High speed clock to output (DDR bit clock; so word clock x 4)
           enable : in STD_LOGIC; --Assert to output high speed clock; when deasserted outputs LP11 unless lp00_mode asserted
           lp00_mode : in std_logic; --Assert to force clock lane to LP00 state
           dphy_hs_clk : inout STD_LOGIC_VECTOR (1 downto 0); --High speed clock lines
           dphy_lp_clk : inout STD_LOGIC_VECTOR (1 downto 0));  --Low power clock lines
end dsi_tx_clock_phy;

architecture Behavioral of dsi_tx_clock_phy is
signal hs_clock_t : std_logic;
signal hs_clock_d : std_logic;
begin
    hs_clock_t <= (not enable) or (lp00_mode);

    dphy_lp_clk <=  "00" when (lp00_mode = '1') else
                    "11" when (enable = '0') else "ZZ";

    --Using the ODDR to route the clock to general purpose IO pair
    clk_drv : ODDR
    generic map(
        DDR_CLK_EDGE => "OPPOSITE_EDGE",
        INIT => '0',
        SRTYPE => "SYNC")
    port map(
        Q => hs_clock_d,
        C => hs_clock_in,
        CE => '1',
        D1 => '1',
        D2 => '0',
        R => '0',
        S => '0');

    dsi_lane_buf : OBUFTDS
    generic map (
       IOSTANDARD => "DIFF_SSTL18_II")
    port map(
       O => dphy_hs_clk(1),
       OB => dphy_hs_clk(0),
       I => hs_clock_d,
       T => hs_clock_t);

end Behavioral;
