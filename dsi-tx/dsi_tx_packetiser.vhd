library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--MIPI DSI Tx 4-lane packetiser for high and low speed transfers
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This implements packetisation for a MIPI DSI link; as is used both for high
--speed video transmission and low power data transfers used in setup

--It is designed for a full 4-lane link and works solely with words
--of 4 bytes; which has the major advantage of reducing the required clock
--frequency by a factor of 4 easing timing closure.

entity dsi_tx_packetiser is
  port ( word_clock : in STD_LOGIC; --Word clock in
           word_ce : in STD_LOGIC; --Word clock enable
           start : in STD_LOGIC; --Assert to begin sending a packet
           short_packet : in STD_LOGIC; --Whether or not a short packet (effectively a header only)
           data_type : in STD_LOGIC_VECTOR (7 downto 0); --MIPI DSI data type
           hdr_0 : in STD_LOGIC_VECTOR (7 downto 0); --Header data byte 0 (long packet length LSB)
           hdr_1 : in STD_LOGIC_VECTOR (7 downto 0); --Header data byte 1 (long packet length MSB)
           payload_in : in STD_LOGIC_VECTOR (31 downto 0); --Streaming payload in
           data_out : out STD_LOGIC_VECTOR (31 downto 0); --Streaming data out
           enable_out : out STD_LOGIC_VECTOR(3 downto 0); --Enable mask for data output; as the final word of the packet may have fewer than 4 bytes
           sot_out : out STD_LOGIC_VECTOR (3 downto 0); --Start of Transfer signals out to lane controllers
           eot_out : out STD_LOGIC_VECTOR (3 downto 0)); --End of Transfer signals out to lane controllers
end dsi_tx_packetiser;

architecture Behavioral of dsi_tx_packetiser is
signal state : unsigned(3 downto 0) := "0000";
signal packet_len : unsigned(15 downto 0);
signal data_count : unsigned(15 downto 0);
signal ecc : std_logic_vector(7 downto 0);
signal checksum : std_logic_vector(15 downto 0);
signal cs_bytes_sent : unsigned(1 downto 0) := "00";
signal header : std_logic_vector(31 downto 0);
signal eot_done : std_logic_vector(3 downto 0) := "0000";
signal int_enable : std_logic_vector(3 downto 0);
signal crc_reset : std_logic;
signal crc_valid_data : std_logic_vector(3 downto 0) := "0000";

begin
    process(word_clock)
    begin
    if rising_edge(word_clock) then
        if word_ce = '1' then
        case state is
            when "0000" => --waiting for start
                if start = '1' then
                    state <= "0001";
                else
                    state <= "0000";
                end if;
             when "0001" => --send SoT
                state <= "0010";
             when "0010" => --send header
                if short_packet = '1' then
                    state <= "0101";
                else
                    state <= "0011";
                end if;
             when "0011" => --send payload
                if (packet_len - data_count) > 4 then
                    state <= "0011"; --plenty more payload to send
                elsif (packet_len - data_count) > 2 then
                    state <= "0100"; --payload will finish, but one more cycle needed to complete checksum
                else
                    state <= "0101"; --payload and checksum will finish
                end if;
             when "0100" => --send checksum
                state <= "0101";
             when "0101" => --send EoT
                state <= "0000";
             when others =>
                state <= "0000";
        end case;
        end if;
    end if;
    end process;
    packet_len <= unsigned(hdr_1 & hdr_0);
    calc_hdr_ecc : entity work.dsi_tx_header_ecc
      port map(
        data => header(23 downto 0),
        ecc => ecc);

    calc_payload_crc : entity work.dsi_tx_payload_crc
      port map(
        clock => word_clock,
        ce => word_ce,
        reset => crc_reset,
        word_data_in => payload_in,
        byte_enable => crc_valid_data,
        crc => checksum);

    header(23 downto 0) <= hdr_1 & hdr_0 & data_type;
    header(31 downto 24) <= ecc;

    enable_out <= int_enable;

    process(state, header, payload_in, checksum, packet_len, data_count, cs_bytes_sent, eot_done)
    begin
        case state is
            when "0001" =>
                crc_reset <= '1';
                sot_out <= "1111";
                data_out <=  x"00000000";
                int_enable <= "0000";
                eot_out <= "0000";
                crc_valid_data <= "0000";
            when "0010" =>
                crc_reset <= '0';
                data_out <= header;
                int_enable <= "1111";
                sot_out <= "0000";
                eot_out <= "0000";
                crc_valid_data <= "0000";
            when "0011" =>
                 crc_reset <= '0';
                 sot_out <= "0000";
                 if (packet_len - data_count) > 4 then --all data, no checksum
                    data_out <= payload_in;
                    int_enable <= "1111";
                    crc_valid_data <= "1111";
                    eot_out <= "0000";
                 elsif (packet_len - data_count) = 3 then --3 data, 1 checksum
                    data_out <= checksum(7 downto 0) & payload_in(23 downto 0);
                    int_enable <= "1111";
                    crc_valid_data <= "0111";
                    eot_out <= "0000";
                 elsif (packet_len - data_count) = 2 then --2 data, 2 checksum
                   data_out <= checksum(15 downto 0) & payload_in(15 downto 0);
                   int_enable <= "1111";
                   crc_valid_data <= "0011";
                   eot_out <= "0000";
                 else --1 data, 2 checksum, 1 done
                    data_out <= x"00" & checksum(15 downto 0) & payload_in(7 downto 0);
                    int_enable <= "0111";
                    crc_valid_data <= "0001";
                    eot_out <= "1000";
                 end if;
            when "0100" =>
                 crc_reset <= '0';
                 sot_out <= "0000";
                 if cs_bytes_sent = 1 then
                    data_out <= x"000000" & checksum(15 downto 8);
                    int_enable <= "0001";
                    eot_out <= "1110";
                 else
                    data_out <= x"0000" & checksum(15 downto 0);
                    int_enable <= "0011";
                    eot_out <= "1100";
                 end if;
                 crc_valid_data <= "0000";
            when "0101" =>
                crc_reset <= '1';
                sot_out <= "0000";
                data_out <= x"00000000";
                int_enable <= "0000";
                eot_out <= not eot_done;
                crc_valid_data <= "0000";
            when others =>
                crc_reset <= '1';
                data_out <= x"00000000";
                int_enable <= "0000";
                sot_out <= "0000";
                eot_out <= "0000";
                crc_valid_data <= "0000";
        end case;
    end process;

    process(word_clock)
    begin
        if rising_edge(word_clock) then
            if word_ce = '1' then
            case state is
                when "0001" => --reset various bits of logic
                    data_count <= x"0000";
                    eot_done <= "0000";
                    cs_bytes_sent <= "00";
                when "0011" =>
                    if (packet_len - data_count) >= 4 then
                        data_count <= data_count + 4;
                    elsif (packet_len - data_count) = 3 then
                        data_count <= packet_len;
                        cs_bytes_sent <= "01";
                    elsif (packet_len - data_count) = 2 then
                        data_count <= packet_len;
                        cs_bytes_sent <= "10";
                    elsif (packet_len - data_count) = 1 then
                        data_count <= packet_len;
                        cs_bytes_sent <= "10";
                        eot_done <= "1000";
                    end if;
                when "0100" =>
                    if cs_bytes_sent = 1 then
                       eot_done <= "1110";
                    else
                       eot_done <= "1100";
                    end if;
                when others =>

             end case;
             end if;
        end if;
    end process;
end Behavioral;
