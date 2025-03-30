const std = @import("std");

fn addExecutable(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "zdb",
        .root_source_file = b.path("src/main.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run zdb");
    run_step.dependOn(&run_exe.step);
}

pub fn build(b: *std.Build) void {
    addExecutable(b);
}
