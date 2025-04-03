const clap = @import("clap");
const std = @import("std");
const linux = std.os.linux;

fn attach() void {}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const params = comptime clap.parseParamsComptime(
        \\-h, --help       Display this help and exit.
        \\-p, --pid  <u16> PID of process to attach to.
        \\<str>
    );

    var res = try clap.parse(clap.Help, &params, clap.parsers.default, .{
        .allocator = gpa.allocator(),
    });
    defer res.deinit();

    if (res.args.help != 0) {
        return clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
    }

    if (res.args.pid) |pid| {
        if (linux.ptrace(linux.PTRACE.ATTACH, pid, 0, 0, 0) < 0) {
            return error.PtraceAttachError;
        }
    } else if (res.positionals[0]) |program_path| {
        std.debug.print("{s}", .{program_path});
    } else {
        return error.NoArguments;
    }
}
