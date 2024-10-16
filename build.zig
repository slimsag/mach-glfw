const builtin = @import("builtin");
const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    var module = b.addModule("zig-glfw", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });

    const test_step = b.step("test", "Run library tests");
    const main_tests = b.addTest(.{
        .name = "glfw-tests",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(main_tests);
    test_step.dependOn(&b.addRunArtifact(main_tests).step);

    if (b.lazyDependency("glfw", .{
        .target = target,
        .optimize = optimize,
    })) |dep| {
        module.linkLibrary(dep.artifact("glfw"));
        @import("glfw").addPaths(module);
        main_tests.linkLibrary(dep.artifact("glfw"));
        @import("glfw").addPaths(&main_tests.root_module);
    }
}
