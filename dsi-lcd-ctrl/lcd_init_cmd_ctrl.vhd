library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--MIPI DSI LCD Init Command Sender
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This reads initialisation commands from ROM following a given format and controls
--a MIPI DSI packetiser and LPDT transmitter to setup the LCD

-- ROM Data Format:
--   first word (and only word for most commands)
--       bits 0-7: type; 0x00=wait ~10ms, 0x10=short dsi packet, 0x11=long dsi packet, 0x20=done
--       bits 15-8: DSI data type for 10/11, don't care otherwise
--       bits 23-16: DSI data 0 (10), packet length LSB (11)
--       bits 31-23: DSI data 1 (10), packet length MSB (11)
--   int[(n+3)/4] words follow with data for long packets

--A python script to generate the ROM contents as a COE file is included in the init-rom-gen folder
--This takes its input as a text file in the same format as the content of a DSI init command
--in a DTSI file; with the addition of a "wait" command for a ~10ms wait.

--As an example see the file "sharp_lcd_in.txt" in the init-rom-gen folder for the Sharp-style Z5 premium
--LCD

entity lcd_init_cmd_ctrl is
    Port ( word_clock : in STD_LOGIC; --LPDT word clock, gated with word_ce
           word_ce : in std_logic; --LPDT word clock enable
           reset : in STD_LOGIC; --Active high reset in
           tx_start : out STD_LOGIC; --Transmit packet start ouptut
           short_packet : out STD_LOGIC; --Whether or not current packet is short packet
           packet_type : out STD_LOGIC_VECTOR (7 downto 0); --Command packet data type
           packet_hdr : out STD_LOGIC_VECTOR (15 downto 0); --Command packet header data
           packet_payload : out STD_LOGIC_VECTOR (31 downto 0); --Streaming command packet payload
           done : out STD_LOGIC); --Initialisation complete out
end lcd_init_cmd_ctrl;

architecture Behavioral of lcd_init_cmd_ctrl is

  signal rom_addr : std_logic_vector(9 downto 0) := (others => '0');
  signal rom_q : std_logic_vector(31 downto 0);

  signal state : std_logic_vector(3 downto 0) := "0000";

  signal wait_cntr : unsigned(18 downto 0) := (others => '0');

  signal cur_cmd : std_logic_vector(31 downto 0);

  constant long_wait_amt : integer := 3125;
  constant short_wait_amt : integer := 31;
  signal words_sent : unsigned(15 downto 0) := (others => '0');

  signal packet_size_words : unsigned(15 downto 0);

  COMPONENT init_config_rom
    PORT (
      clka : IN STD_LOGIC;
      addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
      douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;

begin
    process(word_clock)
    begin
        if reset = '1' then
            state <= "0000";
            wait_cntr <= (others => '0');
            rom_addr <= (others => '0');
            cur_cmd <= (others => '0');
            words_sent <=  (others => '0');
        elsif rising_edge(word_clock) then
            if word_ce = '1' then
            case state is
                when "0000" => --init
                    rom_addr <= (others => '1'); --so it wraps around
                    state <= "0001";
                when "0001" => --incr address
                    wait_cntr <= (others => '0');
                    rom_addr <= std_logic_vector(unsigned(rom_addr) + 1);
                    state <= "0010";
                when "0010" => --read cmd from ROM
                    cur_cmd <= rom_q;
                    case rom_q(7 downto 4) is
                        when x"0" =>
                            state <= "0011";
                        when x"1" =>
                            state <= "0100";
                        when others =>
                            state <= "1111";
                    end case;
                when "0011" => --long wait (~10ms)
                    if wait_cntr >= long_wait_amt then
                        state <= "0001";
                        wait_cntr <= (others => '0');
                    else
                        wait_cntr <= wait_cntr + 1;
                    end if;
                when "0100" => --MIPI packet
                    words_sent <= (others => '0');
                    if cur_cmd(3 downto 0) = x"1" then
                        state <= "0101";
                    else
                        state <= "1110";
                    end if;
                when "0101" => --long packet start, wait for start
                    state <= "0110";
                when "0110" => --increment ROM address until end of packet
                    if words_sent < packet_size_words then
                        state <= "0110";
                        rom_addr <= std_logic_vector(unsigned(rom_addr) + 1);
                        words_sent <= words_sent + 1;
                    else
                        state <= "1110";
                    end if;
                when "1110" => --short wait after packet
                    if wait_cntr >= short_wait_amt then
                        state <= "0001";
                        wait_cntr <= (others => '0');
                    else
                        wait_cntr <= wait_cntr + 1;
                    end if;
                when "1111" => --done
                    state <= "1111";
                when others =>
                    state <= "0000";
            end case;
            end if;
        end if;
    end process;

    packet_size_words <= shift_right(unsigned(cur_cmd(31 downto 16)) + to_unsigned(3, 16), 2);

    tx_start <= '1' when state = "0100" else '0';
    short_packet <= not cur_cmd(0);
    packet_type <= cur_cmd(15 downto 8);
    packet_hdr <= cur_cmd(31 downto 16);
    packet_payload <= rom_q when (state = "0101") or (state = "0110") or (state = "1110") else x"00000000";
    done <= '1' when state = "1111" else '0';

    cfg_rom : init_config_rom
      port map (
        clka => word_clock,
        addra => rom_addr,
        douta => rom_q
      );
end Behavioral;
