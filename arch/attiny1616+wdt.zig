const core = @import("attiny1616+core.zig");
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

const WatchDogTimer = packed struct {
    CTRLA: u8,
    STATUS: u8,
};

pub const Period = enum(u8) {
    off = (0x00 << 0),
    _8_cycles = (0x01 << 0),
    _16_cycles = (0x02 << 0),
    _32_cycles = (0x03 << 0),
    _64_cycles = (0x04 << 0),
    _128_cycles = (0x05 << 0),
    _256_cycles = (0x06 << 0),
    _512_cycles = (0x07 << 0),
    _1k_cycles = (0x08 << 0),
    _2k_cycles = (0x09 << 0),
    _4k_cycles = (0x0A << 0),
    _8k_cycles = (0x0B << 0),
};

pub const Window = enum(u8) {
    off = (0x00 << 4),
    _8_cycles = (0x01 << 4),
    _16_cycles = (0x02 << 4),
    _32_cycles = (0x03 << 4),
    _64_cycles = (0x04 << 4),
    _128_cycles = (0x05 << 4),
    _256_cycles = (0x06 << 4),
    _512_cycles = (0x07 << 4),
    _1k_cycles = (0x08 << 4),
    _2k_cycles = (0x09 << 4),
    _4k_cycles = (0x0A << 4),
    _8k_cycles = (0x0B << 4),
};

const RTC_PITEN_BM: u8 = (1 << 0);
const RTC_PI_BM: u8 = (1 << 0);
const STANDBY_TICK_SPEED: u8 = 3; // Every .128s
const RTC_PERIOD_CYC512_GC: u8 = (0x09 << 3); // Example period config

// Watchdog Timer methods
pub inline fn active() void {
    RealTimeCounter.PITINTCTRL = RTC_PI_BM;
    while (RealTimeCounter.PITSTATUS > 0) {} // Poll to wait for synchronization
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

// TODO: Verify all of this for real uncertain

const WDT_PERIOD_gm: u8 = 0x0F; // Mask for period bits
const WDT_CTRLA: *volatile u8 = @ptrFromInt(0x0100); // Check your device header
const CCP_IOREG_gc: u8 = 0xD8;

pub inline fn disable() void {
    var temp: u8 = undefined;
    asm volatile (
        \\  wdr
        \\  out %i[ccp_reg], %[ioreg_cen_mask]
        \\  lds %[tmp], %[wdt_reg]
        \\  cbr %[tmp], %[timeout_mask]
        \\  sts %[wdt_reg], %[tmp]
        : [tmp] "=d" (temp),
        : [ccp_reg] "n" (&core.CCP),
          [ioreg_cen_mask] "r" (@as(u8, CCP_IOREG_gc)),
          [wdt_reg] "n" (&WDT_CTRLA),
          [timeout_mask] "I" (WDT_PERIOD_gm),
        : .{ .memory = true });
}

// Reset the watchdog timer.  When the watchdog timer is enabled,
// a call to this instruction is required before the timer expires,
// otherwise a watchdog-initiated device reset will occur.
inline fn reset() void {
    asm volatile ("wdr");
}
