const std = @import("std");

const vref = @import("attiny1616+vref.zig");
const clock = @import("attiny1616+clock.zig");

//clock speed / delay stuff
const F_CPU = 10000000;
const BOGOMIPS = F_CPU / 4350;
const DELAY_ZERO_TIME = 1020;

pub fn clock_speed() void {}

//ADC voltage / temperature
pub fn set_admux_therm() void {}

pub fn set_admux_voltage() void {}

pub fn vdd_raw2cooked(measurement: u16) u8 {}

pub fn vdd_raw2fine(measurement: u16) u16 {}

pub fn vdivider_raw2cooked(measurement: u16) u8 {}

pub fn temp_raw2cooked(measurement: u16) u16 {}

//PCINT - pin change interrupt
pub fn switch_vect_clear() void {}
pub fn pcint_on() void {}
pub fn pcint_off() void {}

//misc
pub fn reboot() void {}
pub fn prevent_reboot_loop() void {}
