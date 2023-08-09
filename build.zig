const builtin = @import("builtin");
const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    _ = b.addModule("mach-glfw", .{
        .source_file = .{ .path = "src/main.zig" },
    });

    // TODO: uncomment this once hexops/mach#902 is fixed
    // we cannot call b.dependency inside pub fn build if we want to use this package via the Zig
    // package manager.
    _ = target;
    _ = optimize;

    // const lib = b.addStaticLibrary(.{
    //     .name = "mach-glfw",
    //     .root_source_file = .{ .path = "stub.c" },
    //     .target = target,
    //     .optimize = optimize,
    // });
    // lib.linkLibrary(b.dependency("glfw", .{
    //     .target = lib.target,
    //     .optimize = lib.optimize,
    // }).artifact("glfw"));
    // lib.linkLibrary(b.dependency("vulkan_headers", .{
    //     .target = lib.target,
    //     .optimize = lib.optimize,
    // }).artifact("vulkan-headers"));
    // if (lib.target_info.target.os.tag == .macos) {
    //     @import("xcode_frameworks").addPaths(b, lib);
    // }
    // b.installArtifact(lib);

    // const test_step = b.step("test", "Run library tests");
    // const main_tests = b.addTest(.{
    //     .name = "glfw-tests",
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // main_tests.linkLibrary(lib);
    // try link(b, main_tests);
    // b.installArtifact(main_tests);

    // test_step.dependOn(&b.addRunArtifact(main_tests).step);
}

pub fn link(b: *std.Build, step: *std.build.CompileStep) !void {
    step.linkLibrary(b.dependency("glfw", .{
        .target = step.target,
        .optimize = step.optimize,
    }).artifact("glfw"));
    @import("glfw").addPaths(step);
    if (step.target.toTarget().isDarwin()) @import("xcode_frameworks").addPaths(b, step);
    step.linkLibrary(b.dependency("vulkan_headers", .{
        .target = step.target,
        .optimize = step.optimize,
    }).artifact("vulkan-headers"));
    step.linkLibrary(b.dependency("x11_headers", .{
        .target = step.target,
        .optimize = step.optimize,
    }).artifact("x11-headers"));
    step.linkLibrary(b.dependency("wayland_headers", .{
        .target = step.target,
        .optimize = step.optimize,
    }).artifact("wayland-headers"));
}
