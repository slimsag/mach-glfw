const builtin = @import("builtin");
const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const glfw_dep = b.dependency("glfw", .{
        .target = target,
        .optimize = optimize,
    });

    const module = b.addModule("mach-glfw", .{
        .root_source_file = .{ .path = "src/main.zig" },
    });
    module.linkLibrary(glfw_dep.artifact("glfw"));

    const test_step = b.step("test", "Run library tests");
    const main_tests = b.addTest(.{
        .name = "glfw-tests",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    main_tests.linkLibrary(glfw_dep.artifact("glfw"));
    addPaths(main_tests);
    b.installArtifact(main_tests);

    test_step.dependOn(&b.addRunArtifact(main_tests).step);
}

pub fn link(b: *std.Build, step: *std.Build.Step.Compile) void {
    _ = b;
    _ = step;

    @panic(".link(b, step) has been replaced by .addPaths(step)");
}

pub fn addPaths(step: *std.Build.Step.Compile) void {
    @import("glfw").addPaths(step);
}

comptime {
    const min_zig = std.SemanticVersion.parse("0.12.0-dev.2063+804cee3b9") catch unreachable;
    if (builtin.zig_version.order(min_zig) != .eq) {
        @compileError(std.fmt.comptimePrint("unsupported Zig version ({}). Required Zig version 2024.1.0-mach: https://machengine.org/about/nominated-zig/#202410-mach", .{builtin.zig_version}));
    }
}
