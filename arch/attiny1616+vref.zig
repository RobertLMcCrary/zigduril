// The VREF peripheral provides programmable voltage references for ADC, DAC, and AC.
// References are selected via VREF.CTRLA register (and CTRLC, CTRLD for other channels).
//
// VREF.CTRLA Register Layout (8 bits):
// Bit:  7  6  5  4  3  2  1  0
//          ADC0REFSEL | DAC0REFSEL
//          (bits 6:4) | (bits 2:0)
//
// DAC0REFSEL (bits 2:0): Selects reference voltage for DAC0 and AC0
// These values are written to bits 2:0 of VREF.CTRLA
//
// The OR operation in mcu_set_dac_vref() preserves the ADC0REFSEL bits (6:4)
// while updating only the DAC0REFSEL bits (2:0):
//   VREF.CTRLA = new_dac_vref | (VREF.CTRLA & ~0b00000111)
//                    ^                            ^
//                    |                            mask clears bits 2:0
//                    new DAC ref value            keeps bits 7:3 unchanged

// DAC controls
pub var DAC_LVL: u8 = undefined; // Maps to DAC0.DATA
pub var DAC_VREF: u8 = undefined; // Maps to VREF.CTRLA

// VREF constants (DAC reference voltage selection) from VREF.CTRLA register
pub const V055: u8 = 0x0; // VREF_DAC0REFSEL_0V55_gc - bits 2:0 = 0x0
pub const V05: u8 = V055; // Alias for 0.55V
pub const V11: u8 = 0x1; // VREF_DAC0REFSEL_1V1_gc  - bits 2:0 = 0x1
pub const V25: u8 = 0x2; // VREF_DAC0REFSEL_2V5_gc  - bits 2:0 = 0x2
pub const V43: u8 = 0x3; // VREF_DAC0REFSEL_4V34_gc - bits 2:0 = 0x3
pub const V15: u8 = 0x4; // VREF_DAC0REFSEL_1V5_gc  - bits 2:0 = 0x4

// DAC Vref setting function
pub fn mcu_set_dac_vref(x: u8) void {}

// ADC Vref setting function
pub fn mcu_set_adc0_vref(x: u8) void {}
