const std = @import("std");

const clock = @import("attiny1616+clock.zig");
const core = @import("attiny1616+core.zig");
const vref = @import("attiny1616+vref.zig");
const wdt = @import("attiny1616+wdt.zig");

//clock speed / delay stuff
const F_CPU = 10000000;
const BOGOMIPS = F_CPU / 4350;
const DELAY_ZERO_TIME = 1020;
const RSTCTRL_RSTFR = 0x0040;
const RSTCTRL_WDRF_BITMASK = 0x08;

pub fn vdd_raw2cooked(measurement: u16) u8 {
    _ = measurement; // autofix
}

pub fn vdd_raw2fine(measurement: u16) u16 {
    _ = measurement; // autofix
}

pub fn vdivider_raw2cooked(measurement: u16) u8 {
    _ = measurement; // autofix
}

pub fn temp_raw2cooked(measurement: u16) u16 {
    _ = measurement; // autofix
}

//PCINT - pin change interrupt
pub fn switch_vect_clear() void {}
pub fn pcint_on() void {}
pub fn pcint_off() void {}

pub fn reboot() void {
    // put the WDT in hard reset mode, then trigger it
    core.cli();
    // Enable, timeout 8ms
    core.protected_write(wdt.WatchDogTimer.CTRLA, wdt.Period._8_cycles);
    core.sei();
    wdt_reset();
    while (1) {}
}

pub fn prevent_reboot_loop() void {
    // prevent WDT from rebooting MCU again
    RSTCTRL_RSTFR &= ~(RSTCTRL_WDRF_BITMASK); // reset status flag
    wdt.disable();
}
