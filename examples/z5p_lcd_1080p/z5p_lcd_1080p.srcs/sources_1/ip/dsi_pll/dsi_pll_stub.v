// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.3 (lin64) Build 1682563 Mon Oct 10 19:07:26 MDT 2016
// Date        : Mon Mar 20 14:41:52 2017
// Host        : david-desktop-arch running 64-bit unknown
// Command     : write_verilog -force -mode synth_stub
//               /home/dave/ip/examples/z5p_lcd_1080p/z5p_lcd_1080p.srcs/sources_1/ip/dsi_pll/dsi_pll_stub.v
// Design      : dsi_pll
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module dsi_pll(hs_word_clock, hs_bit_clock, hs_out_clock, 
  ls_2xbit_clock, clkin)
/* synthesis syn_black_box black_box_pad_pin="hs_word_clock,hs_bit_clock,hs_out_clock,ls_2xbit_clock,clkin" */;
  output hs_word_clock;
  output hs_bit_clock;
  output hs_out_clock;
  output ls_2xbit_clock;
  input clkin;
endmodule
