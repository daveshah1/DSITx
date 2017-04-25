library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Enhanced Test Pattern Generator
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This is primarily designed for smartphone-style 1080x1920 displays; other
--resolutions will result in either cropping or repetition

--It is capable of generating 4 different patterns; selectable by switches
-- 00: colour bars
-- 01: alternating black and white dots
-- 10: colour gradients
-- 11: frame-by-frame alternating black and white (for testing response time)

entity test_pattern_enhanced is
    generic(
      video_hlength : natural := 1152; --total visible and blanking pixels per line
      video_vlength : natural := 4326; --total visible and blanking lines per frame

      video_hsync_pol : boolean := true; --hsync polarity: true for positive sync, false for negative sync
      video_hsync_len : natural := 16; --horizontal sync length in pixels
      video_hbp_len : natural := 16; --horizontal back porch length (excluding sync)
      video_h_visible : natural := 1080; --number of visible pixels per line

      video_vsync_pol : boolean := true; --vsync polarity: true for positive sync, false for negative sync
      video_vsync_len : natural := 8; --vertical sync length in lines
      video_vbp_len : natural := 8; --vertical back porch length (excluding sync)
      video_v_visible : natural := 1920); --number of visible lines per frame

    port ( pixel_clock : in STD_LOGIC;
           reset : in std_logic; --active high async reset
           pattern_sel : in STD_LOGIC_VECTOR(1 downto 0);

           video_vsync : out std_logic;
           video_hsync : out std_logic;
           video_den : out std_logic;
           video_line_start : out std_logic;
           pixel_x : out natural range 0 to video_h_visible - 1;
           pixel_y : out natural range 0 to video_v_visible - 1;
           video_pixel : out std_logic_vector(23 downto 0));
end test_pattern_enhanced;

architecture Behavioral of test_pattern_enhanced is

signal tmg_hsync, tmg_vsync, tmg_den, tmg_line_start : std_logic;
signal int_hsync, int_vsync, int_den, int_line_start : std_logic;

signal tmg_pixel_x, int_pixel_x : natural range 0 to video_h_visible - 1;
signal tmg_pixel_y, int_pixel_y : natural range 0 to video_v_visible - 1;

signal odd_frame_int : std_logic := '0';
signal pattern_sel_int : std_logic_vector(1 downto 0);
signal rgb_int : std_logic_vector(23 downto 0);
begin
    process(pixel_clock)
    begin
        if rising_edge(pixel_clock) then
          int_vsync <= tmg_vsync;
          int_hsync <= tmg_hsync;
          int_den <= tmg_den;
          int_line_start <= tmg_line_start;
          pattern_sel_int <= pattern_sel;

          int_pixel_x <= tmg_pixel_x;
          int_pixel_y <= tmg_pixel_y;

          if tmg_vsync = '1' and int_vsync = '0' then
            odd_frame_int <= not odd_frame_int;
          end if;

          video_vsync <= int_vsync;
          video_hsync <= int_hsync;
          video_den <= int_den;
          video_line_start <= int_line_start;

          pixel_x <= int_pixel_x;
          pixel_y <= int_pixel_y;

          video_pixel <= rgb_int;
        end if;
    end process;

    tmg : entity work.video_timing_ctrl
      generic map(
        video_hlength => video_hlength,
        video_vlength => video_vlength,

        video_hsync_pol => video_hsync_pol,
        video_hsync_len => video_hsync_len,
        video_hbp_len => video_hbp_len,
        video_h_visible => video_h_visible,

        video_vsync_pol => video_vsync_pol,
        video_vsync_len => video_vsync_len,
        video_vbp_len => video_vbp_len,
        video_v_visible => video_v_visible)
      port map(
        pixel_clock => pixel_clock,
        reset => reset,
        ext_sync => '0',
        timing_h_pos => open,
        timing_v_pos => open,
        pixel_x => tmg_pixel_x,
        pixel_y => tmg_pixel_y,
        video_hsync => tmg_hsync,
        video_vsync => tmg_vsync,
        video_den => tmg_den,
        video_line_start => tmg_line_start);

    process(int_pixel_x, int_pixel_y, odd_frame_int, pattern_sel_int)
    variable x_int, y_int : unsigned(10 downto 0);
    variable rgb_temp : std_logic_vector(23 downto 0);
    begin
        x_int := to_unsigned(int_pixel_x, 11);
        y_int := to_unsigned(int_pixel_y, 11);

        if pattern_sel_int = "00" then --colour bars
            case x_int(9 downto 6) is
                when "0000" =>
                    rgb_temp := x"FF0000";
                when "0001" =>
                    rgb_temp := x"00FF00";
                when "0010" =>
                    rgb_temp := x"0000FF";
                when "0011" =>
                    rgb_temp := x"FFFF00";
                when "0100" =>
                    rgb_temp := x"FF00FF";
                when "0101" =>
                    rgb_temp := x"00FFFF";
                when "0110" =>
                    rgb_temp := x"000000";
                when "0111" =>
                    rgb_temp := x"111111";
                when "1000" =>
                    rgb_temp := x"333333";
                when "1001" =>
                    rgb_temp := X"555555";
                when "1010" =>
                    rgb_temp := X"777777";
                when "1011" =>
                    rgb_temp := X"999999";
                when "1100" =>
                    rgb_temp := X"BBBBBB";
                when "1101" =>
                    rgb_temp := X"DDDDDD";
                when "1110" =>
                    rgb_temp := X"FFFFFF";
                when "1111" =>
                    rgb_temp := X"FF0000";
                when others =>
                    rgb_temp := X"000000";
            end case;
            if y_int(7) = '0' then
                rgb_int <= rgb_temp;
            else
                rgb_int <= not rgb_temp;
            end if;
        elsif pattern_sel_int = "01" then --dots
            if x_int(0) = y_int(0) then
                rgb_int <= x"FFFFFF";
            else
                rgb_int <= x"000000";
            end if;
        elsif pattern_sel_int = "10" then --gradient
            if y_int(10 downto 9) = "00" then
                rgb_int <= std_logic_vector(x_int(9 downto 2)) & std_logic_vector(y_int(8 downto 1)) & x"00";
            elsif y_int(10 downto 9) = "01" then
                rgb_int <= std_logic_vector(x_int(9 downto 2)) & x"00" & std_logic_vector(y_int(8 downto 1));
            elsif y_int(10 downto 9) = "10" then
                rgb_int <= x"00" & std_logic_vector(x_int(9 downto 2)) & std_logic_vector(y_int(8 downto 1));
            else
                rgb_int <= std_logic_vector(x_int(9 downto 2)) & std_logic_vector(x_int(9 downto 2)) & std_logic_vector(x_int(9 downto 2));
            end if;
        else --response time test
            if odd_frame_int = '1' then
                rgb_int <= x"FFFFFF";
            else
                rgb_int <= x"000000";
            end if;
        end if;
    end process;
end Behavioral;
