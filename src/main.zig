const std = @import("std");
const http = @import("http.zig");
// Uncomment this block to pass the first stage
// const net = std.net;

var buffer: [2048]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buffer);
pub const allocator = fba.allocator();

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
    const connection = try listener.accept();
    try stdout.print("client connected!", .{});
    const stream = connection.stream;
    const response = http.Response{ .status_line = http.StatusLine{ .version = http.Version.First, .code = http.StatusCode.Ok }, .headers = undefined, .body = undefined };
    const response_bytes = try response.toString();
    _ = try stream.writeAll(response_bytes);
}
