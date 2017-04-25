library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

--MIPI DSI Tx High-Speed Lane Transmit PHY
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This deserialises and transmits high speed packets; also handling framing and
--the low-level transmit state machine
--It also controls the "low power" lines when in high speed mode

entity dsi_tx_hs_tx_phy is
    port ( byte_clock : in std_logic; --Data byte clock, used for all inputs
           bit_clock : in std_logic; --DDR bit clock; i.e. byte_clock x 4
           reset : in std_logic; --Active high sync reset
           start : in STD_LOGIC; --Assert to start transfer
           ready : out STD_LOGIC; --Asserted for one clock cycle when preamble done and ready to start receiving data
           data : in STD_LOGIC_VECTOR (7 downto 0); --Data in to transmit
           eot : in STD_LOGIC; --Assert to end transfer
           enable : in STD_LOGIC; --Active high enable (for future use only)
           hs_dphy : inout STD_LOGIC_VECTOR (1 downto 0); --High speed lines: HsD+ HsD-
           lp_dphy : out STD_LOGIC_VECTOR (1 downto 0); --Low power lines (only controlled when in HS mode): LpD+ LpD-
           lp_oe : out STD_LOGIC); --Low power output enable (active high) for tristating

end dsi_tx_hs_tx_phy;

architecture Behavioral of dsi_tx_hs_tx_phy is
signal int_data : std_logic_vector(7 downto 0);
signal int_start : std_logic;
signal int_enable : std_logic;
signal int_eot : std_logic;
signal serdes_data : std_logic_vector(7 downto 0);
signal serdes_oe : std_logic;
signal serdes_oen : std_logic;
signal serdes_oq : std_logic;
signal serdes_tq : std_logic;
signal serdes_rst, serdes_rst_pre : std_logic;

signal int_ctr : unsigned(5 downto 0);
signal state : std_logic_vector(2 downto 0);
signal last_bit : std_logic;

begin
    process(byte_clock)
    begin
        if rising_edge(byte_clock) then
            int_data <= data;
            int_start <= start;
            int_enable <= enable;
            int_eot <= eot;
            serdes_rst <= serdes_rst_pre;
            last_bit <= int_data(7);
            if reset = '1' then
                state <= "000";
                int_ctr <= "000000";
            else
                case state is
                    when "000" => --wait for start
                        int_ctr <= (others => '0');
                        if start = '1' then
                            state <= "001";
                        end if;
                    when "001" => --HS-Rqst
                        if int_ctr > 1 then
                            int_ctr <= (others => '0');
                            state <= "010";
                        else
                            int_ctr <= int_ctr + 1;
                        end if;
                    when "010" => --HS-Br
                        if int_ctr > 1 then
                            int_ctr <= (others => '0');
                            state <= "011";
                        else
                            int_ctr <= int_ctr + 1;
                        end if;
                    when "011" => --HS-0
                        if int_ctr > 4 then
                            int_ctr <= (others => '0');
                            state <= "100";
                        else
                            int_ctr <= int_ctr + 1;
                        end if;
                    when "100" => --HS-Sync
                        state <= "101";
                    when "101" => --Packet
                        if int_eot = '1' then
                            state <= "110";
                        end if;
                    when "110" => --EoT
                        if int_ctr > 1 then
                            int_ctr <= (others => '0');
                            state <= "000";
                        else
                            int_ctr <= int_ctr + 1;
                        end if;
                    when others => --stop
                        state <= "000";
                end case;
            end if;
        end if;
    end process;
    serdes_rst_pre <= '1' when state = "000" else '0';
    ready <= '1' when state = "011" and int_ctr = 4 else '0';

    lp_oe <= '0' when (state = "011") or (state = "100") or (state = "101") or (state = "110") else '1';
    serdes_oe <= '1' when (state = "011") or (state = "100") or (state = "101") or (state = "110") else '0';

    serdes_data <= "10111000" when state = "100" else
                   int_data when state = "101" else
                   (others => not last_bit) when state = "110" else
                   "00000000";

    lp_dphy <= "11" when (state = "000" or state = "110") else
               "01" when state = "001" else
               "00" when state = "010" else
               "00";

    serdes_oen <=  not serdes_oe;



    dsi_serdes : OSERDESE2
      generic map(
          DATA_RATE_OQ => "DDR",
          DATA_RATE_TQ => "SDR",
          DATA_WIDTH => 8,
          INIT_OQ => '0',
          INIT_TQ => '0',
          SERDES_MODE => "MASTER",
          SRVAL_OQ => '0',
          SRVAL_TQ => '1',
          TBYTE_CTL => "FALSE",
          TBYTE_SRC => "FALSE",
          TRISTATE_WIDTH => 1)
      port map(
          OFB  => open,
          OQ => serdes_oq,
          SHIFTOUT1 => open,
          SHIFTOUT2 => open,
          TBYTEOUT => open,
          TFB => open,
          TQ => serdes_tq,
          CLK => bit_clock,
          CLKDIV => byte_clock,
          D1 => serdes_data(0),
          D2 => serdes_data(1),
          D3 => serdes_data(2),
          D4 => serdes_data(3),
          D5 => serdes_data(4),
          D6 => serdes_data(5),
          D7 => serdes_data(6),
          D8 => serdes_data(7),
          OCE => '1',
          RST => serdes_rst,
          SHIFTIN1 => '0',
          SHIFTIN2 => '0',
          T1 => serdes_oen,
          T2 => serdes_oen,
          T3 => serdes_oen,
          T4 => serdes_oen,
          TBYTEIN => '0',
          TCE => '1');

     dsi_lane_buf : OBUFTDS
       generic map (
          IOSTANDARD => "DEFAULT")
       port map(
          O => hs_dphy(1),
          OB => hs_dphy(0),
          I => serdes_oq,
          T => serdes_tq);

end Behavioral;
