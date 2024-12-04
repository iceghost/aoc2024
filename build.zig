const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const day1_test = b.addTest(.{
        .name = "day1",
        .root_source_file = b.path("src/day1.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day1_test = b.addRunArtifact(day1_test);
    const day1_step = b.step("day1", "");
    day1_step.dependOn(&run_day1_test.step);

    const day4_test = b.addTest(.{
        .name = "day4",
        .root_source_file = b.path("src/day4.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_day4_test = b.addRunArtifact(day4_test);
    const day4_step = b.step("day4", "");
    day4_step.dependOn(&run_day4_test.step);

    const all_step = b.step("all", "");
    all_step.dependOn(day1_step);
    all_step.dependOn(day4_step);

    b.default_step = all_step;
}
