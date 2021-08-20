const std = @import("std");
const expect = std.testing.expect;

// TODO: move to separate file
const cstd = @cImport({
    @cInclude("stdlib.h");
});

pub fn main() !void {
    const stdin = std.io.bufferedReader(std.io.getStdIn().reader()).reader();
    var stdout = std.io.bufferedWriter(std.io.getStdOut().writer());

    var buf: [1024]u8 = undefined;

    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try envtpl(stdout.writer(), line);

        try stdout.flush();
    }
}

fn envtpl(writer: anytype, line: []const u8) !void {
    var closingBracePos: ?usize = null;

    for (line) |c, i| {
        switch (c) {
            '$' => {
                closingBracePos = std.mem.indexOfPos(u8, line, i + 1, "}");

                if (closingBracePos) |end| {
                    const name = line[i + 2 .. end];
                    const value = std.os.getenv(name);

                    try writer.print("{s}", .{value});
                } else {
                    try writer.print("{c}", .{c});
                }
            },
            else => {
                if (closingBracePos == null or closingBracePos orelse 0 < i) {
                    try writer.print("{c}", .{c});
                }
            },
        }
    }
}

test "envtpl basics" {
    _ = cstd.setenv("ENVTPL_TEST_USER", "Matt", 1);
    defer _ = cstd.unsetenv("ENVTPL_TEST_USER");

    _ = cstd.setenv("ENVTPL_TEST_HOME", "/users/matt", 1);
    defer _ = cstd.unsetenv("ENVTPL_TEST_HOME");

    var list = std.ArrayList(u8).init(std.testing.allocator);
    defer list.deinit();

    try envtpl(list.writer(), "Hello ${ENVTPL_TEST_USER}, you live at ${ENVTPL_TEST_HOME}!");

    try expect(std.mem.eql(u8, "Hello Matt, you live at /users/matt!", list.items));
}