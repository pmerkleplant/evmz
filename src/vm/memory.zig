//! A simple EVM memory datastructure.
//!
//! This file provides a Memory struct with 4KB page sizes.
const std = @import("std");
const mem = std.mem;

pub const MemoryErr = error{MemoryReferenceTooLarge};

/// EVM memory implementation.
pub const Memory = struct {
    const Self = @This();

    // The page size is 4KB, ie allocations happen in 4KB increments.
    const PAGE_SIZE = 4 * 1024;

    // The data the memory holds.
    // TODO: Switch to u256 and shift?
    data: std.ArrayList(u8),

    /// Initializes zero-length memory.
    pub fn init(allocator: mem.Allocator) Self {
        std.debug.print("memory initialized\n", .{});

        return .{ .data = std.ArrayList(u8).init(allocator) };
    }

    /// Deinitializes the memory.
    pub fn deinit(self: *Self) void {
        self.data.deinit();
    }

    /// Returns the length of the memory in bytes.
    pub inline fn len(self: *Self) usize {
        return self.data.items.len;
    }

    /// Stores the word at offset in memory.
    pub fn store(self: *Self, offset: u256, word: u256) !void {
        // Compute span of memory to write to.
        const start = offset;
        const end = start + 31;

        // Allocate additional page if necessary.
        if (self.len() <= end) {
            const total = self.len() + PAGE_SIZE;

            // Ensure capacity and zero new memory.
            try self.data.ensureTotalCapacity(total);
            for (self.len()..total) |_| {
                self.data.appendAssumeCapacity(0);
            }
            std.debug.print("memory allocated page, now total of {} bytes\n", .{total});
        }

        // Store word byte-wise in span.
        // Fail if span's start cannot be converted to usize.
        const start_usize = std.math.cast(usize, start) orelse return MemoryErr.MemoryReferenceTooLarge;

        // TODO: Would loop be unrolled during comptime?
        //for (0..31) |i| {
        //    self.data.items[start_usize] = @truncate(word >> 256 - (8 * (31 - i)) & 0xFF);
        //}
        self.data.items[start_usize] = @truncate(word >> 248 & 0xFF);
        self.data.items[start_usize + 1] = @truncate(word >> 240 & 0xFF);
        self.data.items[start_usize + 2] = @truncate(word >> 232 & 0xFF);
        self.data.items[start_usize + 3] = @truncate(word >> 224 & 0xFF);
        self.data.items[start_usize + 4] = @truncate(word >> 216 & 0xFF);
        self.data.items[start_usize + 5] = @truncate(word >> 208 & 0xFF);
        self.data.items[start_usize + 6] = @truncate(word >> 200 & 0xFF);
        self.data.items[start_usize + 7] = @truncate(word >> 192 & 0xFF);
        self.data.items[start_usize + 8] = @truncate(word >> 184 & 0xFF);
        self.data.items[start_usize + 9] = @truncate(word >> 176 & 0xFF);
        self.data.items[start_usize + 10] = @truncate(word >> 168 & 0xFF);
        self.data.items[start_usize + 11] = @truncate(word >> 160 & 0xFF);
        self.data.items[start_usize + 12] = @truncate(word >> 152 & 0xFF);
        self.data.items[start_usize + 13] = @truncate(word >> 144 & 0xFF);
        self.data.items[start_usize + 14] = @truncate(word >> 136 & 0xFF);
        self.data.items[start_usize + 15] = @truncate(word >> 128 & 0xFF);
        self.data.items[start_usize + 16] = @truncate(word >> 120 & 0xFF);
        self.data.items[start_usize + 17] = @truncate(word >> 112 & 0xFF);
        self.data.items[start_usize + 18] = @truncate(word >> 104 & 0xFF);
        self.data.items[start_usize + 19] = @truncate(word >> 96 & 0xFF);
        self.data.items[start_usize + 20] = @truncate(word >> 88 & 0xFF);
        self.data.items[start_usize + 21] = @truncate(word >> 80 & 0xFF);
        self.data.items[start_usize + 22] = @truncate(word >> 72 & 0xFF);
        self.data.items[start_usize + 23] = @truncate(word >> 64 & 0xFF);
        self.data.items[start_usize + 24] = @truncate(word >> 56 & 0xFF);
        self.data.items[start_usize + 25] = @truncate(word >> 48 & 0xFF);
        self.data.items[start_usize + 26] = @truncate(word >> 40 & 0xFF);
        self.data.items[start_usize + 27] = @truncate(word >> 32 & 0xFF);
        self.data.items[start_usize + 28] = @truncate(word >> 24 & 0xFF);
        self.data.items[start_usize + 29] = @truncate(word >> 16 & 0xFF);
        self.data.items[start_usize + 30] = @truncate(word >> 8 & 0xFF);
        self.data.items[start_usize + 31] = @truncate(word & 0xFF);
    }

    /// Loads the word at offset from memory.
    pub fn load(self: *Self, offset: u256) !u256 {
        // Fail if offset cannot be converted to usize.
        const offset_usize = std.math.cast(usize, offset) orelse return MemoryErr.MemoryReferenceTooLarge;

        // Return 0 of index out of bounds.
        if (self.len() <= offset_usize) {
            return 0;
        }

        var word: u256 = 0;
        word |= @as(u256, self.data.items[offset_usize]) << 248;
        word |= @as(u256, self.data.items[offset_usize + 1]) << 240;
        word |= @as(u256, self.data.items[offset_usize + 2]) << 232;
        word |= @as(u256, self.data.items[offset_usize + 3]) << 224;
        word |= @as(u256, self.data.items[offset_usize + 4]) << 216;
        word |= @as(u256, self.data.items[offset_usize + 5]) << 208;
        word |= @as(u256, self.data.items[offset_usize + 6]) << 200;
        word |= @as(u256, self.data.items[offset_usize + 7]) << 192;
        word |= @as(u256, self.data.items[offset_usize + 8]) << 184;
        word |= @as(u256, self.data.items[offset_usize + 9]) << 176;
        word |= @as(u256, self.data.items[offset_usize + 10]) << 168;
        word |= @as(u256, self.data.items[offset_usize + 11]) << 160;
        word |= @as(u256, self.data.items[offset_usize + 12]) << 152;
        word |= @as(u256, self.data.items[offset_usize + 13]) << 144;
        word |= @as(u256, self.data.items[offset_usize + 14]) << 136;
        word |= @as(u256, self.data.items[offset_usize + 15]) << 128;
        word |= @as(u256, self.data.items[offset_usize + 16]) << 120;
        word |= @as(u256, self.data.items[offset_usize + 17]) << 112;
        word |= @as(u256, self.data.items[offset_usize + 18]) << 104;
        word |= @as(u256, self.data.items[offset_usize + 19]) << 96;
        word |= @as(u256, self.data.items[offset_usize + 20]) << 88;
        word |= @as(u256, self.data.items[offset_usize + 21]) << 80;
        word |= @as(u256, self.data.items[offset_usize + 22]) << 72;
        word |= @as(u256, self.data.items[offset_usize + 23]) << 64;
        word |= @as(u256, self.data.items[offset_usize + 24]) << 56;
        word |= @as(u256, self.data.items[offset_usize + 25]) << 48;
        word |= @as(u256, self.data.items[offset_usize + 26]) << 40;
        word |= @as(u256, self.data.items[offset_usize + 27]) << 32;
        word |= @as(u256, self.data.items[offset_usize + 28]) << 24;
        word |= @as(u256, self.data.items[offset_usize + 29]) << 16;
        word |= @as(u256, self.data.items[offset_usize + 30]) << 8;
        word |= @as(u256, self.data.items[offset_usize + 31]) << 0;

        return word;
    }

    pub fn print(self: *Self) void {
        std.debug.print("memory summary:\n", .{});
        for (self.data.items, 0..) |_, i| {
            if (i > 32 * 10) {
                break;
            }

            if (i % 32 == 0) {
                std.debug.print("0x{x:3}: 0x", .{i});
                for (0..31) |j| {
                    std.debug.print("{x}", .{self.data.items[(32 * (i / 32)) + j]});
                }
                std.debug.print("\n", .{});
            }
        }
    }
};

test "Simple store and load" {
    std.debug.print("\n", .{});
    const allocator = std.testing.allocator;

    var memory = Memory.init(allocator);
    defer memory.deinit();

    const word = @as(u256, 0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF);
    const offset = @as(u256, 0);
    try memory.store(offset, word);

    memory.print();

    const loaded = try memory.load(offset);

    try std.testing.expectEqual(word, loaded);
}

test "Allocate 5 pages" {
    std.debug.print("\n", .{});
    const allocator = std.testing.allocator;

    // TODO: How to just import in tests?
    const PAGE_SIZE = 4 * 1024;

    var memory = Memory.init(allocator);
    defer memory.deinit();

    const word = @as(u256, 0x00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF);

    const len: usize = 5 * PAGE_SIZE;

    // Note that memory is word allocated.
    for (0..(len / 32)) |i| {
        try memory.store(i * 32, word);
    }

    const gotLen = memory.len();

    try std.testing.expectEqual(len, gotLen);
}
