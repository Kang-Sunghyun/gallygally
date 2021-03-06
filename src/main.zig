const std = @import("std");
const zlm = @import("zlm");
const c = @import("c.zig");

const Allocator = std.mem.Allocator;
const Player = @import("entity/player.zig").Player;
const Laser = @import("entity/laser.zig").Laser;

pub const GameState = struct {
    player: Player,
    lasers: std.ArrayList(Laser),
    allocator: *Allocator,

    pub fn init(allocator: *Allocator) !GameState {
        var lasers = std.ArrayList(Laser).init(allocator);
        errdefer lasers.deinit();

        try lasers.append(Laser.init(.enemy, zlm.Vec2.new(50.0, 50.0)));

        return GameState{
            .player = Player.init(),
            .lasers = lasers,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: GameState) void {
        self.lasers.deinit();
    }
};

fn update(gs: *GameState, dt: f32) void {
    gs.player.update(gs, dt);

    for (gs.lasers.items) |*laser| {
        laser.update(gs, dt);
    }

    var i: usize = 0;
    while (i < gs.lasers.items.len) {
        if (gs.lasers.items[i].to_delete) {
            _ = gs.lasers.orderedRemove(i);
        } else {
            i += 1;
        }
    }
}

fn draw(gs: *const GameState) void {
    c.ClearBackground(c.DARKGRAY);
    gs.player.draw(gs);

    for (gs.lasers.items) |laser| {
        laser.draw(gs);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = &gpa.allocator;

    // Enable VSync to lower CPU usage.
    c.SetConfigFlags(c.FLAG_VSYNC_HINT);
    c.InitWindow(640, 480, "gallygally");
    defer c.CloseWindow();

    var gs = try GameState.init(allocator);
    defer gs.deinit();

    while (!c.WindowShouldClose()) {
        update(&gs, c.GetFrameTime());

        c.BeginDrawing();
        draw(&gs);
        c.EndDrawing();
    }
}
