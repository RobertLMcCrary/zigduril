const std = @import("std");

const vref = @import("attiny1616+vref.zig");
const clock = @import("attiny1616+clock.zig");

//clock speed / delay stuff
const F_CPU = 10000000;
const BOGOMIPS = F_CPU / 4350;
const DELAY_ZERO_TIME = 1020;

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

pub fn clock_speed() void {}

//ADC voltage / temperature
pub fn set_admux_therm() void {}

pub fn set_admux_voltage() void {}

pub fn vdd_raw2cooked(measurement: u16) u8 {}

pub fn vdd_raw2fine(measurement: u16) u16 {}

pub fn vdivider_raw2cooked(measurement: u16) u8 {}

pub fn temp_raw2cooked(measurement: u16) u16 {}

//WDT
pub fn wdt_active() void {}
pub fn wdt_standby() void {}
pub fn wdt_stop() void {}
pub fn wdt_vect_clear() void {}

//PCINT - pin change interrupt
pub fn switch_vect_clear() void {}
pub fn pcint_on() void {}
pub fn pcint_off() void {}

//misc
pub fn reboot() void {}
pub fn prevent_reboot_loop() void {}
