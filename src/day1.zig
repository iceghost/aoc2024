const std = @import("std");

fn collectAndSort(
    alloc: std.mem.Allocator,
    input: []const u8,
) !struct {
    std.ArrayListUnmanaged(i32),
    std.ArrayListUnmanaged(i32),
} {
    var left: std.ArrayListUnmanaged(i32) = .empty;
    errdefer left.deinit(alloc);
    var right: std.ArrayListUnmanaged(i32) = .empty;
    errdefer right.deinit(alloc);

    var it = std.mem.tokenizeAny(u8, input, " \n");
    while (true) {
        const fst = try std.fmt.parseInt(i32, it.next() orelse break, 10);
        const snd = try std.fmt.parseInt(i32, it.next().?, 10);
        try left.append(alloc, fst);
        try right.append(alloc, snd);
    }

    std.mem.sortUnstable(i32, left.items, {}, std.sort.asc(i32));
    std.mem.sortUnstable(i32, right.items, {}, std.sort.asc(i32));

    return .{ left, right };
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u32 {
    var left, var right = try collectAndSort(alloc, input);
    defer left.deinit(alloc);
    defer right.deinit(alloc);

    var sum: u32 = 0;
    for (left.items, right.items) |l, r| {
        sum += @abs(l - r);
    }

    return sum;
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !i32 {
    var left, var right = try collectAndSort(alloc, input);
    defer left.deinit(alloc);
    defer right.deinit(alloc);

    return similarity(left.items, right.items);
}

fn similarity(left: []const i32, right: []const i32) i32 {
    var l: usize = 0;
    var r: usize = 0;
    var rcount: i32 = 0;
    var sum: i32 = 0;

    loop: switch (@as(
        enum { done, search, count, trail },
        .search,
    )) {
        .done => return sum,

        .search => switch (std.math.order(left[l], right[r])) {
            .lt => {
                l += 1;
                continue :loop if (l == left.len) .done else .search;
            },
            .gt => {
                r += 1;
                continue :loop if (r == right.len) .done else .search;
            },
            .eq => {
                continue :loop .count;
            },
        },

        .count => switch (left[l] == right[r]) {
            true => {
                rcount += 1;
                r += 1;
                continue :loop if (r == right.len) .trail else .count;
            },
            false => {
                continue :loop .trail;
            },
        },

        .trail => switch (left[l] == right[r - 1]) {
            true => {
                sum += rcount * left[l];
                l += 1;
                continue :loop if (l == left.len) .done else .trail;
            },
            false => {
                rcount = 0;
                continue :loop if (r == right.len) .done else .search;
            },
        },
    }
}

test {
    const alloc = std.testing.allocator;
    try std.testing.expectEqual(@as(u32, 11), try part1(alloc,
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
        \\
    ));
}

test {
    const alloc = std.testing.allocator;
    try std.testing.expectEqual(
        @as(u32, 2285373),
        try part1(alloc, @embedFile("inputs/day1.txt")),
    );
}

test {
    const alloc = std.testing.allocator;
    try std.testing.expectEqual(@as(i32, 31), try part2(alloc,
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
        \\
    ));
}

test {
    const alloc = std.testing.allocator;
    try std.testing.expectEqual(
        @as(i32, 21142653),
        try part2(alloc, @embedFile("inputs/day1.txt")),
    );
}
