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
    while (true) {
        if (bingo.drawNext()) |score| {
            part01 = score;
            break;
        }
    }

    std.log.info("part01: {d}", .{part01});
}

const Board = struct {
    cells: [25]usize = .{0} ** 25,
    marked: [25]bool = .{false} ** 25,

    fn mark(self: *Board, n: usize) void {
        // check all cells, not just the first match
        for (self.cells) |cell, i| {
            if (cell == n) {
                self.marked[i] = true;
            }
        }
    }

    fn isWinner(self: Board) bool {
        return self.rowFinished() or self.colFinished();
    }

    fn rowFinished(self: Board) bool {
        var row_idx: usize = 0;
        while (row_idx < 5) : (row_idx += 1) {
            var row_res = true;
            var col_idx: usize = 0;
            while (col_idx < 5) : (col_idx += 1) {
                // switch to false if any unmarked
                row_res = row_res and self.marked[row_idx + col_idx];
            }
            if (row_res) {
                return true;
            }
        }
        return false;
    }

    fn colFinished(self: Board) bool {
        var col_idx: usize = 0;
        while (col_idx < 5) : (col_idx += 1) {
            var col_res = true;
            var row_idx: usize = 0;
            while (row_idx < 5) : (row_idx += 1) {
                // switch to false if any unmarked
                col_res = col_res and self.marked[col_idx + row_idx];
            }
            if (col_res) {
                return true;
            }
        }
        return false;
    }

    // sum of unmarked, multiplied by n
    fn score(self: Board, n: usize) usize {
        var total: usize = 0;
        for (self.cells) |cell, i| {
            if (!self.marked[i]) {
                total += cell;
            }
        }

        return total * n;
    }
};

const Boards = ArrayList(Board);
const Draws = ArrayList(usize);

const Bingo = struct {
    curr_idx: usize = 0,
    draws: Draws,
    boards: Boards,

    // winning score
    const Score = usize;

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

    fn drawNext(self: *Bingo) ?Score {
        for (self.boards.items) |*board| {
            // update from draw
            board.mark(self.draws.items[self.curr_idx]);

            // check for winner
            if (board.isWinner()) {
                return board.score(self.draws.items[self.curr_idx]);
            }
        }

        // prep for next draw
        self.curr_idx += 1;

        return null;
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
