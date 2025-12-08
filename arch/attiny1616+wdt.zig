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

// Watchdog Timer methods
pub fn active() void {}
pub fn standby() void {}
pub fn stop() void {}
pub fn vect_clear() void {}
