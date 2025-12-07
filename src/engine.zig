const std = @import("std");
const State = @import("./states.zig");
const Event = @import("./events.zig");

pub const FSM = struct {
    current_state: State,
    previous_state: State,

    pub fn init() FSM {
        return .{
            .current_state = .off,
            .previous_state = .off,
        };
    }

    pub fn handleEvent(self: *FSM, event: Event) void {
        const new_state = self.processEvent(self.current_state, event);

        if (!statesEqual(new_state, self.current_state)) {
            self.onStateExit(self.current_state);
            self.previous_state = self.current_state;
            self.current_state = new_state;
            self.onStateEnter(self.current_state);
        }
    }

    //figuire out which state handler to call based on the current state
    fn processEvent(self: *FSM, event: Event, state: State) State {
        return switch (state) {
            .off => self.handleOffState(event),
            .steady => |level| self.handleSteadyState(level, event),
            .ramping => |ramp| self.handleRampingState(ramp, event),
            .strobe => |mode| self.handleStrobeState(mode, event),
            .config_menu => |cfg| self.handleConfigState(cfg, event),
        };
    }

    //handles events when flashlight is off
    fn handleOffState(self: *FSM, event: Event) State {
        _ = self;
        return switch (event) {
            .button_press => .{ .steady = 50 }, //turn to 50% from off on button press
            .button_hold => .{ .steady = 1 }, //hold from off = moonlight
            .button_click_count => |count| {
                if (count == 3) return .{.strobe == .standard};
                return .off;
            },
            else => .off,
        };
    }

    //handles events when flashlight is on and at a constant brightness
    fn handleSteadyState(self: *FSM, level: u8, event: Event) State {
        _ = self;
        return switch (event) {
            .button_press => .off,
            .button_hold => .{ .ramping = .{ .level = level, .direction = .up } },
            else => .{ .steady = level },
        };
    }

    //handles events when brightness is actively changing
    fn handleRampingState(self: *FSM, ramp: anytype, event: Event) State {
        _ = self;
        return switch (event) {
            .button_release => .{ .steady = ramp.level },
            .timer_tick => blk: {
                var new_level = ramp.level;
                if (ramp.direction == .up) {
                    new_level = @min(ramp.level + 1, 150);
                } else {
                    new_level = if (ramp.level > 0) ramp.level - 1 else 0;
                }
                break :blk .{ .ramping = .{ .level = new_level, .direction = ramp.direction } };
            },
            else => .{ .ramping = ramp },
        };
    }

    //handle when in strobe/flashing mode
    fn handleStrobeState(self: *FSM, mode: State.StrobeMode, event: Event) State {
        _ = self;
        return switch (event) {
            .button_press => .off,
            else => .{ .strobe = mode },
        };
    }

    //handles events when in configuration menu
    fn handleConfigState(self: *FSM, cfg: State.ConfigState, event: Event) State {
        _ = self;
        _ = event;
        return .{ .config_menu = cfg };
    }

    fn onStateEnter(self: *FSM, state: State) void {
        _ = self;
        std.debug.print("Entering state: {}\n", .{state});
    }

    fn onStateExit(self: *FSM, state: State) void {
        _ = self;
        std.debug.print("Exiting state: {}", .{state});
    }

    fn statesEqual(a: State, b: State) bool {
        return std.meta.eql(a, b);
    }
};
