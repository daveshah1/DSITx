EESchema Schematic File Version 2
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
LIBS:logo
LIBS:fmc-cache
EELAYER 25 0
EELAYER END
$Descr A3 16535 11693
encoding utf-8
Sheet 9 10
Title "FMC to MIPI DSI/CSI breakout for AC701"
Date "2016-07-25"
Rev "1.1"
Comp "Elastic Technologies Ltd"
Comment1 "CONFIDENTIAL"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L CONN_02X06 P901
U 1 1 57449E80
P 8000 1800
F 0 "P901" H 8000 2150 50  0000 C CNN
F 1 "DP_GPIO" H 8000 1450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x06" H 8000 600 50  0001 C CNN
F 3 "" H 8000 600 50  0000 C CNN
	1    8000 1800
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR902
U 1 1 57449E81
P 7550 2300
F 0 "#PWR902" H 7550 2050 50  0001 C CNN
F 1 "GND" H 7550 2150 50  0000 C CNN
F 2 "" H 7550 2300 50  0000 C CNN
F 3 "" H 7550 2300 50  0000 C CNN
	1    7550 2300
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR901
U 1 1 57449E82
P 7550 1400
F 0 "#PWR901" H 7550 1250 50  0001 C CNN
F 1 "+3.3V" H 7550 1540 50  0000 C CNN
F 2 "" H 7550 1400 50  0000 C CNN
F 3 "" H 7550 1400 50  0000 C CNN
	1    7550 1400
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR904
U 1 1 57449E85
P 8500 2300
F 0 "#PWR904" H 8500 2050 50  0001 C CNN
F 1 "GND" H 8500 2150 50  0000 C CNN
F 2 "" H 8500 2300 50  0000 C CNN
F 3 "" H 8500 2300 50  0000 C CNN
	1    8500 2300
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR903
U 1 1 57449E86
P 8500 1400
F 0 "#PWR903" H 8500 1250 50  0001 C CNN
F 1 "+3.3V" H 8500 1540 50  0000 C CNN
F 2 "" H 8500 1400 50  0000 C CNN
F 3 "" H 8500 1400 50  0000 C CNN
	1    8500 1400
	1    0    0    -1  
$EndComp
NoConn ~ 8250 1950
Wire Wire Line
	7550 2300 7550 2050
Wire Wire Line
	7550 2050 7750 2050
Wire Wire Line
	7750 1550 7550 1550
Wire Wire Line
	7550 1550 7550 1400
Wire Wire Line
	7750 1650 7350 1650
Wire Wire Line
	7350 1750 7750 1750
Wire Wire Line
	7750 1950 7350 1950
Wire Wire Line
	8500 2300 8500 2050
Wire Wire Line
	8500 2050 8250 2050
Wire Wire Line
	8500 1400 8500 1550
Wire Wire Line
	8500 1550 8250 1550
Text GLabel 7350 1650 0    47   UnSpc ~ 0
VIO
Text GLabel 7350 1750 0    47   BiDi ~ 0
DP_AUX+
Text GLabel 7350 1850 0    47   BiDi ~ 0
DP_AUX-
Wire Wire Line
	7350 1850 7750 1850
Text GLabel 7350 1950 0    47   Input ~ 0
DP_HPD
Text GLabel 8600 1650 2    47   BiDi ~ 0
DP_SCL
Text GLabel 8600 1750 2    47   BiDi ~ 0
DP_SDA
Text GLabel 8600 1850 2    47   Input ~ 0
DP_EN
Wire Wire Line
	8250 1650 8600 1650
Wire Wire Line
	8600 1750 8250 1750
Wire Wire Line
	8250 1850 8600 1850
$EndSCHEMATC
