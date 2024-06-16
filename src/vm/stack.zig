//! A 32-byte word stack datastructure with constant capacity.
//!
//! This file provides a Stack struct with constant capacity of 1024 32-byte
//! words. The memory is allocated during initialization to ensure zero runtime
//! allocations.
const std = @import("std");
const mem = std.mem;

pub const StackErr = error{ Underflow, Overflow };

/// The EVM stack limit.
const STACK_LIMIT: usize = 1024;

/// EVM stack implementation with zero runtime allocations.
pub const Stack = struct {
    const Self = @This();

    // The data the stack holds.
    data: std.ArrayList(u256),

    /// Initializes a new stack.
    pub fn init(allocator: mem.Allocator) !Self {
        var data = try std.ArrayList(u256).initCapacity(allocator, STACK_LIMIT);

        return .{ .data = data };
    }

    /// Deinitializes the stack.
    pub fn deinit(self: *Self) void {
        self.data.deinit();
    }

    /// Returns the length of the stack in words.
    pub inline fn len(self: *Self) usize {
        return self.data.items.len;
    }

    /// Pushes a new word onto the stack.
    ///
    /// Fails with StackErr.Overflow if stack limit reached.
    pub inline fn push(self: *Self, word: u256) !void {
        // Fail if stack limit reached.
        if (self.len() == STACK_LIMIT) {
            return StackErr.Overflow;
        }

        // Push word without performing capacity check.
        return self.data.appendAssumeCapacity(word);
    }

    /// Removes and returns the topmost value from the stack.
    ///
    /// Fails with StackErr.Underflow if stack is empty.
    pub inline fn pop(self: *Self) !u256 {
        // Fail if stack empty.
        if (self.len() == 0) {
            return StackErr.Underflow;
        }

        // Pop word without performing capacity check.
        return self.data.pop();
    }

    /// Returns the topmost value from the stack.
    ///
    /// Fails with StackErr.Underflow if stack is empty.
    pub inline fn peep(self: *Self) !u256 {
        // Fail if stack empty.
        if (self.len() == 0) {
            return StackErr.Underflow;
        }

        return self.data.items[self.len() - 1];
    }
};

test "Push overflow" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var stack = try Stack.init(allocator);
    defer stack.deinit();

    for (0..STACK_LIMIT) |i| {
        try stack.push(i);
    }
    try std.testing.expectError(StackErr.Overflow, stack.push(1));
}

test "Pop underflow" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var stack = try Stack.init(allocator);
    defer stack.deinit();

    try std.testing.expectError(StackErr.Underflow, stack.pop());
}

test "Peep underflow" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var stack = try Stack.init(allocator);
    defer stack.deinit();

    try std.testing.expectError(StackErr.Underflow, stack.peep());
}
