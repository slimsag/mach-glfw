const std = @import("std");
const testing = std.testing;

const c = @import("c.zig").c;

const key = @import("key.zig");
const errors = @import("errors.zig");

/// Possible value for various window hints, etc.
pub const dont_care = c.GLFW_DONT_CARE;

pub const getError = errors.getError;
pub const mustGetError = errors.mustGetError;
pub const getErrorCode = errors.getErrorCode;
pub const mustGetErrorCode = errors.mustGetErrorCode;
pub const getErrorString = errors.getErrorString;
pub const mustGetErrorString = errors.mustGetErrorString;
pub const setErrorCallback = errors.setErrorCallback;
pub const clearError = errors.clearError;
pub const ErrorCode = errors.ErrorCode;
pub const Error = errors.Error;

pub const Action = @import("action.zig").Action;
pub const GamepadAxis = @import("gamepad_axis.zig").GamepadAxis;
pub const GamepadButton = @import("gamepad_button.zig").GamepadButton;
pub const gamepad_axis = @import("gamepad_axis.zig");
pub const gamepad_button = @import("gamepad_button.zig");
pub const GammaRamp = @import("GammaRamp.zig");
pub const Image = @import("Image.zig");
pub const Joystick = @import("Joystick.zig");
pub const Monitor = @import("Monitor.zig");
pub const mouse_button = @import("mouse_button.zig");
pub const MouseButton = mouse_button.MouseButton;
pub const version = @import("version.zig");
pub const VideoMode = @import("VideoMode.zig");
pub const Window = @import("Window.zig");
pub const Cursor = @import("Cursor.zig");
pub const Native = @import("native.zig").Native;
pub const BackendOptions = @import("native.zig").BackendOptions;
pub const Key = key.Key;
pub const setClipboardString = @import("clipboard.zig").setClipboardString;
pub const getClipboardString = @import("clipboard.zig").getClipboardString;
pub const makeContextCurrent = @import("opengl.zig").makeContextCurrent;
pub const getCurrentContext = @import("opengl.zig").getCurrentContext;
pub const swapInterval = @import("opengl.zig").swapInterval;
pub const extensionSupported = @import("opengl.zig").extensionSupported;
pub const GLProc = @import("opengl.zig").GLProc;
pub const getProcAddress = @import("opengl.zig").getProcAddress;
pub const initVulkanLoader = @import("vulkan.zig").initVulkanLoader;
pub const VKGetInstanceProcAddr = @import("vulkan.zig").VKGetInstanceProcAddr;
pub const vulkanSupported = @import("vulkan.zig").vulkanSupported;
pub const getRequiredInstanceExtensions = @import("vulkan.zig").getRequiredInstanceExtensions;
pub const VKProc = @import("vulkan.zig").VKProc;
pub const getInstanceProcAddress = @import("vulkan.zig").getInstanceProcAddress;
pub const getPhysicalDevicePresentationSupport = @import("vulkan.zig").getPhysicalDevicePresentationSupport;
pub const createWindowSurface = @import("vulkan.zig").createWindowSurface;
pub const getTime = @import("time.zig").getTime;
pub const setTime = @import("time.zig").setTime;
pub const getTimerValue = @import("time.zig").getTimerValue;
pub const getTimerFrequency = @import("time.zig").getTimerFrequency;
pub const Hat = @import("hat.zig").Hat;
pub const RawHat = @import("hat.zig").RawHat;
pub const Mods = @import("mod.zig").Mods;
pub const RawMods = @import("mod.zig").RawMods;

const internal_debug = @import("internal_debug.zig");

/// If GLFW was already initialized in your program, e.g. you are embedding Zig code into an existing
/// program that has already called glfwInit via the C API for you - then you need to tell mach/glfw
/// that it has in fact been initialized already, otherwise when you call other methods mach/glfw
/// would panic thinking glfw.init has not been called yet.
pub fn assumeInitialized() void {
    internal_debug.assumeInitialized();
}

/// Initializes the GLFW library.
///
/// This function initializes the GLFW library. Before most GLFW functions can be used, GLFW must
/// be initialized, and before an application terminates GLFW should be terminated in order to free
/// any resources allocated during or after initialization.
///
/// If this function fails, it calls glfw.Terminate before returning. If it succeeds, you should
/// call glfw.Terminate before the application exits.
///
/// Additional calls to this function after successful initialization but before termination will
/// return immediately with no error.
///
/// The glfw.InitHint.platform init hint controls which platforms are considered during
/// initialization. This also depends on which platforms the library was compiled to support.
///
/// macos: This function will change the current directory of the application to the
/// `Contents/Resources` subdirectory of the application's bundle, if present. This can be disabled
/// with `glfw.InitHint.cocoa_chdir_resources`.
///
/// macos: This function will create the main menu and dock icon for the application. If GLFW finds
/// a `MainMenu.nib` it is loaded and assumed to contain a menu bar. Otherwise a minimal menu bar is
/// created manually with common commands like Hide, Quit and About. The About entry opens a minimal
/// about dialog with information from the application's bundle. The menu bar and dock icon can be
/// disabled entirely with `glfw.InitHint.cocoa_menubar`.
///
/// x11: This function will set the `LC_CTYPE` category of the application locale according to the
/// current environment if that category is still "C".  This is because the "C" locale breaks
/// Unicode text input.
///
/// Possible errors include glfw.ErrorCode.PlatformUnavailable, glfw.ErrorCode.PlatformError.
/// Returns a bool indicating success.
///
/// @thread_safety This function must only be called from the main thread.
pub inline fn init(hints: InitHints) bool {
    internal_debug.toggleInitialized();
    internal_debug.assertInitialized();
    errdefer {
        internal_debug.assertInitialized();
        internal_debug.toggleInitialized();
    }

    inline for (comptime std.meta.fieldNames(InitHints)) |field_name| {
        const init_hint = @field(InitHint, field_name);
        const init_value = @field(hints, field_name);
        if (@TypeOf(init_value) == PlatformType) {
            initHint(init_hint, @intFromEnum(init_value));
        } else {
            initHint(init_hint, init_value);
        }
    }

    return c.glfwInit() == c.GLFW_TRUE;
}

// TODO: implement custom allocator support
//
// /*! @brief Sets the init allocator to the desired value.
//  *
//  *  To use the default allocator, call this function with a `NULL` argument.
//  *
//  *  If you specify an allocator struct, every member must be a valid function
//  *  pointer.  If any member is `NULL`, this function emits @ref
//  *  GLFW_INVALID_VALUE and the init allocator is unchanged.
//  *
//  *  @param[in] allocator The allocator to use at the next initialization, or
//  *  `NULL` to use the default one.
//  *
//  *  @errors Possible errors include @ref GLFW_INVALID_VALUE.
//  *
//  *  @pointer_lifetime The specified allocator is copied before this function
//  *  returns.
//  *
//  *  @thread_safety This function must only be called from the main thread.
//  *
//  *  @sa @ref init_allocator
//  *  @sa @ref glfwInit
//  *
//  *  @since Added in version 3.4.
//  *
//  *  @ingroup init
//  */
// GLFWAPI void glfwInitAllocator(const GLFWallocator* allocator);

/// Terminates the GLFW library.
///
/// This function destroys all remaining windows and cursors, restores any modified gamma ramps
/// and frees any other allocated resources. Once this function is called, you must again call
/// glfw.init successfully before you will be able to use most GLFW functions.
///
/// If GLFW has been successfully initialized, this function should be called before the
/// application exits. If initialization fails, there is no need to call this function, as it is
/// called by glfw.init before it returns failure.
///
/// This function has no effect if GLFW is not initialized.
///
/// Possible errors include glfw.ErrorCode.PlatformError.
///
/// warning: The contexts of any remaining windows must not be current on any other thread when
/// this function is called.
///
/// reentrancy: This function must not be called from a callback.
///
/// thread_safety: This function must only be called from the main thread.
pub inline fn terminate() void {
    internal_debug.assertInitialized();
    internal_debug.toggleInitialized();
    c.glfwTerminate();
}

/// Initialization hints for passing into glfw.init
pub const InitHints = struct {
    /// Specifies whether to also expose joystick hats as buttons, for compatibility with earlier
    /// versions of GLFW that did not have glfwGetJoystickHats.
    joystick_hat_buttons: bool = true,

    /// macOS specific init hint. Ignored on other platforms.
    ///
    /// Specifies whether to set the current directory to the application to the Contents/Resources
    /// subdirectory of the application's bundle, if present.
    cocoa_chdir_resources: bool = true,

    /// macOS specific init hint. Ignored on other platforms.
    ///
    /// specifies whether to create a basic menu bar, either from a nib or manually, when the first
    /// window is created, which is when AppKit is initialized.
    cocoa_menubar: bool = true,

    /// Platform selection init hint.
    ///
    /// Possible values are `PlatformType` enums.
    platform: PlatformType = .any,
};

/// Initialization hints for passing into glfw.initHint
const InitHint = enum(c_int) {
    /// Specifies whether to also expose joystick hats as buttons, for compatibility with earlier
    /// versions of GLFW that did not have glfwGetJoystickHats.
    ///
    /// Possible values are `true` and `false`.
    joystick_hat_buttons = c.GLFW_JOYSTICK_HAT_BUTTONS,

    /// ANGLE rendering backend init hint.
    ///
    /// Possible values are `AnglePlatformType` enums.
    angle_platform_type = c.GLFW_ANGLE_PLATFORM_TYPE,

    /// Platform selection init hint.
    ///
    /// Possible values are `PlatformType` enums.
    platform = c.GLFW_PLATFORM,

    /// macOS specific init hint. Ignored on other platforms.
    ///
    /// Specifies whether to set the current directory to the application to the Contents/Resources
    /// subdirectory of the application's bundle, if present.
    ///
    /// Possible values are `true` and `false`.
    cocoa_chdir_resources = c.GLFW_COCOA_CHDIR_RESOURCES,

    /// macOS specific init hint. Ignored on other platforms.
    ///
    /// specifies whether to create a basic menu bar, either from a nib or manually, when the first
    /// window is created, which is when AppKit is initialized.
    ///
    /// Possible values are `true` and `false`.
    cocoa_menubar = c.GLFW_COCOA_MENUBAR,

    /// X11 specific init hint.
    x11_xcb_vulkan_surface = c.GLFW_X11_XCB_VULKAN_SURFACE,

    /// Wayland specific init hint.
    ///
    /// Possible values are `WaylandLibdecorInitHint` enums.
    wayland_libdecor = c.GLFW_WAYLAND_LIBDECOR,
};

/// Angle platform type hints for glfw.InitHint.angle_platform_type
pub const AnglePlatformType = enum(c_int) {
    none = c.GLFW_ANGLE_PLATFORM_TYPE_NONE,
    opengl = c.GLFW_ANGLE_PLATFORM_TYPE_OPENGL,
    opengles = c.GLFW_ANGLE_PLATFORM_TYPE_OPENGLES,
    d3d9 = c.GLFW_ANGLE_PLATFORM_TYPE_D3D9,
    d3d11 = c.GLFW_ANGLE_PLATFORM_TYPE_D3D11,
    vulkan = c.GLFW_ANGLE_PLATFORM_TYPE_VULKAN,
    metal = c.GLFW_ANGLE_PLATFORM_TYPE_METAL,
};

/// Wayland libdecor hints for glfw.InitHint.wayland_libdecor
///
/// libdecor is important for GNOME, since GNOME does not implement server side decorations on
/// wayland. libdecor is loaded dynamically at runtime, so in general enabling it is always
/// safe to do. It is enabled by default.
pub const WaylandLibdecorInitHint = enum(c_int) {
    wayland_prefer_libdecor = c.GLFW_WAYLAND_PREFER_LIBDECOR,
    wayland_disable_libdecor = c.GLFW_WAYLAND_DISABLE_LIBDECOR,
};

/// Platform type hints for glfw.InitHint.platform
pub const PlatformType = enum(c_int) {
    /// Enables automatic platform detection.
    /// Will default to X11 on wayland.
    any = c.GLFW_ANY_PLATFORM,
    win32 = c.GLFW_PLATFORM_WIN32,
    cocoa = c.GLFW_PLATFORM_COCOA,
    wayland = c.GLFW_PLATFORM_WAYLAND,
    x11 = c.GLFW_PLATFORM_X11,
    null = c.GLFW_PLATFORM_NULL,
};

/// Sets the specified init hint to the desired value.
///
/// This function sets hints for the next initialization of GLFW.
///
/// The values you set hints to are never reset by GLFW, but they only take effect during
/// initialization. Once GLFW has been initialized, any values you set will be ignored until the
/// library is terminated and initialized again.
///
/// Some hints are platform specific.  These may be set on any platform but they will only affect
/// their specific platform.  Other platforms will ignore them. Setting these hints requires no
/// platform specific headers or functions.
///
/// @param hint: The init hint to set.
/// @param value: The new value of the init hint.
///
/// Possible errors include glfw.ErrorCode.InvalidEnum and glfw.ErrorCode.InvalidValue.
///
/// @remarks This function may be called before glfw.init.
///
/// @thread_safety This function must only be called from the main thread.
fn initHint(hint: InitHint, value: anytype) void {
    switch (@typeInfo(@TypeOf(value))) {
        .int, .comptime_int => {
            c.glfwInitHint(@intFromEnum(hint), @as(c_int, @intCast(value)));
        },
        .bool => c.glfwInitHint(@intFromEnum(hint), @as(c_int, @intCast(@intFromBool(value)))),
        else => @compileError("expected a int or bool, got " ++ @typeName(@TypeOf(value))),
    }
}

/// Returns a string describing the compile-time configuration.
///
/// This function returns the compile-time generated version string of the GLFW library binary. It
/// describes the version, platform, compiler and any platform or operating system specific
/// compile-time options. It should not be confused with the OpenGL or OpenGL ES version string,
/// queried with `glGetString`.
///
/// __Do not use the version string__ to parse the GLFW library version. Use the glfw.version
/// constants instead.
///
/// __Do not use the version string__ to parse what platforms are supported. The
/// `glfw.platformSupported` function lets you query platform support.
///
/// returns: The ASCII encoded GLFW version string.
///
/// remark: This function may be called before @ref glfw.Init.
///
/// pointer_lifetime: The returned string is static and compile-time generated.
///
/// thread_safety: This function may be called from any thread.
pub inline fn getVersionString() [:0]const u8 {
    return std.mem.span(@as([*:0]const u8, @ptrCast(c.glfwGetVersionString())));
}

/// Returns the currently selected platform.
///
/// This function returns the platform that was selected during initialization. The returned value
/// will be one of `glfw.PlatformType.win32`, `glfw.PlatformType.cocoa`,
/// `glfw.PlatformType.wayland`, `glfw.PlatformType.x11` or `glfw.PlatformType.null`.
///
/// thread_safety: This function may be called from any thread.
pub fn getPlatform() PlatformType {
    internal_debug.assertInitialized();
    return @as(PlatformType, @enumFromInt(c.glfwGetPlatform()));
}

/// Returns whether the library includes support for the specified platform.
///
/// This function returns whether the library was compiled with support for the specified platform.
/// The platform must be one of `glfw.PlatformType.win32`, `glfw.PlatformType.cocoa`,
/// `glfw.PlatformType.wayland`, `glfw.PlatformType.x11` or `glfw.PlatformType.null`.
///
/// remark: This function may be called before glfw.Init.
///
/// thread_safety: This function may be called from any thread.
pub fn platformSupported(platform: PlatformType) bool {
    internal_debug.assertInitialized();
    return c.glfwPlatformSupported(@intFromEnum(platform)) == c.GLFW_TRUE;
}

/// Processes all pending events.
///
/// This function processes only those events that are already in the event queue and then returns
/// immediately. Processing events will cause the window and input callbacks associated with those
/// events to be called.
///
/// On some platforms, a window move, resize or menu operation will cause event processing to
/// block. This is due to how event processing is designed on those platforms. You can use the
/// window refresh callback (see window_refresh) to redraw the contents of your window when
/// necessary during such operations.
///
/// Do not assume that callbacks you set will _only_ be called in response to event processing
/// functions like this one. While it is necessary to poll for events, window systems that require
/// GLFW to register callbacks of its own can pass events to GLFW in response to many window system
/// function calls. GLFW will pass those events on to the application callbacks before returning.
///
/// Event processing is not required for joystick input to work.
///
/// Possible errors include glfw.ErrorCode.PlatformError.
///
/// @reentrancy This function must not be called from a callback.
///
/// @thread_safety This function must only be called from the main thread.
///
/// see also: events, glfw.waitEvents, glfw.waitEventsTimeout
pub inline fn pollEvents() void {
    internal_debug.assertInitialized();
    c.glfwPollEvents();
}

/// Waits until events are queued and processes them.
///
/// This function puts the calling thread to sleep until at least one event is available in the
/// event queue. Once one or more events are available, it behaves exactly like glfw.pollEvents,
/// i.e. the events in the queue are processed and the function then returns immediately.
/// Processing events will cause the window and input callbacks associated with those events to be
/// called.
///
/// Since not all events are associated with callbacks, this function may return without a callback
/// having been called even if you are monitoring all callbacks.
///
/// On some platforms, a window move, resize or menu operation will cause event processing to
/// block. This is due to how event processing is designed on those platforms. You can use the
/// window refresh callback (see window_refresh) to redraw the contents of your window when
/// necessary during such operations.
///
/// Do not assume that callbacks you set will _only_ be called in response to event processing
/// functions like this one. While it is necessary to poll for events, window systems that require
/// GLFW to register callbacks of its own can pass events to GLFW in response to many window system
/// function calls. GLFW will pass those events on to the application callbacks before returning.
///
/// Event processing is not required for joystick input to work.
///
/// Possible errors include glfw.ErrorCode.PlatformError.
///
/// @reentrancy This function must not be called from a callback.
///
/// @thread_safety This function must only be called from the main thread.
///
/// see also: events, glfw.pollEvents, glfw.waitEventsTimeout
pub inline fn waitEvents() void {
    internal_debug.assertInitialized();
    c.glfwWaitEvents();
}

/// Waits with timeout until events are queued and processes them.
///
/// This function puts the calling thread to sleep until at least one event is available in the
/// event queue, or until the specified timeout is reached. If one or more events are available, it
/// behaves exactly like glfw.pollEvents, i.e. the events in the queue are processed and the
/// function then returns immediately. Processing events will cause the window and input callbacks
/// associated with those events to be called.
///
/// The timeout value must be a positive finite number.
///
/// Since not all events are associated with callbacks, this function may return without a callback
/// having been called even if you are monitoring all callbacks.
///
/// On some platforms, a window move, resize or menu operation will cause event processing to
/// block. This is due to how event processing is designed on those platforms. You can use the
/// window refresh callback (see window_refresh) to redraw the contents of your window when
/// necessary during such operations.
///
/// Do not assume that callbacks you set will _only_ be called in response to event processing
/// functions like this one. While it is necessary to poll for events, window systems that require
/// GLFW to register callbacks of its own can pass events to GLFW in response to many window system
/// function calls. GLFW will pass those events on to the application callbacks before returning.
///
/// Event processing is not required for joystick input to work.
///
/// @param[in] timeout The maximum amount of time, in seconds, to wait.
///
/// Possible errors include glfw.ErrorCode.InvalidValue and glfw.ErrorCode.PlatformError.
///
/// @reentrancy This function must not be called from a callback.
///
/// @thread_safety This function must only be called from the main thread.
///
/// see also: events, glfw.pollEvents, glfw.waitEvents
pub inline fn waitEventsTimeout(timeout: f64) void {
    internal_debug.assertInitialized();
    std.debug.assert(!std.math.isNan(timeout));
    std.debug.assert(timeout >= 0);
    std.debug.assert(timeout <= std.math.floatMax(f64));
    c.glfwWaitEventsTimeout(timeout);
}

/// Posts an empty event to the event queue.
///
/// This function posts an empty event from the current thread to the event queue, causing
/// glfw.waitEvents or glfw.waitEventsTimeout to return.
///
/// Possible errors include glfw.ErrorCode.PlatformError.
///
/// @thread_safety This function may be called from any thread.
///
/// see also: events, glfw.waitEvents, glfw.waitEventsTimeout
pub inline fn postEmptyEvent() void {
    internal_debug.assertInitialized();
    c.glfwPostEmptyEvent();
}

/// Returns whether raw mouse motion is supported.
///
/// This function returns whether raw mouse motion is supported on the current system. This status
/// does not change after GLFW has been initialized so you only need to check this once. If you
/// attempt to enable raw motion on a system that does not support it, glfw.ErrorCode.PlatformError
/// will be emitted.
///
/// Raw mouse motion is closer to the actual motion of the mouse across a surface. It is not
/// affected by the scaling and acceleration applied to the motion of the desktop cursor. That
/// processing is suitable for a cursor while raw motion is better for controlling for example a 3D
/// camera. Because of this, raw mouse motion is only provided when the cursor is disabled.
///
/// @return `true` if raw mouse motion is supported on the current machine, or `false` otherwise.
///
/// @thread_safety This function must only be called from the main thread.
///
/// see also: raw_mouse_motion, glfw.setInputMode
pub inline fn rawMouseMotionSupported() bool {
    internal_debug.assertInitialized();
    return c.glfwRawMouseMotionSupported() == c.GLFW_TRUE;
}

pub fn basicTest() !void {
    defer clearError(); // clear any error we generate
    if (!init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{getErrorString()});
        std.process.exit(1);
    }
    defer terminate();

    const window = Window.create(640, 480, "GLFW example", null, null, .{}) orelse {
        std.log.warn("failed to create window: {?s}", .{getErrorString()});
        return error.SkipZigTest; // note: we don't exit(1) here because our CI can't open windows
    };
    defer window.destroy();

    const start = std.time.milliTimestamp();
    while (std.time.milliTimestamp() < start + 1000 and !window.shouldClose()) {
        c.glfwPollEvents();
    }
}

test {
    std.testing.refAllDeclsRecursive(@This());
}

test "getVersionString" {
    std.debug.print("\nGLFW version v{}.{}.{}\n", .{ version.major, version.minor, version.revision });
    std.debug.print("\nstring: {s}\n", .{getVersionString()});
}

test "init" {
    _ = init(.{ .cocoa_chdir_resources = true });
    if (getErrorString()) |err| {
        std.log.err("failed to initialize GLFW: {?s}", .{err});
        std.process.exit(1);
    }
    defer terminate();
}

test "pollEvents" {
    defer clearError(); // clear any error we generate
    if (!init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{getErrorString()});
        std.process.exit(1);
    }
    defer terminate();

    pollEvents();
}

test "waitEventsTimeout" {
    defer clearError(); // clear any error we generate
    if (!init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{getErrorString()});
        std.process.exit(1);
    }
    defer terminate();

    waitEventsTimeout(0.25);
}

test "postEmptyEvent_and_waitEvents" {
    defer clearError(); // clear any error we generate
    if (!init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{getErrorString()});
        std.process.exit(1);
    }
    defer terminate();

    postEmptyEvent();
    waitEvents();
}

test "rawMouseMotionSupported" {
    defer clearError(); // clear any error we generate
    if (!init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{getErrorString()});
        std.process.exit(1);
    }
    defer terminate();

    _ = rawMouseMotionSupported();
}

test "basic" {
    try basicTest();
}
