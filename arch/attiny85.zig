const std = @import("std");

const PROGMEM = 8192;
const EEPROM_SIZE = 512;

//clock speed / delay stuff
const F_CPU = 8000000;
const BOGOMIPS = F_CPU / 4000;
const DELAY_ZERO_TIME = 1020;

//default hw_setup
pub fn hwdef_setup() void {}

//ADC voltage / tempurature
pub fn mcu_set_admux_therm() void {}

pub fn mcu_set_admux_voltage() void {}

pub fn mcu_adc_sleep_mode() void {}

pub fn mcu_adc_start_measurement() void {}

pub fn mcu_adc_off() void {}

pub fn mcu_adc_result() u16 {}

//return volts * 50, range 0 to 5.10V
pub fn mcu_vdd_raw2cooked(measurement: u16) u8 {}
pub fn mcu_vdivider_raw2cooked(measurement: u16) u8 {}

//return (temp in kelvin << 6)
pub fn mcu_temp_raw2cooked(measurement: u16) u16 {}

pub fn mcu_adc_lsb() u8 {}

//WDT
pub fn mcu_wdt_active() void {}
pub fn mcu_wdt_standby() void {}
pub fn mc_wdt_stop() void {}

//PCINT - pin change interrupt
pub fn mcu_pint_on() void {}
pub fn mcu_pint_off() void {}

//misc
pub fn reboot() void {}
pub fn prevent_reboot_loop() void {}
