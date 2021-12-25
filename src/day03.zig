const std = @import("std");
const Allocator = std.mem.Allocator;
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
    try part02();
}

fn part01() !void {
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
    for (bit_counts) |count, i| {
        // bit place is counted from the reverse direction of i.
        // TODO this is confusing and should be fixed in a cleanup pass
        const bit = @as(usize, 1) << @intCast(u6, bit_counts.len - 1 - i);

        if (count >= num_lines / 2) {
            // using `or` is like adding.
            gamma |= bit;
        }
    }

    // mask to set least significant bits. shift left and subtract 1
    const mask: usize = (@as(usize, 1) << @intCast(u6, bit_counts.len)) - 1;
    const epsilon = ~gamma & mask;

    std.log.info("part 01: {d}", .{epsilon * gamma});
}

fn part02() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const num_len = comptime std.mem.indexOf(u8, data, "\n").?;

    var input = blk: {
        var buf = std.ArrayList(usize).init(alloc);

        // Convert str(binary) to usize
        var lines = std.mem.tokenize(u8, data, "\n");
        while (lines.next()) |line| {
            const x = try std.fmt.parseInt(usize, line, 2);
            try buf.append(x);
        }

        break :blk buf.toOwnedSlice();
    };
    // this is actually a no-op w/ arena
    defer alloc.free(input);

    // find oxygen rating by filtering
    // bits are counted from left to right here
    std.log.info("filter for oxygen, most common bit", .{});
    const oxygen = try filter_with(alloc, input, num_len, most_common);

    // find CO2 rating by filtering
    // bits are counted from left to right here
    std.log.info("filter for c02, least common bit", .{});
    const co2 = try filter_with(alloc, input, num_len, least_common);

    std.log.info("part 02: {d}", .{oxygen * co2});
}

fn filter_with(alloc: Allocator, input: []const usize, num_len: usize, f: fn (count: usize, buf_len: usize) bool) !usize {
    var buf = std.ArrayList(usize).init(alloc);
    try buf.appendSlice(input);

    var i: usize = 0;
    while (true) {
        var buf_filtered = std.ArrayList(usize).init(alloc);
        const bit = @as(usize, 1) << @intCast(u6, num_len - 1 - i);

        // first count at bit i
        var count: usize = 0;
        for (buf.items) |x| {
            if (x & bit != 0) {
                count += 1;
            }
        }

        // select_bit is 0 or 1. Depending on fn f, it's selected by
        // either least_common or most_common.
        const select_bit = @boolToInt(f(count, buf.items.len));
        std.debug.print("select_bit: {d}, position (1-idx): {d}\n", .{ select_bit, i + 1 });

        // Now filter for least common value at bit position
        for (buf.items) |x| {
            // mask for bit position, then shift it all the way to right
            // so it can be checked easily against least as 1 or 0.
            if ((x & bit) >> @intCast(u6, num_len - 1 - i) == select_bit) {
                try buf_filtered.append(x);
            }
        }

        // set buf to the filtered buf
        buf.deinit();
        buf = buf_filtered;
        for (buf.items) |x| {
            std.debug.print("{b:0>5}\n", .{x});
        }
        std.debug.print("\n", .{});

        if (buf.items.len == 1) {
            break;
        }

        i += 1;
    }
    return buf.items[0];
}

fn least_common(count: usize, buf_len: usize) bool {
    return count < buf_len - count;
}

fn most_common(count: usize, buf_len: usize) bool {
    return count >= buf_len - count;
}
