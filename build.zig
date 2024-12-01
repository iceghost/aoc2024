const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const day1_test = b.addTest(.{
        .root_source_file = b.path("src/day1.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day1_test = b.addRunArtifact(day1_test);
    const day1_step = b.step("day1", "");
    day1_step.dependOn(&run_day1_test.step);
}
