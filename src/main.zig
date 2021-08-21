const std = @import("std");
usingnamespace @import("envtpl.zig");

const version = "0.2.0";

const help = 
    \\ Usage: envtpl
    \\
    \\ Templates plain text with environment variables.
    \\
    \\ Options:
    \\ -h, --help:        display this help and exit
    \\ -V, --version:     display version and exit
    \\
    \\ The `envtpl` binary expects input on STDIN and writes to STDOUT. Any
    \\ template strings of the format `${NAME}` will be replaced with the value
    \\ of the environment variable matching `NAME`.
;

pub fn main() !void {
    var args = std.process.args();

    // Ignore the binary name
    _ = args.nextPosix();

    const flag = args.nextPosix();

    if (flag) |f| {
        if (std.mem.eql(u8, f, "--help") or std.mem.eql(u8, f, "-h")) {
            std.debug.print("{s}", .{help});
            std.os.exit(0);
        } else if (std.mem.eql(u8, f, "--version") or std.mem.eql(u8, f, "-V")) {
            std.debug.print("envtpl {s}", .{version});
            std.os.exit(0);
        } else {
            std.debug.warn("Unknown flag {s}", .{f});
            std.os.exit(1);
        }
    }

    const stdin = std.io.bufferedReader(std.io.getStdIn().reader()).reader();
    var stdout = std.io.bufferedWriter(std.io.getStdOut().writer());

    var buf: [1024]u8 = undefined;

    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try envtpl(stdout.writer(), line);

        try stdout.flush();
    }
}
