const std = @import("std");
const lib = @import("cavablocks_zig");

pub fn main() !void {
    // Memory Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Configuration
    const width: usize = 20;
    // const framerate = 60;
    const config_path = "config";

    // Stdout

    // Child Process Handling
    var child = std.process.Child.init(&[_][]const u8{ "cava", "-p", config_path }, alloc);
    child.stdout_behavior = .Pipe;
    child.stdin_behavior = .Ignore;
    child.stderr_behavior = .Inherit;

    try child.spawn();

    var child_reader_buffer: [4096]u8 = undefined;
    var child_output_buffer: [width]u8 = undefined;

    var child_stdout_reader = child.stdout.?.reader(&child_reader_buffer);
    const child_stdout_reader_interface = &child_stdout_reader.interface;

    while (true) {
        const bytes_read = child_stdout_reader_interface.readSliceShort(&child_output_buffer) catch break;

        std.debug.print("{} bytes read\n", .{bytes_read});
    }

    _ = try child.wait();
}
