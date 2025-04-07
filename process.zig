const std = @import("std");

const linux = std.os.linux;
const Allocator = std.mem.Allocator;
const PtraceError = std.posix.PtraceError;

pub const ProcessError = error{
    ForkError,
} || PtraceError;

pub const State = enum {
    Paused,
};

pub const Process = @This();

allocator: Allocator,
pid: usize,
state: State,

pub fn init(program_name: []const u8, allocator: Allocator) ProcessError!Process {
    const pid = linux.fork();
    if (pid < 0) {
        return ProcessError.ForkError;
    }

    const is_child = pid == 0;
    if (is_child) {
        try std.posix.ptrace(linux.PTRACE.TRACEME, pid, 0, 0);
    }

    return Process{
        .allocator = allocator,
        .pid = pid,
        .state = State.Paused,
    };
}
