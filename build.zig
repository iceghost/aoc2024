const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const all_step = b.step("all", "");
    b.default_step = all_step;

    inline for (.{ "day1", "day4", "day5", "day6", "day8", "day14", "day16", "day17", "day22", "day24", "day25" }) |day| {
        const build_test = b.addTest(.{
            .name = day,
            .root_source_file = b.path("src/" ++ day ++ ".zig"),
            .target = target,
            .optimize = optimize,
        });
        const run_test = b.addRunArtifact(build_test);
        run_test.has_side_effects = true;
        const step = b.step(day, "");
        step.dependOn(&run_test.step);
        all_step.dependOn(step);
    }

    inline for (.{"day14"}) |day| {
        const build_main = b.addExecutable(.{
            .name = day ++ "-main",
            .root_source_file = b.path("src/" ++ day ++ ".zig"),
            .target = target,
            .optimize = optimize,
        });
        const run_main = b.addRunArtifact(build_main);
        const step = b.step(day ++ "-main", "");
        step.dependOn(&run_main.step);
    }
}
