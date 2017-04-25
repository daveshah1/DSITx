library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--MIPI DSI Tx Payload CRC calculator (using 32-bit blocks)
--Copyright (C) 2016-17 David Shah
--Licensed under the MIT License

--This is a very crude implementation that allows inputs of up to 32 bits at a
--time. Its development was aided by the online calculator at OutputLogic.com

entity dsi_tx_payload_crc is
    port ( clock : in std_logic; --Word clock input
           ce : in std_logic; --Clock enable
           reset : in std_logic; --Active high sync reset
           word_data_in : in STD_LOGIC_VECTOR (31 downto 0); --word data in; masked using byte_enable
           byte_enable : in STD_LOGIC_VECTOR (3 downto 0); --byte enables allowing less than 4 bytes to be shifted in a cycle
           crc : out STD_LOGIC_VECTOR (15 downto 0)); --current CRC out
end dsi_tx_payload_crc;


architecture Behavioral of dsi_tx_payload_crc is
    signal crc_res : std_logic_vector(15 downto 0);
    signal crc_8 : std_logic_vector(15 downto 0);
    signal crc_16 : std_logic_vector(15 downto 0);
    signal crc_24 : std_logic_vector(15 downto 0);
    signal crc_32 : std_logic_vector(15 downto 0);
    signal lfsr_q : std_logic_vector(15 downto 0);
    signal data_in : std_logic_vector(31 downto 0);

    function reverse (a: in std_logic_vector)
    return std_logic_vector is
      variable result: std_logic_vector(a'RANGE);
    begin
      for i in a'RANGE loop
        result(a'LEFT - i) := a(i);
      end loop;
      return result;
    end;
begin
    --Bit order must be reversed in multiple places
    --Should rewrite this in a better way (E.g. for loops) at some point
    crc_32(0) <= lfsr_q(3) xor lfsr_q(4) xor lfsr_q(6) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(12) xor data_in(0) xor data_in(4) xor data_in(8) xor data_in(11) xor data_in(12) xor data_in(19) xor data_in(20) xor data_in(22) xor data_in(26) xor data_in(27) xor data_in(28);
    crc_32(1) <= lfsr_q(4) xor lfsr_q(5) xor lfsr_q(7) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(13) xor data_in(1) xor data_in(5) xor data_in(9) xor data_in(12) xor data_in(13) xor data_in(20) xor data_in(21) xor data_in(23) xor data_in(27) xor data_in(28) xor data_in(29);
    crc_32(2) <= lfsr_q(5) xor lfsr_q(6) xor lfsr_q(8) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(14) xor data_in(2) xor data_in(6) xor data_in(10) xor data_in(13) xor data_in(14) xor data_in(21) xor data_in(22) xor data_in(24) xor data_in(28) xor data_in(29) xor data_in(30);
    crc_32(3) <= lfsr_q(6) xor lfsr_q(7) xor lfsr_q(9) xor lfsr_q(13) xor lfsr_q(14) xor lfsr_q(15) xor data_in(3) xor data_in(7) xor data_in(11) xor data_in(14) xor data_in(15) xor data_in(22) xor data_in(23) xor data_in(25) xor data_in(29) xor data_in(30) xor data_in(31);
    crc_32(4) <= lfsr_q(0) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(10) xor lfsr_q(14) xor lfsr_q(15) xor data_in(4) xor data_in(8) xor data_in(12) xor data_in(15) xor data_in(16) xor data_in(23) xor data_in(24) xor data_in(26) xor data_in(30) xor data_in(31);
    crc_32(5) <= lfsr_q(0) xor lfsr_q(1) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(6) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(12) xor lfsr_q(15) xor data_in(0) xor data_in(4) xor data_in(5) xor data_in(8) xor data_in(9) xor data_in(11) xor data_in(12) xor data_in(13) xor data_in(16) xor data_in(17) xor data_in(19) xor data_in(20) xor data_in(22) xor data_in(24) xor data_in(25) xor data_in(26) xor data_in(28) xor data_in(31);
    crc_32(6) <= lfsr_q(1) xor lfsr_q(2) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(7) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(13) xor data_in(1) xor data_in(5) xor data_in(6) xor data_in(9) xor data_in(10) xor data_in(12) xor data_in(13) xor data_in(14) xor data_in(17) xor data_in(18) xor data_in(20) xor data_in(21) xor data_in(23) xor data_in(25) xor data_in(26) xor data_in(27) xor data_in(29);
    crc_32(7) <= lfsr_q(2) xor lfsr_q(3) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(8) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(14) xor data_in(2) xor data_in(6) xor data_in(7) xor data_in(10) xor data_in(11) xor data_in(13) xor data_in(14) xor data_in(15) xor data_in(18) xor data_in(19) xor data_in(21) xor data_in(22) xor data_in(24) xor data_in(26) xor data_in(27) xor data_in(28) xor data_in(30);
    crc_32(8) <= lfsr_q(0) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(9) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(15) xor data_in(3) xor data_in(7) xor data_in(8) xor data_in(11) xor data_in(12) xor data_in(14) xor data_in(15) xor data_in(16) xor data_in(19) xor data_in(20) xor data_in(22) xor data_in(23) xor data_in(25) xor data_in(27) xor data_in(28) xor data_in(29) xor data_in(31);
    crc_32(9) <= lfsr_q(0) xor lfsr_q(1) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(10) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(14) xor data_in(4) xor data_in(8) xor data_in(9) xor data_in(12) xor data_in(13) xor data_in(15) xor data_in(16) xor data_in(17) xor data_in(20) xor data_in(21) xor data_in(23) xor data_in(24) xor data_in(26) xor data_in(28) xor data_in(29) xor data_in(30);
    crc_32(10) <= lfsr_q(0) xor lfsr_q(1) xor lfsr_q(2) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(11) xor lfsr_q(13) xor lfsr_q(14) xor lfsr_q(15) xor data_in(5) xor data_in(9) xor data_in(10) xor data_in(13) xor data_in(14) xor data_in(16) xor data_in(17) xor data_in(18) xor data_in(21) xor data_in(22) xor data_in(24) xor data_in(25) xor data_in(27) xor data_in(29) xor data_in(30) xor data_in(31);
    crc_32(11) <= lfsr_q(1) xor lfsr_q(2) xor lfsr_q(3) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(12) xor lfsr_q(14) xor lfsr_q(15) xor data_in(6) xor data_in(10) xor data_in(11) xor data_in(14) xor data_in(15) xor data_in(17) xor data_in(18) xor data_in(19) xor data_in(22) xor data_in(23) xor data_in(25) xor data_in(26) xor data_in(28) xor data_in(30) xor data_in(31);
    crc_32(12) <= lfsr_q(0) xor lfsr_q(2) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(15) xor data_in(0) xor data_in(4) xor data_in(7) xor data_in(8) xor data_in(15) xor data_in(16) xor data_in(18) xor data_in(22) xor data_in(23) xor data_in(24) xor data_in(28) xor data_in(29) xor data_in(31);
    crc_32(13) <= lfsr_q(0) xor lfsr_q(1) xor lfsr_q(3) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(13) xor lfsr_q(14) xor data_in(1) xor data_in(5) xor data_in(8) xor data_in(9) xor data_in(16) xor data_in(17) xor data_in(19) xor data_in(23) xor data_in(24) xor data_in(25) xor data_in(29) xor data_in(30);
    crc_32(14) <= lfsr_q(1) xor lfsr_q(2) xor lfsr_q(4) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(14) xor lfsr_q(15) xor data_in(2) xor data_in(6) xor data_in(9) xor data_in(10) xor data_in(17) xor data_in(18) xor data_in(20) xor data_in(24) xor data_in(25) xor data_in(26) xor data_in(30) xor data_in(31);
    crc_32(15) <= lfsr_q(2) xor lfsr_q(3) xor lfsr_q(5) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(15) xor data_in(3) xor data_in(7) xor data_in(10) xor data_in(11) xor data_in(18) xor data_in(19) xor data_in(21) xor data_in(25) xor data_in(26) xor data_in(27) xor data_in(31);

    crc_24(0) <= lfsr_q(0) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(14) xor data_in(0) xor data_in(4) xor data_in(8) xor data_in(11) xor data_in(12) xor data_in(19) xor data_in(20) xor data_in(22);
    crc_24(1) <= lfsr_q(1) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(15) xor data_in(1) xor data_in(5) xor data_in(9) xor data_in(12) xor data_in(13) xor data_in(20) xor data_in(21) xor data_in(23);
    crc_24(2) <= lfsr_q(2) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(13) xor lfsr_q(14) xor data_in(2) xor data_in(6) xor data_in(10) xor data_in(13) xor data_in(14) xor data_in(21) xor data_in(22);
    crc_24(3) <= lfsr_q(3) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(14) xor lfsr_q(15) xor data_in(3) xor data_in(7) xor data_in(11) xor data_in(14) xor data_in(15) xor data_in(22) xor data_in(23);
    crc_24(4) <= lfsr_q(0) xor lfsr_q(4) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(15) xor data_in(4) xor data_in(8) xor data_in(12) xor data_in(15) xor data_in(16) xor data_in(23);
    crc_24(5) <= lfsr_q(0) xor lfsr_q(1) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(14) xor data_in(0) xor data_in(4) xor data_in(5) xor data_in(8) xor data_in(9) xor data_in(11) xor data_in(12) xor data_in(13) xor data_in(16) xor data_in(17) xor data_in(19) xor data_in(20) xor data_in(22);
    crc_24(6) <= lfsr_q(1) xor lfsr_q(2) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(15) xor data_in(1) xor data_in(5) xor data_in(6) xor data_in(9) xor data_in(10) xor data_in(12) xor data_in(13) xor data_in(14) xor data_in(17) xor data_in(18) xor data_in(20) xor data_in(21) xor data_in(23);
    crc_24(7) <= lfsr_q(2) xor lfsr_q(3) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(13) xor lfsr_q(14) xor data_in(2) xor data_in(6) xor data_in(7) xor data_in(10) xor data_in(11) xor data_in(13) xor data_in(14) xor data_in(15) xor data_in(18) xor data_in(19) xor data_in(21) xor data_in(22);
    crc_24(8) <= lfsr_q(0) xor lfsr_q(3) xor lfsr_q(4) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(14) xor lfsr_q(15) xor data_in(3) xor data_in(7) xor data_in(8) xor data_in(11) xor data_in(12) xor data_in(14) xor data_in(15) xor data_in(16) xor data_in(19) xor data_in(20) xor data_in(22) xor data_in(23);
    crc_24(9) <= lfsr_q(0) xor lfsr_q(1) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(15) xor data_in(4) xor data_in(8) xor data_in(9) xor data_in(12) xor data_in(13) xor data_in(15) xor data_in(16) xor data_in(17) xor data_in(20) xor data_in(21) xor data_in(23);
    crc_24(10) <= lfsr_q(1) xor lfsr_q(2) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(13) xor lfsr_q(14) xor data_in(5) xor data_in(9) xor data_in(10) xor data_in(13) xor data_in(14) xor data_in(16) xor data_in(17) xor data_in(18) xor data_in(21) xor data_in(22);
    crc_24(11) <= lfsr_q(2) xor lfsr_q(3) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(14) xor lfsr_q(15) xor data_in(6) xor data_in(10) xor data_in(11) xor data_in(14) xor data_in(15) xor data_in(17) xor data_in(18) xor data_in(19) xor data_in(22) xor data_in(23);
    crc_24(12) <= lfsr_q(0) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(10) xor lfsr_q(14) xor lfsr_q(15) xor data_in(0) xor data_in(4) xor data_in(7) xor data_in(8) xor data_in(15) xor data_in(16) xor data_in(18) xor data_in(22) xor data_in(23);
    crc_24(13) <= lfsr_q(0) xor lfsr_q(1) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(11) xor lfsr_q(15) xor data_in(1) xor data_in(5) xor data_in(8) xor data_in(9) xor data_in(16) xor data_in(17) xor data_in(19) xor data_in(23);
    crc_24(14) <= lfsr_q(1) xor lfsr_q(2) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(12) xor data_in(2) xor data_in(6) xor data_in(9) xor data_in(10) xor data_in(17) xor data_in(18) xor data_in(20);
    crc_24(15) <= lfsr_q(2) xor lfsr_q(3) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(13) xor data_in(3) xor data_in(7) xor data_in(10) xor data_in(11) xor data_in(18) xor data_in(19) xor data_in(21);


    crc_16(0) <= lfsr_q(0) xor lfsr_q(4) xor lfsr_q(8) xor lfsr_q(11) xor lfsr_q(12) xor data_in(0) xor data_in(4) xor data_in(8) xor data_in(11) xor data_in(12);
    crc_16(1) <= lfsr_q(1) xor lfsr_q(5) xor lfsr_q(9) xor lfsr_q(12) xor lfsr_q(13) xor data_in(1) xor data_in(5) xor data_in(9) xor data_in(12) xor data_in(13);
    crc_16(2) <= lfsr_q(2) xor lfsr_q(6) xor lfsr_q(10) xor lfsr_q(13) xor lfsr_q(14) xor data_in(2) xor data_in(6) xor data_in(10) xor data_in(13) xor data_in(14);
    crc_16(3) <= lfsr_q(3) xor lfsr_q(7) xor lfsr_q(11) xor lfsr_q(14) xor lfsr_q(15) xor data_in(3) xor data_in(7) xor data_in(11) xor data_in(14) xor data_in(15);
    crc_16(4) <= lfsr_q(4) xor lfsr_q(8) xor lfsr_q(12) xor lfsr_q(15) xor data_in(4) xor data_in(8) xor data_in(12) xor data_in(15);
    crc_16(5) <= lfsr_q(0) xor lfsr_q(4) xor lfsr_q(5) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(13) xor data_in(0) xor data_in(4) xor data_in(5) xor data_in(8) xor data_in(9) xor data_in(11) xor data_in(12) xor data_in(13);
    crc_16(6) <= lfsr_q(1) xor lfsr_q(5) xor lfsr_q(6) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(14) xor data_in(1) xor data_in(5) xor data_in(6) xor data_in(9) xor data_in(10) xor data_in(12) xor data_in(13) xor data_in(14);
    crc_16(7) <= lfsr_q(2) xor lfsr_q(6) xor lfsr_q(7) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(13) xor lfsr_q(14) xor lfsr_q(15) xor data_in(2) xor data_in(6) xor data_in(7) xor data_in(10) xor data_in(11) xor data_in(13) xor data_in(14) xor data_in(15);
    crc_16(8) <= lfsr_q(3) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(11) xor lfsr_q(12) xor lfsr_q(14) xor lfsr_q(15) xor data_in(3) xor data_in(7) xor data_in(8) xor data_in(11) xor data_in(12) xor data_in(14) xor data_in(15);
    crc_16(9) <= lfsr_q(4) xor lfsr_q(8) xor lfsr_q(9) xor lfsr_q(12) xor lfsr_q(13) xor lfsr_q(15) xor data_in(4) xor data_in(8) xor data_in(9) xor data_in(12) xor data_in(13) xor data_in(15);
    crc_16(10) <= lfsr_q(5) xor lfsr_q(9) xor lfsr_q(10) xor lfsr_q(13) xor lfsr_q(14) xor data_in(5) xor data_in(9) xor data_in(10) xor data_in(13) xor data_in(14);
    crc_16(11) <= lfsr_q(6) xor lfsr_q(10) xor lfsr_q(11) xor lfsr_q(14) xor lfsr_q(15) xor data_in(6) xor data_in(10) xor data_in(11) xor data_in(14) xor data_in(15);
    crc_16(12) <= lfsr_q(0) xor lfsr_q(4) xor lfsr_q(7) xor lfsr_q(8) xor lfsr_q(15) xor data_in(0) xor data_in(4) xor data_in(7) xor data_in(8) xor data_in(15);
    crc_16(13) <= lfsr_q(1) xor lfsr_q(5) xor lfsr_q(8) xor lfsr_q(9) xor data_in(1) xor data_in(5) xor data_in(8) xor data_in(9);
    crc_16(14) <= lfsr_q(2) xor lfsr_q(6) xor lfsr_q(9) xor lfsr_q(10) xor data_in(2) xor data_in(6) xor data_in(9) xor data_in(10);
    crc_16(15) <= lfsr_q(3) xor lfsr_q(7) xor lfsr_q(10) xor lfsr_q(11) xor data_in(3) xor data_in(7) xor data_in(10) xor data_in(11);

    crc_8(0) <= lfsr_q(8) xor lfsr_q(12) xor data_in(0) xor data_in(4);
    crc_8(1) <= lfsr_q(9) xor lfsr_q(13) xor data_in(1) xor data_in(5);
    crc_8(2) <= lfsr_q(10) xor lfsr_q(14) xor data_in(2) xor data_in(6);
    crc_8(3) <= lfsr_q(11) xor lfsr_q(15) xor data_in(3) xor data_in(7);
    crc_8(4) <= lfsr_q(12) xor data_in(4);
    crc_8(5) <= lfsr_q(8) xor lfsr_q(12) xor lfsr_q(13) xor data_in(0) xor data_in(4) xor data_in(5);
    crc_8(6) <= lfsr_q(9) xor lfsr_q(13) xor lfsr_q(14) xor data_in(1) xor data_in(5) xor data_in(6);
    crc_8(7) <= lfsr_q(10) xor lfsr_q(14) xor lfsr_q(15) xor data_in(2) xor data_in(6) xor data_in(7);
    crc_8(8) <= lfsr_q(0) xor lfsr_q(11) xor lfsr_q(15) xor data_in(3) xor data_in(7);
    crc_8(9) <= lfsr_q(1) xor lfsr_q(12) xor data_in(4);
    crc_8(10) <= lfsr_q(2) xor lfsr_q(13) xor data_in(5);
    crc_8(11) <= lfsr_q(3) xor lfsr_q(14) xor data_in(6);
    crc_8(12) <= lfsr_q(4) xor lfsr_q(8) xor lfsr_q(12) xor lfsr_q(15) xor data_in(0) xor data_in(4) xor data_in(7);
    crc_8(13) <= lfsr_q(5) xor lfsr_q(9) xor lfsr_q(13) xor data_in(1) xor data_in(5);
    crc_8(14) <= lfsr_q(6) xor lfsr_q(10) xor lfsr_q(14) xor data_in(2) xor data_in(6);
    crc_8(15) <= lfsr_q(7) xor lfsr_q(11) xor lfsr_q(15) xor data_in(3) xor data_in(7);

    data_in <= "--------" &  "--------" &  "--------" &  "--------"                       when byte_enable = "0000" else
               "--------" &  "--------" &  "--------" & reverse(word_data_in(7 downto 0)) when byte_enable = "0001" else
               "--------" &  "--------" & reverse(word_data_in(15 downto 0))              when byte_enable = "0011" else
               "--------" & reverse(word_data_in(23 downto 0))                            when byte_enable = "0111" else
               reverse(word_data_in(31 downto 0));

    crc_res <= lfsr_q when byte_enable = "0000" else
               crc_8  when byte_enable = "0001" else
               crc_16 when byte_enable = "0011" else
               crc_24 when byte_enable = "0111" else
               crc_32;

    crc <= reverse(crc_res);


    process(clock)
    begin
        if rising_edge(clock) then
          if ce = '1' then
            if reset = '1' then
                lfsr_q <= x"FFFF";
            else
                lfsr_q <= crc_res;
            end if;
          end if;
        end if;
    end process;
end Behavioral;
