const std = @import("std");

fn parse(alloc: std.mem.Allocator, input: []const u8) !struct { usize, []u8 } {
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    const size = it.peek().?.len;
    var arr: std.ArrayListUnmanaged(u8) = try .initCapacity(alloc, size * size);
    errdefer unreachable;

    while (it.next()) |line| {
        for (line) |c| {
            arr.appendAssumeCapacity(c);
        }
    }
    std.debug.assert(arr.capacity == arr.items.len);

    return .{ size, arr.allocatedSlice() };
}

fn check(arr: []const u8, size: usize, row: usize, col: usize, res: []u1) void {
    for (0..size) |j| {
        for (0..size) |i| {
            if (j == row and i == col) continue;
            if (arr[row * size + col] == arr[j * size + i]) {
                res[(2 * row + size - j) * 3 * size + (2 * col + size - i)] = 1;
                res[(2 * j + size - row) * 3 * size + (2 * i + size - col)] = 1;
            }
        }
    }
    return;
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !usize {
    const size, const arr = try parse(alloc, input);
    defer alloc.free(arr);

    const res = try alloc.alloc(u1, 9 * size * size);
    defer alloc.free(res);
    @memset(res, 0);

    for (0..size) |j|
        for (0..size) |i|
            if (arr[j * size + i] == '.')
                continue
            else
                check(arr, size, j, i, res);

    var sum: usize = 0;

    for (0..size) |j| {
        for (0..size) |i| {
            sum += res[(j + size) * 3 * size + (i + size)];
        }
    }

    return sum;
}

fn check2(arr: []const u8, size: usize, row: usize, col: usize, res: []u1) void {
    for (0..size) |j| {
        for (0..size) |i| {
            if (j == row and i == col) continue;
            if (arr[row * size + col] == arr[j * size + i]) {
                res[row * size + col] = 1;
                res[j * size + i] = 1;
                for (2..size) |mult| {
                    var y = size + mult * row - (mult - 1) * j;
                    var x = size + mult * col - (mult - 1) * i;
                    if (x < size or x >= 2 * size or
                        y < size or y >= 2 * size)
                        break;
                    y -= size;
                    x -= size;
                    res[y * size + x] = 1;
                }
                for (2..size) |mult| {
                    var y = size + mult * j - (mult - 1) * row;
                    var x = size + mult * i - (mult - 1) * col;
                    if (x < size or x >= 2 * size or
                        y < size or y >= 2 * size)
                        break;
                    y -= size;
                    x -= size;
                    res[y * size + x] = 1;
                }
            }
        }
    }
    return;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !usize {
    const size, const arr = try parse(alloc, input);
    defer alloc.free(arr);

    const res = try alloc.alloc(u1, size * size);
    defer alloc.free(res);
    @memset(res, 0);

    for (0..size) |j| {
        for (0..size) |i| {
            if (arr[j * size + i] == '.') continue;
            check2(arr, size, j, i, res);
        }
    }

    var sum: usize = 0;
    for (res) |b| sum += b;
    return sum;
}

const example =
    \\............
    \\........0...
    \\.....0......
    \\.......0....
    \\....0.......
    \\......A.....
    \\............
    \\............
    \\........A...
    \\.........A..
    \\............
    \\............
    \\
;

test "part 1" {
    try std.testing.expectEqual(
        @as(usize, 14),
        try part1(std.testing.allocator, example),
    );
    try std.testing.expectEqual(
        @as(usize, 413),
        try part1(std.testing.allocator, @embedFile("inputs/day8.txt")),
    );
}

test "part 2" {
    try std.testing.expectEqual(
        @as(usize, 34),
        try part2(std.testing.allocator, example),
    );
    try std.testing.expectEqual(
        @as(usize, 1417),
        try part2(std.testing.allocator, @embedFile("inputs/day8.txt")),
    );
}
