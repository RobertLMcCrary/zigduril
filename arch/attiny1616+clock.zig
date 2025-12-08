// The ATtiny1616 main clock is controlled via the MCLKCTRLB register.
// After reset, the device runs at 20MHz (or 16MHz depending on fuses),
// divided by 6 to give ~3.3MHz (or 2.66MHz).
//
// MCLKCTRLB Register Layout (8 bits):
// Bit:  7  6  5  4  3  2  1  0
//                 (bits 4:1)  (bit 0)
//       Reserved | PDIV[3:0] | PEN
//
// PEN (Prescaler Enable, bit 0): Must be 1 to enable the prescaler
// PDIV (Prescaler Divider, bits 4:1): Selects the division ratio
//
// The <<1 shift places the PDIV value in bits 4:1 (leaving bit 0 for PEN)
// The |CLKCTRL_PEN_bm combines the PDIV value with the enable bit

// PDIV field values (shifted left 1 bit to occupy bits 4:1 of MCLKCTRLB)
pub const CLKCTRL_PDIV = enum(u8) {
    @"2X" = 0x0 << 1,
    @"4X" = 0x1 << 1,
    @"8X" = 0x2 << 1,
    @"16X" = 0x3 << 1,
    @"32X" = 0x4 << 1,
    @"64X" = 0x5 << 1,
};

// PEN bit mask (bit 0 of MCLKCTRLB)
pub const CLKCTRL_PRESCALE_ENABLE_BITMASK: u8 = 0x1; // Bit 0 - Prescaler Enable

// Configuration Change Protection (CCP) register
// CCP I/O address for AVR XMEGA3 (see datasheet section 10.3.5)
const CCP_ADDRESS: u8 = 0x34; // CCP register I/O address
const CCP_IOREG_gc: u8 = 0xD8; // Signature for protected I/O register access

// CLKCTRL peripheral base address and register offsets (from datasheet section 10.4)
const CLKCTRL_BASE: u16 = 0x0060;
const CLKCTRL_MCLKCTRLB_ADDRESS: u16 = CLKCTRL_BASE + 0x01; // 0x0061
const CLKCTRL_MCLKSTATUS_ADDRESS: u16 = CLKCTRL_BASE + 0x03; // 0x0063

// MCLKSTATUS register bit masks (datasheet section 10.5.3)
const CLKCTRL_SOSC_BITMASK: u8 = 0x01; // System Oscillator Changing (bit 0)

// Clock divider enum using named constants
// Example: clock_div_4 = 0b00000101 = PDIV_8X (0x2<<1) | PEN (0x1)
//          This divides 20MHz by 8 = 2.5MHz, then by prescaler setting = final clock
pub const Divider = enum(u8) {
    Standard_1 = CLKCTRL_PDIV.@"2X" | CLKCTRL_PRESCALE_ENABLE_BITMASK, // 10 MHz
    Standard_2 = CLKCTRL_PDIV.@"4X" | CLKCTRL_PRESCALE_ENABLE_BITMASK, // 5 MHz
    Standard_4 = CLKCTRL_PDIV.@"8X" | CLKCTRL_PRESCALE_ENABLE_BITMASK, // 2.5 MHz
    Standard_8 = CLKCTRL_PDIV.@"6X" | CLKCTRL_PRESCALE_ENABLE_BITMASK, // 1.25 MHz
    Standard_16 = CLKCTRL_PDIV.@"2X" | CLKCTRL_PRESCALE_ENABLE_BITMASK, // 625 kHz
    Standard_32 = CLKCTRL_PDIV.@"4X" | CLKCTRL_PRESCALE_ENABLE_BITMASK, // 312 kHz
    Standard_64 = CLKCTRL_PDIV.@"4X" | CLKCTRL_PRESCALE_ENABLE_BITMASK, // 312 kHz
    Standard_28 = CLKCTRL_PDIV.@"4X" | CLKCTRL_PRESCALE_ENABLE_BITMASK, // 312 kHz
    Standard_56 = CLKCTRL_PDIV.@"4X" | CLKCTRL_PRESCALE_ENABLE_BITMASK, // 312 kHz
};

/// Protected write for AVR XMEGA3 devices
/// This implements the _PROTECTED_WRITE macro which:
/// 1. Writes signature (0xD8) to CCP register (I/O space)
/// 2. Within 4 CPU cycles, writes value to the protected register (memory space)
/// See datasheet section 10.3.5 "Configuration Change Protection"
inline fn protected_write(comptime reg_addr: u16, value: u8) void {
    asm volatile (
        \\  out %i[ccp], %[signature]
        \\  sts %[reg], %[val]
        :
        : [ccp] "n" (&CCP_ADDRESS),
          [signature] "d" (CCP_IOREG_gc),
          [reg] "n" (reg_addr),
          [val] "r" (value),
    );
}

inline fn disable_interrupts() void {
    asm volatile ("cli");
}

inline fn enable_interrupts() void {
    asm volatile ("sei");
}

///Read a memory-mapped register
inline fn read_register(comptime addr: u16) u8 {
    // Volatile to cover for possible side-effect cases
    const ptr = @as(*volatile u8, @ptrFromInt(addr));
    return ptr.*;
}

/// The prescaler divides the main clock frequency:
/// - Pass one of the Divider enum values for standard divisions
/// - Or construct manually: PDIV value (bits 4:1) | PEN enable bit (bit 0)
pub fn set_prescale(scale: u8) void {
    disable_interrupts(); // Disable during clock change

    // Write to protected MCLKCTRLB register
    // This requires the CCP unlock sequence (handled by protected_write)
    protected_write(CLKCTRL_MCLKCTRLB_ADDRESS, scale);

    // Wait for clock change to complete
    // Poll MCLKSTATUS.SOSC bit until it clears
    while ((read_register(CLKCTRL_MCLKSTATUS_ADDRESS) & CLKCTRL_SOSC_BITMASK) != 0) {}

    enable_interrupts(); // Re-enable
}

/// Initializes the clock speed to 10 MHz
/// Sets up the system clock to run at 10 MHz instead of the default 3.33 MHz
/// divides the 20 MHz internal oscillator by 2
/// C equivalent: mcu_clock_speed()
pub fn setup_speed() void {
    // Set clock to 10 MHz: 20 MHz / 2
    // PDIV[3:0] = 0x0 (divide by 2) in bits 4:1
    // PEN = 1 (enable prescaler) in bit 0
    protected_write(CLKCTRL_MCLKCTRLB_ADDRESS, CLKCTRL_PDIV.@"2X" | CLKCTRL_PRESCALE_ENABLE_BITMASK);
}
