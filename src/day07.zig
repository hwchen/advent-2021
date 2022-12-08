const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;
const asc_usize = std.sort.asc(usize);

const data = @embedFile("input/day07.txt");

// from prompt
//const data = "16,1,2,0,4,2,7,1,2,14";

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var crabs = blk: {
        var res = ArrayList(usize).init(alloc);

        var it = std.mem.tokenize(u8, std.mem.trim(u8, data, "\r\n"), ",");
        while (it.next()) |crab| {
            try res.append(try parseInt(usize, crab, 10));
        }
        std.sort.sort(usize, res.items, {}, asc_usize);
        break :blk try res.toOwnedSlice();
    };

    // initially tried avg, but it's actually median
    const median: isize = @intCast(isize, crabs[crabs.len / 2]);
    var part1: isize = 0;
    for (crabs) |crab| {
        part1 += try std.math.absInt(@intCast(isize, crab) - median);
    }

    std.log.info("part1: {}", .{part1});
}
