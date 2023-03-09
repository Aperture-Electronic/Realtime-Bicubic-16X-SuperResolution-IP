# APV21B - Real-time Video 16X Bicubic Super-resolution IP, AXI4-Stream Video Interface Compatible, 4K 60FPS
## Introduction
The APV21B Real-time Video 16X Bicubic Super-resolution core is a soft IP core. It provides fully
real-time 16X Bicubic interpolation video super-resolution, and its high performance design allows it to
support video output resolutions in excess of 4K 60FPS.  

The APV21B is compatibled with the AXI4-Stream Video protocol as described in the Video IP:
AXI Feature Adoption section of the *Vivado AXI Reference Guide* (Xilinx Inc. UG1037) and AXI4-
Stream Signaling Interface section of the *AXI4-Stream Video IP and System Design Guide* (Xilinx
Inc. UG934).

## Features
* AXI4-Stream Video Interface input/output
* Supported single 8-bit channel input
* Supported 4 pixel per clock (4 x 8-bit) output to reduce the interface frequency
* Real-time Bicubic computation core
* Parametric configurable input resolution
* Output supported to 4K 60FPS (@150 MHz)
* Optimized design for DSP48E2 unit of Xilinx UltraScale+ architecture
* Complete synthesizable HDL design
* Macro switches to using different implementations (DSP Macro/Verilog Inferring)

## File Directory Structure
Please see the Documentation at doc/latex/bicubic_user_manual.pdf, Section 7.1

## Licensing and Open Source Information
The Real-time Video Bicubic Super-resolution IP is a fully open source IP core, with all source code
and detailed design materials publicly available.  
The Real-time Video Bicubic Super-resolution IP is licensed under the GNU Lesser General Public
License (LGPL).
