const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const data = @embedFile("input/day10.txt");

// from prompt
//const data =
//    \\[({(<(())[]>[[{[]{<()<>>
//    \\[(()[<>])]({[<{<<[]>>(
//    \\{([(<{}[<>[]}>{[]{[(<()>
//    \\(((({<>}<{<{<>}{[]{[]{}
//    \\[[<[([]))<([[{}[[()]]]
//    \\[{[{({}]{}}([{[{{{}}([]
//    \\{<[[]]>}<{[{[{[]{()[[[]
//    \\[<(<(<(<{}))><([]([]()
//    \\<{([([[(<>()){}]>(<<{{
//    \\<{([{{}}[<[[[<>{}]]]>[]]
//;

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var part1: usize = 0;
    var stack = ArrayList(u8).init(alloc);

    var lines = std.mem.tokenize(u8, data, "\n");
    while (lines.next()) |line| {
        for (line) |c| {
            switch (c) {
                '(', '[', '{', '<' => {
                    try stack.append(c);
                },
                else => {
                    // the break ignores mismatch in number of parens
                    const b = stack.popOrNull() orelse break;
                    switch (b) {
                        '(' => if (c != ')') {
                            part1 += score(c);
                            break;
                        },
                        '[' => if (c != ']') {
                            part1 += score(c);
                            break;
                        },
                        '{' => if (c != '}') {
                            part1 += score(c);
                            break;
                        },
                        '<' => if (c != '>') {
                            part1 += score(c);
                            break;
                        },
                        else => unreachable,
                    }
                },
            }
        }
    }

    std.log.info("part1: {}", .{part1});
}

fn score(c: u8) usize {
    return switch (c) {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
        else => unreachable,
    };
}
