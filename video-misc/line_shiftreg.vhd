library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Simple Line Shift Register for 2D Moving Windows
--Copyright (C) 2016 David Shah
--Licensed under the MIT License

--This is designed to be a cross-platform VHDL alternative to Altera's very nice
--'altshift_taps' component

entity line_shiftreg is
  generic(
    line_width : natural := 3840; --width of one line
    data_width : natural := 20; --width of data input port
    n_taps : natural := 2
  );
  port(
    clock : in std_logic;
    enable : in std_logic;
    data_in : in std_logic_vector(data_width - 1 downto 0);
    taps : out std_logic_vector((n_taps*data_width) - 1 downto 0)
  );
end line_shiftreg;

architecture Behavioral of line_shiftreg is
  type shiftram_t is array (0 to line_width - 1) of std_logic_vector((n_taps*data_width) - 1 downto 0);
  signal ram : shiftram_t;
  signal ram_d, ram_q, ram_q_pre : std_logic_vector((n_taps*data_width) - 1 downto 0);
  signal read_ptr, write_ptr : natural range 0 to line_width - 1 := 0;
  signal en_lat : std_logic;
begin

  ram_d(data_width - 1 downto 0) <= data_in;

  gen_din : for i in 1 to n_taps - 1 generate
    ram_d(((i + 1)*data_width) - 1 downto (i * data_width)) <= ram_q(((i)*data_width) - 1 downto ((i - 1) * data_width));
  end generate;

  process(clock)
  begin
    if rising_edge(clock) then
      en_lat <= enable;
      if enable = '1' then
        ram(write_ptr) <= ram_d;
        ram_q_pre <= ram(read_ptr);
      end if;
      if en_lat = '1' then
        ram_q <= ram_q_pre;
      end if;
    end if;
  end process;

  process(clock)
  begin
    if rising_edge(clock) then
      if enable = '1' then
        if write_ptr = line_width - 1 then
          write_ptr <= 0;
        else
          write_ptr <= write_ptr + 1;
        end if;
      end if;
    end if;
  end process;

  read_ptr <= 0 when write_ptr = line_width - 2 else
              1 when write_ptr = line_width - 1 else
                write_ptr + 2;

  taps <= ram_q;
end Behavioral;
