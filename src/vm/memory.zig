//! A simple EVM memory datastructure.
//!
//! This file provides a Memory struct with 4KB page sizes.
const std = @import("std");
const mem = std.mem;

pub const Memory = struct {
    const Self = @This();

    // The page size is 4KB, ie allocations happen in 4KB increments.
    const PAGE_SIZE = 4 * 1024;

    // The data the memory holds.
    data: std.ArrayList(u8),

    /// Initializes a new memory with 4KB capacity.
    pub fn init(allocator: mem.Allocator) !Self {
        var data = try std.ArrayList(u8).initCapacity(allocator, PAGE_SIZE);

        return .{ .data = data };
    }

    /// Deinitializes the memory.
    pub fn deinit(self: *Self) void {
        self.data.deinit();
    }

    /// Returns the length of the memory in bytes.
    pub inline fn len(self: *Self) usize {
        return self.data.items.len;
    }

    //pub fn grow(self: *Self, size: usize) !void {
    //}

    //pub fn set(self: *Self, offset: usize, value: u8[]) !void {
    //}
};
