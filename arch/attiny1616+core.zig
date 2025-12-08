// Configuration Change Protection (CCP) register
// CCP I/O address for AVR XMEGA3 (see datasheet section 10.3.5)
const CCP_ADDRESS: u8 = 0x34; // CCP register I/O address
const CCP_IOREG_gc: u8 = 0xD8; // Signature for protected I/O register access

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
