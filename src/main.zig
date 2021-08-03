const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stdin = std.io.bufferedReader(std.io.getStdIn().reader()).reader();
    var stdout = std.io.bufferedWriter(std.io.getStdOut().writer());

    var buf: [1024]u8 = undefined;

    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var iter = env_map.iterator();

        var replaced = line;

        while (iter.next()) |entry| {
            const key = entry.key_ptr.*;
            const value = entry.value_ptr.*;

            var tplKey = try std.fmt.allocPrint(allocator, "${{{s}}}", .{key});

            const outputSize = std.mem.replacementSize(u8, replaced, tplKey, value);

            var output = try allocator.alloc(u8, outputSize);

            var replacements = std.mem.replace(u8, replaced, tplKey, value, output[0..]);

            replaced = output;
        }

        try stdout.writer().print("{s}\n", .{replaced});
    }

    try stdout.flush();
}
