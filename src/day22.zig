const std = @import("std");

inline fn nextSecret(n: u64) u64 {
    var res = n;
    res = prune(mix(res, @shlExact(res, 6)));
    res = prune(mix(res, res >> 5));
    res = prune(mix(res, @shlExact(res, 11)));
    return res;
}

inline fn prune(a: u64) u64 {
    return a % 16777216;
}

inline fn mix(a: u64, b: u64) u64 {
    return a ^ b;
}

inline fn digit(a: u64) u5 {
    return @intCast(a % 10);
}

inline fn change(a: u5, b: u5) u20 {
    return @intCast(b -% a);
}

fn parse(alloc: std.mem.Allocator, input: []const u8) ![]u64 {
    var arr = try std.ArrayList(u64).initCapacity(alloc, 1000);
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        const num = try std.fmt.parseInt(u64, line, 10);
        try arr.append(num);
    }
    return try arr.toOwnedSlice();
}

fn part1(alloc: std.mem.Allocator, input: []const u8) !u64 {
    const arr = try parse(alloc, input);
    defer alloc.free(arr);

    var sum: u64 = 0;
    for (0.., arr) |i, _| {
        var x = arr[i];
        for (0..2000) |_| {
            x = nextSecret(x);
        }
        sum += x;
    }
    return sum;
}

inline fn computePatterns(profits: []std.atomic.Value(u16), initial_secret: u64) void {
    const T = struct {
        threadlocal var visited: ?std.DynamicBitSetUnmanaged = null;
    };

    var visited = if (T.visited) |v| v else blk: {
        @branchHint(.unlikely);
        T.visited = std.DynamicBitSetUnmanaged.initEmpty(std.heap.page_allocator, profits.len) catch @panic("");
        break :blk T.visited.?;
    };

    var x = initial_secret;

    var key: u20 = 0;

    for (0..3) |_| {
        const y = nextSecret(x);
        key = @shlExact(change(digit(x), digit(y)), 15) | key >> 5;
        x = y;
    }

    for (3..2000) |_| {
        const y = nextSecret(x);
        key = @shlExact(change(digit(x), digit(y)), 15) | key >> 5;
        x = y;
        if (!visited.isSet(key)) {
            @branchHint(.likely);
            visited.set(key);
            _ = profits[key].fetchAdd(digit(y), .acq_rel);
        }
    }

    visited.unsetAll();
}

fn part2(alloc: std.mem.Allocator, input: []const u8) !u16 {
    const arr = try parse(alloc, input);
    defer alloc.free(arr);

    var t = try std.time.Timer.start();
    defer std.debug.print("part2: {}\n", .{t.read()});

    const profits = try alloc.alloc(std.atomic.Value(u16), std.math.maxInt(u20) + 1);
    defer alloc.free(profits);
    @memset(profits, .init(0));

    var pool: std.Thread.Pool = undefined;
    try pool.init(.{ .allocator = alloc });
    defer pool.deinit();

    var wait_group: std.Thread.WaitGroup = .{};
    for (arr) |secret|
        pool.spawnWg(&wait_group, computePatterns, .{ profits, secret });
    pool.waitAndWork(&wait_group);

    var max: u16 = 0;
    for (profits) |p| {
        max = @max(max, p.load(.unordered));
    }

    return max;
}

const example =
    \\1
    \\10
    \\100
    \\2024
;

const example2 =
    \\1
    \\2
    \\3
    \\2024
;

test "part 1" {
    try std.testing.expectEqual(
        @as(usize, 37327623),
        try part1(std.testing.allocator, example),
    );
    try std.testing.expectEqual(
        @as(usize, 18525593556),
        try part1(std.testing.allocator, @embedFile("inputs/day22.txt")),
    );
}

test "part 2" {
    try std.testing.expectEqual(
        @as(usize, 23),
        try part2(std.testing.allocator, example2),
    );

    var arena: std.heap.ArenaAllocator = .init(std.testing.allocator);
    defer arena.deinit();
    try std.testing.expectEqual(
        @as(usize, 2089),
        try part2(arena.allocator(), @embedFile("inputs/day22.txt")),
    );
}
