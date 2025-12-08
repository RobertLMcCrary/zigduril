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

// --- CTRLA (Control A) ---
// Offset: 0x00
pub const ENABLE_BITMASK: u8 = (1 << 0); // Enable ADC
pub const FREERUN_BITMASK: u8 = (1 << 1); // Free-Running Mode
pub const RESSEL_BITMASK: u8 = (1 << 2); // Resolution Selection (0=10-bit, 1=8-bit)
pub const RUNSTBY_BITMASK: u8 = (1 << 7); // Run in Standby Mode

// --- CTRLB (Control B) ---
// Offset: 0x01
// Sample Accumulation Number Select (SAMPNUM)
pub const SAMPNUM_ACC4_GROUP_CONFIGURATION: u8 = 0x02; // Accumulate 4 samples

// --- CTRLC (Control C) ---
// Offset: 0x02
// Prescaler (PRESC) - bits [2:0]
pub const PRESC_DIV16_GROUP_CONFIGURATION: u8 = 0x03;

// Reference Selection (REFSEL) - bits [5:4]
pub const REFSEL_INTREF_GROUP_CONFIGURATION: u8 = (0x0 << 4); // Internal Reference (VREF peripheral)
pub const REFSEL_VDDREF_GROUP_CONFIGURATION: u8 = (0x1 << 4); // VDD Reference
pub const REFSEL_EXTREF_GROUP_CONFIGURATION: u8 = (0x2 << 4); // External Reference (VREFA pin)

// Sample Capacitance Selection (SAMPCAP) - bit 6
pub const SAMPCAP_BITMASK: u8 = (1 << 6); // Reduced sampling capacitance (required for Temp Sense)

// --- CTRLD (Control D) ---
// Offset: 0x03
// Initialization Delay (INITDLY) - bits [7:5]
// Defines delay before first conversion starts
pub const INITDLY_DLY0_GROUP_CONFIGURATION: u8 = (0x0 << 5);
pub const INITDLY_DLY16_GROUP_CONFIGURATION: u8 = (0x1 << 5);
pub const INITDLY_DLY32_GROUP_CONFIGURATION: u8 = (0x2 << 5); // Required for Temp Sense (>= 32us)
pub const INITDLY_DLY64_GROUP_CONFIGURATION: u8 = (0x3 << 5);

// --- MUXPOS (Multiplexer Positive Input) ---
// Offset: 0x06
pub const MUXPOS_AIN0_GROUP_CONFIGURATION: u8 = 0x00;
pub const MUXPOS_INTREF_GROUP_CONFIGURATION: u8 = 0x1C; // DAC/Internal Reference
pub const MUXPOS_GND_GROUP_CONFIGURATION: u8 = 0x1D; // Ground
pub const MUXPOS_TEMPSENSE_GROUP_CONFIGURATION: u8 = 0x1E; // Temperature Sensor

// --- COMMAND (Command) ---
// Offset: 0x08
pub const STCONV_BITMASK: u8 = (1 << 0); // Start Conversion

// --- INTFLAGS (Interrupt Flags) ---
// Offset: 0x0B
pub const RESRDY_BITMASK: u8 = (1 << 0); // Result Ready Flag
pub const WCMP_BITMASK: u8 = (1 << 1); // Window Comparator Flag

pub fn sleep_mode() void {}

pub fn start_measurement() void {
    AnalogToDigital.INTCTRL |= RESRDY_BITMASK; // enable interrupt
    AnalogToDigital.COMMAND |= STCONV_BITMASK; // actually start measuring
}

pub fn off() void {
    AnalogToDigital.CTRLA &= ~(ENABLE_BITMASK);
}

pub fn vect_clear() void {
    AnalogToDigital.INTFLAGS &= RESRDY_BITMASK;
}

pub fn result_temp() u16 {
    // just return left-aligned ADC result, don't convert to calibrated units
    return AnalogToDigital.RES << 4;
}

pub fn result_volts() u16 {
    // ADC has no left-aligned mode, so left-align it manually
    return AnalogToDigital.RES << 4;
}

pub fn lsb() u8 {
    //return (ADCL >> 6) + (ADCH << 2);
    return AnalogToDigital.RESL; // right aligned, not left... so should be equivalent?
}
