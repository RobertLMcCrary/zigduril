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
const dV = 1;

pub fn vdd_raw2cooked(measurement: u16) u8 {
    // ... spend the extra 84 bytes of ROM for better precision
    // 4096 = how much ADC resolution we're using (12 bits)
    const vbat: u8 = (10 * dV * 1.5 * 4096) / (measurement >> 4);
    return vbat;
}

pub fn vdd_raw2fine(measurement: u16) u16 {
    // In : 65535 * 1.5 / Vbat
    // Out: 65535 * (Vbat / 10) / 1.024V
    const voltage: u16 = @intCast((1.5 * 4096 * 100 * 64 * 16) / measurement);
    return voltage;
}

//pub fn vdivider_raw2cooked(measurement: u16) u8 {
// In : 4095 * Vdiv / 1.1V
// Out: uint8_t: Vbat * 50
// Vdiv = Vbat / 4.3 (typically)
// 1.1 = ADC Vref
//    const adc_per_volt: u16 = (@as(u16, ADC_44) << 4) - (@as(u16, ADC_22) << 4) / (dV * (44 - 22));
//    const result: u8 = @intCast(measurement / adc_per_volt);
//    return result;
//}

// Signature row structure
const SIGROW_t = extern struct {
    DEVICEID0: u8, // Device ID Byte 0
    DEVICEID1: u8, // Device ID Byte 1
    DEVICEID2: u8, // Device ID Byte 2
    SERNUM0: u8, // Serial Number Byte 0
    SERNUM1: u8, // Serial Number Byte 1
    SERNUM2: u8, // Serial Number Byte 2
    SERNUM3: u8, // Serial Number Byte 3
    SERNUM4: u8, // Serial Number Byte 4
    SERNUM5: u8, // Serial Number Byte 5
    SERNUM6: u8, // Serial Number Byte 6
    SERNUM7: u8, // Serial Number Byte 7
    SERNUM8: u8, // Serial Number Byte 8
    SERNUM9: u8, // Serial Number Byte 9
    reserved_1: [19]u8,
    TEMPSENSE0: u8, // Temperature Sensor Calibration Byte 0
    TEMPSENSE1: u8, // Temperature Sensor Calibration Byte 1
    OSC16ERR3V: u8, // OSC16 error at 3V
    OSC16ERR5V: u8, // OSC16 error at 5V
    OSC20ERR3V: u8, // OSC20 error at 3V
    OSC20ERR5V: u8, // OSC20 error at 5V
    reserved_2: [26]u8,
};

// SIGROW base address for ATtiny1616 (check datasheet for correct address)
// Typically at 0x1100 for ATtiny1616, but verify in your datasheet
const SIGROW = @as(*volatile SIGROW_t, @ptrFromInt(0x1100));

pub fn temp_raw2cooked(measurement: u16) u16 {
    // convert raw ADC values to calibrated temperature
    // In: ADC raw temperature (16-bit, or 12-bit left-aligned)
    // Out: Kelvin << 6
    // Precision: 1/64th Kelvin (but noisy)
    // attiny1616 datasheet section 30.3.2.6

    const sigrow_gain: u8 = SIGROW.TEMPSENSE0; // factory calibration data
    const sigrow_offset: i8 = @bitCast(SIGROW.TEMPSENSE1);
    const scaling_factor: u32 = 65536; // use all 16 bits of ADC data

    var temp: u32 = measurement - @as(u32, @bitCast(@as(i32, sigrow_offset) << 6));
    temp *= sigrow_gain; // 24-bit result
    temp += scaling_factor / 8; // Add 1/8th K to get correct rounding on later divisions
    temp = temp >> 8; // change (K << 14) to (K << 6)

    return @intCast(temp); // left-aligned uint16_t, 0 to 1023.98 Kelvin
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
