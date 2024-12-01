const std = @import("std");
const input = @embedFile("./input.txt");

const loc_num = 1000;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var num_buf = std.ArrayList(u8).init(allocator);
    var nums = std.ArrayList(i32).init(allocator);

    for (input) |byte| {
        if ((byte < 48) or (byte > 57)) {
            if (num_buf.items.len > 0) {
                const num_str = try arrayListToString(&num_buf, allocator);
                const num: i32 = try std.fmt.parseInt(i32, num_str, 10);
                try nums.append(num);

                num_buf.clearRetainingCapacity();
            }
        } else {
            try num_buf.append(byte);
        }
    }

    var left: [loc_num]i32 = undefined;
    var right: [loc_num]i32 = undefined;
    for (nums.items, 0..) |num, idx| {
        const i: usize = idx / 2;
        if (idx % 2 == 0) {
            left[i] = num;
        } else {
            right[i] = num;
        }
    }

    //PART 1
    // std.mem.sort(i32, &left, {}, comptime std.sort.asc(i32));
    // std.mem.sort(i32, &right, {}, comptime std.sort.asc(i32));
    // var dist: u64 = 0;
    // for (left, 0..) |_, i| {
    //     const diff: i32 = left[i] - right[i];
    //     dist += @abs(diff);
    // }

    // std.debug.print("{d}\n", .{dist});

    //PART 2
    var map = std.AutoHashMap(i32, [2]i32).init(
        allocator,
    );
    defer map.deinit();

    var similarity_score: i32 = 0;
    for (left) |left_val| {
        const map_val = map.get(left_val);
        if (map_val != null) {
            similarity_score += map_val.?[1];
            continue;
        }

        var total: i32 = 0;
        for (right) |right_val| {
            if (left_val == right_val) {
                total += 1;
            }
        }

        const score: i32 = left_val * total;
        similarity_score += score;
        try map.put(left_val, .{ total, score });
    }

    std.debug.print("{d}\n", .{similarity_score});
}

fn arrayListToString(arrayList: *const std.ArrayList(u8), allocator: std.mem.Allocator) ![]u8 {
    const slice = arrayList.items; // Get the slice from the ArrayList
    const result = try allocator.alloc(u8, slice.len); // Allocate memory for the result
    std.mem.copyForwards(u8, result, slice); // Copy the data from the ArrayList slice to the allocated buffer
    return result;
}
