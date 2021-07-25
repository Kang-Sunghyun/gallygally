const std = @import("std");
const zlm = @import("zlm");
const c = @import("../c.zig");

const GameState = @import("root").GameState;
const Vec2 = zlm.Vec2;

pub const Player = struct {
    lives: u32,
    pos: Vec2,
    vel: Vec2,

    const dim = Vec2.new(16.0, 16.0);
    const speed = 200;

    pub fn init() Player {
        return Player{ .lives = 3, .pos = Vec2.new(0.0, 0.0), .vel = Vec2.new(0.0, 0.0) };
    }

    pub fn draw(self: *const Player, _: *const GameState) void {
        c.DrawRectangle(@floatToInt(c_int, @round(self.pos.x)), @floatToInt(c_int, @round(self.pos.y)), dim.x, dim.y, c.VIOLET);
    }

    pub fn update(self: *Player, _: *GameState, dt: f32) void {
        const left = c.IsKeyDown(c.KEY_A);
        const right = c.IsKeyDown(c.KEY_D);
        const screen_width = @intToFloat(f32, c.GetScreenWidth());
        const screen_height = @intToFloat(f32, c.GetScreenHeight());

        self.pos.y = screen_height - dim.y - 15.0;
        if (left and !right) {
            self.vel.x = -speed;
        } else if (!left and right) {
            self.vel.x = speed;
        } else {
            self.vel.x = 0.0;
        }

        self.pos = self.pos.add(self.vel.scale(dt));
        self.pos.x = std.math.clamp(self.pos.x, 0, screen_width - dim.x);
    }
};
