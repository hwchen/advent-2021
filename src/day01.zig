const std = @import("std");
const data = @embedFile("../input/day01.txt");

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    var input = std.ArrayList(i64).init(allocator);
    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        const x = try std.fmt.parseInt(i64, line, 10);
        try input.append(x);
    }
    const part01_output = part01(input.items);
    const part02_output = part02(input.items);

    std.log.info("part 01: {d}", .{part01_output});
    std.log.info("part 02: {d}", .{part02_output});
}

fn part01(input: []const i64) usize {
    var increased: usize = 0;

    // window of 2
    var i: usize = 1;
    while (i < input.len) : (i += 1) {
        if (input[i] > input[i - 1]) {
            increased += 1;
        }
    }

    return increased;
}

fn part02(input: []const i64) usize {
    var increased: usize = 0;
    var prev_window_sum: i64 = 0;

    // window of 3
    var i: usize = 2;
    while (i < input.len) : (i += 1) {
        const sum = input[i] + input[i - 1] + input[i - 2];
        if (sum > prev_window_sum) {
            increased += 1;
        }
        prev_window_sum = sum;
    }

    // subtract 1 because first comparison is always an increase
    increased -= 1;

    return increased;
}
