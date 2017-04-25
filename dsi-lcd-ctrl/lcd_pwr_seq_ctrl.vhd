library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--LCD Power-on Sequencer
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This is designed to handle power on and reset sequencing of modern smartphone-style
--MIPI DSI displays; such as the 4k H546UAN01.0


entity lcd_pwr_seq_ctrl is
    port ( clock : in STD_LOGIC; --30MHz
           reset_in : in STD_LOGIC; --Input active high async reset
           bypass : in STD_LOGIC; --Force LCD power on and deassert reset immediately
           vddd_en : out STD_LOGIC; --Active high LCD VddD enable
           vdda_en : out STD_LOGIC; --Active high LCD VddA enable
           lcd_reset_b : out STD_LOGIC; --Active low LCD reset pin
           dsi_reset : out STD_LOGIC; --Active high reset out to DSI driver
           dsi_lp00 : out STD_LOGIC; --DSI force LP00
           pwm_en : out STD_LOGIC); --Enable backlight LED PWM
end lcd_pwr_seq_ctrl;

architecture Behavioral of lcd_pwr_seq_ctrl is

signal wait_ctr : unsigned(18 downto 0) := (others => '0');

signal state : std_logic_vector(2 downto 0) := "000";

begin
    process(clock, reset_in)
    begin
        if reset_in = '1' then
            state <= "000";
            wait_ctr <= (others => '0');
        elsif rising_edge(clock) then
            case state is
                when "000" => --init
                    state <= "001";
                    wait_ctr <= (others => '0');
                when "001" => --pwr on
                    if wait_ctr >= 300000 then
                        wait_ctr <= (others => '0');
                        state <= "010";
                    else
                        wait_ctr <= wait_ctr + 1;
                    end if;
                when "010" => --mipi => lp11
                    if wait_ctr >= 200000 then
                        wait_ctr <= (others => '0');
                        state <= "011";
                    else
                        wait_ctr <= wait_ctr + 1;
                    end if;
                when "011" => --reset = 1
                    if wait_ctr >= 300000 then
                        wait_ctr <= (others => '0');
                        state <= "100";
                    else
                        wait_ctr <= wait_ctr + 1;
                    end if;
                when "100" => --reset = 0
                    if wait_ctr >= 300 then
                        wait_ctr <= (others => '0');
                        state <= "101";
                    else
                        wait_ctr <= wait_ctr + 1;
                    end if;
                when "101" => --reset = 1
                    if wait_ctr >= 350000 then
                        wait_ctr <= (others => '0');
                        state <= "111";
                    else
                        wait_ctr <= wait_ctr + 1;
                    end if;
                when "111" => --done, tx begin
                    state <= "111";
                when others =>
                    state <= "000";
            end case;
        end if;
    end process;

    vddd_en <= '0' when state = "000" and bypass = '0' else '1';
    vdda_en <= '0' when state = "000" and bypass = '0' else '1';
    dsi_reset <= '0' when state = "111" or bypass = '1' else '1';
    lcd_reset_b <= '1' when state = "011" or state = "101" or state = "111" or bypass = '1' else '0';
    dsi_lp00 <= '1' when (state = "000" or state = "001") and bypass = '0' else '0';
    pwm_en <= '1' when state = "101" or state = "111" or bypass = '1' else '0';
end Behavioral;
