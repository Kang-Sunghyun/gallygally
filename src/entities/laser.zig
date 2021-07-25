const std = @import("std");
const zlm = @import("zlm");
const c = @import("../c.zig");

const GameState = @import("root").GameState;
const Vec2 = zlm.Vec2;

pub const Laser = struct {
    pos: Vec2,
    vel: Vec2,
    kind: Kind,
    to_delete: bool,

    pub const Kind = enum {
        enemy,
        player,
    };

    const dim = Vec2.new(4, 25);
    const speed = 300.0;

    pub fn init(kind: Kind) Laser {
        return Laser{
            .pos = Vec2.new(50.0, 50.0),
            .vel = Vec2.new(0.0, if (kind == .enemy) speed else -speed),
            .kind = kind,
            .to_delete = false,
        };
    }

    pub fn update(self: *Laser, _: *GameState, dt: f32) void {
        const screen_height = @intToFloat(f32, c.GetScreenHeight());

        self.pos = self.pos.add(self.vel.scale(dt));

        if (self.pos.y < 0 or self.pos.y > screen_height) {
            self.to_delete = true;
        }
    }

    pub fn draw(self: Laser, _: *const GameState) void {
        c.DrawRectangle(
            @floatToInt(c_int, @round(self.pos.x)),
            @floatToInt(c_int, @round(self.pos.y)),
            dim.x,
            dim.y,
            c.RED,
        );
    }
};
