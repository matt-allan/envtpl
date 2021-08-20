const std = @import("std");
const expect = std.testing.expect;
const cstd = @cImport({
    @cInclude("stdlib.h");
});

pub fn envtpl(writer: anytype, line: []const u8) !void {
    var openingBracePos: ?usize = null;
    var closingBracePos: ?usize = null;

    for (line) |c, i| {
        switch (c) {
            '$' => blk: {
                openingBracePos = std.mem.indexOfPos(u8, line, i + 1, "{");
                // offset by opening brace, closing brace, and at least one char
                closingBracePos = std.mem.indexOfPos(u8, line, i + 3, "}");

                // If there aren't braces, it's just something that starts with $
                if (openingBracePos == null or closingBracePos == null) {
                    try writer.print("{c}", .{c});
                    break :blk;
                }

                const name = line[i + 2 .. closingBracePos.?];
                const value = std.os.getenv(name);

                if (value) |v| {
                    try writer.print("{s}", .{value});
                }
            },
            else => {
                // Only print the actual contents if we aren't inside a template string
                if (openingBracePos == null or closingBracePos == null or closingBracePos.? < i) {
                    try writer.print("{c}", .{c});
                }
            },
        }
    }
}

test "envtpl with variables" {
    _ = cstd.setenv("ENVTPL_TEST_USER", "Matt", 1);
    defer _ = cstd.unsetenv("ENVTPL_TEST_USER");

    _ = cstd.setenv("ENVTPL_TEST_HOME", "/users/matt", 1);
    defer _ = cstd.unsetenv("ENVTPL_TEST_HOME");

    var list = std.ArrayList(u8).init(std.testing.allocator);
    defer list.deinit();

    try envtpl(list.writer(), "Hello ${ENVTPL_TEST_USER}, you live at ${ENVTPL_TEST_HOME}!");

    try expect(std.mem.eql(u8, "Hello Matt, you live at /users/matt!", list.items));
}

test "envtpl without curly braces" {
    var list = std.ArrayList(u8).init(std.testing.allocator);
    defer list.deinit();

    try envtpl(list.writer(), "Hello $USER!");

    try expect(std.mem.eql(u8, "Hello $USER!", list.items));
}

test "envtpl without opening curly brace" {
    var list = std.ArrayList(u8).init(std.testing.allocator);
    defer list.deinit();

    try envtpl(list.writer(), "Hello $USER}!");

    try expect(std.mem.eql(u8, "Hello $USER}!", list.items));
}

test "envtpl without closing curly brace" {
    var list = std.ArrayList(u8).init(std.testing.allocator);
    defer list.deinit();

    try envtpl(list.writer(), "Hello ${USER!");

    try expect(std.mem.eql(u8, "Hello ${USER!", list.items));
}

test "envtpl with empty braces" {
    var list = std.ArrayList(u8).init(std.testing.allocator);
    defer list.deinit();

    try envtpl(list.writer(), "Hello ${}!");

    try expect(std.mem.eql(u8, "Hello ${}!", list.items));
}

test "envtpl with subsequent variables" {
    _ = cstd.setenv("ENVTPL_TEST_HOME_DIR", "/users/", 1);
    defer _ = cstd.unsetenv("ENVTPL_TEST_HOME_DIR");

    _ = cstd.setenv("ENVTPL_TEST_USER", "matt", 1);
    defer _ = cstd.unsetenv("ENVTPL_TEST_USER");

    var list = std.ArrayList(u8).init(std.testing.allocator);
    defer list.deinit();

    try envtpl(list.writer(), "The home directory is ${ENVTPL_TEST_HOME_DIR}${ENVTPL_TEST_USER}");

    try expect(std.mem.eql(u8, "The home directory is /users/matt", list.items));
}

test "envtpl with unset var" {
    _ = cstd.unsetenv("ENVTPL_TEST_USER");

    var list = std.ArrayList(u8).init(std.testing.allocator);
    defer list.deinit();

    try envtpl(list.writer(), "Hello ${ENVTPL_TEST_USER}!");

    try expect(std.mem.eql(u8, "Hello !", list.items));
}