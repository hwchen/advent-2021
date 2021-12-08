const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;
const data = @embedFile("../input/day06.txt");

// from prompt
//const data = "3,4,3,1,2";

const DAYS = 80;

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = &arena.allocator;

    var fishes = ArrayList(u4).init(alloc);

    var it = std.mem.tokenize(u8, std.mem.trim(u8, data, "\r\n"), ",");
    while (it.next()) |fish| {
        std.debug.print("{c}", .{fish});
        try fishes.append(try parseInt(u4, fish, 10));
    }

    // part01
    var i: usize = 0;
    while (i < DAYS) : (i += 1) {
        var new_fishes: usize = 0;
        for (fishes.items) |*fish| {
            switch (fish.*) {
                0 => {
                    fish.* = 6;
                    new_fishes += 1;
                },
                1...8 => fish.* -= 1,
                else => unreachable,
            }
        }

        // append new fishes
        var j: usize = 0;
        while (j < new_fishes) : (j += 1) {
            try fishes.append(8);
        }
    }

    std.log.info("part01: {}", .{fishes.items.len});
}
