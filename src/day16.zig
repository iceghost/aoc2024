const std = @import("std");

const Vec2 = struct {
    x: i9,
    y: i9,

    const left: Vec2 = .{ .x = -1, .y = 0 };
    const right: Vec2 = .{ .x = 1, .y = 0 };
    const top: Vec2 = .{ .x = 0, .y = -1 };
    const bottom: Vec2 = .{ .x = 0, .y = 1 };

    fn neg(self: @This()) Vec2 {
        return .{ .x = -self.x, .y = -self.y };
    }
};

fn parse(alloc: std.mem.Allocator, input: []const u8) !struct { usize, std.DynamicBitSetUnmanaged, Vec2, Vec2 } {
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    const size = it.peek().?.len;
    var walls = try std.DynamicBitSetUnmanaged.initEmpty(alloc, size * size);
    errdefer walls.deinit(alloc);

    var start: ?Vec2 = null;
    var end: ?Vec2 = null;

    var row: usize = 0;
    while (it.next()) |line| : (row += 1) {
        for (0.., line) |col, c| {
            switch (c) {
                '#' => walls.set(row * size + col),
                '.' => {},
                'S' => start = .{ .x = @intCast(col), .y = @intCast(row) },
                'E' => end = .{ .x = @intCast(col), .y = @intCast(row) },
                else => unreachable,
            }
        }
    }

    return .{ size, walls, start.?, end.? };
}

const Item = struct {
    start_to_here: usize,
    here_to_end: usize,
    here: Vec2,
    direction: Vec2,

    fn init(start_to_here: usize, here: Vec2, direction: Vec2, end: Vec2) @This() {
        const dx: isize = end.x - here.x;
        const dy: isize = end.y - here.y;
        const here_to_end: usize = if (dx == 0 and std.math.sign(dy) == direction.y)
            @abs(dx) + @abs(dy)
        else if (dy == 0 and std.math.sign(dx) == direction.x)
            @abs(dx) + @abs(dy)
        else
            @abs(dx) + @abs(dy);

        return .{
            .start_to_here = start_to_here,
            .here_to_end = here_to_end,
            .here = here,
            .direction = direction,
        };
    }

    fn order(_: void, a: @This(), b: @This()) std.math.Order {
        return std.math.order(a.start_to_here + a.here_to_end, b.start_to_here + b.here_to_end);
    }
};

fn idx(pos: Vec2, size: usize) usize {
    return @abs(pos.y) * size + @abs(pos.x);
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !usize {
    const size, var walls, const start, const end = try parse(alloc, input);
    defer walls.deinit(alloc);

    var visited = try std.DynamicBitSetUnmanaged.initEmpty(alloc, size * size);
    defer visited.deinit(alloc);

    var queue = std.PriorityQueue(Item, void, Item.order).init(alloc, {});
    defer queue.deinit();

    try queue.add(Item.init(0, start, Vec2.right, end));

    while (queue.removeOrNull()) |item| {
        if (item.here.x == end.x and
            item.here.y == end.y)
            return item.start_to_here;

        if (visited.isSet(@abs(item.here.y) * size + @abs(item.here.x)))
            continue;

        visited.set(@abs(item.here.y) * size + @abs(item.here.x));

        for ([4]Vec2{ Vec2.left, Vec2.right, Vec2.top, Vec2.bottom }) |dir| {
            if (dir.x == -item.direction.x and
                dir.y == -item.direction.y)
                continue;

            const next_pos: Vec2 = .{
                .x = item.here.x + dir.x,
                .y = item.here.y + dir.y,
            };

            if (walls.isSet(@abs(next_pos.y) * size + @abs(next_pos.x)))
                continue;

            if (visited.isSet(@abs(next_pos.y) * size + @abs(next_pos.x)))
                continue;

            if (dir.x == item.direction.x and
                dir.y == item.direction.y)
            {
                try queue.add(Item.init(item.start_to_here + 1, next_pos, dir, end));
                continue;
            }

            try queue.add(Item.init(item.start_to_here + 1001, next_pos, dir, end));
        }
    }

    unreachable;
}

fn part2(alloc: std.mem.Allocator, input: []const u8, part1_solution: usize) !usize {
    const size, var walls, const start, const end = try parse(alloc, input);
    defer walls.deinit(alloc);

    var visited_items = try alloc.alloc(?Item, size * size);
    defer alloc.free(visited_items);
    @memset(visited_items, null);

    var queue = std.PriorityQueue(Item, void, Item.order).init(alloc, {});
    defer queue.deinit();
    try queue.ensureTotalCapacity(size * size);

    queue.add(Item.init(0, start, Vec2.right, end)) catch unreachable;

    var best_end_item: ?Item = null;
    while (queue.removeOrNull()) |item| {
        if (visited_items[idx(item.here, size)] != null)
            continue;

        // keep on going until we ran out of potential solutions
        if (best_end_item) |bei| if (Item.order({}, item, bei) == .gt) {
            break;
        };

        visited_items[idx(item.here, size)] = item;

        if (item.here.x == end.x and item.here.y == end.y) {
            best_end_item = item;
            continue;
        }

        for ([4]Vec2{ Vec2.left, Vec2.right, Vec2.top, Vec2.bottom }) |dir| {
            // ignore if go backward
            if (dir.x == -item.direction.x and
                dir.y == -item.direction.y)
                continue;

            var next_item = Item.init(item.start_to_here + 1, .{
                .x = item.here.x + dir.x,
                .y = item.here.y + dir.y,
            }, dir, end);

            if (walls.isSet(idx(next_item.here, size)) or
                visited_items[idx(next_item.here, size)] != null)
                continue;

            // penalize if change direction
            if (dir.x != item.direction.x or
                dir.y != item.direction.y)
                next_item.start_to_here += 1000;

            queue.add(next_item) catch unreachable;
        }
    }

    // _ = part1_solution;
    std.debug.assert(best_end_item.?.start_to_here == part1_solution);

    // backtrack time
    queue.items.len = 0;

    var stack_trace = try std.DynamicBitSetUnmanaged.initEmpty(alloc, size * size);
    defer stack_trace.deinit(alloc);

    best_end_item.?.here_to_end = 0;
    queue.add(best_end_item.?) catch unreachable;

    var first_loop = true;
    while (queue.removeOrNull()) |item| {
        if (stack_trace.isSet(idx(item.here, size)))
            continue;
        stack_trace.set(idx(item.here, size));

        for ([4]Vec2{ Vec2.left, Vec2.right, Vec2.top, Vec2.bottom }) |dir| {
            const next_pos: Vec2 = .{
                .x = item.here.x + dir.x,
                .y = item.here.y + dir.y,
            };

            if (walls.isSet(idx(next_pos, size)))
                continue;

            var visited_item = visited_items[idx(next_pos, size)] orelse
                continue;

            if (stack_trace.isSet(idx(visited_item.here, size)))
                continue;

            // std.debug.print("{}\n", .{item});
            // std.debug.print("{}\n", .{visited_item});

            var to_end_cost: usize = 1 + item.here_to_end;

            if (!first_loop and
                (item.direction.x != -dir.x or
                item.direction.y != -dir.y))
            {
                to_end_cost += 1000;
            }

            var from_start_cost: usize = visited_item.start_to_here;
            if (!first_loop and
                visited_item.direction.x != -dir.x or
                visited_item.direction.y != -dir.y)
            {
                from_start_cost += 1000;
            }

            if (first_loop or from_start_cost + to_end_cost == best_end_item.?.start_to_here) {
                visited_item.here_to_end = to_end_cost;
                visited_item.start_to_here = 0;
                visited_item.direction = dir.neg();
                queue.add(visited_item) catch unreachable;
            }
        }

        first_loop = false;
    }

    return stack_trace.count();
}

const example1 =
    \\###############
    \\#.......#....E#
    \\#.#.###.#.###.#
    \\#.....#.#...#.#
    \\#.###.#####.#.#
    \\#.#.#.......#.#
    \\#.#.#####.###.#
    \\#...........#.#
    \\###.#.#####.#.#
    \\#...#.....#.#.#
    \\#.#.#.###.#.#.#
    \\#.....#...#.#.#
    \\#.###.#.#.#.#.#
    \\#S..#.....#...#
    \\###############
;

const example2 =
    \\#################
    \\#...#...#...#..E#
    \\#.#.#.#.#.#.#.#.#
    \\#.#.#.#...#...#.#
    \\#.#.#.#.###.#.#.#
    \\#...#.#.#.....#.#
    \\#.#.#.#.#.#####.#
    \\#.#...#.#.#.....#
    \\#.#.#####.#.###.#
    \\#.#.#.......#...#
    \\#.#.###.#####.###
    \\#.#.#...#.....#.#
    \\#.#.#.#####.###.#
    \\#.#.#.........#.#
    \\#.#.#.#########.#
    \\#S#.............#
    \\#################
;

const example3 =
    \\#########
    \\#########
    \\#########
    \\#########
    \\#########
    \\#...#...#
    \\#S#...#E#
    \\#...#...#
    \\#########
;

test "part 1" {
    try std.testing.expectEqual(
        @as(usize, 7036),
        try part1(std.testing.allocator, example1),
    );
    try std.testing.expectEqual(
        @as(usize, 11048),
        try part1(std.testing.allocator, example2),
    );
    try std.testing.expectEqual(
        @as(usize, 7010),
        try part1(std.testing.allocator, example3),
    );
    try std.testing.expectEqual(
        @as(usize, 72400),
        try part1(std.testing.allocator, @embedFile("inputs/day16.txt")),
    );
}

test "part 2" {
    try std.testing.expectEqual(
        @as(usize, 45),
        try part2(std.testing.allocator, example1, 7036),
    );
    try std.testing.expectEqual(
        @as(usize, 64),
        try part2(std.testing.allocator, example2, 11048),
    );
    try std.testing.expectEqual(
        @as(usize, 17),
        try part2(std.testing.allocator, example3, 7010),
    );
    try std.testing.expectEqual(
        @as(usize, 435),
        try part2(std.testing.allocator, @embedFile("inputs/day16.txt"), 72400),
    );
}
