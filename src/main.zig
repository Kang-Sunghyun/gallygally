const std = @import("std");
const c = @import("c.zig");

fn update(dt: f32) void {
    _ = dt;
}

fn draw() void {
    c.ClearBackground(c.DARKGRAY);
    c.DrawText("Congrats! You created your first window!", 190, 200, 20, c.RAYWHITE);
}

pub fn main() !void {
    // Enable VSync to lower CPU usage.
    c.SetConfigFlags(c.FLAG_VSYNC_HINT);
    c.InitWindow(800, 450, "gallygally");
    defer c.CloseWindow();

    while (!c.WindowShouldClose()) {
        update(c.GetFrameTime());

        c.BeginDrawing();
        draw();
        c.EndDrawing();
    }
}
