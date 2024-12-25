const std = @import("std");

const Schematic = union(enum) {
    lock: [5]u3,
    key: [5]u3,
};

fn parse(alloc: std.mem.Allocator, input: []const u8) ![]Schematic {
    var arr: std.ArrayListUnmanaged(Schematic) = .empty;
    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.peek()) |_| {
        var schematic: Schematic = if (std.mem.allEqual(u8, it.next().?, '#'))
            .{ .lock = @splat(0) }
        else
            .{ .key = @splat(0) };

        switch (schematic) {
            .lock, .key => |*s| {
                while (it.next()) |line| {
                    if (line.len == 0) break;
                    for (0.., line) |i, c| {
                        s[i] += if (c == '#') 1 else 0;
                    }
                }
            },
        }

        try arr.append(alloc, schematic);
    }

    return try arr.toOwnedSlice(alloc);
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !usize {
    const arr = try parse(alloc, input);
    defer alloc.free(arr);

    var sum: usize = 0;
    for (arr) |s1| switch (s1) {
        .lock => |ls| {
            inner: for (arr) |s2| switch (s2) {
                .key => |ks| {
                    for (ls, ks) |l, k| {
                        if (l +| k > 6)
                            continue :inner;
                    }
                    sum += 1;
                },
                else => continue,
            };
        },
        else => continue,
    };

    return sum;
}

const example =
    \\#####
    \\.####
    \\.####
    \\.####
    \\.#.#.
    \\.#...
    \\.....
    \\
    \\#####
    \\##.##
    \\.#.##
    \\...##
    \\...#.
    \\...#.
    \\.....
    \\
    \\.....
    \\#....
    \\#....
    \\#...#
    \\#.#.#
    \\#.###
    \\#####
    \\
    \\.....
    \\.....
    \\#.#..
    \\###..
    \\###.#
    \\###.#
    \\#####
    \\
    \\.....
    \\.....
    \\.....
    \\#....
    \\#.#..
    \\#.#.#
    \\#####
    \\
;

test "part 1" {
    try std.testing.expectEqual(
        @as(usize, 3),
        try part1(std.testing.allocator, example),
    );
    try std.testing.expectEqual(
        @as(usize, 3466),
        try part1(std.testing.allocator, @embedFile("inputs/day25.txt")),
    );
}
