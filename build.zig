const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const all_step = b.step("all", "");
    b.default_step = all_step;

    inline for (.{ "day1", "day4", "day5", "day6" }) |day| {
        const build_test = b.addTest(.{
            .name = day,
            .root_source_file = b.path("src/" ++ day ++ ".zig"),
            .target = target,
            .optimize = optimize,
        });
        const run_test = b.addRunArtifact(build_test);
        const step = b.step(day, "");
        step.dependOn(&run_test.step);
        all_step.dependOn(step);
    }
}
