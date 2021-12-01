// previously allocated.
// This solution follows https://github.com/SpexGuy/Advent2021/blob/main/src/day01.zig,
// which uses an array as the window instead of separate vars.

const std = @import("std");
const data = @embedFile("../input/day01.txt");

pub fn main() anyerror!void {
    var part01: usize = 0;
    var part02: usize = 0;
    var count: usize = 0;
    var window = [3]i64{ 0, 0, 0 };

    var lines = std.mem.tokenize(u8, data, "\n");

    while (lines.next()) |line| {
        const x = try std.fmt.parseInt(i64, line, 10);

        // part01, compare to leading edge of window (like
        // window of 2, including the current x)
        if (count >= 1 and x > window[2]) {
            part01 += 1;
        }

        // part02, compare to trailing edge of window (like
        // window of 4, including the current x) (which is
        // like comparing the sums of two windows(3))
        if (count >= 3 and x > window[0]) {
            part02 += 1;
        }

        window[0] = window[1];
        window[1] = window[2];
        window[2] = x;

        count += 1;
    }

    std.log.info("part 01: {d}, part 02: {d}", .{ part01, part02 });
}
