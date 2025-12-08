// The ATtiny1616 main clock is controlled via the MCLKCTRLB register.
// After reset, the device runs at 20MHz (or 16MHz depending on fuses),
// divided by 6 to give ~3.3MHz (or 2.66MHz).
//
// MCLKCTRLB Register Layout (8 bits):
// Bit:  7  6  5  4  3  2  1  0
//       Reserved | PDIV[3:0] | PEN
//                 (bits 4:1)  (bit 0)
//
// PEN (Prescaler Enable, bit 0): Must be 1 to enable the prescaler
// PDIV (Prescaler Divider, bits 4:1): Selects the division ratio
//
// The <<1 shift places the PDIV value in bits 4:1 (leaving bit 0 for PEN)
// The |CLKCTRL_PEN_bm combines the PDIV value with the enable bit

// PDIV field values (shifted left 1 bit to occupy bits 4:1 of MCLKCTRLB)
pub const CLKCTRL_PrescaleDivider_2X_gc: u8 = 0x0 << 1;
pub const CLKCTRL_PrescaleDivider_4X_gc: u8 = 0x1 << 1;
pub const CLKCTRL_PrescaleDivider_8X_gc: u8 = 0x2 << 1;
pub const CLKCTRL_PrescaleDivider_16X_gc: u8 = 0x3 << 1;
pub const CLKCTRL_PrescaleDivider_32X_gc: u8 = 0x4 << 1;
pub const CLKCTRL_PrescaleDivider_64X_gc: u8 = 0x5 << 1;

// PEN bit mask (bit 0 of MCLKCTRLB)
pub const CLKCTRL_PrescaleEnable_bitmask: u8 = 0x1; // Bit 0 - Prescaler Enable

// Clock divider enum using named constants
// Example: clock_div_4 = 0b00000101 = PDIV_8X (0x2<<1) | PEN (0x1)
//          This divides 20MHz by 8 = 2.5MHz, then by prescaler setting = final clock
pub const Divider = enum(u8) {
    clock_div_1 = CLKCTRL_PrescaleDivider_2X_gc | CLKCTRL_PrescaleEnable_bitmask, // 10 MHz
    clock_div_2 = CLKCTRL_PrescaleDivider_4X_gc | CLKCTRL_PrescaleEnable_bitmask, // 5 MHz
    clock_div_4 = CLKCTRL_PrescaleDivider_8X_gc | CLKCTRL_PrescaleEnable_bitmask, // 2.5 MHz
    clock_div_8 = CLKCTRL_PrescaleDivider_16X_gc | CLKCTRL_PrescaleEnable_bitmask, // 1.25 MHz
    clock_div_16 = CLKCTRL_PrescaleDivider_32X_gc | CLKCTRL_PrescaleEnable_bitmask, // 625 kHz
    clock_div_32 = CLKCTRL_PrescaleDivider_64X_gc | CLKCTRL_PrescaleEnable_bitmask, // 312 kHz
    clock_div_64 = CLKCTRL_PrescaleDivider_64X_gc | CLKCTRL_PrescaleEnable_bitmask, // 312 kHz
    clock_div_128 = CLKCTRL_PrescaleDivider_64X_gc | CLKCTRL_PrescaleEnable_bitmask, // 312 kHz
    clock_div_256 = CLKCTRL_PrescaleDivider_64X_gc | CLKCTRL_PrescaleEnable_bitmask, // 312 kHz
};
