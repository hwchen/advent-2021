const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;
const data = @embedFile("../input/day06.txt");

// from prompt
//const data = "3,4,3,1,2";

const PART_1_DAYS = 80;
const PART_2_DAYS = 256;

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    var fishes = [_]usize{ 0, 0, 0, 0, 0, 0, 0, 0, 0 };

    var it = std.mem.tokenize(u8, std.mem.trim(u8, data, "\r\n"), ",");
    while (it.next()) |fish| {
        fishes[try parseInt(usize, fish, 10)] += 1;
    }

    var i: usize = 0;
    while (i < PART_2_DAYS) : (i += 1) {
        if (i == PART_1_DAYS) {
            std.log.info("part01: {d}", .{count(fishes)});
        }

        shift_agg(&fishes);
    }

    std.log.info("part02: {}", .{count(fishes)});
}

fn count(fishes: [9]usize) usize {
    var res: usize = 0;
    for (fishes) |fish_count| {
        res += fish_count;
    }

    return res;
}

fn shift_agg(fishes: *[9]usize) void {
    var new_fishes = fishes[0];
    fishes[0] = fishes[1];
    fishes[1] = fishes[2];
    fishes[2] = fishes[3];
    fishes[3] = fishes[4];
    fishes[4] = fishes[5];
    fishes[5] = fishes[6];
    fishes[6] = fishes[7] + new_fishes;
    fishes[7] = fishes[8];
    fishes[8] = new_fishes;
}
