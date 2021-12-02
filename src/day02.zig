const std = @import("std");
const data = @embedFile("../input/day02.txt");

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    var part01_horiz: i64 = 0;
    var part01_vert: i64 = 0;
    var part02_horiz: i64 = 0;
    var part02_vert: i64 = 0;
    var part02_aim: i64 = 0;
    var lines = std.mem.tokenize(u8, data, "\n");

    while (lines.next()) |line| {
        var cols = std.mem.split(u8, line, " ");
        const direction = cols.next().?;
        const x = try std.fmt.parseInt(i64, cols.next().?, 10);

        if (std.mem.eql(u8, "forward", direction)) {
            part01_horiz += x;
            part02_horiz += x;
            part02_vert += x * part02_aim;
        } else if (std.mem.eql(u8, "up", direction)) {
            part01_vert -= x;
            part02_aim -= x;
        } else if (std.mem.eql(u8, "down", direction)) {
            part01_vert += x;
            part02_aim += x;
        } else {
            return error.UnsupportedDirection;
        }
    }

    std.log.info("part 01: {d}, part 02: {d}", .{ part01_horiz * part01_vert, part02_horiz * part02_vert });
}
