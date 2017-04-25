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
$Descr A3 16535 11693
encoding utf-8
Sheet 3 9
Title "FMC to MIPI DSI/CSI breakout"
Date "2016-07-25"
Rev "1.2"
Comp "David Shah"
Comment1 "CONFIDENTIAL"
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L FMC-HPC-AC701 P1
U 11 1 5745CA68
P 7750 9400
F 0 "P1" H 7750 9400 60  0000 C CNN
F 1 "FMC-HPC-AC701" H 7750 9300 60  0000 C CNN
F 2 "Custom Parts:ASP-134488-01" H 7750 9400 60  0001 C CNN
F 3 "" H 7750 9400 60  0000 C CNN
	11   7750 9400
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR07
U 1 1 5745CCF7
P 6700 9400
F 0 "#PWR07" H 6700 9150 50  0001 C CNN
F 1 "GND" H 6700 9250 50  0000 C CNN
F 2 "" H 6700 9400 50  0000 C CNN
F 3 "" H 6700 9400 50  0000 C CNN
	1    6700 9400
	1    0    0    -1  
$EndComp
Wire Wire Line
	6700 9400 6700 1400
Wire Wire Line
	6700 1400 6950 1400
Wire Wire Line
	6950 1500 6700 1500
Connection ~ 6700 1500
Connection ~ 6700 1600
Connection ~ 6700 1700
Connection ~ 6700 1800
Connection ~ 6700 1900
Connection ~ 6700 2000
Connection ~ 6700 2100
Connection ~ 6700 2200
Connection ~ 6700 2300
Connection ~ 6700 2400
Connection ~ 6700 2500
Connection ~ 6700 2600
Connection ~ 6700 2700
Connection ~ 6700 2800
Connection ~ 6700 2900
Connection ~ 6700 3000
Connection ~ 6700 3100
Connection ~ 6700 3200
Connection ~ 6700 3300
Connection ~ 6700 3400
Connection ~ 6700 3500
Connection ~ 6700 3600
Connection ~ 6700 3700
Connection ~ 6700 3800
Connection ~ 6700 3900
Connection ~ 6700 4000
Connection ~ 6700 4100
Connection ~ 6700 4200
Connection ~ 6700 4300
Connection ~ 6700 4400
Connection ~ 6700 4500
Connection ~ 6700 4600
Connection ~ 6700 4700
Connection ~ 6700 4800
Connection ~ 6700 4900
Connection ~ 6700 5000
Connection ~ 6700 5100
Connection ~ 6700 5200
Connection ~ 6700 5300
Connection ~ 6700 5400
Connection ~ 6700 5500
Connection ~ 6700 5600
Connection ~ 6700 5700
Connection ~ 6700 5800
Connection ~ 6700 5900
Connection ~ 6700 6000
Connection ~ 6700 6100
Connection ~ 6700 6200
Connection ~ 6700 6300
Connection ~ 6700 6400
Connection ~ 6700 6500
Connection ~ 6700 6600
Connection ~ 6700 6700
Connection ~ 6700 6800
Connection ~ 6700 6900
Connection ~ 6700 7000
Connection ~ 6700 7100
Connection ~ 6700 7200
Connection ~ 6700 7300
Connection ~ 6700 7400
Connection ~ 6700 7500
Connection ~ 6700 7600
Connection ~ 6700 7700
Connection ~ 6700 7800
Connection ~ 6700 7900
Connection ~ 6700 8000
Connection ~ 6700 8100
Connection ~ 6700 8200
Connection ~ 6700 8300
Connection ~ 6700 8400
Connection ~ 6700 8500
Connection ~ 6700 8600
Connection ~ 6700 8700
Connection ~ 6700 8800
Connection ~ 6700 8900
Connection ~ 6700 9000
Connection ~ 6700 9100
Connection ~ 6700 9200
Connection ~ 6700 9300
Wire Wire Line
	6950 1600 6700 1600
Wire Wire Line
	6950 1700 6700 1700
Wire Wire Line
	6950 1800 6700 1800
Wire Wire Line
	6950 1900 6700 1900
Wire Wire Line
	6950 2000 6700 2000
Wire Wire Line
	6950 2100 6700 2100
Wire Wire Line
	6950 2200 6700 2200
Wire Wire Line
	6950 2300 6700 2300
Wire Wire Line
	6950 2400 6700 2400
Wire Wire Line
	6950 2500 6700 2500
Wire Wire Line
	6950 2600 6700 2600
Wire Wire Line
	6950 2700 6700 2700
Wire Wire Line
	6950 2800 6700 2800
Wire Wire Line
	6950 2900 6700 2900
Wire Wire Line
	6950 3000 6700 3000
Wire Wire Line
	6950 3100 6700 3100
Wire Wire Line
	6950 3200 6700 3200
Wire Wire Line
	6950 3300 6700 3300
Wire Wire Line
	6950 3400 6700 3400
Wire Wire Line
	6950 3500 6700 3500
Wire Wire Line
	6950 3600 6700 3600
Wire Wire Line
	6950 3700 6700 3700
Wire Wire Line
	6950 3800 6700 3800
Wire Wire Line
	6950 3900 6700 3900
Wire Wire Line
	6950 4000 6700 4000
Wire Wire Line
	6950 4100 6700 4100
Wire Wire Line
	6950 4200 6700 4200
Wire Wire Line
	6950 4300 6700 4300
Wire Wire Line
	6950 4400 6700 4400
Wire Wire Line
	6950 4500 6700 4500
Wire Wire Line
	6950 4600 6700 4600
Wire Wire Line
	6950 4700 6700 4700
Wire Wire Line
	6950 4800 6700 4800
Wire Wire Line
	6950 4900 6700 4900
Wire Wire Line
	6950 5000 6700 5000
Wire Wire Line
	6950 5100 6700 5100
Wire Wire Line
	6950 5200 6700 5200
Wire Wire Line
	6950 5300 6700 5300
Wire Wire Line
	6950 5400 6700 5400
Wire Wire Line
	6950 5500 6700 5500
Wire Wire Line
	6950 5600 6700 5600
Wire Wire Line
	6950 5700 6700 5700
Wire Wire Line
	6950 5800 6700 5800
Wire Wire Line
	6950 5900 6700 5900
Wire Wire Line
	6950 6000 6700 6000
Wire Wire Line
	6950 6100 6700 6100
Wire Wire Line
	6950 6200 6700 6200
Wire Wire Line
	6950 6300 6700 6300
Wire Wire Line
	6950 6400 6700 6400
Wire Wire Line
	6950 6500 6700 6500
Wire Wire Line
	6950 6600 6700 6600
Wire Wire Line
	6950 6700 6700 6700
Wire Wire Line
	6950 6800 6700 6800
Wire Wire Line
	6950 6900 6700 6900
Wire Wire Line
	6950 7000 6700 7000
Wire Wire Line
	6950 7100 6700 7100
Wire Wire Line
	6950 7200 6700 7200
Wire Wire Line
	6950 7300 6700 7300
Wire Wire Line
	6950 7400 6700 7400
Wire Wire Line
	6950 7500 6700 7500
Wire Wire Line
	6950 7600 6700 7600
Wire Wire Line
	6950 7700 6700 7700
Wire Wire Line
	6950 7800 6700 7800
Wire Wire Line
	6950 7900 6700 7900
Wire Wire Line
	6950 8000 6700 8000
Wire Wire Line
	6950 8100 6700 8100
Wire Wire Line
	6950 8200 6700 8200
Wire Wire Line
	6950 8300 6700 8300
Wire Wire Line
	6950 8400 6700 8400
Wire Wire Line
	6950 8500 6700 8500
Wire Wire Line
	6950 8600 6700 8600
Wire Wire Line
	6950 8700 6700 8700
Wire Wire Line
	6950 8800 6700 8800
Wire Wire Line
	6950 8900 6700 8900
Wire Wire Line
	6950 9000 6700 9000
Wire Wire Line
	6950 9100 6700 9100
Wire Wire Line
	6950 9200 6700 9200
Wire Wire Line
	6950 9300 6700 9300
Wire Wire Line
	8550 1400 8800 1400
Wire Wire Line
	8550 1500 8800 1500
Wire Wire Line
	8550 1600 8800 1600
Wire Wire Line
	8550 1700 8800 1700
Wire Wire Line
	8550 1800 8800 1800
Wire Wire Line
	8550 1900 8800 1900
Wire Wire Line
	8550 2000 8800 2000
Wire Wire Line
	8550 2100 8800 2100
Wire Wire Line
	8550 2200 8800 2200
Wire Wire Line
	8550 2300 8800 2300
Wire Wire Line
	8550 2400 8800 2400
Wire Wire Line
	8550 2500 8800 2500
Wire Wire Line
	8550 2600 8800 2600
Wire Wire Line
	8550 2700 8800 2700
Wire Wire Line
	8550 2800 8800 2800
Wire Wire Line
	8550 2900 8800 2900
Wire Wire Line
	8550 3000 8800 3000
Wire Wire Line
	8550 3100 8800 3100
Wire Wire Line
	8550 3200 8800 3200
Wire Wire Line
	8550 3300 8800 3300
Wire Wire Line
	8550 3400 8800 3400
Wire Wire Line
	8550 3500 8800 3500
Wire Wire Line
	8550 3600 8800 3600
Wire Wire Line
	8550 3700 8800 3700
Wire Wire Line
	8550 3800 8800 3800
Wire Wire Line
	8550 3900 8800 3900
Wire Wire Line
	8550 4000 8800 4000
Wire Wire Line
	8550 4100 8800 4100
Wire Wire Line
	8550 4200 8800 4200
Wire Wire Line
	8550 4300 8800 4300
Wire Wire Line
	8550 4400 8800 4400
Wire Wire Line
	8550 4500 8800 4500
Wire Wire Line
	8550 4600 8800 4600
Wire Wire Line
	8550 4700 8800 4700
Wire Wire Line
	8550 4800 8800 4800
Wire Wire Line
	8550 4900 8800 4900
Wire Wire Line
	8550 5000 8800 5000
Wire Wire Line
	8550 5100 8800 5100
Wire Wire Line
	8550 5200 8800 5200
Wire Wire Line
	8550 5300 8800 5300
Wire Wire Line
	8550 5400 8800 5400
Wire Wire Line
	8550 5500 8800 5500
Wire Wire Line
	8550 5600 8800 5600
Wire Wire Line
	8550 5700 8800 5700
Wire Wire Line
	8550 5800 8800 5800
Wire Wire Line
	8550 5900 8800 5900
Wire Wire Line
	8550 6000 8800 6000
Wire Wire Line
	8550 6100 8800 6100
Wire Wire Line
	8550 6200 8800 6200
Wire Wire Line
	8550 6300 8800 6300
Wire Wire Line
	8550 6400 8800 6400
Wire Wire Line
	8550 6500 8800 6500
Wire Wire Line
	8550 6600 8800 6600
Wire Wire Line
	8550 6700 8800 6700
Wire Wire Line
	8550 6800 8800 6800
Wire Wire Line
	8550 6900 8800 6900
Wire Wire Line
	8550 7000 8800 7000
Wire Wire Line
	8550 7100 8800 7100
Wire Wire Line
	8550 7200 8800 7200
Wire Wire Line
	8550 7300 8800 7300
Wire Wire Line
	8550 7400 8800 7400
Wire Wire Line
	8550 7500 8800 7500
Wire Wire Line
	8550 7600 8800 7600
Wire Wire Line
	8550 7700 8800 7700
Wire Wire Line
	8550 7800 8800 7800
Wire Wire Line
	8550 7900 8800 7900
Wire Wire Line
	8550 8000 8800 8000
Wire Wire Line
	8550 8100 8800 8100
Wire Wire Line
	8550 8200 8800 8200
Wire Wire Line
	8550 8300 8800 8300
Wire Wire Line
	8550 8400 8800 8400
Wire Wire Line
	8550 8500 8800 8500
Wire Wire Line
	8550 8600 8800 8600
Wire Wire Line
	8550 8700 8800 8700
Wire Wire Line
	8550 8800 8800 8800
Wire Wire Line
	8550 8900 8800 8900
Wire Wire Line
	8550 9000 8800 9000
Wire Wire Line
	8550 9100 8800 9100
Wire Wire Line
	8550 9200 8800 9200
Wire Wire Line
	8800 1400 8800 9400
Connection ~ 8800 1500
Connection ~ 8800 1600
Connection ~ 8800 1700
Connection ~ 8800 1800
Connection ~ 8800 1900
Connection ~ 8800 2000
Connection ~ 8800 2100
Connection ~ 8800 2200
Connection ~ 8800 2300
Connection ~ 8800 2400
Connection ~ 8800 2500
Connection ~ 8800 2600
Connection ~ 8800 2700
Connection ~ 8800 2800
Connection ~ 8800 2900
Connection ~ 8800 3000
Connection ~ 8800 3100
Connection ~ 8800 3200
Connection ~ 8800 3300
Connection ~ 8800 3400
Connection ~ 8800 3500
Connection ~ 8800 3600
Connection ~ 8800 3700
Connection ~ 8800 3800
Connection ~ 8800 3900
Connection ~ 8800 4000
Connection ~ 8800 4100
Connection ~ 8800 4200
Connection ~ 8800 4300
Connection ~ 8800 4400
Connection ~ 8800 4500
Connection ~ 8800 4600
Connection ~ 8800 4700
Connection ~ 8800 4800
Connection ~ 8800 4900
Connection ~ 8800 5000
Connection ~ 8800 5100
Connection ~ 8800 5200
Connection ~ 8800 5300
Connection ~ 8800 5400
Connection ~ 8800 5500
Connection ~ 8800 5600
Connection ~ 8800 5700
Connection ~ 8800 5800
Connection ~ 8800 5900
Connection ~ 8800 6000
Connection ~ 8800 6100
Connection ~ 8800 6200
Connection ~ 8800 6300
Connection ~ 8800 6400
Connection ~ 8800 6500
Connection ~ 8800 6600
Connection ~ 8800 6700
Connection ~ 8800 6800
Connection ~ 8800 6900
Connection ~ 8800 7000
Connection ~ 8800 7100
Connection ~ 8800 7200
Connection ~ 8800 7300
Connection ~ 8800 7400
Connection ~ 8800 7500
Connection ~ 8800 7600
Connection ~ 8800 7700
Connection ~ 8800 7800
Connection ~ 8800 7900
Connection ~ 8800 8000
Connection ~ 8800 8100
Connection ~ 8800 8200
Connection ~ 8800 8300
Connection ~ 8800 8400
Connection ~ 8800 8500
Connection ~ 8800 8600
Connection ~ 8800 8700
Connection ~ 8800 8800
Connection ~ 8800 8900
Connection ~ 8800 9000
Connection ~ 8800 9100
Connection ~ 8800 9200
$Comp
L GND #PWR08
U 1 1 5745D5B5
P 8800 9400
F 0 "#PWR08" H 8800 9150 50  0001 C CNN
F 1 "GND" H 8800 9250 50  0000 C CNN
F 2 "" H 8800 9400 50  0000 C CNN
F 3 "" H 8800 9400 50  0000 C CNN
	1    8800 9400
	1    0    0    -1  
$EndComp
$EndSCHEMATC
