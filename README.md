<a href="https://machengine.org/pkg/mach-glfw">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="https://machengine.org/assets/mach/glfw-full-dark.svg">
        <img alt="mach-glfw" src="https://machengine.org/assets/mach/glfw-full-light.svg" height="150px">
    </picture>
</a>

Perfected GLFW bindings for Zig, with 100% API coverage, zero-fuss installation, cross compilation, and more.

## Features

* Zero-fuss installation, cross-compilation at the flip of a switch, and broad platform support.
* 100% API coverage. Every function, type, constant, etc. has been exposed in a ziggified API.

## Community maintained

The [Mach engine](https://machengine.org/) project no longer uses GLFW, and so this project is now community-maintained. Pull requests are welcome and will be reviewed. The project will still target [nominated Zig versions](https://machengine.org/docs/nominated-zig/) (and may incidentally work with other Zig versions) but may not see regular updates as it is no longer a Mach project (see [hexops/mach#1166](https://github.com/hexops/mach/issues/1166)).

Some old documentation is available at https://machengine.org/v0.4/pkg/mach-glfw/ (most of which is replicated below).

## What does a ziggified GLFW API offer?

* **Enums**, always know what value a GLFW function can accept as everything is strictly typed. And use the nice Zig syntax to access enums, like `window.getKey(.escape)` instead of `c.glfwGetKey(window, c.GLFW_KEY_ESCAPE)`
* Slices instead of C pointers and lengths.
* Generics, so you can just use window.hint instead of glfwWindowHint, glfwWindowHintString, etc.
* [packed structs](https://ziglang.org/documentation/master/#packed-struct) represent bit masks, so you can use `if (joystick.down and joystick.right)` instead of `if (joystick & c.GLFW_HAT_DOWN and joystick & c.GLFW_HAT_RIGHT)`, etc.
* Methods, e.g. `my_window.hint(...)` instead of `glfwWindowHint(my_window, ...)`.
* `true` and `false` instead of `c.GLFW_TRUE` and `c.GLFW_FALSE` constants.

## How do I use OpenGL, Vulkan, etc. with this?

You’ll need to bring your own library, e.g.:

* OpenGL: [castholm/zigglgen](https://github.com/castholm/zigglgen) ([example](https://github.com/slimsag/mach-glfw-opengl-example))
* Vulkan: [Snektron/vulkan-zig](https://github.com/Snektron/vulkan-zig) or [hexops/vulkan-zig-generated](https://github.com/hexops/vulkan-zig-generated) ([example](https://github.com/slimsag/mach-glfw-vulkan-example))

## Getting started

First `zig init` to create a Zig project. Then you will need to add mach-glfw to your `build.zig.zon`, and update your `build.zig` and `src/main.zig` files:

### `build.zig.zon`

mach-glfw uses the Zig package manager. To add it as a dependency, run the following command:

```sh
zig fetch --save https://pkg.machengine.org/mach-glfw/LATEST_COMMIT.tar.gz
```

(Change `LATEST_COMMIT` to the actual latest mach-glfw commit hash.) This will add an entry for mach-glfw to your `build.zig.zon`.

### `build.zig`

Add the following to your `build.zig` below your `const exe = b.addExecutable(...)` line:

```zig
    // Use mach-glfw
    const glfw_dep = b.dependency("mach-glfw", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("mach-glfw", glfw_dep.module("mach-glfw"));
```

### `src/main.zig`

Here’s an example program to get you started:

```zig
const std = @import("std");
const glfw = @import("mach-glfw");

/// Default GLFW error handling callback
fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

pub fn main() !void {
    glfw.setErrorCallback(errorCallback);
    if (!glfw.init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    defer glfw.terminate();

    // Create our window
    const window = glfw.Window.create(640, 480, "Hello, mach-glfw!", null, null, .{}) orelse {
        std.log.err("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    defer window.destroy();

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        window.swapBuffers();
        glfw.pollEvents();
    }
}
```

### Ran into trouble?

Feel free to join the [Mach Discord community](https://machengine.org/discord/) for help.

## A warning about error handling

**Unless the action you’re performing is truly critical to your application continuing further, you should avoid terminating on GLFW errors and log them instead.**

Unfortunately, GLFW must return errors for a *large portion* of its functionality on some platforms, but especially for Wayland in particular. If you want your application to run well for most Linux users, you should e.g. merely log errors that are not critical.

Here is a rough list of functionality Wayland does not support:

* `Window.setIcon`
* `Window.setPos`, `Window.getPos`
* `Window.iconify`, `Window.focus`
* `Monitor.setGamma`
* `Monitor.getGammaRamp`, `Monitor.setGammaRamp`

For example, `window.getPos()` will always return x=0, y=0 on Wayland due to lack of platform support. Ignoring this error is a reasonable choice for most applications. However, errors like this can still be caught and handled:

```zig
const pos = window.getPos();

// Option 1: convert a GLFW error into a Zig error.
// Heed our warning about Wayland above, though!
glfw.getErrorCode() catch |err| {
    std.log.err("failed to get window position: error={}", .{err});
    return err; // Or fall back to an alternative implementation.
};

// Option 2: log a human-readable description of the error.
if (glfw.getErrorString()) |description| {
    std.log.err("failed to get window position: {s}", .{description});
    // ...
}

// Option 3: use a combination of the above approaches.
if (glfw.getError()) |err| {
    const error_code = err.error_code; // Zig error
    const description = err.description; // Human-readable description
    std.log.err("failed to get window position: error={}: {s}", .{error_code, description});
    // ...
}
```

Note that the above example relies on GLFW’s saved error being empty; otherwise, previously emitted errors may be mistaken for an error caused by `window.getPos()`.

If your application frequently ignores errors, it may be necessary to call `glfw.clearError()` or `defer glfw.clearError()` to ensure a clean slate for future error handling.

## GLFW version

We generally follow the latest master version of GLFW, as recorded [here](https://github.com/slimsag/glfw), as this allows us to work with the GLFW author to fix e.g. undefined behavior that Zig catches, and benefit from the latest & greatest changes - such as runtime X11/Wayland switching recently.
