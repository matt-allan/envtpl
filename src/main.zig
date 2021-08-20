const std = @import("std");

pub fn main() !void {
    const stdin = std.io.bufferedReader(std.io.getStdIn().reader()).reader();
    var stdout = std.io.bufferedWriter(std.io.getStdOut().writer());

    var buf: [1024]u8 = undefined;

    var closingBracePos: ?usize = null;

    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line) |c, i| {
            switch (c) {
                '$' => {
                    closingBracePos = std.mem.indexOfPos(u8, line, i + 1, "}");

                    if (closingBracePos) |end| {
                        const name = line[i + 2 .. end];
                        const value = std.os.getenv(name);

                        try stdout.writer().print("{s}", .{value});
                    } else {
                        try stdout.writer().print("{c}", .{c});
                    }
                },
                else => {
                    if (closingBracePos == null or closingBracePos orelse 0 < i) {
                        try stdout.writer().print("{c}", .{c});
                    }
                },
            }
        }

        try stdout.flush();
    }
}
