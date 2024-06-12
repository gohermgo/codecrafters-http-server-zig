const std = @import("std");
// Uncomment this block to pass the first stage
// const net = std.net;

fn arrayConcat(comptime T: type, slices: []const []const T) std.mem.Allocator.Error![]const T {
    return std.mem.concat(std.heap.FixedBufferAllocator, T, slices);
}
fn arrayConcatu8(slices: []const []const u8) std.mem.Allocator.Error![]const u8 {
    return std.mem.concat(std.heap.GeneralPurposeAllocator(.{}).allocator(), u8, slices);
}

const http = struct {
    const Version = enum {
        First,
        fn toBytes(self: Version) std.mem.Allocator.Error![:0]const u8 {
            const start_bytes = "HTTP/";
            const version_bytes = comptime switch (self) {
                Version.First => "1.1",
            };
            return arrayConcatu8(&[_][]const u8{ start_bytes, version_bytes });
        }
    };
    const status = struct {
        const Code = enum(u8) {
            OK = 200,
            fn reasonPhrase(self: Code) [:0]const u8 {
                return comptime @tagName(self);
            }
            fn toBytes(self: Code) std.mem.Allocator.Error![:0]const u8 {
                return arrayConcatu8(&[_][]const u8{ @intFromEnum(self), '\n', self.reasonPhrase() });
            }
        };
        const Line = struct {
            version: Version,
            code: Code,
            fn toBytes(self: Line) std.mem.Allocator.Error![:0]const u8 {
                return arrayConcatu8(&[_][]const u8{ try self.version.toBytes(), '\n', try self.code.toBytes(), "\n\r\n" });
            }
        };
    };
    const HeaderKind = enum {};
    const Header = union(HeaderKind) {
        fn toBytes(_: Header) [:0]const u8 {
            // const header_bytes = comptime switch (self) {
            //     _ => "",
            // };
            return comptime "";
        }
    };
    const ResponseBody = struct {
        fn toBytes(self: ResponseBody) []const u8 {
            self;
        }
    };
    const Response = struct {
        status_line: status.Line,
        headers: ?[]Header,
        body: ?ResponseBody,
        fn toBytes(self: Response) std.mem.Allocator.Error![]const u8 {
            const header_bytes = if (self.headers) |headers| {
                var bytes: []const u8 = "";
                for (headers) |header| {
                    bytes = try arrayConcatu8(&[_][]const u8{ bytes, header.toBytes() });
                }
                try arrayConcatu8(&[_][]const u8{ bytes, "\r\n" });
            } else {
                "";
            };
            return comptime self.status_line.toBytes() + header_bytes + self.body.?.toBytes();
        }
    };
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    // You can use print statements as follows for debugging, they'll be visible when running tests.
    try stdout.print("Logs from your program will appear here!\n", .{});

    // Uncomment this block to pass the first stage
    const address = try std.net.Address.resolveIp("127.0.0.1", 4221);
    var listener = try address.listen(.{
        .reuse_address = true,
    });
    defer listener.deinit();
    //
    _ = try listener.accept();
    try stdout.print("client connected!", .{});
    var stream = listener.stream;
    const status_line = http.status.Line{
        .version = http.Version.First,
        .code = http.status.Code.OK,
    };
    const response = http.Response{ .status_line = status_line, .headers = undefined, .body = undefined };
    const response_bytes = try response.toBytes();
    _ = try stream.writeAll(response_bytes);
}
