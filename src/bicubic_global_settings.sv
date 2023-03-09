// System verilog global macro defination file
// Bicubic IP global settings
// Designer:    Deng LiWei
// Date:        2022/03
// Description: Global settings include synthesis settings for the Bicubic IP

// If defined this, the IP will use DSP48E2 primitive which designed for Xilinx UltraScale+ FPGAs
// We recommend you use this when you synthesis on Xilinx UltraScale+ FPGAs to enhance the performance,
//  because we have deeply optimized on these devices.
// NOTE: If you using other FPGAs, or the synthesizer doesn't supported Xilinx primitives,
//  comment this then we can use pure verilog for the calculation, 
//  but it may decrease the performance or increase resource usage.
`define USE_DSP48E2_PRIMITIVE

// If defined this, the IP will use LUT for rounding the result, it may decrease the maximum performance,
// but decrease the usage of DSP slice
//`define USE_LUT_FOR_ROUNDING

// If defined this, the IP will use XPM macros to implement memories (RAM/ROM)
`define USE_XPM_MEMORY


