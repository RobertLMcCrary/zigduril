const std = @import("std");

//events.h
//event types
pub const Event = union(enum) {
    button_press,
    button_release,
    button_hold: u16, //duration in ms
    button_click_count: u8, //multiple clicks
    timer_click,
    battery_low,
    temperatue_high,
};
