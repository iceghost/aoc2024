const std = @import("std");

const Vm = struct {
    a: u64,
    b: u64 = 0,
    c: u64 = 0,
    instructions: []const u3,
    ip: usize = 0,

    inline fn evaluate(a: u64, instructions: []const u3, result: []u3) usize {
        var vm: Vm = .{ .a = a, .instructions = instructions };
        return vm.run(result);
    }

    fn run(self: *Vm, result: []u3) usize {
        var arr: std.ArrayListUnmanaged(u3) = .initBuffer(result);
        loop: switch (self.opcode() orelse return arr.items.len) {
            // adv
            0 => {
                self.a >>= std.math.lossyCast(u6, self.combo());
                continue :loop self.nextOpcode() orelse return arr.items.len;
            },
            // bxl
            1 => {
                self.b ^= self.literal();
                continue :loop self.nextOpcode() orelse return arr.items.len;
            },
            // bst
            2 => {
                self.b = self.combo() & 0b111;
                continue :loop self.nextOpcode() orelse return arr.items.len;
            },
            // jnz
            3 => if (self.a == 0) {
                @branchHint(.unlikely);
                continue :loop self.nextOpcode() orelse return arr.items.len;
            } else {
                self.ip = self.literal();
                continue :loop self.opcode() orelse return arr.items.len;
            },
            // bxc
            4 => {
                self.b ^= self.c;
                continue :loop self.nextOpcode() orelse return arr.items.len;
            },
            // out
            5 => {
                arr.appendAssumeCapacity(@intCast(self.combo() & 0b111));
                continue :loop self.nextOpcode() orelse return arr.items.len;
            },
            // bdv
            6 => {
                self.b = self.a >> std.math.lossyCast(u6, self.combo());
                continue :loop self.nextOpcode() orelse return arr.items.len;
            },
            // cdv
            7 => {
                self.c = self.a >> std.math.lossyCast(u6, self.combo());
                continue :loop self.nextOpcode() orelse return arr.items.len;
            },
        }
    }

    inline fn opcode(self: Vm) ?u3 {
        return if (self.ip > self.instructions.len)
            null
        else
            self.instructions[self.ip];
    }

    inline fn nextOpcode(self: *Vm) ?u3 {
        self.ip += 2;
        return self.opcode();
    }

    inline fn literal(self: Vm) u64 {
        return self.instructions[self.ip + 1];
    }

    inline fn combo(self: Vm) u64 {
        return switch (self.instructions[self.ip + 1]) {
            0...3 => self.literal(),
            4 => self.a,
            5 => self.b,
            6 => self.c,
            7 => unreachable,
        };
    }
};

test "example" {
    var buf: [10]u3 = undefined;
    const len = Vm.evaluate(729, &.{ 0, 1, 5, 4, 3, 0 }, &buf);
    try std.testing.expectEqualSlices(u3, &.{ 4, 6, 3, 5, 6, 3, 5, 2, 1, 0 }, buf[0..len]);
}

test "example 2" {
    var buf: [10]u3 = undefined;
    const len = Vm.evaluate(117440, &.{ 0, 3, 5, 4, 3, 0 }, &buf);
    try std.testing.expectEqualSlices(u3, &.{ 0, 3, 5, 4, 3, 0 }, buf[0..len]);
}

const input_program = [_]u3{ 2, 4, 1, 3, 7, 5, 1, 5, 0, 3, 4, 1, 5, 5, 3, 0 };

test "part 1" {
    var buf: [10]u3 = undefined;
    var t = try std.time.Timer.start();
    const len = Vm.evaluate(21539243, &input_program, &buf);
    const x = t.read();
    try std.testing.expectEqualSlices(u3, &.{ 6, 7, 5, 2, 1, 3, 5, 1, 7 }, buf[0..len]);
    std.debug.print("part 1: {}ns {any}\n", .{ x, buf[0..len] });
}

fn check(a: u64, expected: []const u3) bool {
    var buf: [64]u3 = undefined;
    const len = Vm.evaluate(a, &input_program, &buf);
    return std.mem.eql(u3, expected, buf[0..len]);
}

fn brute(a: u64, i: usize) ?u64 {
    for (0..8) |m| {
        if (check(a << 3 | m, input_program[input_program.len - i ..])) {
            if (i == input_program.len) {
                @branchHint(.unlikely);
                return a << 3 | m;
            }
            if (brute(a << 3 | m, i + 1)) |c| {
                @branchHint(.unlikely);
                return c;
            }
        }
    }
    return null;
}

test "part 2" {
    var t = try std.time.Timer.start();
    const ans = brute(0, 1);
    const x = t.read();
    std.debug.print("part 2: {}ns {}\n", .{ x, ans.? });
}
