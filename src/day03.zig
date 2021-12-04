const std = @import("std");
const data = @embedFile("../input/day03.txt");
// example from prompt
//const data =
//    \\00100
//    \\11110
//    \\10110
//    \\10111
//    \\10101
//    \\01111
//    \\00111
//    \\11100
//    \\10000
//    \\11001
//    \\00010
//    \\01010
//;

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    try part01();
}

fn part01() anyerror!void {
    const num_len = comptime std.mem.indexOf(u8, data, "\n").?;

    // counts of 1's. 0's are calculated by subtracting from num_lines
    var bit_counts = [_]usize{0} ** num_len;
    var num_lines: usize = 0;

    var lines = std.mem.tokenize(u8, data, "\n");

    while (lines.next()) |line| {
        for (line) |c, i| {
            if (c == '1') {
                bit_counts[i] += 1;
            }
        }
        num_lines += 1;
    }

    // find most common bit, pack into `gamma`
    // least common bit, pack into `epsilon`
    var gamma: usize = 0;
    var epsilon: usize = 0;
    for (bit_counts) |count, i| {
        // bit place is counted from the reverse direction of i
        const bit_place = bit_counts.len - 1 - i;
        if (count >= num_lines / 2) {
            gamma += try std.math.powi(usize, 2, bit_place);
        } else {
            epsilon += try std.math.powi(usize, 2, bit_place);
        }
    }

    // how to do this with a mask?
    //const epsilon = ~gamma;

    std.log.info("part 01: {d}", .{epsilon * gamma});
}
