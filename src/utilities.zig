const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const allocator = @import("main.zig").allocator;

fn concat(comptime T: type, slices: []const []const T) Allocator.Error![]T {
    return mem.concat(allocator, T, slices);
}
pub fn concatBytes(slices: []const []const u8) Allocator.Error![]u8 {
    return concat(u8, slices);
}
pub fn concatNewline(slice: []const u8, newline: Newline) Allocator.Error![]u8 {
    return concat(u8, &[_][]const u8{ slice, newline.toBytes() });
}
pub fn concatBytesNewline(slices: []const []const u8, newline: Newline) Allocator.Error![]u8 {
    return concatNewline(try concatBytes(slices), newline);
}

pub const EscapeSequence = enum(u8) {
    LineFeed = '\n',
    CarriageReturn = '\r',
    fn toInt(self: EscapeSequence) [1]u8 {
        return @intFromEnum(self);
    }
};
pub const Newline = enum {
    Unix,
    Windows,
    fn toBytes(self: Newline) []const u8 {
        return switch (self) {
            .Unix => &[_]u8{'\n'},
            .Windows => &[_]u8{ '\r', '\n' },
        };
    }
};
