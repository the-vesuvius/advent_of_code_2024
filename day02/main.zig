const std = @import("std");
const input = @embedFile("./input.txt");

const loc_num = 1000;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var num_buf = std.ArrayList(u8).init(allocator);
    defer num_buf.deinit();
    var line_buf = std.ArrayList(i32).init(allocator);
    defer line_buf.deinit();

    var safe_count: usize = 0;

    for (input) |byte| {
        if ((byte < 48) or (byte > 57)) {
            defer num_buf.clearRetainingCapacity();
            if (num_buf.items.len > 0) {
                const num_str = try arrayListToString(&num_buf, allocator);
                const num: i32 = try std.fmt.parseInt(i32, num_str, 10);
                try line_buf.append(num);
            }
        } else {
            try num_buf.append(byte);
        }

        if (byte == '\n') {
            defer line_buf.clearRetainingCapacity();
            const line: []i32 = try arrayListToSlice(&line_buf, allocator);
            if (is_safe(line)) {
                safe_count += 1;
            } else if (try is_problem_dampener_safe(line, allocator)) {
                safe_count += 1;
            }
        }
    }

    std.debug.print("Safe: {d}\n", .{safe_count});
}

fn is_problem_dampener_safe(line: []i32, allocator: std.mem.Allocator) !bool {
    var i: usize = 0;
    while (i < line.len) : (i += 1) {
        if (is_safe(try get_slice_ignoring_idx(line, i, allocator))) {
            return true;
        }
    }

    return false;
}

fn get_slice_ignoring_idx(line: []i32, idx: usize, allocator: std.mem.Allocator) ![]i32 {
    var line_buf = std.ArrayList(i32).init(allocator);
    defer line_buf.deinit();

    var i: usize = 0;
    while (i < line.len) : (i += 1) {
        if (i == idx) continue;

        try line_buf.append(line[i]);
    }

    return arrayListToSlice(&line_buf, allocator);
}

fn is_safe(line: []i32) bool {
    var trend: bool = get_trend_direction(line[0], line[1]);
    var i: usize = 1;
    while (i < line.len) : (i += 1) {
        const num = line[i];
        const prev_num = line[i - 1];
        const diff = prev_num - num;
        const trend_tmp = diff > 0;
        if (@abs(diff) < 1 or @abs(diff) > 3) {
            return false;
        }

        if (trend != trend_tmp) {
            return false;
        }

        trend = diff > 0;
    }

    return true;
}

fn get_trend_direction(a: i32, b: i32) bool {
    return (a - b) > 0;
}

fn arrayListToString(arrayList: *const std.ArrayList(u8), allocator: std.mem.Allocator) ![]u8 {
    const slice = arrayList.items; // Get the slice from the ArrayList
    const result = try allocator.alloc(u8, slice.len); // Allocate memory for the result
    std.mem.copyForwards(u8, result, slice); // Copy the data from the ArrayList slice to the allocated buffer
    return result;
}

fn arrayListToSlice(arrayList: *const std.ArrayList(i32), allocator: std.mem.Allocator) ![]i32 {
    const slice = arrayList.items; // Get the slice from the ArrayList
    const result = try allocator.alloc(i32, slice.len); // Allocate memory for the result
    std.mem.copyForwards(i32, result, slice); // Copy the data from the ArrayList slice to the allocated buffer
    return result;
}
