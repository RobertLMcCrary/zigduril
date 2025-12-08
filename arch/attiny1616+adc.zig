const vref = @import("attiny1616+vref.zig");
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
    RES: Register16, // 0x10 (16-bit access)
    WINLT: Register16, // 0x12
    WINHT: Register16, // 0x14
    CALIB: u8, // 0x16
    _reserved3: [1]u8,
};

const VREF_ADC0REFSEL = enum(u8) {
    _0V55_gc = (0x00 << 4), //  Voltage reference at 0.55V
    _1V1_gc = (0x01 << 4), // Voltage reference at 1.1V
    _2V5_gc = (0x02 << 4), // Voltage reference at 2.5V
    _4V34_gc = (0x03 << 4), //  Voltage reference at 4.34V
    _1V5_gc = (0x04 << 4), // Voltage reference at 1.5V
};

const Register16 = union(enum) {
    value: u16,
    bytes: packed struct {
        lo: u8,
        hi: u8,
    },
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
pub const MUXPOS_GROUND_GROUP_CONFIGURATION: u8 = 0x1D; // Ground
pub const MUXPOS_TEMPERATURE_SENSOR_GROUP_CONFIGURATION: u8 = 0x1E; // Temperature Sensor

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

inline fn set_admux_therm() void {
    // put the ADC in temperature mode
    // attiny1616 datasheet section 30.3.2.6
    vref.set_adc0(VREF_ADC0REFSEL._1V1_gc); // Set Vbg ref to 1.1V
    AnalogToDigital.MUXPOS = MUXPOS_TEMPERATURE_SENSOR_GROUP_CONFIGURATION; // read temperature
    AnalogToDigital.CTRLB = SAMPNUM_ACC4_GROUP_CONFIGURATION; // 10-bit result + 4x oversampling
    AnalogToDigital.CTRLC = SAMPCAP_BITMASK | PRESC_DIV16_GROUP_CONFIGURATION | REFSEL_INTREF_GROUP_CONFIGURATION; // Internal ADC reference
}
