EESchema Schematic File Version 2
LIBS:fmc-rescue
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:fmcboard
LIBS:fmc-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 4 9
Title "FMC to MIPI DSI/CSI breakout"
Date "2016-07-25"
Rev "1.2"
Comp "David Shah"
Comment1 "CONFIDENTIAL"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Sheet
S 4600 950  1300 2500
U 5745D7F1
F0 "DSI0 Level Shifter" 60
F1 "dsi-levelshifter.sch" 60
F2 "CLK_HS+" I L 4600 1150 47 
F3 "CLK_HS-" I L 4600 1250 47 
F4 "CLK_LP-" I L 4600 1350 47 
F5 "CLK_LP+" I L 4600 1050 47 
F6 "CLK+" O R 5900 1100 47 
F7 "CLK-" O R 5900 1300 47 
F8 "D0_HS+" I L 4600 1650 47 
F9 "D0_HS-" I L 4600 1750 47 
F10 "D0_LP-" I L 4600 1850 47 
F11 "D0_LP+" I L 4600 1550 47 
F12 "D0+" O R 5900 1600 47 
F13 "D0-" O R 5900 1800 47 
F14 "D1_HS+" I L 4600 2150 47 
F15 "D1_HS-" I L 4600 2250 47 
F16 "D1_LP-" I L 4600 2350 47 
F17 "D1_LP+" I L 4600 2050 47 
F18 "D1+" O R 5900 2100 47 
F19 "D1-" O R 5900 2300 47 
F20 "D2_HS+" I L 4600 2650 47 
F21 "D2_HS-" I L 4600 2750 47 
F22 "D2_LP-" I L 4600 2850 47 
F23 "D2_LP+" I L 4600 2550 47 
F24 "D2+" O R 5900 2600 47 
F25 "D2-" O R 5900 2800 47 
F26 "D3_HS+" I L 4600 3150 47 
F27 "D3_HS-" I L 4600 3250 47 
F28 "D3_LP-" I L 4600 3350 47 
F29 "D3_LP+" I L 4600 3050 47 
F30 "D3+" O R 5900 3100 47 
F31 "D3-" O R 5900 3300 47 
$EndSheet
Text GLabel 4100 1050 0    47   Input ~ 0
DSI0_CLK_LP+
Text GLabel 4100 1150 0    47   Input ~ 0
DSI0_CLK_HS+
Text GLabel 4100 1250 0    47   Input ~ 0
DSI0_CLK_HS-
Text GLabel 4100 1350 0    47   Input ~ 0
DSI0_CLK_LP-
Text GLabel 4100 1550 0    47   Input ~ 0
DSI0_D0_LP+
Text GLabel 4100 1650 0    47   Input ~ 0
DSI0_D0_HS+
Text GLabel 4100 1750 0    47   Input ~ 0
DSI0_D0_HS-
Text GLabel 4100 1850 0    47   Input ~ 0
DSI0_D0_LP-
Text GLabel 4100 2050 0    47   Input ~ 0
DSI0_D1_LP+
Text GLabel 4100 2150 0    47   Input ~ 0
DSI0_D1_HS+
Text GLabel 4100 2250 0    47   Input ~ 0
DSI0_D1_HS-
Text GLabel 4100 2350 0    47   Input ~ 0
DSI0_D1_LP-
Text GLabel 4100 2550 0    47   Input ~ 0
DSI0_D2_LP+
Text GLabel 4100 2650 0    47   Input ~ 0
DSI0_D2_HS+
Text GLabel 4100 2750 0    47   Input ~ 0
DSI0_D2_HS-
Text GLabel 4100 2850 0    47   Input ~ 0
DSI0_D2_LP-
Text GLabel 4100 3050 0    47   Input ~ 0
DSI0_D3_LP+
Text GLabel 4100 3150 0    47   Input ~ 0
DSI0_D3_HS+
Text GLabel 4100 3250 0    47   Input ~ 0
DSI0_D3_HS-
Text GLabel 4100 3350 0    47   Input ~ 0
DSI0_D3_LP-
Wire Wire Line
	4100 1050 4600 1050
Wire Wire Line
	4100 1150 4600 1150
Wire Wire Line
	4100 1250 4600 1250
Wire Wire Line
	4100 1350 4600 1350
Wire Wire Line
	4100 1550 4600 1550
Wire Wire Line
	4100 1650 4600 1650
Wire Wire Line
	4100 1750 4600 1750
Wire Wire Line
	4100 1850 4600 1850
Wire Wire Line
	4100 2050 4600 2050
Wire Wire Line
	4100 2150 4600 2150
Wire Wire Line
	4100 2250 4600 2250
Wire Wire Line
	4100 2350 4600 2350
Wire Wire Line
	4100 2650 4600 2650
Wire Wire Line
	4100 2750 4600 2750
Wire Wire Line
	4100 2850 4600 2850
Wire Wire Line
	4100 3050 4600 3050
Wire Wire Line
	4100 3150 4600 3150
Wire Wire Line
	4100 3250 4600 3250
Wire Wire Line
	4100 3350 4600 3350
Wire Wire Line
	4100 2550 4600 2550
Text GLabel 6400 1100 2    47   Output ~ 0
DSI0_CLK+
Text GLabel 6400 1300 2    47   Output ~ 0
DSI0_CLK-
Text GLabel 6400 1600 2    47   Output ~ 0
DSI0_D0+
Text GLabel 6400 1800 2    47   Output ~ 0
DSI0_D0-
Text GLabel 6400 2100 2    47   Output ~ 0
DSI0_D1+
Text GLabel 6400 2300 2    47   Output ~ 0
DSI0_D1-
Text GLabel 6400 2600 2    47   Output ~ 0
DSI0_D2+
Text GLabel 6400 2800 2    47   Output ~ 0
DSI0_D2-
Text GLabel 6400 3100 2    47   Output ~ 0
DSI0_D3+
Text GLabel 6400 3300 2    47   Output ~ 0
DSI0_D3-
Wire Wire Line
	6400 1100 5900 1100
Wire Wire Line
	5900 1300 6400 1300
Wire Wire Line
	5900 1600 6400 1600
Wire Wire Line
	5900 1800 6400 1800
Wire Wire Line
	5900 2100 6400 2100
Wire Wire Line
	5900 2300 6400 2300
Wire Wire Line
	5900 2600 6400 2600
Wire Wire Line
	5900 2800 6400 2800
Wire Wire Line
	5900 3100 6400 3100
Wire Wire Line
	5900 3300 6400 3300
Text Notes 3400 1900 3    47   ~ 0
From FPGA
Text Notes 7000 2300 1    47   ~ 0
To Panel
$Sheet
S 4600 3900 1300 2500
U 5746B433
F0 "DSI1 Level Shifter" 60
F1 "dsi-levelshifter.sch" 60
F2 "CLK_HS+" I L 4600 4100 47 
F3 "CLK_HS-" I L 4600 4200 47 
F4 "CLK_LP-" I L 4600 4300 47 
F5 "CLK_LP+" I L 4600 4000 47 
F6 "CLK+" O R 5900 4050 47 
F7 "CLK-" O R 5900 4250 47 
F8 "D0_HS+" I L 4600 4600 47 
F9 "D0_HS-" I L 4600 4700 47 
F10 "D0_LP-" I L 4600 4800 47 
F11 "D0_LP+" I L 4600 4500 47 
F12 "D0+" O R 5900 4550 47 
F13 "D0-" O R 5900 4750 47 
F14 "D1_HS+" I L 4600 5100 47 
F15 "D1_HS-" I L 4600 5200 47 
F16 "D1_LP-" I L 4600 5300 47 
F17 "D1_LP+" I L 4600 5000 47 
F18 "D1+" O R 5900 5050 47 
F19 "D1-" O R 5900 5250 47 
F20 "D2_HS+" I L 4600 5600 47 
F21 "D2_HS-" I L 4600 5700 47 
F22 "D2_LP-" I L 4600 5800 47 
F23 "D2_LP+" I L 4600 5500 47 
F24 "D2+" O R 5900 5550 47 
F25 "D2-" O R 5900 5750 47 
F26 "D3_HS+" I L 4600 6100 47 
F27 "D3_HS-" I L 4600 6200 47 
F28 "D3_LP-" I L 4600 6300 47 
F29 "D3_LP+" I L 4600 6000 47 
F30 "D3+" O R 5900 6050 47 
F31 "D3-" O R 5900 6250 47 
$EndSheet
Text GLabel 4100 4000 0    47   Input ~ 0
DSI1_CLK_LP+
Text GLabel 4100 4100 0    47   Input ~ 0
DSI1_CLK_HS+
Text GLabel 4100 4200 0    47   Input ~ 0
DSI1_CLK_HS-
Text GLabel 4100 4300 0    47   Input ~ 0
DSI1_CLK_LP-
Text GLabel 4100 4500 0    47   Input ~ 0
DSI1_D0_LP+
Text GLabel 4100 4600 0    47   Input ~ 0
DSI1_D0_HS+
Text GLabel 4100 4700 0    47   Input ~ 0
DSI1_D0_HS-
Text GLabel 4100 4800 0    47   Input ~ 0
DSI1_D0_LP-
Text GLabel 4100 5000 0    47   Input ~ 0
DSI1_D1_LP+
Text GLabel 4100 5100 0    47   Input ~ 0
DSI1_D1_HS+
Text GLabel 4100 5200 0    47   Input ~ 0
DSI1_D1_HS-
Text GLabel 4100 5300 0    47   Input ~ 0
DSI1_D1_LP-
Text GLabel 4100 5500 0    47   Input ~ 0
DSI1_D2_LP+
Text GLabel 4100 5600 0    47   Input ~ 0
DSI1_D2_HS+
Text GLabel 4100 5700 0    47   Input ~ 0
DSI1_D2_HS-
Text GLabel 4100 5800 0    47   Input ~ 0
DSI1_D2_LP-
Text GLabel 4100 6000 0    47   Input ~ 0
DSI1_D3_LP+
Text GLabel 4100 6100 0    47   Input ~ 0
DSI1_D3_HS+
Text GLabel 4100 6200 0    47   Input ~ 0
DSI1_D3_HS-
Text GLabel 4100 6300 0    47   Input ~ 0
DSI1_D3_LP-
Wire Wire Line
	4100 4000 4600 4000
Wire Wire Line
	4100 4100 4600 4100
Wire Wire Line
	4100 4200 4600 4200
Wire Wire Line
	4100 4300 4600 4300
Wire Wire Line
	4100 4500 4600 4500
Wire Wire Line
	4100 4600 4600 4600
Wire Wire Line
	4100 4700 4600 4700
Wire Wire Line
	4100 4800 4600 4800
Wire Wire Line
	4100 5000 4600 5000
Wire Wire Line
	4100 5100 4600 5100
Wire Wire Line
	4100 5200 4600 5200
Wire Wire Line
	4100 5300 4600 5300
Wire Wire Line
	4100 5600 4600 5600
Wire Wire Line
	4100 5700 4600 5700
Wire Wire Line
	4100 5800 4600 5800
Wire Wire Line
	4100 6000 4600 6000
Wire Wire Line
	4100 6100 4600 6100
Wire Wire Line
	4100 6200 4600 6200
Wire Wire Line
	4100 6300 4600 6300
Wire Wire Line
	4100 5500 4600 5500
Text GLabel 6400 4050 2    47   Output ~ 0
DSI1_CLK+
Text GLabel 6400 4250 2    47   Output ~ 0
DSI1_CLK-
Text GLabel 6400 4550 2    47   Output ~ 0
DSI1_D0+
Text GLabel 6400 4750 2    47   Output ~ 0
DSI1_D0-
Text GLabel 6400 5050 2    47   Output ~ 0
DSI1_D1+
Text GLabel 6400 5250 2    47   Output ~ 0
DSI1_D1-
Text GLabel 6400 5550 2    47   Output ~ 0
DSI1_D2+
Text GLabel 6400 5750 2    47   Output ~ 0
DSI1_D2-
Text GLabel 6400 6050 2    47   Output ~ 0
DSI1_D3+
Text GLabel 6400 6250 2    47   Output ~ 0
DSI1_D3-
Wire Wire Line
	6400 4050 5900 4050
Wire Wire Line
	5900 4250 6400 4250
Wire Wire Line
	5900 4550 6400 4550
Wire Wire Line
	5900 4750 6400 4750
Wire Wire Line
	5900 5050 6400 5050
Wire Wire Line
	5900 5250 6400 5250
Wire Wire Line
	5900 5550 6400 5550
Wire Wire Line
	5900 5750 6400 5750
Wire Wire Line
	5900 6050 6400 6050
Wire Wire Line
	5900 6250 6400 6250
Text Notes 3400 4850 3    47   ~ 0
From FPGA
Text Notes 7000 5250 1    47   ~ 0
To Panel
$EndSCHEMATC
