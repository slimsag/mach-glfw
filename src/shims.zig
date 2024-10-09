// Zig 0.14.0-dev changed the names of all 'std.builtin.Type' fields.
const old_std_builtin_type_field_names = @hasField(@import("std").builtin.Type, "Type");

pub const std = struct {
    pub const builtin = struct {
        pub const Type = if (old_std_builtin_type_field_names) union(enum) {
            type: void,
            void: void,
            bool: void,
            noreturn: void,
            int: Int,
            float: Float,
            pointer: Pointer,
            array: Array,
            @"struct": Struct,
            comptime_float: void,
            comptime_int: void,
            undefined: void,
            null: void,
            optional: Optional,
            error_union: ErrorUnion,
            error_set: ErrorSet,
            @"enum": Enum,
            @"union": Union,
            @"fn": Fn,
            @"opaque": Opaque,
            frame: Frame,
            @"anyframe": AnyFrame,
            vector: Vector,
            enum_literal: void,

            pub const Int = @import("std").builtin.Type.Int;
            pub const Float = @import("std").builtin.Type.Float;
            pub const Pointer = @import("std").builtin.Type.Pointer;
            pub const Array = @import("std").builtin.Type.Array;
            pub const ContainerLayout = @import("std").builtin.Type.ContainerLayout;
            pub const StructField = @import("std").builtin.Type.StructField;
            pub const Struct = @import("std").builtin.Type.Struct;
            pub const Optional = @import("std").builtin.Type.Optional;
            pub const ErrorUnion = @import("std").builtin.Type.ErrorUnion;
            pub const Error = @import("std").builtin.Type.Error;
            pub const ErrorSet = @import("std").builtin.Type.ErrorSet;
            pub const EnumField = @import("std").builtin.Type.EnumField;
            pub const Enum = @import("std").builtin.Type.Enum;
            pub const UnionField = @import("std").builtin.Type.UnionField;
            pub const Union = @import("std").builtin.Type.Union;
            pub const Fn = @import("std").builtin.Type.Fn;
            pub const Opaque = @import("std").builtin.Type.Opaque;
            pub const Frame = @import("std").builtin.Type.Frame;
            pub const AnyFrame = @import("std").builtin.Type.AnyFrame;
            pub const Vector = @import("std").builtin.Type.Vector;
            pub const Declaration = @import("std").builtin.Type.Declaration;
        } else @import("std").builtin.Type;
    };
};

pub fn typeInfo(comptime T: type) std.builtin.Type {
    return if (old_std_builtin_type_field_names) switch (@typeInfo(T)) {
        .Type => .type,
        .Void => .void,
        .Bool => .bool,
        .NoReturn => .noreturn,
        .Int => |x| .{ .int = x },
        .Float => |x| .{ .float = x },
        .Pointer => |x| .{ .pointer = x },
        .Array => |x| .{ .array = x },
        .Struct => |x| .{ .@"struct" = x },
        .ComptimeFloat => .comptime_float,
        .ComptimeInt => .comptime_int,
        .Undefined => .undefined,
        .Null => .null,
        .Optional => |x| .{ .optional = x },
        .ErrorUnion => |x| .{ .error_union = x },
        .ErrorSet => |x| .{ .error_set = x },
        .Enum => |x| .{ .@"enum" = x },
        .Union => |x| .{ .@"union" = x },
        .Fn => |x| .{ .@"fn" = x },
        .Opaque => |x| .{ .@"opaque" = x },
        .Frame => |x| .{ .frame = x },
        .AnyFrame => .@"anyframe",
        .Vector => |x| .{ .vector = x },
        .EnumLiteral => .enum_literal,
    } else @typeInfo(T);
}
