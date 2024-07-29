<a href="https://machengine.org/pkg/mach-glfw">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="https://machengine.org/assets/mach/glfw-full-dark.svg">
        <img alt="mach-glfw" src="https://machengine.org/assets/mach/glfw-full-light.svg" height="150px">
    </picture>
</a>

Perfected, community-maintained Zig bindings for GLFW

A previous version of this document can be found (here)[https://machengine.org/v0.4/pkg/mach-glfw/].

## Features of this ziggified GLFW API
 - Zero-fuss installation
 - Simple cross-compiling over a broad range of platforms
 - 100% API coverage, including each function, type, and constant.

 - Strict typing on GLFW functions

 - Zig enums provide a pleasant syntax for the developer
     - `window.getKey(.escape)` vs `c.glfwGetKey(window, c.GLFW_KEY_ESCAPE)`

 - Zig API works with slices instead of C-style pointers and lengths

 - Generics provide a cleaner interface
     - allowing `window.hint` over `glfwWindowHint` or `glfwWindowHintString`, etc.

 - Zig's packed structs make working with bitmasks easier
     - `if (joystick.down and joystick.right)` with mach-glfw
     - `if (joystick & c.GLFW_HAT_DOWN and joystick & c.GLFW_HAT_RIGHT)` with standard Zig/C interfacing

 - Namespaced methods instead of long variable names
     - `my_window.hint(...)` vs `c.glfwWindowHint(my_window, ...)`

 - Native boolean support with `true` and `false`
     - No more `c.GLFW_TRUE` and `c.GLFW_FALSE`

## Targeting
This project was originally a part of the [Mach engine](https://machengine.org), but was dropped
with the end of GLFW support in the project. It is now community-maintained.

This project targets the latest `master` version of GLFW, allowing its authors to work
with the GLFW author to fix integration hiccups. Following `master` means that new
changes (such as runtime X11/Wayland switching) can be integrated seamlessly.

This project additionally targets (nominated zig versions)[https://machengine.org/about/zig-version/]
but may not recieve as regular updates (see (hexops/mach#1166)[https://github.com/hexops/mach/issues/1166])

## How-to-use OpenGL, Vulkan, WebGPU, etc
This project can be used in conjunction with other libraries, as these authors have done:

 - WebGPU: [mach-gpu](https://machengine.org/v0.4/pkg/mach-gpu) - [example](https://github.com/hexops/mach-gpu) (deprecated)

 - Vulkan: [example](https://github.com/hexops/mach-glfw-vulkan-example)

     - [Snektron/vulkan-zig](https://github.com/Snektron/vulkan-zig)

     - [hexops/vulkan-zig-generated](https://github.com/hexops/vulkan-zig-generated)

 - OpenGL: [castholm/zigglegen](https://github.com/hexops/mach-glfw-opengl-example) - [example](https://github.com/hexops/mach-glfw-opengl-example)

## Getting Started
This project is best suited for development using native zig tooling.

First run `zig init` to create a valid zig project. This will generate `build.zig` and
`build.zig.zon` files, which you will need to modify in the following steps.

### build.zig.zon
The `zig` command-line tool supports a CLI for modifying your `build.zig.zon`.
```sh
zig fetch --save "https://pkg.machengine.org/mach-glfw/LATEST_COMMIT.tar.gz"
```
The `zig fetch` command above will include this project in your dependency list.
You will need to check the git repository in order to find the latest full commit hash.

### build.zig
A depedency step must be added in order for your project to build with mach-glfw. Below
the line beginning with `const exe = b.addExecutable`, add the following snippet:
```typescript
const glfw_dep = b.dependency("mach-glfw", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("mach-glfw", glfw_dep.module("mach-glfw"));
```

### src/main.zig
Below follows an example program, to test your functionality:
```typescript
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

## Issues persisting?
If you're manually configuring your `build.zig.zon`, verify that this structure exists:
```typescript
.{
    // ... .name, .version, etc
    .dependencies = .{
        // ... other dependencies of yours
        .@"mach-glfw" = .{
            .url = "https://pkg.machengine.org/mach-glfw/FULL_HASH_LATEST_COMMIT.tar.gz",
            .hash = "" // place anything here--zig build will error and give you the correct hash
        },
    },
    // ... .paths is down here
}
```

You may need to modify the `.url` or `.hash` fields for accuracy.

## Developer's Notes

**TLDR: Unless your intended action is truly critical to your intended functionality, you should avoid terminating on GLFW errors.**

For some platforms, a large portion of GLFW's functionality will return errors.
For Wayland on Linux in particular, errors should probably be logged instead of crashing.

Wayland does not support the following functionality:
 - `Window.setIcon`
 - `Window.setPos`, `Window.getPos`
 - `Window.iconify`, `Window.focus`
 - `Monitor.setGamma`
 - `Monitor.getGammaRamp`, `Monitor.setGammaRamp`

Non-critical errors (such as the failure of `Window.getPos`) can still be caught and handled:
```typescript
const pos = window.getPos(); // always returns x=0, y=0 on Wayland

// Option 1: GLFW error -> Zig error
glfw.getErrorCode() catch |err| {
    std.log.err("Failed to get window position: error={}", .{err});
    return err; // or fall back to other code
};

// Option 2: Log the error, without failing
if (glfw.getErrorString()) |description| {
    std.log.err("Failed to get window position: {s}", .{description});
}

// Option 3: A combination of both, using zig constructs
if (glfw.getError()) |err| {
    const error_code = err.error_code;
    const description = err.description;
    std.log.err("Failed to get window position: error={}: {s}", .{error_code, description});
}
```

It is of note that these options rely on GLFW's saved error being empty; otherwise,
previously emitted errors can be mistaked for a `Window.getPos` error.

If your application frequently ignores errors, `glfw.clearError()` or `defer glfw.clearError()`
will ensure a clean slate for future error handling.


