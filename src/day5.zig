const std = @import("std");

fn part2(alloc: std.mem.Allocator, input: []const u8) !usize {
    var rules = std.mem.zeroes([100][100]u1);
    var line_it = std.mem.splitScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) break;
        var component_it = std.mem.tokenizeScalar(u8, line, '|');
        const first = try std.fmt.parseInt(u8, component_it.next().?, 10);
        const second = try std.fmt.parseInt(u8, component_it.next().?, 10);
        rules[first][second] = 1;
    }

    var updates: std.ArrayListUnmanaged(u8) = .empty;
    defer updates.deinit(alloc);

    var total: usize = 0;
    lines: while (line_it.next()) |line| {
        if (line.len == 0) break;
        updates.clearRetainingCapacity();
        var component_it = std.mem.tokenizeScalar(u8, line, ',');
        while (component_it.next()) |component| {
            try updates.append(alloc, try std.fmt.parseInt(u8, component, 10));
        }

        loop: for (0..updates.items.len - 1) |i| {
            for (i + 1..updates.items.len) |j| {
                if (rules[updates.items[j]][updates.items[i]] == 1)
                    break :loop;
            }
        } else {
            continue :lines;
        }

        for (0..updates.items.len - 1) |i| {
            for (i + 1..updates.items.len) |j| {
                if (rules[updates.items[j]][updates.items[i]] == 1)
                    std.mem.swap(u8, &updates.items[j], &updates.items[i]);
            }
        }

        total += updates.items[@divFloor(updates.items.len, 2)];
    }

    return total;
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !usize {
    var rules = std.mem.zeroes([100][100]u1);
    var line_it = std.mem.splitScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) break;
        var component_it = std.mem.tokenizeScalar(u8, line, '|');
        const first = try std.fmt.parseInt(u8, component_it.next().?, 10);
        const second = try std.fmt.parseInt(u8, component_it.next().?, 10);
        rules[first][second] = 1;
    }

    var updates: std.ArrayListUnmanaged(u8) = .empty;
    defer updates.deinit(alloc);

    var total: usize = 0;
    lines: while (line_it.next()) |line| {
        if (line.len == 0) break;
        updates.clearRetainingCapacity();
        var component_it = std.mem.tokenizeScalar(u8, line, ',');
        while (component_it.next()) |component| {
            try updates.append(alloc, try std.fmt.parseInt(u8, component, 10));
        }

        for (0..updates.items.len - 1) |i| {
            for (i + 1..updates.items.len) |j| {
                if (rules[updates.items[j]][updates.items[i]] == 1)
                    continue :lines;
            }
        }

        total += updates.items[@divFloor(updates.items.len, 2)];
    }

    return total;
}

const example =
    \\47|53
    \\97|13
    \\97|61
    \\97|47
    \\75|29
    \\61|13
    \\75|53
    \\29|13
    \\97|29
    \\53|29
    \\61|53
    \\97|53
    \\61|29
    \\47|13
    \\75|47
    \\97|75
    \\47|61
    \\75|61
    \\47|29
    \\75|13
    \\53|13
    \\
    \\75,47,61,53,29
    \\97,61,53,29,13
    \\75,29,13
    \\75,97,47,61,53
    \\61,13,29
    \\97,13,75,29,47
    \\
;

test "part 1" {
    try std.testing.expectEqual(
        @as(usize, 143),
        try part1(std.testing.allocator, example),
    );
    try std.testing.expectEqual(
        @as(usize, 2569),
        try part1(std.testing.allocator, @embedFile("inputs/day5.txt")),
    );
}

test "part 2" {
    try std.testing.expectEqual(
        @as(usize, 123),
        try part2(std.testing.allocator, example),
    );
    try std.testing.expectEqual(
        @as(usize, 4922),
        try part2(std.testing.allocator, @embedFile("inputs/day5.txt")),
    );
}
