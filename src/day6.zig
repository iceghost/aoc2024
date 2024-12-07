const std = @import("std");

const Vec2 = struct { x: usize, y: usize };

const Square = packed struct {
    b: bool = false,
    t: bool = false,
    l: bool = false,
    r: bool = false,

    const top: Square = .{ .t = true };
    const bottom: Square = .{ .b = true };
    const left: Square = .{ .l = true };
    const right: Square = .{ .r = true };
    const empty: Square = .{};
};

fn parse(alloc: std.mem.Allocator, input: []const u8) !struct {
    usize,
    Vec2,
    Square,
    []Square,
} {
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    const s = it.peek().?.len;

    var blockage = try alloc.alloc(Square, (s + 2) * (s + 2));
    errdefer unreachable;
    @memset(blockage, .empty);

    var start: ?Vec2 = null;

    var j: usize = 0;
    while (it.next()) |line| : (j += 1) {
        std.debug.assert(line.len == s);
        for (0..s) |i| {
            if (line[i] == '#') {
                blockage[(j + 0) * (s + 2) + i + 1].b = true;
                blockage[(j + 2) * (s + 2) + i + 1].t = true;
                blockage[(j + 1) * (s + 2) + i + 2].l = true;
                blockage[(j + 1) * (s + 2) + i + 0].r = true;
            }
            if (line[i] == '^')
                start = .{ .x = i, .y = j };
        }
    }

    return .{ s, start.?, .top, blockage };
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !usize {
    const s, var pos, var dir, const blockage = try parse(alloc, input);
    defer alloc.free(blockage);
    var footprints = try alloc.alloc(u1, (s + 2) * (s + 2));
    defer alloc.free(footprints);

    pos.x += 1;
    pos.y += 1;

    while (true) {
        footprints[pos.y * (s + 2) + pos.x] = 1;

        const block = blockage[pos.y * (s + 2) + pos.x];
        if (block.b and dir.b) {
            dir = .left;
            continue;
        }

        if (block.t and dir.t) {
            dir = .right;
            continue;
        }

        if (block.l and dir.l) {
            dir = .top;
            continue;
        }

        if (block.r and dir.r) {
            dir = .bottom;
            continue;
        }

        if (dir.b) pos.y += 1;
        if (dir.t) pos.y -= 1;
        if (dir.l) pos.x -= 1;
        if (dir.r) pos.x += 1;

        if (pos.x == 0 or pos.y == 0 or pos.x == s + 1 or pos.y == s + 1)
            break;
    }

    var sum: usize = 0;
    for (footprints) |f| sum += f;
    return sum;
}

const example =
    \\....#.....
    \\.........#
    \\..........
    \\..#.......
    \\.......#..
    \\..........
    \\.#..^.....
    \\........#.
    \\#.........
    \\......#...
;

test "part 1" {
    try std.testing.expectEqual(
        @as(usize, 41),
        try part1(std.testing.allocator, example),
    );
    try std.testing.expectEqual(
        @as(usize, 5461),
        try part1(std.testing.allocator, @embedFile("inputs/day6.txt")),
    );
}
