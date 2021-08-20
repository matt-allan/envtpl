const std = @import("std");
usingnamespace @import("envtpl.zig");

pub fn main() !void {
    const stdin = std.io.bufferedReader(std.io.getStdIn().reader()).reader();
    var stdout = std.io.bufferedWriter(std.io.getStdOut().writer());

    var buf: [1024]u8 = undefined;

    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try envtpl(stdout.writer(), line);

        try stdout.flush();
    }
}
