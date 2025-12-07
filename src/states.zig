const std = @import("std");

//state types
pub const State = union(enum) {
    off,
    steady: u8, //brightness
    ramping: struct {
        level: u8,
        direction: Direction,
    },
    strobe: StrobeMode,
    config_menu: ConfigState,

    pub const Direction = enum { up, down };
    pub const StrobeMode = enum { standard, tactical, beacon };
    pub const ConfigState = enum {
        //config menu state
    };
};
