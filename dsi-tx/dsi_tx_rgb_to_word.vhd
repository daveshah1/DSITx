library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--MIPI DSI Tx 24-bit RGB to 32-bit word packer
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This takes 24-bit RGB pixel data in and shifts out 32-bit words for the 4 lane
--link; masked with a write enable signal as one word is not produced every clock
--cycle

entity dsi_tx_rgb_to_word is
    port(clock : in STD_LOGIC; --Pixel clock in
         reset : in STD_LOGIC; --Active high async reset
         input_rgb : in STD_LOGIC_VECTOR (23 downto 0); --Input RGB data
         input_den : in STD_LOGIC; --Input data enable
         output_word : out STD_LOGIC_VECTOR (31 downto 0); --Output 32-bit word
         output_wren : out STD_LOGIC); --Output write enable (to control FIFO)
end dsi_tx_rgb_to_word;

architecture Behavioral of dsi_tx_rgb_to_word is
signal bgr : STD_LOGIC_VECTOR (23 downto 0);
signal rgb_int : std_logic_vector(23 downto 0);
signal disp_int : std_logic;
signal word_int : std_logic_vector(31 downto 0);
signal word_q : std_logic_vector(31 downto 0);
signal remainder_int : std_logic_vector(15 downto 0);
signal remainder_q : std_logic_vector(15 downto 0);
signal word_size : integer range 0 to 4;
signal word_size_q : integer range 0 to 4;
signal rem_size : integer range 0 to 2;
signal rem_size_q : integer range 0 to 2;
signal wren_int : std_logic;
begin
    process(rgb_int, disp_int, word_q, remainder_q, word_size_q, rem_size_q)
    variable word_size_mod : integer range 0 to 3;
    variable shifted_word :  std_logic_vector(39 downto 0);
    variable shifted_word_size : integer range 0 to 5;
    variable rem_size_int : integer range 0 to 2;

    begin
        if disp_int = '0' then
            word_int <= word_q;
            remainder_int <= remainder_q;
            word_size <= word_size_q;
            rem_size <= rem_size_q;
        else
            if word_size_q >= 4 then
                word_size_mod := 0;
            else
                word_size_mod := word_size_q;
            end if;
            if rem_size_q = 2 then
                shifted_word := rgb_int & remainder_q;
                shifted_word_size := 5;
            elsif rem_size_q = 1 then
                shifted_word := x"00" & rgb_int & remainder_q(7 downto 0);
                shifted_word_size := 4;
            else
                shifted_word := x"0000" & rgb_int;
                shifted_word_size := 3;
            end if;

            --word_int <= shifted_word((32 - (word_size_mod * 8)) - 1 downto 0) & word_q((word_size_mod * 8) - 1 downto 0);
            if word_size_mod = 0 then
                word_int <= shifted_word(31 downto 0);
            elsif word_size_mod = 1 then
                word_int <= shifted_word(23 downto 0) & word_q(7 downto 0);
            elsif word_size_mod = 2 then
                word_int <= shifted_word(15 downto 0) & word_q(15 downto 0);
            else
                word_int <= shifted_word(7 downto 0) & word_q(23 downto 0);
            end if;

            if (word_size_mod + shifted_word_size) >= 4 then
                word_size <= 4;
                rem_size_int := (word_size_mod + shifted_word_size) - 4;
            else
                word_size <= (word_size_mod + shifted_word_size);
                rem_size_int := 0;
            end if;

            if rem_size_int = 0 then
                remainder_int <= x"0000";
            elsif rem_size_int = 1 then
                if word_size_mod = 0 then
                    remainder_int <= x"00" & shifted_word(39 downto 32);
                elsif word_size_mod = 1 then
                    remainder_int <= x"00" & shifted_word(31 downto 24);
                elsif word_size_mod = 2 then
                    remainder_int <= x"00" & shifted_word(23 downto 16);
                else
                    remainder_int <= x"00" & shifted_word(15 downto 8);
                end if;
            else
                if word_size_mod = 1 then
                    remainder_int <= shifted_word(39 downto 24);
                elsif word_size_mod = 2 then
                    remainder_int <= shifted_word(31 downto 16);
                else
                    remainder_int <= shifted_word(23 downto 8);
                end if;
            end if;

            rem_size <= rem_size_int;

        end if;
    end process;


    wren_int <= '1' when (word_size >= 4) and (disp_int = '1') else '0';
    bgr <= input_rgb(7 downto 0) & input_rgb(15 downto 8) & input_rgb(23 downto 16);
    process(clock, reset)
    begin
        if rising_edge(clock) then
          if reset = '1' then
            rgb_int <= x"000000";
            disp_int <= '0';
            word_q <= (others => '0');
            remainder_q <= (others => '0');
            word_size_q <= 0;
            rem_size_q <= 0;
            output_wren <= '0';
          else
            rgb_int <= bgr; --match DSI colour order
            disp_int <= input_den;
            word_q <= word_int;
            remainder_q <= remainder_int;
            rem_size_q <= rem_size;
            word_size_q <= word_size;
            output_wren <= wren_int;
        end if;
      end if;
    end process;
    output_word <= word_q;
end Behavioral;
