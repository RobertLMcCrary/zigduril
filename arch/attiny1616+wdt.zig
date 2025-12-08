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

const RTC_PITEN_BM: u8 = (1 << 0);
const RTC_PI_BM: u8 = (1 << 0);
const STANDBY_TICK_SPEED: u8 = 3; // Every .128s
const RTC_PERIOD_CYC512_GC: u8 = (0x09 << 3); // Example period config

// Watchdog Timer methods
pub inline fn active() void {
    RealTimeCounter.PITINTCTRL = RTC_PI_BM;
    while (RealTimeCounter.PITSTATUS > 0) {} // Wait for synchronization
    RealTimeCounter.PITCTRLA = RTC_PERIOD_CYC512_GC | RTC_PITEN_BM;
}

pub inline fn standby() void {
    RealTimeCounter.PITINTCTRL = RTC_PI_BM;
    while (RealTimeCounter.PITSTATUS > 0) {}

    const period = (1 << 6);

    // Assuming (STANDBY_TICK_SPEED << 3) aligns with PERIOD mask.
    // Set period (64 Hz / STANDBY_TICK_SPEED = 8 Hz), enable the PI Timer
    RealTimeCounter.PITCTRLA = period | (STANDBY_TICK_SPEED << 3) | RTC_PITEN_BM;
}

pub inline fn stop() void {
    while (RealTimeCounter.PITSTATUS > 0) {}
    RealTimeCounter.PITCTRLA = 0;
}

pub inline fn vect_clear() void {
    RealTimeCounter.PITINTFLAGS = RTC_PI_BM;
}
