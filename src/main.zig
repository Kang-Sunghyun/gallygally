const std = @import("std");
const zlm = @import("zlm");
const c = @import("c.zig");

const Allocator = std.mem.Allocator;
const Player = @import("entities/player.zig").Player;

pub const GameState = struct {
    player: Player,
    allocator: *Allocator,
    
    pub fn init(allocator: *Allocator) GameState {
        return GameState{
            .player = Player.init(),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: GameState) void {
        _ = self;
    }
};

fn update(gs: *GameState, dt: f32) void {
    gs.player.update(gs, dt);
}

fn draw(gs: *const GameState) void {
    c.ClearBackground(c.DARKGRAY);
    gs.player.draw(gs);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = &gpa.allocator;

    // Enable VSync to lower CPU usage.
    c.SetConfigFlags(c.FLAG_VSYNC_HINT);
    c.InitWindow(640, 480, "gallygally");
    defer c.CloseWindow();

    var gs = GameState.init(allocator);
    defer gs.deinit();

    while (!c.WindowShouldClose()) {
        update(&gs, c.GetFrameTime());

        c.BeginDrawing();
        draw(&gs);
        c.EndDrawing();
    }
}
