const builtin = @import("builtin");
const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    _ = b.addModule("mach-glfw", .{
        .source_file = .{ .path = "src/main.zig" },
    });

    const lib = b.addStaticLibrary(.{
        .name = "mach-glfw",
        .root_source_file = .{ .path = "stub.c" },
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibrary(b.dependency("glfw", .{
        .target = lib.target,
        .optimize = lib.optimize,
    }).artifact("glfw"));
    lib.linkLibrary(b.dependency("vulkan_headers", .{
        .target = lib.target,
        .optimize = lib.optimize,
    }).artifact("vulkan-headers"));
    if (lib.target_info.target.os.tag == .macos) {
        @import("xcode_frameworks").addPaths(b, lib);
    }
    b.installArtifact(lib);

    const test_step = b.step("test", "Run library tests");
    const main_tests = b.addTest(.{
        .name = "glfw-tests",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    main_tests.linkLibrary(lib);
    // TODO(build-system): linking the library above doesn't seem to transitively carry over the
    // headers for dependencies already linked to `lib`, so we have to add them ourselves:
    {
        main_tests.linkLibrary(b.dependency("glfw", .{
            .target = main_tests.target,
            .optimize = main_tests.optimize,
        }).artifact("glfw"));
        main_tests.linkLibrary(b.dependency("vulkan_headers", .{
            .target = main_tests.target,
            .optimize = main_tests.optimize,
        }).artifact("vulkan-headers"));
        if (main_tests.target_info.target.os.tag == .macos) {
            @import("xcode_frameworks").addPaths(b, main_tests);
        }
    }

    b.installArtifact(main_tests);

    test_step.dependOn(&b.addRunArtifact(main_tests).step);
}
