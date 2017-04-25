library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--MIPI DSI Tx Command Mode Controller
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This takes standard pixel data with hsync+vsync+den and interfaces with the
--packetiser to output the data to a DSI Command Mode compatible display

entity dsi_tx_cmd_mode_controller is
    generic(
      vsync_to_start : natural := 8160; --VSYNC falling edge to first command
      hsync_to_cmd : integer := 1; --HSYNC falling edge to write command for that line
      line_width_words : integer := 405; --line width in words (NOT pixels)
      frame_height : integer := 1920 --frame height in lines
    );
    port (
      pixel_clock : in STD_LOGIC; --Input pixel clock
      reset : in STD_LOGIC; --Active high async reset
      input_hsync : in STD_LOGIC; --Input HSYNC - HSYNC and VSYNC are active low
      input_vsync : in STD_LOGIC; --Input VSYNC
      input_den : in STD_LOGIC; --Input data enable
      input_rgb : in STD_LOGIC_VECTOR (23 downto 0); --Input RGB pixel data
      word_clock : in STD_LOGIC; --DSI link word clock
      enable : in STD_LOGIC; --System enable
      phy_start : out STD_LOGIC; --Transfer start out to PHY
      phy_ready : in STD_LOGIC; --Ready to transmit in from PHY
      packet_type : out STD_LOGIC_VECTOR (7 downto 0); --Data type out to packetiser
      packet_len : out STD_LOGIC_VECTOR (15 downto 0); --Length out to packetiser
      packet_data : out STD_LOGIC_VECTOR (31 downto 0)); --Streaming payload data out to packetiser
end dsi_tx_cmd_mode_controller;


architecture Behavioral of dsi_tx_cmd_mode_controller is

  constant wr_mem_start : std_logic_vector(7 downto 0) := x"2C"; --write memory start command
  constant wr_mem_continue : std_logic_vector(7 downto 0) := x"3C"; --write memory continue command

  constant dsi_data_type : std_logic_vector(7 downto 0) := x"39";

  signal underflow_data : std_logic_vector(31 downto 0) := x"ADEADDE0"; --data used in case of fifo underflow

  function max(a, b: natural) return natural is
  begin
    if a > b then return a;
             else return b;
    end if;
  end max;

  COMPONENT video_data_fifo
    PORT (
      rst : IN STD_LOGIC;
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC
    );
  END COMPONENT;

  signal word_pack_reset : std_logic := '1';
  signal word_pack_wren : std_logic;
  signal word_pack_data : std_logic_vector(31 downto 0);

  signal fifo_wren : std_logic;

  signal fifo_rst : std_logic := '1';

  signal fifo_rden : std_logic;
  signal fifo_full : std_logic;
  signal fifo_empty : std_logic;
  signal fifo_dout : std_logic_vector(31 downto 0);

  signal video_data : std_logic_vector(31 downto 0);

  signal word_count : natural range 0 to line_width_words - 1;
  signal line_count : natural range 0 to frame_height - 1;

  signal last_hsync : std_logic;
  signal last_vsync : std_logic;

  signal state : std_logic_vector(2 downto 0);
  signal wait_ctr : natural range 0 to max(vsync_to_start, hsync_to_cmd);

  signal current_cmd : std_logic_vector(7 downto 0);
  signal first_word : std_logic;
  signal payload_data : std_logic_vector(31 downto 0);


begin

    process(word_clock, reset)
    begin
        if reset = '1' then
           state <= "000";
           wait_ctr <= 0;
           last_hsync <= '1';
           last_vsync <= '1';
        elsif rising_edge(word_clock) then
           if enable = '1' then
           case state is
             when "000" => --waiting for vsync
                wait_ctr <= 0;
                line_count <= 0;
                word_count <= 0;
                if input_vsync = '0' and last_vsync = '1' then
                    state <= "001";
                end if;
             when "001" => --waiting for post-vsync delay
                if wait_ctr >= vsync_to_start then
                    wait_ctr <= 0;
                    state <= "010";
                else
                    wait_ctr <= wait_ctr + 1;
                end if;
             when "010" => --waiting for hsync
                word_count <= 0;
                if input_hsync = '0' and last_hsync = '1' then
                    state <= "011";
                end if;
             when "011" => --horizontal delay
                if wait_ctr >= hsync_to_cmd then
                    state <= "100";
                    wait_ctr <= 0;
                else
                    wait_ctr <= wait_ctr + 1;
                end if;
             when "100" => --wait for phy
                if phy_ready = '1' then
                    state <= "101";
                end if;
             when "101" => --wait 1 cycle for header
                state <= "110";
             when "110" => --tx line
                if word_count >= (line_width_words - 1) then
                    word_count <= 0;
                    state <= "111";
                else
                    word_count <= word_count + 1;
                end if;
             when "111" => --line done
                if line_count >= (frame_height - 1) then
                    line_count <= 0;
                    state <= "000";
                else
                    line_count <= line_count + 1;
                    state <= "010";
                end if;
             when others =>
                state <= "000";
           end case;
           end if;
           last_hsync <= input_hsync;
           last_vsync <= input_vsync;
        end if;
    end process;

    phy_start <= '1' when (state = "100") and (enable = '1') else '0';
    fifo_rden <= '1' when ((state = "101") or ((state = "110") and (word_count < (line_width_words - 1)))) and (enable = '1') else '0';
    word_pack_reset <= not input_den;
    fifo_rst <= not input_vsync;
    fifo_wren <= word_pack_wren and enable;

    word_packer : entity work.dsi_tx_rgb_to_word port map(
        clock => pixel_clock,
        reset => word_pack_reset,
        input_rgb => input_rgb,
        input_den => input_den,
        output_word => word_pack_data,
        output_wren => word_pack_wren);

    word_fifo : video_data_fifo port map(
        rst => fifo_rst,
        wr_clk => pixel_clock,
        rd_clk => word_clock,
        din => word_pack_data,
        wr_en => fifo_wren,
        rd_en => fifo_rden,
        dout => fifo_dout,
        full => fifo_full,
        empty => fifo_empty);

     video_data <= fifo_dout when fifo_empty = '0' else underflow_data;

     current_cmd <= wr_mem_start when line_count = 0 else wr_mem_continue;
     first_word <= '1' when word_count = 0 else '0';

     make_payload : entity work.dsi_tx_prepend_dcs_cmd port map(
        clock => word_clock,
        first_word => first_word,
        cmd_in => current_cmd,
        data_in => video_data,
        payload_out => payload_data
     );

     packet_type <= dsi_data_type;
     packet_len <= std_logic_vector(to_unsigned((4*line_width_words) + 1, 16));
     packet_data <= payload_data;
end Behavioral;
