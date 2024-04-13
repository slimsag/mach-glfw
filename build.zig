const builtin = @import("builtin");
const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const glfw_dep = b.dependency("glfw", .{
        .target = target,
        .optimize = optimize,
    });

    var module = b.addModule("mach-glfw", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/main.zig" },
    });
    module.linkLibrary(glfw_dep.artifact("glfw"));
    @import("glfw").addPaths(module);

    const test_step = b.step("test", "Run library tests");
    const main_tests = b.addTest(.{
        .name = "glfw-tests",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    main_tests.linkLibrary(glfw_dep.artifact("glfw"));
    @import("glfw").addPaths(&main_tests.root_module);
    b.installArtifact(main_tests);

    test_step.dependOn(&b.addRunArtifact(main_tests).step);
}

comptime {
    const supported_zig = std.SemanticVersion.parse("0.12.0-dev.3644+05d975576") catch unreachable;
    if (builtin.zig_version.order(supported_zig) != .eq) {
        @compileError(std.fmt.comptimePrint("unsupported Zig version ({}). Required Zig version 2024.3.0-mach: https://machengine.org/about/nominated-zig/#202430-mach", .{builtin.zig_version}));
    }
}
