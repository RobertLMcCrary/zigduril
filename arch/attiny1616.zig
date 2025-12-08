const std = @import("std");

//clock speed / delay stuff
const F_CPU = 10000000;
const BOGOMIPS = F_CPU / 4350;
const DELAY_ZERO_TIME = 1020;

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
pub const ClockDiv = enum(u8) {
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

// The VREF peripheral provides programmable voltage references for ADC, DAC, and AC.
// References are selected via VREF.CTRLA register (and CTRLC, CTRLD for other channels).
//
// VREF.CTRLA Register Layout (8 bits):
// Bit:  7  6  5  4  3  2  1  0
//          ADC0REFSEL | DAC0REFSEL
//          (bits 6:4) | (bits 2:0)
//
// DAC0REFSEL (bits 2:0): Selects reference voltage for DAC0 and AC0
// These values are written to bits 2:0 of VREF.CTRLA
//
// The OR operation in mcu_set_dac_vref() preserves the ADC0REFSEL bits (6:4)
// while updating only the DAC0REFSEL bits (2:0):
//   VREF.CTRLA = new_dac_vref | (VREF.CTRLA & ~0b00000111)
//                    ^                            ^
//                    |                            mask clears bits 2:0
//                    new DAC ref value            keeps bits 7:3 unchanged

// DAC controls
pub var DAC_LVL: u8 = undefined; // Maps to DAC0.DATA
pub var DAC_VREF: u8 = undefined; // Maps to VREF.CTRLA

// VREF constants (DAC reference voltage selection) from VREF.CTRLA register
pub const V055: u8 = 0x0; // VREF_DAC0REFSEL_0V55_gc - bits 2:0 = 0x0
pub const V05: u8 = V055; // Alias for 0.55V
pub const V11: u8 = 0x1; // VREF_DAC0REFSEL_1V1_gc  - bits 2:0 = 0x1
pub const V25: u8 = 0x2; // VREF_DAC0REFSEL_2V5_gc  - bits 2:0 = 0x2
pub const V43: u8 = 0x3; // VREF_DAC0REFSEL_4V34_gc - bits 2:0 = 0x3
pub const V15: u8 = 0x4; // VREF_DAC0REFSEL_1V5_gc  - bits 2:0 = 0x4

// DAC Vref setting function
pub fn mcu_set_dac_vref(x: u8) void {}

// ADC Vref setting function
pub fn mcu_set_adc0_vref(x: u8) void {}

pub fn mcu_clock_speed() void {}

//clock dividers
pub fn clock_prescale_set(n: u8) void {}

//ADC voltage / temperature
pub fn mcu_set_admux_therm() void {}

pub fn mcu_set_admux_voltage() void {}

pub fn mcu_adc_sleep_mode() void {}

pub fn mcu_adc_start_measurement() void {}

pub fn mcu_adc_off() void {}

pub fn mcu_adc_vect_clear() void {}

pub fn mcu_adc_result_temp() u16 {}

pub fn mcu_adc_result_volts() u16 {}

pub fn mcu_vdd_raw2cooked(measurement: u16) u8 {}

pub fn mcu_vdd_raw2fine(measurement: u16) u16 {}

pub fn mcu_vdivider_raw2cooked(measurement: u16) u8 {}

pub fn mcu_temp_raw2cooked(measurement: u16) u16 {}

pub fn mcu_adc_lsb() u8 {}

//WDT
pub fn mcu_wdt_active() void {}
pub fn mcu_wdt_standby() void {}
pub fn mcu_wdt_stop() void {}
pub fn mcu_wdt_vect_clear() void {}

//PCINT - pin change interrupt
pub fn mcu_switch_vect_clear() void {}
pub fn mcu_pcint_on() void {}
pub fn mcu_pcint_off() void {}

//misc
pub fn reboot() void {}
pub fn prevent_reboot_loop() void {}
