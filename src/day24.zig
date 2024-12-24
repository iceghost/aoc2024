const std = @import("std");

const Equation = struct {
    left: []const u8,
    op: enum { bin_and, bin_or, bin_xor },
    right: []const u8,
    result: []const u8,

    pub fn format(
        self: Equation,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        const op = switch (self.op) {
            .bin_and => "&",
            .bin_or => "|",
            .bin_xor => "^",
        };
        try std.fmt.format(writer, "{s} {s} {s} -> {s}", .{ self.left, op, self.right, self.result });
    }
};

fn part1(alloc: std.mem.Allocator, input: []const u8) !usize {
    var map = std.StringHashMap(u1).init(alloc);
    defer map.deinit();
    var equations = std.ArrayList(Equation).init(alloc);
    defer equations.deinit();
    {
        var it = std.mem.splitScalar(u8, input, '\n');
        while (it.next()) |line| {
            if (line.len == 0) break;
            var it2 = std.mem.tokenizeAny(u8, line, ": ");
            const left = it2.next().?;
            const right = it2.next().?;
            try map.putNoClobber(left, if (std.mem.eql(u8, right, "1")) 1 else 0);
        }

        while (it.next()) |line| {
            if (line.len == 0) break;
            var it2 = std.mem.tokenizeAny(u8, line, "-> ");
            const left = it2.next().?;
            const op = it2.next().?;
            const right = it2.next().?;
            const res = it2.next().?;
            try equations.append(.{
                .left = left,
                .op = if (std.mem.eql(u8, op, "AND"))
                    .bin_and
                else if (std.mem.eql(u8, op, "OR"))
                    .bin_or
                else
                    .bin_xor,
                .right = right,
                .result = res,
            });
        }
    }

    outer: while (equations.items.len != 0) {
        for (0.., equations.items) |i, eq| {
            const left = map.get(eq.left) orelse continue;
            const right = map.get(eq.right) orelse continue;
            try map.putNoClobber(eq.result, switch (eq.op) {
                .bin_and => left & right,
                .bin_or => left | right,
                .bin_xor => left ^ right,
            });
            _ = equations.swapRemove(i);
            continue :outer;
        }
    }

    var num: u64 = 0;

    {
        var it = map.iterator();
        while (it.next()) |entry| {
            if (entry.key_ptr.*[0] == 'z') {
                const shift = try std.fmt.parseInt(u6, entry.key_ptr.*[1..3], 10);
                num |= @as(u64, entry.value_ptr.*) << shift;
            }
        }
    }

    return num;
}

const example =
    \\x00: 1
    \\x01: 0
    \\x02: 1
    \\x03: 1
    \\x04: 0
    \\y00: 1
    \\y01: 1
    \\y02: 1
    \\y03: 1
    \\y04: 1
    \\
    \\ntg XOR fgs -> mjb
    \\y02 OR x01 -> tnw
    \\kwq OR kpj -> z05
    \\x00 OR x03 -> fst
    \\tgd XOR rvg -> z01
    \\vdt OR tnw -> bfw
    \\bfw AND frj -> z10
    \\ffh OR nrd -> bqk
    \\y00 AND y03 -> djm
    \\y03 OR y00 -> psh
    \\bqk OR frj -> z08
    \\tnw OR fst -> frj
    \\gnj AND tgd -> z11
    \\bfw XOR mjb -> z00
    \\x03 OR x00 -> vdt
    \\gnj AND wpb -> z02
    \\x04 AND y00 -> kjc
    \\djm OR pbm -> qhw
    \\nrd AND vdt -> hwm
    \\kjc AND fst -> rvg
    \\y04 OR y02 -> fgs
    \\y01 AND x02 -> pbm
    \\ntg OR kjc -> kwq
    \\psh XOR fgs -> tgd
    \\qhw XOR tgd -> z09
    \\pbm OR djm -> kpj
    \\x03 XOR y03 -> ffh
    \\x00 XOR y04 -> ntg
    \\bfw OR bqk -> z06
    \\nrd XOR fgs -> wpb
    \\frj XOR qhw -> z04
    \\bqk OR frj -> z07
    \\y03 OR x01 -> nrd
    \\hwm AND bqk -> z03
    \\tgd XOR rvg -> z12
    \\tnw OR pbm -> gnj
    \\
;

test "part 1" {
    try std.testing.expectEqual(
        @as(usize, 2024),
        try part1(std.testing.allocator, example),
    );
    try std.testing.expectEqual(
        @as(usize, 48508229772400),
        try part1(std.testing.allocator, @embedFile("inputs/day24.txt")),
    );
}
