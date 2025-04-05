const clap = @import("clap");
const std = @import("std");
const linux = std.os.linux;
const posix = std.posix;

const ProcessedArgsTag = enum {
    pid,
    program_name,
};
const ProcessedArgsTagged = union(ProcessedArgsTag) {
    pid: usize,
    program_name: []const u8,
};

fn parse_args(allocator: std.mem.Allocator) !ProcessedArgsTagged {
    const params = comptime clap.parseParamsComptime(
        \\-h, --help         Display this help and exit.
        \\-p, --pid  <usize> PID of process to attach to.
        \\<str>
    );

    var res = try clap.parse(clap.Help, &params, clap.parsers.default, .{
        .allocator = allocator,
    });
    defer res.deinit();

    if (res.args.pid) |pid| {
        return ProcessedArgsTagged{ .pid = pid };
    } else if (res.positionals[0]) |program_name| {
        return ProcessedArgsTagged{ .program_name = program_name };
    }

    try clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
    return error.NoArgumentsProvided;
}

fn attach(processed_args: ProcessedArgsTagged, allocator: std.mem.Allocator) !usize {
    var pid: ?usize = null;

    switch (processed_args) {
        ProcessedArgsTag.pid => |pid_from_arg| {
            pid = pid_from_arg;
            try posix.ptrace(linux.PTRACE.ATTACH, @intCast(pid.?), 0, 0);
        },
        ProcessedArgsTag.program_name => |program_name| {
            pid = linux.fork();
            if (pid.? < 0) {
                return error.ForkError;
            } else if (pid.? == 0) {
                try posix.ptrace(linux.PTRACE.TRACEME, @intCast(pid.?), 0, 0);

                const c_str = try allocator.alignedAlloc(u8, 8, program_name.len + 1);
                defer allocator.free(c_str);
                @memcpy(c_str[0..program_name.len], program_name);
                c_str[program_name.len] = 0;

                switch (posix.execveZ(@ptrCast(c_str), &.{null}, &.{null})) {
                    else => |err| std.debug.print("execveZ failed: {}\n", .{err}),
                }
            }
        },
    }

    return pid.?;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const args = try parse_args(gpa.allocator());
    const pid = try attach(args, gpa.allocator());
    const waitpid_result = posix.waitpid(@intCast(pid), 0);

    if (linux.W.IFSTOPPED(waitpid_result.status)) {
        std.debug.print("process was stopped\n", .{});
    } else {
        std.debug.print("something else happened to the process\n", .{});
    }

    std.debug.print("Killing process: {}\n", .{pid});
    try posix.kill(@intCast(pid), linux.SIG.KILL);
}
