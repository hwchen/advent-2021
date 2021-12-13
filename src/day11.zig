const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const PART_1_STEP_LIMIT = 100;
const data = @embedFile("../input/day11.txt");

// from prompt
//const data =
//    \\5483143223
//    \\2745854711
//    \\5264556173
//    \\6141336146
//    \\6357385478
//    \\4167524645
//    \\2176841721
//    \\6882881134
//    \\4846848554
//    \\5283751526
//;

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = &arena.allocator;

    // grid with borders
    var grid: [12][12]u4 = undefined;

    var part1: usize = 0;

    var lines = std.mem.tokenize(u8, data, "\n");

    // load grid from input
    {
        var i: usize = 1;
        while (lines.next()) |line| {
            for (line) |c, j| {
                grid[i][j + 1] = @intCast(u4, c - 48);
            }
            i += 1;
        }
    }
    std.debug.print("{any}\n", .{grid});

    // iterate a generation, then count flashes
    {
        var step: usize = 0;
        while (step < PART_1_STEP_LIMIT) : (step += 1) {
            var stack = ArrayList(Point).init(alloc);
            // first scan
            try initialScan(&grid, &stack);

            // then floodfill
            try floodFill(&grid, &stack);

            // then score
            part1 += score(grid);

            std.debug.print("{any}\n", .{grid});
        }
    }

    std.log.info("part1: {}", .{part1});
}

// grid has one cell border
fn initialScan(grid: *[12][12]u4, stack: *ArrayList(Point)) !void {
    var i: usize = 1;
    while (i <= 10) : (i += 1) {
        var j: usize = 1;
        while (j <= 10) : (j += 1) {
            grid[i][j] = @mod(grid[i][j] + 1, 10);
            if (grid[i][j] == 0) {
                try stack.append(Point{ .i = i, .j = j });
            }
        }
    }
}

// dfs
// grid has one cell border
// don't update cells that are at 0 (they're in flash mode until next step)
fn floodFill(grid: *[12][12]u4, stack: *ArrayList(Point)) !void {
    while (stack.popOrNull()) |point| {
        const i = point.i;
        const j = point.j;

        var k: isize = -1;

        while (k <= 1) : (k += 1) {
            var m: isize = -1;
            while (m <= 1) : (m += 1) {
                // skip the middle
                if (k == 0 and m == 0) continue;

                const row_idx = @intCast(isize, i) + k;
                const col_idx = @intCast(isize, j) + m;

                //skip border cells
                if (row_idx == 0 or row_idx == 11 or col_idx == 0 or col_idx == 11) continue;

                var cell = &grid[@intCast(usize, row_idx)][@intCast(usize, col_idx)];

                // check before update; if it's already zero, then continue;
                if (cell.* == 0) continue;

                // now update and count.
                cell.* = @mod(cell.* + 1, 10);
                if (cell.* == 0) {
                    try stack.append(Point{ .i = @intCast(usize, row_idx), .j = @intCast(usize, col_idx) });
                }
            }
        }
    }
}

// grid has one cell border
fn score(grid: [12][12]u4) usize {
    var res: usize = 0;
    var i: usize = 1;
    while (i <= 10) : (i += 1) {
        var j: usize = 1;
        while (j <= 10) : (j += 1) {
            if (grid[i][j] == 0) {
                res += 1;
            }
        }
    }

    return res;
}

const Point = struct {
    i: usize,
    j: usize,
};
