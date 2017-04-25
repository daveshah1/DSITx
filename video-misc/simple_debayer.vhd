library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Minimal Debayering Block for CSI-2 Rx
--Copyright (C) 2016 David Shah
--Licensed under the MIT License

--This uses the simplest possible method to debayer two pixels per clock,
--purely as a proof of concept to demo the CSI-2 Rx core. It is designed to go between
--the CSI-2 Rx and the white balance/gain controller, also included in the example

entity simple_debayer is
  generic(
    line_width : in natural := 3840
  );
  port(
    clock : in std_logic;

    input_hsync : in std_logic;
    input_vsync : in std_logic;
    input_den : in std_logic;
    input_line_start : in std_logic;
    input_odd_line : in std_logic;
    input_data : in std_logic_vector(19 downto 0);

    output_hsync : out std_logic;
    output_vsync : out std_logic;
    output_den : out std_logic;
    output_line_start : out std_logic;
    output_data_even : out std_logic_vector(29 downto 0); --10bit R:G:B
    output_data_odd : out std_logic_vector(29 downto 0) --10bit R:G:B
  );
end simple_debayer;

architecture Behavioral of simple_debayer is

  signal pre_hsync, pre_vsync, pre_den, pre_line_start : std_logic;
  signal pre_data_even, pre_data_odd : std_logic_vector(29 downto 0);

  function average_2(val_1, val_2 : std_logic_vector)
    return std_logic_vector is
      variable sum : unsigned(10 downto 0);
      variable result : std_logic_vector(9 downto 0);
    begin
      sum := resize(unsigned(val_1), 11) + resize(unsigned(val_2), 11);
      result := std_logic_vector(sum(10 downto 1));
      return result;
  end function;

  function average_4(val_1, val_2, val_3, val_4 : std_logic_vector)
    return std_logic_vector is
      variable sum : unsigned(11 downto 0);
      variable result : std_logic_vector(9 downto 0);
    begin
      sum := resize(unsigned(val_1), 12) + resize(unsigned(val_2), 12) + resize(unsigned(val_3), 12) + resize(unsigned(val_4), 12);
      result := std_logic_vector(sum(11 downto 2));
      return result;
  end function;

  signal taps : std_logic_vector(39 downto 0);

  type window_t is array(0 to 3, 0 to 2) of std_logic_vector(9 downto 0);

  signal window : window_t;

begin
  process(clock)
    variable pixel_0_R, pixel_0_G, pixel_0_B : std_logic_vector(9 downto 0);
    variable pixel_1_R, pixel_1_G, pixel_1_B : std_logic_vector(9 downto 0);

  begin
    if rising_edge(clock) then
      pre_hsync <= input_hsync;
      pre_vsync <= input_vsync;
      pre_den <= input_den;
      pre_line_start <= input_line_start;

      --Solve for the middle of the 4x3 window
      if input_odd_line = '1' then --BGBG, GRGR, BGBG
        pixel_0_R := window(1, 1);
        pixel_0_G := average_4(window(0, 1), window(1, 0), window(2, 1), window(1, 2));
        pixel_0_B := average_4(window(0, 0), window(2, 0), window(0, 2), window(2, 2));

        pixel_1_R := average_2(window(1, 1), window(3, 1));
        pixel_1_G := window(2, 1);
        pixel_1_B := average_2(window(2, 0), window(2, 2));
      else
        pixel_0_R := average_2(window(1, 0), window(1, 2));
        pixel_0_G := window(1, 1);
        pixel_0_B := average_2(window(0, 1), window(2, 1));

        pixel_1_R := average_4(window(1, 0), window(3, 0), window(1, 2), window(3, 2));
        pixel_1_G := average_4(window(2, 0), window(3, 1), window(2, 2), window(1, 1));
        pixel_1_B := window(2, 1);
      end if;

      pre_data_even <= pixel_0_R & pixel_0_G & pixel_0_B;
      pre_data_odd <= pixel_1_R & pixel_1_G & pixel_1_B;

      output_hsync <= pre_hsync;
      output_vsync <= pre_vsync;
      output_den <= pre_den;
      output_line_start <= pre_line_start;
      output_data_even <= pre_data_even;
      output_data_odd <= pre_data_odd;

      if input_den = '1' then
        for y in 0 to 2 loop
          window(0, y) <= window(2, y);
          window(1, y) <= window(3, y);
        end loop;
      end if;
    end if;
  end process;

  shiftreg : entity work.line_shiftreg
    generic map(
      line_width => line_width,
      data_width => 20,
      n_taps => 2)
    port map(
      clock => clock,
      enable => input_den,
      data_in => input_data,
      taps => taps);

  window(2, 2) <= input_data(9 downto 0);
  window(3, 2) <= input_data(19 downto 10);
  window(2, 1) <= taps(9 downto 0);
  window(3, 1) <= taps(19 downto 10);
  window(2, 0) <= taps(29 downto 20);
  window(3, 0) <= taps(39 downto 30);
end architecture;
