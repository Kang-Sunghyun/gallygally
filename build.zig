const std = @import("std");
const Builder = std.build.Builder;
const Step = std.build.Step;
const LibExeObjStep = std.build.LibExeObjStep;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("gallygally", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    exe.linkLibC();
    exe.addIncludeDir("include");
    exe.addLibPath("lib");
    exe.linkSystemLibrary("raylibdll");

    exe.addPackagePath("zlm", "pkg/zlm/zlm.zig");

    const dll_copy = DllCopyStep.create(b);
    b.default_step.dependOn(&dll_copy.step);
    if (exe.install_step) |install_step| {
        dll_copy.step.dependOn(&install_step.step);
    }

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

const DllCopyStep = struct {
    step: Step,
    builder: *Builder,

    pub fn create(b: *Builder) *DllCopyStep {
        var self = b.allocator.create(DllCopyStep) catch unreachable;
        self.* = DllCopyStep{
            .step = Step.init(.custom, "dll", b.allocator, make),
            .builder = b,
        };

        return self;
    }

    fn make(step: *Step) !void {
        const self = @fieldParentPtr(DllCopyStep, "step", step);
        const b = self.builder;

        var lib = try std.fs.cwd().openDir("lib", .{ .iterate = true });
        defer lib.close();

        var exe_dir = try std.fs.cwd().openDir(b.exe_dir, .{});
        defer exe_dir.close();

        var files = lib.iterate();
        while (try files.next()) |file| {
            if (std.mem.endsWith(u8, file.name, ".dll")) {
                try lib.copyFile(file.name, exe_dir, file.name, .{});
            }
        }
    }
};
