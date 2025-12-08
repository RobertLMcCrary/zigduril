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

pub fn sleep_mode() void {}

pub fn start_measurement() void {}

pub fn off() void {}

pub fn vect_clear() void {}

pub fn result_temp() u16 {}

pub fn result_volts() u16 {}

pub fn lsb() u8 {}
