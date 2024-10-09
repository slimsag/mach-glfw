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
        .root_source_file = b.path("src/main.zig"),
    });
    module.linkLibrary(glfw_dep.artifact("glfw"));

    const test_step = b.step("test", "Run library tests");
    const main_tests = b.addTest(.{
        .name = "glfw-tests",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    main_tests.linkLibrary(glfw_dep.artifact("glfw"));
    b.installArtifact(main_tests);
    test_step.dependOn(&b.addRunArtifact(main_tests).step);

    if (target.result.isDarwin()) {
        if (glfw_dep.builder.lazyDependency("xcode_frameworks", .{
            .target = target,
            .optimize = optimize,
        })) |dep| {
            module.addSystemFrameworkPath(dep.path("Frameworks"));
            module.addSystemIncludePath(dep.path("include"));
            module.addLibraryPath(dep.path("lib"));

            main_tests.root_module.addSystemFrameworkPath(dep.path("Frameworks"));
            main_tests.root_module.addSystemIncludePath(dep.path("include"));
            main_tests.root_module.addLibraryPath(dep.path("lib"));
        }
    }
}

comptime {
    const supported_zig = std.SemanticVersion.parse("0.14.0-dev.1911+3bf89f55c") catch unreachable;
    if (builtin.zig_version.order(supported_zig) != .eq) {
        @compileError(std.fmt.comptimePrint("unsupported Zig version ({}). Required Zig version 2024.10.0-mach: https://machengine.org/docs/nominated-zig/#2024100-mach", .{builtin.zig_version}));
    }
}
