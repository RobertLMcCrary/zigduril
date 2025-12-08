const std = @import("std");

//clock speed / delay stuff
const F_CPU = 10000000;
const BOGOMIPS = F_CPU / 4350;
const DELAY_ZERO_TIME = 1020;

// PDIV constants (bits 4:1 of MCLKCTRLB)
pub const CLKCTRL_PDIV_2X_gc: u8 = 0x0 << 1;
pub const CLKCTRL_PDIV_4X_gc: u8 = 0x1 << 1;
pub const CLKCTRL_PDIV_8X_gc: u8 = 0x2 << 1;
pub const CLKCTRL_PDIV_16X_gc: u8 = 0x3 << 1;
pub const CLKCTRL_PDIV_32X_gc: u8 = 0x4 << 1;
pub const CLKCTRL_PDIV_64X_gc: u8 = 0x5 << 1;
pub const CLKCTRL_PEN_bm: u8 = 0x1; // Bit 0 - Prescaler Enable

// Clock divider enum using named constants
pub const ClockDiv = enum(u8) {
    clock_div_1 = CLKCTRL_PDIV_2X_gc | CLKCTRL_PEN_bm, // 10 MHz
    clock_div_2 = CLKCTRL_PDIV_4X_gc | CLKCTRL_PEN_bm, // 5 MHz
    clock_div_4 = CLKCTRL_PDIV_8X_gc | CLKCTRL_PEN_bm, // 2.5 MHz
    clock_div_8 = CLKCTRL_PDIV_16X_gc | CLKCTRL_PEN_bm, // 1.25 MHz
    clock_div_16 = CLKCTRL_PDIV_32X_gc | CLKCTRL_PEN_bm, // 625 kHz
    clock_div_32 = CLKCTRL_PDIV_64X_gc | CLKCTRL_PEN_bm, // 312 kHz
    clock_div_64 = CLKCTRL_PDIV_64X_gc | CLKCTRL_PEN_bm, // 312 kHz
    clock_div_128 = CLKCTRL_PDIV_64X_gc | CLKCTRL_PEN_bm, // 312 kHz
    clock_div_256 = CLKCTRL_PDIV_64X_gc | CLKCTRL_PEN_bm, // 312 kHz
};

// DAC controls
pub var DAC_LVL: u8 = undefined; // Maps to DAC0.DATA
pub var DAC_VREF: u8 = undefined; // Maps to VREF.CTRLA

// Vref voltage constants
pub const V05: u8 = 0x00;
pub const V055: u8 = 0x00;
pub const V11: u8 = 0x01;
pub const V15: u8 = 0x02;
pub const V25: u8 = 0x03;
pub const V43: u8 = 0x04;

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
