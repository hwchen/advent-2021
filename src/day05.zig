const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const PointCount = std.AutoHashMap(Point, u64);
const data = @embedFile("input/day05.txt");

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const out = try run(data, alloc);

    std.log.info("part01: {d}, part02: {d}", .{ out.part01, out.part02 });
}

fn run(input: []const u8, alloc: Allocator) !struct { part01: u64, part02: u64 } {
    var pointcount01 = PointCount.init(alloc);
    var pointcount02 = PointCount.init(alloc);
    defer pointcount01.deinit();
    defer pointcount02.deinit();

    var rows = std.mem.tokenize(u8, input, "\n");
    while (rows.next()) |row| {
        const line = try parseLine(row);
        // part01, only use horizontal and vertical lines
        if (isHv(line)) {
            try addLineToPointCount(line, &pointcount01);
        }
        try addLineToPointCount(line, &pointcount02);
    }

    var part01: u64 = 0;
    var part01_it = pointcount01.valueIterator();
    while (part01_it.next()) |count| {
        if (count.* >= 2) {
            part01 += 1;
        }
    }

    var part02: u64 = 0;
    var part02_it = pointcount02.valueIterator();
    while (part02_it.next()) |count| {
        if (count.* >= 2) {
            part02 += 1;
        }
    }

    return .{ .part01 = part01, .part02 = part02 };
}

fn addLineToPointCount(line: Line, pointcount: *PointCount) !void {
    // if horiz or vertical, then the x or y does not advance
    // diagonals are only 45 degree, where both x and y advance one

    const point1 = line.point1;
    const point2 = line.point2;

    if (point1.x == point2.x) {
        // vertical line
        var end: u32 = std.math.max(point1.y, point2.y);
        var idx: u32 = std.math.min(point1.y, point2.y);
        while (idx <= end) : (idx += 1) {
            try updatePointCount(Point{ .x = point1.x, .y = idx }, pointcount);
        }
    } else if (point1.y == point2.y) {
        // vertical line
        var end: u32 = std.math.max(point1.x, point2.x);
        var idx: u32 = std.math.min(point1.x, point2.x);
        while (idx <= end) : (idx += 1) {
            try updatePointCount(Point{ .x = idx, .y = point1.y }, pointcount);
        }
    } else {
        // diagonal
        var x = point1.x;
        var y = point1.y;

        while (x != point2.x and y != point2.y) {
            try updatePointCount(Point{ .x = x, .y = y }, pointcount);
            // step towards point2
            if (x < point2.x) x += 1 else x -= 1;
            if (y < point2.y) y += 1 else y -= 1;
        }

        // add last point
        try updatePointCount(point2, pointcount);
    }
}

fn updatePointCount(point: Point, pointcount: *PointCount) !void {
    const entry = try pointcount.getOrPut(point);
    if (entry.found_existing) {
        entry.value_ptr.* += 1;
    } else {
        entry.value_ptr.* = 1;
    }
}

const Line = struct {
    point1: Point,
    point2: Point,
};

const Point = struct {
    x: u32,
    y: u32,
};

// horizontal or vertical lines
fn isHv(line: Line) bool {
    return line.point1.x == line.point2.x or line.point1.y == line.point2.y;
}

fn parseLine(row: []const u8) !Line {
    // parse a row into a Line
    var row_it = std.mem.tokenize(u8, row, " ->,");

    return Line{
        .point1 = Point{
            .x = try std.fmt.parseInt(u32, row_it.next().?, 10),
            .y = try std.fmt.parseInt(u32, row_it.next().?, 10),
        },
        .point2 = Point{
            .x = try std.fmt.parseInt(u32, row_it.next().?, 10),
            .y = try std.fmt.parseInt(u32, row_it.next().?, 10),
        },
    };
}

test "test_day05" {
    const input =
        \\0,9 -> 5,9
        \\8,0 -> 0,8
        \\9,4 -> 3,4
        \\2,2 -> 2,1
        \\7,0 -> 7,4
        \\6,4 -> 2,0
        \\0,9 -> 2,9
        \\3,4 -> 1,4
        \\0,0 -> 8,8
        \\5,5 -> 8,2
    ;
    const out = try run(input, std.testing.allocator);
    try std.testing.expectEqual(out.part01, 5);
    try std.testing.expectEqual(out.part02, 12);
}
