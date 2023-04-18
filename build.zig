const builtin = @import("builtin");
const std = @import("std");
const Build = std.Build;

const glfw_opt_params = [_]struct { type, []const u8, []const u8 }{
    .{ bool, "shared", "Build as shared library" },
    .{ bool, "x11", "Build with X11. Only useful on Linux" },
    .{ bool, "opengl", "Build with OpenGl; deprecated on MacOS" },
    .{ bool, "gles", "Build with GLES; not supported on MacOS" },
    .{ bool, "metal", "Build with Metal; only supported on MacOS" },
};

//const shared = b.option(bool, "shared", "Build as a shared library") orelse false;
//
//const use_x11 = b.option(bool, "x11", "Build with X11. Only useful on Linux") orelse true;
//const use_wl = b.option(bool, "wayland", "Build with Wayland. Only useful on Linux") orelse true;
//
//const use_opengl = b.option(bool, "opengl", "Build with OpenGL; deprecated on MacOS") orelse false;
//const use_gles = b.option(bool, "gles", "Build with GLES; not supported on MacOS") orelse false;
//const use_metal = b.option(bool, "metal", "Build with Metal; only supported on MacOS") orelse true;

pub const GlfwOptions = struct {
    target: std.zig.CrossTarget,
    optimize: std.builtin.Mode,

    shared: bool = false,
    x11: bool = true,
    wayland: bool = true,
    opengl: bool = false,
    gles: bool = false,
    metal: bool = true,
};

pub fn build(b: *Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    var glfw_opts = GlfwOptions{ .target = target, .optimize = optimize };

    // TODO: wonk
    inline for (glfw_opt_params) |opt| {
        if (b.option(opt.@"0", opt.@"1", opt.@"2")) |val| {
            @field(glfw_opts, opt.@"1") = val;
        }
    }

    _ = b.addModule("mach-glfw", .{
        .source_file = .{ .path = "src/main.zig" },
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&(try testStep(b, glfw_opts)).step);
    test_step.dependOn(&(try testStepShared(b, glfw_opts)).step);
}

fn testStep(b: *Build, glfw_opts_: GlfwOptions) !*std.build.RunStep {
    var glfw_opts = glfw_opts_;
    glfw_opts.shared = false;

    const main_tests = b.addTest(.{
        .name = "glfw-tests",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = glfw_opts.target,
        .optimize = glfw_opts.optimize,
    });

    const glfw = b.dependency("glfw", glfw_opts);
    main_tests.linkLibrary(glfw.artifact("glfw"));
    // mach-glfw @cIncludes vulkan through the glfw header. Thus, we must link it.
    main_tests.linkLibrary(glfw.builder.dependency("vulkan_headers", .{
        .target = glfw_opts.target,
        .optimize = glfw_opts.optimize,
    }).artifact("vulkan-headers"));

    return b.addRunArtifact(main_tests);
}

fn testStepShared(b: *Build, glfw_opts_: GlfwOptions) !*std.build.RunStep {
    var glfw_opts = glfw_opts_;
    glfw_opts.shared = true;

    const main_tests = b.addTest(.{
        .name = "glfw-tests-shared",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = glfw_opts.target,
        .optimize = glfw_opts.optimize,
    });

    const glfw = b.dependency("glfw", glfw_opts);
    main_tests.linkLibrary(glfw.artifact("glfw"));
    // mach-glfw @cIncludes vulkan through the glfw header. Thus, we must link it.
    main_tests.linkLibrary(glfw.builder.dependency("vulkan_headers", .{
        .target = glfw_opts.target,
        .optimize = glfw_opts.optimize,
    }).artifact("vulkan-headers"));
    return b.addRunArtifact(main_tests);
}
