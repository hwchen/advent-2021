const std = @import("std");
const data = @embedFile("input/day09.txt");

// from prompt
//const data =
//    \\2199943210
//    \\3987894921
//    \\9856789892
//    \\8767896789
//    \\9899965678
//;

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    const row_len = comptime std.mem.indexOf(u8, data, "\n").?;
    var row_prev = [_]u4{10} ** row_len;
    var row_curr = [_]u4{10} ** row_len;
    var row_prev_low = [_]bool{false} ** row_len;
    var row_curr_low = [_]bool{false} ** row_len;

    var part1: usize = 0;

    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        // bump rows
        row_prev = row_curr;
        row_prev_low = row_curr_low;

        // fill row1 from input
        for (line) |c, i| {
            row_curr[i] = @intCast(u4, c - 48);
        }
        row_curr_low = [_]bool{false} ** row_len;

        // For prev row, if those lows are still low comparing w/ curr,
        // then they should be counted.
        {
            var i: usize = 0;
            while (i < row_len) : (i += 1) {
                if (row_prev[i] < row_curr[i]) {
                    if (row_prev_low[i]) {
                        part1 += 1 + row_prev[i];
                    }
                } else {
                    // since row_curr is lower, then we should check if
                    // adjacent cells are lower. If it's lowest point so
                    // far, can set row_curr_low to true.

                    if (isLowerThanSides(i, &row_curr)) {
                        row_curr_low[i] = true;
                    }
                }
            }
        }
    }

    // Finishing step, comparison for last row
    {
        row_prev = row_curr;
        row_prev_low = row_curr_low;
        row_curr = [_]u4{10} ** row_len;
        var i: usize = 0;
        while (i < row_len) : (i += 1) {
            if (row_prev[i] < row_curr[i] and row_prev_low[i]) {
                part1 += 1 + row_prev[i];
            }
        }
    }

    std.log.info("part1: {}", .{part1});
}

fn isLowerThanSides(i: usize, row: []u4) bool {
    const left = if (i == 0) 10 else row[i - 1];
    const right = if (i >= row.len - 1) 10 else row[i + 1];
    return row[i] < left and row[i] < right;
}
