const std = @import("std");
const Allocator = std.mem.Allocator;
const utilities = @import("utilities.zig");
const Newline = utilities.Newline;
pub const Version = enum {
    First,
    Second,
    Third,
    fn toString(self: Version) []const u8 {
        return switch (self) {
            .First => "HTTP/1.1",
            .Second => "HTTP/2",
            .Third => "HTTP/3",
        };
    }
};
const status = struct {
    const Code = enum(u16) {
        Ok = 200,
        NotFound = 404,
        fn toString(self: Code) []const u8 {
            return switch (self) {
                .Ok => "200 OK",
                .NotFound => "404 Not Found",
            };
        }
    };
    const Line = struct {
        version: Version,
        code: Code,
        fn toString(self: Line) Allocator.Error![]u8 {
            const temp = try utilities.concatBytes(&[_][]const u8{ self.version.toString(), &[_]u8{' '}, self.code.toString() });
            return utilities.concatNewline(temp, Newline.Windows);
        }
    };
};
pub const StatusLine = status.Line;
pub const StatusCode = status.Code;

const header = struct {
    const Kind = enum {};
    const list = struct {
        fn toString(self: List) Allocator.Error![]u8 {
            var temp: []const u8 = "";
            for (self) |header_entry| {
                temp = try utilities.concatBytes(&[_][]const u8{ temp, try header_entry.toString() });
            }
            return temp;
        }
    };
    const List = []Header;
};

pub const Header = union(header.Kind) {
    fn toString(_: Header) Allocator.Error![]u8 {
        return utilities.concatBytes(&[_][]const u8{});
    }
};

const response = struct {
    const Body = struct {
        fn toString(_: Body) Allocator.Error![]u8 {
            return utilities.concatBytes(&[_][]const u8{});
        }
    };
};
pub const ResponseBody = response.Body;

pub const Response = struct {
    status_line: StatusLine,
    headers: ?[]Header,
    body: ?ResponseBody,
    pub fn toString(self: Response) Allocator.Error![]u8 {
        const status_line_bytes = try self.status_line.toString();
        var header_bytes: []const u8 = "";
        if (self.headers) |headers| {
            for (headers) |header_field| {
                header_bytes = try utilities.concatBytes(&[_][]const u8{ header_bytes, try header_field.toString() });
            }
        }
        header_bytes = try utilities.concatNewline(header_bytes, Newline.Windows);

        var response_bytes = try utilities.concatBytes(&[_][]const u8{ status_line_bytes, header_bytes });
        if (self.body) |body_entry| {
            response_bytes = try utilities.concatBytes(&[_][]const u8{ response_bytes, try body_entry.toString() });
        }
        return response_bytes;
    }
};
