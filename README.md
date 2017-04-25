# MIPI DSI FPGA LCD Interface

This is a work-in-progress core to interface advanced MIPI DSI displays with a Xilinx
7-series FPGA. The current display target is the Sony Z5 Premium LCD (AUO H546UAN01.0 or Sharp LS055D1SX05)
which is a  5.5" 4k (2160x3840) LCD. At the moment I am running it in a mode where content is upscaled by the panel
from 1080x1920, as 4k content must be compressed using VESA DSC or Qualcomm FBC. I am working on an encoder for the former.

The only DSI mode currently supported is Command Mode, Video Mode is still being worked on and is not as well documented for the target panels. This
panel works in dual DSI mode, so two transmitters are used each transmitting half of each line. Single-link command mode panels would also work, with
by only instantiating one `dsi_tx_cmd_mode_top`.

A demo project is included for the afforementioned panel and config. It was designed for an FMC breakout board I've built for the Genesys 2 development
board with a Kintex-7 FPGA. Unfortunately a signal integrity issue on this board means I have to run the DSI link at its lowest rate, 200Mbps, which limits
the framerate to about 30fps. Nonetheless, the design files for this board are included if you want a circuit to run the display, although in any system
you develop the MIPI DSI translator resistors should be located much closer to the FPGA to avoid the issues I've had.

The final intended use of this interface is for a larger project I am working on, the [openMixR](https://github.com/daveshah1/openMixR) 4k headset.
