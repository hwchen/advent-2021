const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;
const asc_usize = std.sort.asc(usize);

const data = @embedFile("input/day07.txt");

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const out = try run(data, alloc);

    std.log.info("part01: {d}, part02: {d}", .{ out.part01, out.part02 });
}

fn run(input: []const u8, alloc: Allocator) !struct { part01: u64, part02: u64 } {
    var crabs = blk: {
        var res = ArrayList(usize).init(alloc);

        var it = std.mem.tokenize(u8, std.mem.trim(u8, input, "\r\n"), ",");
        while (it.next()) |crab| {
            try res.append(try parseInt(usize, crab, 10));
        }
        std.sort.sort(usize, res.items, {}, asc_usize);
        break :blk try res.toOwnedSlice();
    };
    defer alloc.free(crabs);

    // initially tried avg, but it's actually median
    const median: isize = @intCast(isize, crabs[crabs.len / 2]);
    var part01: isize = 0;
    for (crabs) |crab| {
        part01 += try std.math.absInt(@intCast(isize, crab) - median);
    }

    return .{ .part01 = @intCast(u64, (part01)), .part02 = 0 };
}

test "test_day07" {
    const input = "16,1,2,0,4,2,7,1,2,14";

    const out = try run(input, std.testing.allocator);
    try std.testing.expectEqual(out.part01, 37);
    try std.testing.expectEqual(out.part02, 0);
}
