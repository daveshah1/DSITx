library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Simple Video Splitter
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This 'splits' a parallel video stream by generating seperate left and right
--den signals

--It is designed for dual link MIPI LCDs; where each link sends one half of the
--image

entity video_splitter is
  generic (
    line_width : natural := 1080);
  port (
    input_den : in std_logic; --input den signal
    pixel_x : in natural range 0 to line_width - 1; --input X coordinate
    output_den_left : out std_logic; --left and right den out
    output_den_right : out std_logic);
end video_splitter;

architecture Behavioral of video_splitter is
  constant split_pos : natural := line_width / 2;
begin
  output_den_left <= input_den when pixel_x < split_pos else '0';
  output_den_right <= input_den when pixel_x >= split_pos else '0';
end Behavioral;
