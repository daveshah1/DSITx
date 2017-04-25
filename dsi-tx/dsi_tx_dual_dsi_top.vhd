library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Horizontally-split 4-lane MIPI DSI Command Mode Transmitter - Top Level Design
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This wraps around two Command Mode transmitters (dsi_tx_dual_dsi_top.vhd) to
--drive a horizontally-split dual link display, such as many modern high res
--smartphone displays

--For further details on the hardware setup and clocking, please refer to the
--comments in dsi_tx_dual_dsi_top.vhd

--This also handles LCD power-on sequencing

entity dsi_tx_dual_dsi_top is
    generic (
      command_mode : boolean := true; --reserved for future use, set to true

      vsync_to_first_cmd : natural := 8160; --VSYNC falling edge to first command
      hsync_to_cmd : natural := 1; --HSYNC falling edge to line data write command

      line_width : natural := 1080; --Line width in pixels
      frame_height : natural := 1920 --Frame height in pixels
    );
    port (
      pixel_clock : in STD_LOGIC; --Video pixel clock

      hs_word_clock : in STD_LOGIC; --DSI clocks, see above
      hs_bit_clock : in STD_LOGIC;
      hs_out_clock : in STD_LOGIC;
      ls_2xbit_clock : in STD_LOGIC;

      reset : in STD_LOGIC; --Active high master reset in

      --Parallel video port, note sync pins are active low
      video_hsync : in STD_LOGIC;
      video_vsync : in STD_LOGIC;
      video_den : in STD_LOGIC;
      video_rgb : in STD_LOGIC_VECTOR (23 downto 0);
      video_pixel_x : in NATURAL range 0 to line_width - 1;
      --LCD power sequencing outputs
      vddd_en : out STD_LOGIC; --Active high LCD VddD enable
      vdda_en : out STD_LOGIC; --Active high LCD VddA enable
      lcd_reset_b : out STD_LOGIC; --Active low LCD reset pin
      pwm_en : out STD_LOGIC; --Backlight PWM enable

      panel_init_done : out STD_LOGIC; --Finished sending init commands

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
end dsi_tx_dual_dsi_top;

architecture Behavioral of dsi_tx_dual_dsi_top is
  signal left_video_den, right_video_den : std_logic;
  signal mipi_enable, mipi_lp00, mipi_reset : std_logic;

  signal ms_sync : std_logic;

  constant halfline_width : natural := line_width / 2;
  constant halfline_words : natural := ((halfline_width * 3) + 3) / 4;
begin
  init_ctrl : entity work.lcd_pwr_seq_ctrl
    port map(
      clock => ls_2xbit_clock,
      reset_in => reset,
      bypass => '0',
      vddd_en => vddd_en,
      vdda_en => vdda_en,
      lcd_reset_b => lcd_reset_b,
      dsi_reset => mipi_reset,
      dsi_lp00 => mipi_lp00,
      pwm_en => pwm_en);

  mipi_enable <= not mipi_reset;

  video_split : entity work.video_splitter
    generic map(
      line_width => line_width)
    port map(
      input_den => video_den,
      pixel_x => video_pixel_x,
      output_den_left => left_video_den,
      output_den_right => right_video_den);

  left_dsi : entity work.dsi_tx_cmd_mode_top
    generic map(
      is_master => true,
      vsync_to_first_cmd => vsync_to_first_cmd,
      hsync_to_cmd => hsync_to_cmd,
      line_width_words => halfline_words,
      frame_height => frame_height)
    port map(
      pixel_clock => pixel_clock,
      hs_word_clock => hs_word_clock,
      hs_bit_clock => hs_bit_clock,
      hs_out_clock => hs_out_clock,
      ls_2xbit_clock => ls_2xbit_clock,
      global_enable => mipi_enable,
      lp00_mode => mipi_lp00,
      reset => mipi_reset,
      video_hsync => video_hsync,
      video_vsync => video_vsync,
      video_den => left_video_den,
      video_rgb => video_rgb,
      master_out => ms_sync,
      slave_in => '1',

      dphy_hs_clk => dphy0_hs_clk,
      dphy_lp_clk => dphy0_lp_clk,
      dphy_hs_d0 => dphy0_hs_d0,
      dphy_lp_d0 => dphy0_lp_d0,
      dphy_hs_d1 => dphy0_hs_d1,
      dphy_lp_d1 => dphy0_lp_d1,
      dphy_hs_d2 => dphy0_hs_d2,
      dphy_lp_d2 => dphy0_lp_d2,
      dphy_hs_d3 => dphy0_hs_d3,
      dphy_lp_d3 => dphy0_lp_d3);

  panel_init_done <= ms_sync;

  right_dsi : entity work.dsi_tx_cmd_mode_top
    generic map(
      is_master => false,
      vsync_to_first_cmd => vsync_to_first_cmd,
      hsync_to_cmd => hsync_to_cmd,
      line_width_words => halfline_words,
      frame_height => frame_height)
    port map(
      pixel_clock => pixel_clock,
      hs_word_clock => hs_word_clock,
      hs_bit_clock => hs_bit_clock,
      hs_out_clock => hs_out_clock,
      ls_2xbit_clock => ls_2xbit_clock,
      global_enable => mipi_enable,
      lp00_mode => mipi_lp00,
      reset => mipi_reset,
      video_hsync => video_hsync,
      video_vsync => video_vsync,
      video_den => right_video_den,
      video_rgb => video_rgb,
      master_out => open,
      slave_in => ms_sync,

      dphy_hs_clk => dphy1_hs_clk,
      dphy_lp_clk => dphy1_lp_clk,
      dphy_hs_d0 => dphy1_hs_d0,
      dphy_lp_d0 => dphy1_lp_d0,
      dphy_hs_d1 => dphy1_hs_d1,
      dphy_lp_d1 => dphy1_lp_d1,
      dphy_hs_d2 => dphy1_hs_d2,
      dphy_lp_d2 => dphy1_lp_d2,
      dphy_hs_d3 => dphy1_hs_d3,
      dphy_lp_d3 => dphy1_lp_d3);
end Behavioral;
