const builtin = @import("builtin");
const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    _ = b.addModule("mach-glfw", .{
        .root_source_file = .{ .path = "src/main.zig" },
    });

    const lib = b.addStaticLibrary(.{
        .name = "mach-glfw",
        .root_source_file = b.addWriteFiles().add("empty.c", ""),
        .target = target,
        .optimize = optimize,
    });
    link(b, lib);
    b.installArtifact(lib);

    const test_step = b.step("test", "Run library tests");
    const main_tests = b.addTest(.{
        .name = "glfw-tests",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    main_tests.linkLibrary(lib);
    link(b, main_tests);
    b.installArtifact(main_tests);

    test_step.dependOn(&b.addRunArtifact(main_tests).step);
}

pub fn link(b: *std.Build, step: *std.Build.Step.Compile) void {
    const target_triple: []const u8 = step.rootModuleTarget().zigTriple(b.allocator) catch @panic("OOM");
    const cpu_opts: []const u8 = step.root_module.resolved_target.?.query.serializeCpuAlloc(b.allocator) catch @panic("OOM");
    const glfw_dep = b.dependency("glfw", .{
        .target = target_triple,
        .cpu = cpu_opts,
        .optimize = step.root_module.optimize.?,
    });
    @import("glfw").link(glfw_dep.builder, step);
    step.linkLibrary(glfw_dep.artifact("glfw"));
}
