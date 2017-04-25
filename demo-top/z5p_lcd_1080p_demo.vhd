library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

--Top Level Design for Z5P LCD

--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This is a top level design for a 1080p demo of the Sharp-variant Z5 Premium
--LCD. It is designed to use a custom FMC breakout attached to the Digilent
--Genesys 2

entity z5p_lcd_1080p_demo is
  port(
    --Genesys 2 core
    clock_p : in std_logic;
    clock_n : in std_logic;

    reset_n : in std_logic;
    switches : in std_logic_vector(7 downto 0);
    leds : out std_logic_vector(7 downto 0);

    --LCD control and IO
    vddd_en : out std_logic;
    vdda_en : out std_logic;
    lcd_reset_b : out std_logic;
    bl_pwm_b : out std_logic;
    lcd_te : in std_logic;

    --DSI port 0 (master, left)
    dphy0_hs_clk : inout STD_LOGIC_VECTOR (1 downto 0); --DSI lanes; hs is high speed and lp is low power for resistor network
    dphy0_lp_clk : inout STD_LOGIC_VECTOR (1 downto 0); -- In each case 1 is P and 0 is N
    dphy0_hs_d0 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy0_lp_d0 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy0_hs_d1 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy0_lp_d1 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy0_hs_d2 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy0_lp_d2 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy0_hs_d3 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy0_lp_d3 : inout STD_LOGIC_VECTOR (1 downto 0);

    --DSI port 1 (slave, right)
    dphy1_hs_clk : inout STD_LOGIC_VECTOR (1 downto 0); --DSI lanes; hs is high speed and lp is low power for resistor network
    dphy1_lp_clk : inout STD_LOGIC_VECTOR (1 downto 0); -- In each case 1 is P and 0 is N
    dphy1_hs_d0 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy1_lp_d0 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy1_hs_d1 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy1_lp_d1 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy1_hs_d2 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy1_lp_d2 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy1_hs_d3 : inout STD_LOGIC_VECTOR (1 downto 0);
    dphy1_lp_d3 : inout STD_LOGIC_VECTOR (1 downto 0)
  );
end z5p_lcd_1080p_demo;

architecture Behavioral of z5p_lcd_1080p_demo is
  signal sys_clock : std_logic;
  signal reset : std_logic;

  signal pattern_vsync, pattern_hsync, pattern_den, pattern_line_start : std_logic;
  signal pattern_rgb : std_logic_vector(23 downto 0);
  signal pattern_sel : std_logic_vector(1 downto 0);
  signal pattern_x : natural range 0 to 1079;
  signal pattern_y : natural range 0 to 1919;

  signal pixel_clock : std_logic;
  signal hs_word_clock, hs_bit_clock, hs_out_clock, ls_2xbit_clock : std_logic;

  signal pwm_en : std_logic;

  signal te_toggle : std_logic := '0';

  component video_pll is
    port(
      clkin : in std_logic;
      pixel_clock : out std_logic
    );
  end component;

  component dsi_pll is
    port(
      clkin : in std_logic;
      hs_word_clock : out std_logic;
      hs_bit_clock : out std_logic;
      hs_out_clock : out std_logic;
      ls_2xbit_clock : out std_logic
    );
  end component;

  component dsi_debug is
    port(
      clk : IN STD_LOGIC;
      probe0 : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
  end component;

begin
  reset <= not reset_n;

  clkbuf : IBUFGDS
    generic map(
        DIFF_TERM => TRUE,
        IBUF_LOW_PWR => FALSE,
        IOSTANDARD => "DEFAULT")
    port map(
        O => sys_clock,
        I => clock_p,
        IB => clock_n);

  vpll : video_pll
    port map(
      clkin => sys_clock,
      pixel_clock => pixel_clock
    );

  dsipll : dsi_pll
    port map(
      clkin => sys_clock,
      hs_word_clock => hs_word_clock,
      hs_bit_clock => hs_bit_clock,
      hs_out_clock => hs_out_clock,
      ls_2xbit_clock => ls_2xbit_clock);

  pattern_sel <= switches(1 downto 0);

  patgen : entity work.test_pattern_enhanced
    generic map(
      video_hlength => 1152,
      video_vlength => 4326,
      video_hsync_pol => false,
      video_hsync_len => 16,
      video_hbp_len => 16,
      video_h_visible => 1080,
      video_vsync_pol => false,
      video_vsync_len => 8,
      video_vbp_len => 8,
      video_v_visible => 1920)
    port map(
      pixel_clock => pixel_clock,
      reset => reset,
      pattern_sel => pattern_sel,
      video_vsync => pattern_vsync,
      video_hsync => pattern_hsync,
      video_den => pattern_den,
      video_line_start => pattern_line_start,
      pixel_x => pattern_x,
      pixel_y => pattern_y,
      video_pixel => pattern_rgb);


  dsidrv : entity work.dsi_tx_dual_dsi_top
    generic map(
      command_mode => true,
      vsync_to_first_cmd => 8160,
      hsync_to_cmd => 1,
      line_width => 1080,
      frame_height => 1920)
    port map(
      pixel_clock => pixel_clock,
      hs_word_clock => hs_word_clock,
      hs_bit_clock => hs_bit_clock,
      hs_out_clock => hs_out_clock,
      ls_2xbit_clock => ls_2xbit_clock,
      reset => reset,
      video_hsync => pattern_hsync,
      video_vsync => pattern_vsync,
      video_den => pattern_den,
      video_rgb => pattern_rgb,
      video_pixel_x => pattern_x,
      vddd_en => vddd_en,
      vdda_en => vdda_en,
      lcd_reset_b => lcd_reset_b,
      pwm_en => pwm_en,

      panel_init_done => leds(3),

      dphy0_hs_clk => dphy0_hs_clk,
      dphy0_lp_clk => dphy0_lp_clk,
      dphy0_hs_d0 => dphy0_hs_d0,
      dphy0_lp_d0 => dphy0_lp_d0,
      dphy0_hs_d1 => dphy0_hs_d1,
      dphy0_lp_d1 => dphy0_lp_d1,
      dphy0_hs_d2 => dphy0_hs_d2,
      dphy0_lp_d2 => dphy0_lp_d2,
      dphy0_hs_d3 => dphy0_hs_d3,
      dphy0_lp_d3 => dphy0_lp_d3,

      dphy1_hs_clk => dphy1_hs_clk,
      dphy1_lp_clk => dphy1_lp_clk,
      dphy1_hs_d0 => dphy1_hs_d0,
      dphy1_lp_d0 => dphy1_lp_d0,
      dphy1_hs_d1 => dphy1_hs_d1,
      dphy1_lp_d1 => dphy1_lp_d1,
      dphy1_hs_d2 => dphy1_hs_d2,
      dphy1_lp_d2 => dphy1_lp_d2,
      dphy1_hs_d3 => dphy1_hs_d3,
      dphy1_lp_d3 => dphy1_lp_d3
    );

    bl_pwm_b <= not pwm_en;

    leds(0) <= '1';
    leds(1) <= pwm_en;
    leds(2) <= te_toggle;
    --dbg only
    process(lcd_te)
    begin
      if rising_edge(lcd_te) then
        te_toggle <= not te_toggle;
      end if;
    end process;

    leds(7 downto 4) <= (others => '0');

    dbg : dsi_debug
      port map(
        clk => ls_2xbit_clock,
        probe0 => dphy0_lp_d0
      );
    

end Behavioral;
