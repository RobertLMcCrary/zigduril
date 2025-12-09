const std = @import("std");

const clock = @import("attiny1616+clock.zig");
const core = @import("attiny1616+core.zig");
const port = @import("attiny1616+port.zig");
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

/// This corresponds to VPORTB_INTFLAGS, but matching audril logic
const SWITCH_INTFLAG = 0x0007;

/// This corresponds to PORTA_PIN1CTRL, which seems like it's different per light, so it looks like this should be a parameter somewhere in the state.
const SWITCH_ISC_REG = 0x0411;

const PORT_ISC_gm = 0x07;

//PCINT - pin change interrupt
pub fn switch_vect_clear() void {
    // Write a '1' to clear the interrupt flag
    SWITCH_INTFLAG |= (1 << port.Port.PIN1CTRL); // Switch pin also looks defined per light
}

pub fn pcint_on() void {
    SWITCH_ISC_REG |= port.Isc.both_edges; // Botheders is correspondant
}

pub fn pcint_off() void {
    SWITCH_ISC_REG &= ~(PORT_ISC_gm);
}

// TODO: I don't understand this logic?
pub fn reboot() void {
    // put the WDT in hard reset mode, then trigger it

    core.disable_interrupts();

    // Enable, timeout 8ms
    core.protected_write(wdt.WatchDogTimer.CTRLA, wdt.Period._8_cycles);
    core.enable_interrupts();

    wdt.reset();

    // Deadlock the system until off?
    while (1) {}
}

pub fn prevent_reboot_loop() void {
    // prevent WDT from rebooting MCU again
    RSTCTRL_RSTFR &= ~(RSTCTRL_WDRF_BITMASK); // reset status flag
    wdt.disable();
}
