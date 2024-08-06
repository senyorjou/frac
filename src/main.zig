// raylib-zig (c) Nikolas Wipper 2023
const std = @import("std");
const rl = @import("raylib");

const screenWidth = 800;
const screenHeight = 600;
const max_iters = 200;

var zoom: f32 = 0.398;
var off_x: f32 = -0.117;
var off_y: f32 = 1.239;

fn pixelColor(x: usize, y: usize) rl.Color {
    const signed_x: i32 = @as(i32, @intCast(x));
    const final_x: f32 = @floatFromInt(signed_x - screenHeight);
    var zx: f32 = final_x / (zoom * screenWidth) + off_x;

    const signed_y: i32 = @as(i32, @intCast(y));
    const final_y: f32 = @floatFromInt(signed_y - screenHeight);
    var zy: f32 = final_y / (zoom * screenHeight) + off_y;

    const cx = zx;
    const cy = zy;

    var iteration: u16 = 0;
    var xtemp: f32 = undefined;

    while ((zx * zx + zy * zy) < 4 and iteration < max_iters) {
        xtemp = zx * zx - zy * zy + cx;
        zy = 2.0 * zx * zy + cy;
        zx = xtemp;
        iteration += 1;
    }

    const red: u8 = @intCast(@mod(iteration * 2, 256));
    const green: u8 = @intCast(@mod(iteration * 4, 256));
    const blue: u8 = @intCast(@mod(iteration * 8, 256));

    const color = if (iteration == max_iters) rl.Color.black else rl.Color.init(red, green, blue, 255);
    // const color = if (iteration == max_iters) rl.Color.black else rl.Color.init(@as(u8, @mod(iteration * 8, 255)), @mod(iteration * 4, 255), @mod(iteration * 2, 255), 255);
    // const color = if (iteration == max_iters) rl.Color.lime else rl.Color.black;

    if (x == 100 and y == 100) {
        std.debug.print("Zoom {}, X {}, Y {}\n", .{ zoom, off_x, off_y });
    }

    return color;
}

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------

    rl.initWindow(screenWidth, screenHeight, "Some fractal called Mandy");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var redraw: bool = true;
    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update

        if (rl.isKeyDown(rl.KeyboardKey.key_a)) {
            off_x -= 0.02;
            redraw = true;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_d)) {
            off_x += 0.02;
            redraw = true;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
            off_y -= 0.02;
            redraw = true;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) {
            off_y += 0.02;
            redraw = true;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_z)) {
            zoom *= 1.05;
            redraw = true;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_x)) {
            zoom /= 1.05;
            redraw = true;
        }
        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        if (redraw) {
            rl.clearBackground(rl.Color.white);
            for (0..screenWidth) |x_pos| {
                for (0..screenHeight) |y_pos| {
                    const color = pixelColor(x_pos, y_pos);
                    rl.drawPixel(@intCast(x_pos), @intCast(y_pos), color);
                }
            }
            redraw = false;
        }
        rl.drawText("Here's the thing", 10, 10, 20, rl.Color.light_gray);

        //----------------------------------------------------------------------------------
    }
}
