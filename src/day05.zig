const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;
const PointSet = std.AutoHashMap(Point, void);
const data = @embedFile("../input/day05.txt");

// from prompt
//const data =
//    \\0,9 -> 5,9
//    \\8,0 -> 0,8
//    \\9,4 -> 3,4
//    \\2,2 -> 2,1
//    \\7,0 -> 7,4
//    \\6,4 -> 2,0
//    \\0,9 -> 2,9
//    \\3,4 -> 1,4
//    \\0,0 -> 8,8
//    \\5,5 -> 8,2
//;

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var lines = ArrayList(Line).init(alloc);

    var rows = std.mem.tokenize(u8, data, "\n");
    while (rows.next()) |row| {
        const line = try parseLine(row);
        // for part 1, only use horizontal and vertical lines
        if (is_hv(line)) {
            try lines.append(line);
        }
    }

    var overlaps = PointSet.init(alloc);

    var i: usize = 0;
    while (i < lines.items.len) : (i += 1) {
        var j: usize = i + 1;
        while (j < lines.items.len) : (j += 1) {
            try update_overlaps(lines.items[i], lines.items[j], &overlaps);
        }
    }

    std.log.info("part1: {}", .{overlaps.count()});
}

const Line = struct {
    point1: Point,
    point2: Point,

    fn min_x(self: Line) usize {
        return std.math.min(self.point1.x, self.point2.x);
    }

    fn max_x(self: Line) usize {
        return std.math.max(self.point1.x, self.point2.x);
    }

    fn min_y(self: Line) usize {
        return std.math.min(self.point1.y, self.point2.y);
    }

    fn max_y(self: Line) usize {
        return std.math.max(self.point1.y, self.point2.y);
    }
};

const Point = struct {
    x: usize,
    y: usize,
};

fn update_overlaps(line1: Line, line2: Line, overlaps: *PointSet) !void {
    // check where x ranges overlap
    // check where y ranges overlap
    const x_overlap = [2]usize{ std.math.max(line1.min_x(), line2.min_x()), std.math.min(line1.max_x(), line2.max_x()) };
    const y_overlap = [2]usize{ std.math.max(line1.min_y(), line2.min_y()), std.math.min(line1.max_y(), line2.max_y()) };

    // generate points
    var x: usize = x_overlap[0];
    while (x <= x_overlap[1]) : (x += 1) {
        var y: usize = y_overlap[0];
        while (y <= y_overlap[1]) : (y += 1) {
            try overlaps.put(Point{
                .x = x,
                .y = y,
            }, {});
        }
    }
}

// horizontal or vertical lines
fn is_hv(line: Line) bool {
    return line.point1.x == line.point2.x or line.point1.y == line.point2.y;
}

fn parseLine(row: []const u8) !Line {
    // parse a row into a Line
    var points = std.mem.split(u8, row, " -> ");
    const point1 = points.next().?;
    const point2 = points.next().?;

    var point1_xy = std.mem.split(u8, point1, ",");
    var point2_xy = std.mem.split(u8, point2, ",");

    return Line{
        .point1 = Point{
            .x = try parseInt(usize, point1_xy.next().?, 10),
            .y = try parseInt(usize, point1_xy.next().?, 10),
        },
        .point2 = Point{
            .x = try parseInt(usize, point2_xy.next().?, 10),
            .y = try parseInt(usize, point2_xy.next().?, 10),
        },
    };
}
