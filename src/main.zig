const std = @import("std");
const temp = @import("temp");

pub fn main() !void {
    // Memory Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Configuration
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len < 3) {
        std.debug.print("Usage: cavablocks <width> <framerate>", .{});
    }

    const width = try std.fmt.parseInt(usize, args[1], 10);
    const framerate = try std.fmt.parseInt(u16, args[2], 10);

    // Temp file
    var config = try temp.create_file(alloc, "config-*");
    defer config.deinit();

    var config_file = try config.open(.{ .mode = .write_only });

    var config_buffer: [256]u8 = undefined;
    var config_file_writer = config_file.writer(&config_buffer);
    const config_file_interface = &config_file_writer.interface;
    try config_file_interface.print(
        \\[general]
        \\framerate = {}
        \\bars = {}
        \\[output]
        \\method = raw
        \\data_format = binary
        \\bit_format = 8bit
        \\channels = mono
    , .{
        framerate,
        width,
    });
    try config_file_interface.flush();

    const config_path = try config.parent_dir.realpathAlloc(alloc, config.basename);
    defer alloc.free(config_path);

    std.debug.print("{s}", .{config_path});

    config_file.close();

    // Stdout
    var stdout_buffer: [256]u8 = undefined;
    var stdout = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout_writer = &stdout.interface;

    // Child Process Handling
    var child = std.process.Child.init(&[_][]const u8{ "cava", "-p", config_path }, alloc);
    child.stdout_behavior = .Pipe;
    child.stdin_behavior = .Ignore;
    child.stderr_behavior = .Inherit;

    try child.spawn();

    var child_reader_buffer: [4096]u8 = undefined;
    const child_output_buffer: []u8 = try alloc.alloc(u8, width);
    defer alloc.free(child_output_buffer);

    var child_stdout_reader = child.stdout.?.reader(&child_reader_buffer);
    const child_stdout_reader_interface = &child_stdout_reader.interface;

    while (true) {
        const bytes_read = child_stdout_reader_interface.readSliceShort(child_output_buffer) catch break;

        // std.debug.print("{} bytes read\n", .{bytes_read});
        _ = bytes_read;

        for (child_output_buffer) |char| {
            try stdout_writer.print("{s}", .{byte_to_block(char)});
        }
        try stdout_writer.print("\n", .{});
        try stdout_writer.flush();
    }

    _ = try child.wait();
}

/// Function to convert bytes emitted by Cava to ASCII bock chars
pub fn byte_to_block(byte: u8) *const [3:0]u8 {
    return switch (byte) {
        0...31 => "▁",
        32...63 => "▂",
        64...95 => "▃",
        96...127 => "▄",
        128...159 => "▅",
        160...191 => "▆",
        192...223 => "▇",
        224...255 => "█",
    };
}
