const std = @import("std");

const vref = @import("attiny1616+vref.zig");
const clock = @import("attiny1616+clock.zig");

//clock speed / delay stuff
const F_CPU = 10000000;
const BOGOMIPS = F_CPU / 4350;
const DELAY_ZERO_TIME = 1020;

/// Rough interface to the underlying register structure. Packed because what is assigned here is directly written.
const AnalogToDigital = packed struct {
    CTRLA: u8, // 0x00
    CTRLB: u8, // 0x01
    CTRLC: u8, // 0x02
    CTRLD: u8, // 0x03
    CTRLE: u8, // 0x04
    SAMPCTRL: u8, // 0x05
    MUXPOS: u8, // 0x06
    _reserved1: u8,
    COMMAND: u8, // 0x08
    EVCTRL: u8, // 0x09
    INTCTRL: u8, // 0x0A
    INTFLAGS: u8, // 0x0B
    DBGCTRL: u8, // 0x0C
    TEMP: u8, // 0x0D
    _reserved2: [2]u8,
    RES: u16, // 0x10 (16-bit access)
    WINLT: u16, // 0x12
    WINHT: u16, // 0x14
    CALIB: u8, // 0x16
};

/// Rough interface to the underlying register structure. Packed because what is assigned here is directly written.
const RealTimeCounter = packed struct {
    CTRLA: u8, // 0x00
    STATUS: u8, // 0x01
    INTCTRL: u8, // 0x02
    INTFLAGS: u8, // 0x03
    TEMP: u8, // 0x04
    DBGCTRL: u8, // 0x05
    _reserved1: u8,
    CLKSEL: u8, // 0x07
    CNT: u16, // 0x08
    PER: u16, // 0x0A
    CMP: u16, // 0x0C
    _reserved2: [2]u8,
    PITCTRLA: u8, // 0x10
    PITSTATUS: u8, // 0x11
    PITINTCTRL: u8, // 0x12
    PITINTFLAGS: u8, // 0x13
};

pub fn mcu_clock_speed() void {}

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
