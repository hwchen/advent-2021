const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const data = @embedFile("../input/day04.txt");

// from prompt
//const data =
//    \\7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
//    \\
//    \\22 13 17 11  0
//    \\ 8  2 23  4 24
//    \\21  9 14 16  7
//    \\ 6 10  3 18  5
//    \\ 1 12 20 15 19
//    \\
//    \\ 3 15  0  2 22
//    \\ 9 18 13 17  5
//    \\19  8  7 25 23
//    \\20 11 10 24  4
//    \\14 21 16 12  6
//    \\
//    \\14 21 17 24  4
//    \\10 16 15  9 19
//    \\18  8 23 26 20
//    \\22 11 13  6  5
//    \\ 2  0 12  3  7
//;

// required to print if release-fast
pub const log_level: std.log.Level = .info;

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = &arena.allocator;

    var bingo = try parse_input(alloc, data);
    var part01: ?usize = null;
    var part02: ?usize = null;
    var found_first_winner = false;
    while (true) {
        switch (bingo.drawNext()) {
            .winner => |score| {
                if (found_first_winner) {
                    // if not first winner, update until last winner
                    part02 = score;
                    std.log.info("Draw: winner, part 02 updated", .{});
                } else {
                    // first time, track the first winner
                    part01 = score;
                    std.log.info("Draw: winner, part 01 updated", .{});
                }
                found_first_winner = true;
            },
            .no_winner => {
                std.log.info("Draw: no winner", .{});
                continue;
            },
            .no_more_draws => {
                std.log.info("Draw: no more draws", .{});
                break;
            },
        }
    }

    std.log.info("part01: {d}, part02: {d}", .{ part01, part02 });
}

const Board = struct {
    cells: [25]usize = .{0} ** 25,
    marked: u25 = 0,
    is_finished: bool = false,

    fn mark(self: *Board, n: usize) void {
        // check all cells, not just the first match
        for (self.cells) |cell, i| {
            if (cell == n) {
                const bit = @as(u25, 1) << @intCast(u5, i);
                self.marked |= bit;
            }
        }
    }

    fn isWinner(self: *Board) bool {
        const successes = [_]u25{
            0b1000010000100001000010000,
            0b0100001000010000100001000,
            0b0010000100001000010000100,
            0b0001000010000100001000010,
            0b0000100001000010000100001,
            0b1111100000000000000000000,
            0b0000011111000000000000000,
            0b0000000000111110000000000,
            0b0000000000000001111100000,
            0b0000000000000000000011111,
        };

        for (successes) |pattern| {
            if (pattern & self.marked == pattern) {
                return true;
            }
        }

        return false;
    }

    // sum of unmarked, multiplied by n
    fn score(self: Board, n: usize) usize {
        var total: usize = 0;
        for (self.cells) |cell, i| {
            // mask to check bit at i
            const bit = @as(u25, 1) << @intCast(u5, i);
            if (self.marked & bit == 0) {
                total += cell;
            }
        }

        return total * n;
    }
};

const Boards = ArrayList(Board);
const Draws = ArrayList(usize);

const DrawResult = union(enum) {
    winner: Score,
    no_winner,
    no_more_draws,
};
// winning score
const Score = usize;

const Bingo = struct {
    draw_idx: usize = 0,
    draws: Draws,
    boards: Boards,

    fn init(alloc: *Allocator) Bingo {
        return Bingo{
            .draws = Draws.init(alloc),
            .boards = Boards.init(alloc),
        };
    }

    fn deinit(self: Bingo) void {
        self.draws.deinit();
        self.boards.deinit();
    }

    fn drawNext(self: *Bingo) DrawResult {
        if (self.draw_idx >= self.draws.items.len) {
            return .no_more_draws;
        }
        // takes the last winning score for this round of draws
        // TODO prompt is vague, but will there be problems with
        // multiple winners in a round?
        var score: ?Score = null;

        for (self.boards.items) |*board| {
            if (board.is_finished) {
                continue;
            }

            // update from draw
            board.mark(self.draws.items[self.draw_idx]);

            // check for winner
            if (board.isWinner()) {
                score = board.score(self.draws.items[self.draw_idx]);
                // TODO: should board be removed instead?
                board.is_finished = true;
            }
        }

        // prep for next draw
        self.draw_idx += 1;

        return if (score) |s| .{ .winner = s } else .no_winner;
    }
};

fn parse_input(alloc: *Allocator, input: []const u8) !Bingo {
    var bingo = Bingo.init(alloc);

    // Split into sections, first one is draws, rest are boards.
    // Separated by one empty line.
    var sections = std.mem.split(u8, input, "\n\n");

    // parse draws
    const draws_line = sections.next().?;
    var draws = std.mem.tokenize(u8, draws_line, ",");
    while (draws.next()) |d| {
        try bingo.draws.append(try std.fmt.parseInt(usize, d, 10));
    }

    // parse bingo boards
    while (sections.next()) |section| {
        var board = Board{};

        // tokenize enter or space to go across all lines
        var cells = std.mem.tokenize(u8, section, "\n ");
        var i: usize = 0;
        while (cells.next()) |cell| {
            board.cells[i] = try std.fmt.parseInt(usize, cell, 10);
            i += 1;
        }
        try bingo.boards.append(board);
    }

    return bingo;
}
