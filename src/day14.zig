const std = @import("std");
const posix = std.posix;

const Robot = struct { px: i64, py: i64, vx: i64, vy: i64 };

fn parse(alloc: std.mem.Allocator, input: []const u8) ![]Robot {
    var arr = try std.ArrayListUnmanaged(Robot).initCapacity(alloc, 500);
    errdefer arr.deinit(alloc);

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        var num_it = std.mem.tokenize(u8, line, "pv=, ");
        const px = try std.fmt.parseInt(i64, num_it.next().?, 10);
        const py = try std.fmt.parseInt(i64, num_it.next().?, 10);
        const vx = try std.fmt.parseInt(i64, num_it.next().?, 10);
        const vy = try std.fmt.parseInt(i64, num_it.next().?, 10);
        try arr.append(alloc, .{ .px = px, .py = py, .vx = vx, .vy = vy });
    }
    return try arr.toOwnedSlice(alloc);
}

fn part1(alloc: std.mem.Allocator, input: []const u8, width: i64, height: i64, times: usize) !usize {
    const data = try parse(alloc, input);
    defer alloc.free(data);
    var quads = [4]usize{ 0, 0, 0, 0 };
    for (data) |*p| {
        p.px += p.vx * @as(i64, @intCast(times));
        p.px = @mod(p.px, width);
        p.py += p.vy * @as(i64, @intCast(times));
        p.py = @mod(p.py, height);

        const mid_w = @divExact(width - 1, 2);
        const mid_h = @divExact(height - 1, 2);

        if (p.px < mid_w and p.py < mid_h)
            quads[0] += 1;
        if (p.px > mid_w and p.py < mid_h)
            quads[1] += 1;
        if (p.px < mid_w and p.py > mid_h)
            quads[2] += 1;
        if (p.px > mid_w and p.py > mid_h)
            quads[3] += 1;
    }

    return quads[0] * quads[1] * quads[2] * quads[3];
}

fn part2(alloc: std.mem.Allocator, input: []const u8, width: i64, height: i64) !void {
    const data = try parse(alloc, input);
    defer alloc.free(data);

    const original = try posix.tcgetattr(posix.STDIN_FILENO);
    defer posix.tcsetattr(posix.STDIN_FILENO, posix.TCSA.NOW, original) catch {};
    var term = original;
    // return from read() when seeing 1 character inside buffer
    term.cc[@intFromEnum(posix.V.MIN)] = 1;
    // disable line buffer
    term.lflag.ICANON = false;
    // and no echo
    term.lflag.ECHO = false;
    try posix.tcsetattr(posix.STDIN_FILENO, posix.TCSA.FLUSH, term);

    var stdout = std.io.getStdOut();
    var bw = std.io.bufferedWriter(stdout.writer());

    // enter alternate screen
    _ = try bw.write("\x1b[?1049h");
    try bw.flush();
    defer {
        _ = bw.write("\x1b[?1049l") catch {};
        _ = bw.flush() catch {};
    }

    const buf = try alloc.alloc(u21, @intCast(width * height));
    defer alloc.free(buf);

    var time: i64 = 0;
    while (true) {
        // reset to home (0, 0)
        try std.fmt.format(bw.writer(), "\x1b[H\x1b[2J", .{});
        try std.fmt.format(bw.writer(), "TIME {}\n", .{time});

        // print out screen

        @memset(buf, '░');
        for (data) |robot|
            buf[@intCast(robot.py * width + robot.px)] = '█';

        var col: usize = 0;
        for (buf) |c| {
            var c_buf: [4]u8 = undefined;
            const c_l = try std.unicode.utf8Encode(c, &c_buf);
            // double the width
            try std.fmt.format(bw.writer(), "{s}", .{c_buf[0..c_l]});
            try std.fmt.format(bw.writer(), "{s}", .{c_buf[0..c_l]});
            col += 1;
            if (col == width) {
                try std.fmt.format(bw.writer(), "\n", .{});
                col = 0;
            }
        }
        try bw.flush();

        // read stdin

        var ch: [1]u8 = undefined;
        std.debug.assert(try std.posix.read(std.posix.STDIN_FILENO, &ch) == 1);
        if (ch[0] == 'q')
            return;

        if (ch[0] == 'h') {
            time -= 1;
            for (data) |*robot| {
                robot.px = @mod(robot.px - robot.vx, width);
                robot.py = @mod(robot.py - robot.vy, height);
            }
            continue;
        }

        if (ch[0] == 'l') {
            time += 1;
            for (data) |*robot| {
                robot.px = @mod(robot.px + robot.vx, width);
                robot.py = @mod(robot.py + robot.vy, height);
            }
            continue;
        }
    }
}

const example =
    \\p=0,4 v=3,-3
    \\p=6,3 v=-1,-3
    \\p=10,3 v=-1,2
    \\p=2,0 v=2,-1
    \\p=0,0 v=1,3
    \\p=3,0 v=-2,-2
    \\p=7,6 v=-1,-3
    \\p=3,0 v=-1,-2
    \\p=9,3 v=2,3
    \\p=7,3 v=-1,2
    \\p=2,4 v=2,-3
    \\p=9,5 v=-3,-3
    \\
;

test "part 1" {
    try std.testing.expectEqual(
        @as(usize, 12),
        try part1(std.testing.allocator, example, 11, 7, 100),
    );
    try std.testing.expectEqual(
        @as(usize, 413),
        try part1(std.testing.allocator, @embedFile("inputs/day14.txt"), 101, 103, 100),
    );
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) {
        _ = gpa.detectLeaks();
    };
    try part2(gpa.allocator(), @embedFile("inputs/day14.txt"), 101, 103);
}
