const std = @import("std");

fn parse(alloc: std.mem.Allocator, input: []const u8, pad: usize) !struct {
    std.ArrayListUnmanaged(u8),
    usize,
    usize,
} {
    var characters: std.ArrayListUnmanaged(u8) = .empty;
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    const width = it.peek().?.len;
    for (0..pad) |_|
        try characters.appendNTimes(alloc, '.', pad + width + pad);
    var height: usize = 0;
    while (it.next()) |line| : (height += 1) {
        try characters.appendNTimes(alloc, '.', pad);
        try characters.appendSlice(alloc, line);
        try characters.appendNTimes(alloc, '.', pad);
    }
    for (0..pad) |_|
        try characters.appendNTimes(alloc, '.', pad + width + pad);
    return .{ characters, pad + width + pad, pad + height + pad };
}

pub fn countX(characters: []const u8, w: usize, _: usize, i: usize) usize {
    std.debug.assert(characters[i] == 'X');

    var total: usize = 0;
    inline for ([_]usize{ std.math.maxInt(usize), 0, 1 }) |dx| {
        inline for ([_]usize{ std.math.maxInt(usize), 0, 1 }) |dy| {
            if (dx != 0 or dy != 0) {
                inline for ("MAS", 1..) |c, m| {
                    if (characters[i +% m *% dx +% m *% dy *% w] != c)
                        break;
                } else {
                    total += 1;
                }
            }
        }
    }
    return total;
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !usize {
    const pad = 3;

    var characters, const width, const height = try parse(alloc, input, pad);
    defer characters.deinit(alloc);

    var total: usize = 0;
    for (characters.items, 0..) |c, i| if (c == 'X') {
        total += countX(characters.items, width, height, i);
    };
    return total;
}

pub fn countA(characters: []const u8, w: usize, _: usize, i: usize) usize {
    var total: usize = 0;

    std.debug.assert(characters[i] == 'A');

    inline for ([_]usize{ std.math.maxInt(usize), 1 }) |dx| {
        inline for ([_]usize{ std.math.maxInt(usize), 1 }) |dy| {
            if (characters[i +% dx +% dy *% w] == 'M' and characters[i -% dx -% dy *% w] == 'S') {
                total += 1;
            }
        }
    }

    if (total == 2)
        return 1
    else
        return 0;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !usize {
    const pad = 1;

    var characters, const width, const height = try parse(alloc, input, pad);
    defer characters.deinit(alloc);

    var total: usize = 0;
    for (characters.items, 0..) |c, i| if (c == 'A') {
        total += countA(characters.items, width, height, i);
    };

    return total;
}

const example =
    \\MMMSXXMASM
    \\MSAMXMSMSA
    \\AMXSXMAAMM
    \\MSAMASMSMX
    \\XMASAMXAMM
    \\XXAMMXXAMA
    \\SMSMSASXSS
    \\SAXAMASAAA
    \\MAMMMXMMMM
    \\MXMXAXMASX
;

test "part 1" {
    try std.testing.expectEqual(
        @as(usize, 18),
        try part1(std.testing.allocator, example),
    );
    try std.testing.expectEqual(
        @as(usize, 2569),
        try part1(std.testing.allocator, @embedFile("inputs/day4.txt")),
    );
}

test "part 2" {
    try std.testing.expectEqual(
        @as(usize, 9),
        try part2(std.testing.allocator, example),
    );
    try std.testing.expectEqual(
        @as(usize, 1998),
        try part2(std.testing.allocator, @embedFile("inputs/day4.txt")),
    );
}
