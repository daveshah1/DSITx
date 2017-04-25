library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--4-lane MIPI DSI Command Mode Transmitter - Top Level Design
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This is a 4-lane MIPI DSI command mode transmitter intended to support a range
--of modern panels including dual link devices (such as recent 5.5" 4k displays).

--The primary testing platform is a Digilent Genesys 2 (Kintex-7 XC7K325T) with a
--custom FMC breakout board to A Z5 Premium LCD. At present although this is a 4k display
--I am running it in a mode where it upscales from 1080p as 4k usage seems to require
--a VESA DSC encoder which I am still working on.

--A resistor network is used; as with other FPGA DSI projects; to translate the seperate high speed
--and low power signals into a single MIPI DSI lane with the correct voltage levels

--At minimum you will need to provide suitable DSI clocks (example freqs for a 1Gbps link rate):
--  hs_word_clock : link rate / 8  [125MHz]
--  hs_bit_clock : link rate / 2 (note DDR) [500MHz]
--  hs_out_clock : same freq as hs_bit_clock, potentially different phase [500MHz]
--  ls_2xbit_clock : low power mode bitrate * 2 [30MHz]

--You will also need to provide a typical parallel pixel interfce with active low
--hsync/vsync and active high den; along with a pixel clock which will depend on
--the video timings

--If using a dual link (or more) panel where only setup commands are sent only on the first link;
--set is_master to false on the second link's driver and connect the master_out on the first link
--to slave_in on the second so initialisation is synchronised


entity dsi_tx_cmd_mode_top is
    generic (
      is_master : boolean := true; --Set to false to not send init commands
      vsync_to_first_cmd : natural := 8160; --VSYNC falling edge to first command
      hsync_to_cmd : natural := 1; --HSYNC falling edge to line data write command
      line_width_words : natural := 405; --Visible line width in words (not pixels)
      frame_height : natural := 1920 --Visible frame height in lines
    );
    port (
      pixel_clock : in STD_LOGIC; --Video pixel clock
      hs_word_clock : in STD_LOGIC; --DSI clocks, see above
      hs_bit_clock : in STD_LOGIC;
      hs_out_clock : in STD_LOGIC;
      ls_2xbit_clock : in STD_LOGIC;
      global_enable : in STD_LOGIC; --Entire driver enable
      lp00_mode : in STD_LOGIC; --Force all lanes to LP00 state
      reset : in STD_LOGIC; --Active high master reset in
      video_hsync : in STD_LOGIC; --Parallel video port, note sync pins are active low
      video_vsync : in STD_LOGIC;
      video_den : in STD_LOGIC;
      video_rgb : in STD_LOGIC_VECTOR (23 downto 0);
      master_out : out std_logic; --Used for synchronising drivers in multi link config
      slave_in : in std_logic; --Connect to master_out of master if is_master = False; otherwise hardwire to 1
      dphy_hs_clk : inout STD_LOGIC_VECTOR (1 downto 0); --DSI lanes; hs is high speed and lp is low power for resistor network
      dphy_lp_clk : inout STD_LOGIC_VECTOR (1 downto 0); -- In each case 1 is P and 0 is N
      dphy_hs_d0 : inout STD_LOGIC_VECTOR (1 downto 0);
      dphy_lp_d0 : inout STD_LOGIC_VECTOR (1 downto 0);
      dphy_hs_d1 : inout STD_LOGIC_VECTOR (1 downto 0);
      dphy_lp_d1 : inout STD_LOGIC_VECTOR (1 downto 0);
      dphy_hs_d2 : inout STD_LOGIC_VECTOR (1 downto 0);
      dphy_lp_d2 : inout STD_LOGIC_VECTOR (1 downto 0);
      dphy_hs_d3 : inout STD_LOGIC_VECTOR (1 downto 0);
      dphy_lp_d3 : inout STD_LOGIC_VECTOR (1 downto 0)
    );
end dsi_tx_cmd_mode_top;

architecture Behavioral of dsi_tx_cmd_mode_top is

  signal ls_word_ce : std_logic := '0';

  signal start_video_data : std_logic := '0';

  signal config_lp_d0 : STD_LOGIC_VECTOR (1 downto 0);

  signal video_lp_d0 : STD_LOGIC_VECTOR (1 downto 0);
  signal video_lp_d1 : STD_LOGIC_VECTOR (1 downto 0);
  signal video_lp_d2 : STD_LOGIC_VECTOR (1 downto 0);
  signal video_lp_d3 : STD_LOGIC_VECTOR (1 downto 0);

  signal video_lp_oe0 : std_logic;
  signal video_lp_oe1 : std_logic;
  signal video_lp_oe2 : std_logic;
  signal video_lp_oe3 : std_logic;

  signal hs_phy_start : std_logic;
  signal hs_phy_rdy : std_logic;
  signal hs_packet_type : STD_LOGIC_VECTOR (7 downto 0);
  signal hs_packet_len : STD_LOGIC_VECTOR (15 downto 0);
  signal hs_payload : STD_LOGIC_VECTOR (31 downto 0);

  signal hs_data : std_logic_vector(31 downto 0);
  signal hs_enable : std_logic_vector(3 downto 0);
  signal hs_eot : std_logic_vector(3 downto 0);

  signal ls_packet_start : std_logic;
  signal ls_is_short : std_logic;
  signal ls_packet_type : std_logic_vector(7 downto 0);
  signal ls_packet_hdr : std_logic_vector(15 downto 0);
  signal ls_payload : std_logic_vector(31 downto 0);

  signal ls_data : std_logic_vector(31 downto 0);
  signal ls_sot : std_logic_vector(3 downto 0);
  signal ls_enable : std_logic_vector(3 downto 0);
  signal ls_eot : std_logic_vector(3 downto 0);


signal mipi_enable : std_logic;

begin
  mipi_enable <= global_enable and not reset;

  wordce_div : entity work.dsi_tx_wordclk_div
    port map(
       bitclk_2x_in => ls_2xbit_clock,
       enable => mipi_enable,
       reset => reset,
       word_ce => ls_word_ce);

  gen_master : if is_master generate
         init_ctrl : entity work.lcd_init_cmd_ctrl
          port map (
           word_clock => ls_2xbit_clock,
           word_ce => ls_word_ce,
           reset => reset,
           tx_start => ls_packet_start,
           short_packet => ls_is_short,
           packet_type => ls_packet_type,
           packet_hdr => ls_packet_hdr,
           packet_payload => ls_payload,
           done => start_video_data);
  end generate;

  gen_slave : if not is_master generate
         start_video_data <= slave_in;
  end generate;

  master_out <= start_video_data;

  video_cmd_ctrl : entity work.dsi_tx_cmd_mode_controller
    generic map(
      vsync_to_start => vsync_to_first_cmd,
      hsync_to_cmd => hsync_to_cmd,
      line_width_words => line_width_words,
      frame_height => frame_height)
    port map (
     pixel_clock => pixel_clock,
     reset  => reset,
     input_hsync => video_hsync,
     input_vsync => video_vsync,
     input_den => video_den,
     input_rgb  => video_rgb,
     word_clock  => hs_word_clock,
     enable => start_video_data,
     phy_start => hs_phy_start,
     phy_ready => hs_phy_rdy,
     packet_type => hs_packet_type,
     packet_len => hs_packet_len,
     packet_data => hs_payload);

  hs_packetiser : entity work.dsi_tx_packetiser
    port map(
      word_clock => hs_word_clock,
      word_ce => '1',
      start => hs_phy_rdy,
      short_packet => '0',
      data_type => hs_packet_type,
      hdr_0 => hs_packet_len(7 downto 0),
      hdr_1 => hs_packet_len(15 downto 8),
      payload_in => hs_payload,
      data_out => hs_data,
      enable_out => hs_enable,
      sot_out => open,
      eot_out => hs_eot);

  ls_packetiser : entity work.dsi_tx_packetiser
    port map(
      word_clock => ls_2xbit_clock,
      word_ce => ls_word_ce,
      start => ls_packet_start,
      short_packet => ls_is_short,
      data_type => ls_packet_type,
      hdr_0 => ls_packet_hdr(7 downto 0),
      hdr_1 => ls_packet_hdr(15 downto 8),
      payload_in => ls_payload,
      data_out => ls_data,
      enable_out => ls_enable,
      sot_out => ls_sot,
      eot_out => ls_eot);

   lpdt_d0_phy : entity work.dsi_tx_lpdt_tx
    port map(
      bit_clk_2x => ls_2xbit_clock,
      word_ce => ls_word_ce,
      lpdt_sot => ls_sot(0),
      lpdt_data => ls_data,
      lpdt_enable => ls_enable,
      lpdt_eot => ls_eot,
      lp_dphy => config_lp_d0);

   hs_d0_phy : entity work.dsi_tx_hs_tx_phy
    port map(
      byte_clock  => hs_word_clock,
      bit_clock => hs_bit_clock,
      reset => reset,
      start => hs_phy_start,
      ready => hs_phy_rdy,
      data => hs_data(7 downto 0),
      eot => hs_eot(0),
      enable => hs_enable(0),
      hs_dphy => dphy_hs_d0,
      lp_dphy => video_lp_d0,
      lp_oe => video_lp_oe0);

   hs_d1_phy : entity work.dsi_tx_hs_tx_phy
    port map(
      byte_clock  => hs_word_clock,
      bit_clock => hs_bit_clock,
      reset => reset,
      start => hs_phy_start,
      ready => open,
      data => hs_data(15 downto 8),
      eot => hs_eot(1),
      enable => hs_enable(1),
      hs_dphy => dphy_hs_d1,
      lp_dphy => video_lp_d1,
      lp_oe => video_lp_oe1);

   hs_d2_phy : entity work.dsi_tx_hs_tx_phy
    port map(
      byte_clock  => hs_word_clock,
      bit_clock => hs_bit_clock,
      reset => reset,
      start => hs_phy_start,
      ready => open,
      data => hs_data(23 downto 16),
      eot => hs_eot(2),
      enable => hs_enable(2),
      hs_dphy => dphy_hs_d2,
      lp_dphy => video_lp_d2,
      lp_oe => video_lp_oe2);

   hs_d3_phy : entity work.dsi_tx_hs_tx_phy
    port map(
      byte_clock  => hs_word_clock,
      bit_clock => hs_bit_clock,
      reset => reset,
      start => hs_phy_start,
      ready => open,
      data => hs_data(31 downto 24),
      eot => hs_eot(3),
      enable => hs_enable(3),
      hs_dphy => dphy_hs_d3,
      lp_dphy => video_lp_d3,
      lp_oe => video_lp_oe3);

     ls_d0_sw : entity work.dsi_tx_lp_lane_ctrl
      port map(
        enable => mipi_enable,
        lp00_mode => lp00_mode,
        hs_mode => start_video_data,
        hstx_lp_dphy => video_lp_d0,
        hstx_lp_oe => video_lp_oe0,
        lpdt_lp_dphy => config_lp_d0,
        lp_dphy => dphy_lp_d0);

     ls_d1_sw : entity work.dsi_tx_lp_lane_ctrl
      port map (
        enable => mipi_enable,
        lp00_mode => lp00_mode,
        hs_mode => start_video_data,
        hstx_lp_dphy => video_lp_d1,
        hstx_lp_oe => video_lp_oe1,
        lpdt_lp_dphy => "11",
        lp_dphy => dphy_lp_d1);

     ls_d2_sw : entity work.dsi_tx_lp_lane_ctrl
      port map (
        enable => mipi_enable,
        lp00_mode => lp00_mode,
        hs_mode => start_video_data,
        hstx_lp_dphy => video_lp_d2,
        hstx_lp_oe => video_lp_oe2,
        lpdt_lp_dphy => "11",
        lp_dphy => dphy_lp_d2);

     ls_d3_sw : entity work.dsi_tx_lp_lane_ctrl
      port map (
        enable => mipi_enable,
        lp00_mode => lp00_mode,
        hs_mode => start_video_data,
        hstx_lp_dphy => video_lp_d3,
        hstx_lp_oe => video_lp_oe3,
        lpdt_lp_dphy => "11",
        lp_dphy => dphy_lp_d3);

     hs_lp_clock_phy : entity work.dsi_tx_clock_phy
      port map(
        hs_clock_in => hs_out_clock,
        enable => mipi_enable,
        lp00_mode => lp00_mode,
        dphy_hs_clk => dphy_hs_clk,
        dphy_lp_clk => dphy_lp_clk);
end Behavioral;
