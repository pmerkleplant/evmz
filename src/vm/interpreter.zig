//! An EVM bytecode interpreter.
const std = @import("std");
const mem = std.mem;

pub const Interpreter = struct {
    const Self = @This();

    pub fn init() !Self {
        return .{};
    }

    pub fn deinit() void {}

    pub fn run() void {}
};
