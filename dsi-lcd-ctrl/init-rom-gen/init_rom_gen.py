import sys
#Map commands to whether short or long; and name for debug purposes
mipi_commands = {0x05 : (False, "DCS_SHORT_WRITE"),
                 0x15 : (False, "DCS_SHORT_WRITE"),
                 0x39 : (True,  "DCS_LONG_WRITE"),
                 0x37 : (False, "SET_MAXIMUM_RETURN_PACKET_SIZE")} #test only to match example
rom_size = 1024
#Take a Linux DTS style DSI command set; with the addition of a "wait" command;
#and generate a ROM for the FPGA DSI controller
def main():
    #Little endian, like DSI
    rom_data = bytearray()
    with open(sys.argv[1], 'r') as f:
        content = f.read().split()
    i = 0
    while i < len(content):
        if content[i].lower() == "wait":
            rom_data.extend(bytearray([00, 00, 00, 00]))
        else:
            mcmd = int(content[i], 16)
            i += 1
            command_data = bytearray()
            is_long, name = mipi_commands[mcmd]
            i += 5 #skip 5 boring bits
            command_len = int(content[i], 16)
            while len(command_data) < command_len:
                i += 1
                command_data.append(int(content[i], 16))

            data_str = " ".join(["%02X" % (x) for x in command_data])
            print(name, data_str)
            if is_long:
                while (len(command_data) % 4) != 0:
                    command_data.append(00)
                rom_data.extend(bytearray([0x11, mcmd, command_len, 0]))
                rom_data.extend(command_data)
            else:
                while len(command_data) < 2:
                    command_data.append(00)
                rom_data.extend(bytearray([0x10, mcmd, command_data[0], command_data[1]]))
        i += 1
    #end of commands
    rom_data.extend(bytearray([0x20, 00, 00, 00]))

    if len(rom_data) % 4 != 0:
        print("alignment error")
        return 1
    if len(rom_data) > (4 * rom_size):
        print("out of ROM")
        return 1
    out_data = "memory_initialization_radix=16;\nmemory_initialization_vector="
    for i in range(0, len(rom_data), 4):
        if i > 0:
            out_data += ","
        out_data += "\n"
        for j in range(0, 4):
            out_data += "%02X" % (rom_data[i + (3-j)])
    out_data += ";\n"
    with open(sys.argv[2], 'w') as f:
        f.write(out_data)

if __name__ == "__main__":
    main()
