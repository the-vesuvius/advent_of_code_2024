const std = @import("std");
const input = @embedFile("./input.txt");

const WIDTH = 141;
const HEIGHT = 140;
const NEEDLE = "XMAS";

pub fn main() !void {
    var input_matrix: [HEIGHT][WIDTH]u8 = undefined;

    var i: usize = 0;
    var j: usize = 0;
    for (input) |byte| {
        if (byte == '\n') {
            i += 1;
            j = 0;
            continue;
        }

        input_matrix[i][j] = byte;
        j += 1;
    }

    var total: usize = 0;

    for (input_matrix, 0..) |row_val, row| {
        for (row_val, 0..) |col_val, col| {
            if (col_val == 'A') {
                total += seek_xmas(input_matrix, row, col);
            }
        }
    }
    std.debug.print("RESULT: {d}\n", .{total});
}

fn seek_xmas(data: [HEIGHT][WIDTH]u8, start_row: usize, start_col: usize) usize {
    const left = check_left_mas(data, start_row, start_col) catch false;
    const right = check_right_mas(data, start_row, start_col) catch false;

    if (left and right) return 1;
    return 0;
}

fn check_left_mas(data: [HEIGHT][WIDTH]u8, start_row: usize, start_col: usize) !bool {
    const allocator = std.heap.page_allocator;
    var buf = std.ArrayList(u8).init(allocator);

    const start_row_signed: i32 = @intCast(start_row);
    const start_col_signed: i32 = @intCast(start_col);

    var row_signed = start_row_signed - 1;
    var col_signed = start_col_signed - 1;
    if (row_signed >= 0 and col_signed >= 0) {
        const row: usize = @intCast(row_signed);
        const col: usize = @intCast(col_signed);
        try buf.append(data[row][col]);
    }
    try buf.append('A');
    row_signed = start_row_signed + 1;
    col_signed = start_col_signed + 1;
    if (row_signed < HEIGHT and col_signed < WIDTH) {
        const row: usize = @intCast(row_signed);
        const col: usize = @intCast(col_signed);
        try buf.append(data[row][col]);
    }
    const left = arrayListToString(&buf, allocator) catch "";
    if (std.mem.eql(u8, left, "MAS") or std.mem.eql(u8, left, "SAM")) {
        return true;
    }

    return false;
}

fn check_right_mas(data: [HEIGHT][WIDTH]u8, start_row: usize, start_col: usize) !bool {
    const allocator = std.heap.page_allocator;
    var buf = std.ArrayList(u8).init(allocator);

    const start_row_signed: i32 = @intCast(start_row);
    const start_col_signed: i32 = @intCast(start_col);

    var row_signed = start_row_signed - 1;
    var col_signed = start_col_signed + 1;
    if (row_signed >= 0 and col_signed < WIDTH) {
        const row: usize = @intCast(row_signed);
        const col: usize = @intCast(col_signed);
        try buf.append(data[row][col]);
    }
    try buf.append('A');
    row_signed = start_row_signed + 1;
    col_signed = start_col_signed - 1;
    if (row_signed < HEIGHT and col_signed >= 0) {
        const row: usize = @intCast(row_signed);
        const col: usize = @intCast(col_signed);
        try buf.append(data[row][col]);
    }
    const right = arrayListToString(&buf, allocator) catch "";
    if (std.mem.eql(u8, right, "MAS") or std.mem.eql(u8, right, "SAM")) {
        return true;
    }

    return false;
}

fn check_direction(data: [HEIGHT][WIDTH]u8, start_row: usize, start_col: usize, row_dir: i8, col_dir: i8) bool {
    var iter_num: usize = 1;

    while (iter_num < 4) : (iter_num += 1) {
        const start_row_signed: i32 = @intCast(start_row);
        const start_col_signed: i32 = @intCast(start_col);

        const iter_num_signed: i32 = @intCast(iter_num);
        const row_signed = start_row_signed + iter_num_signed * row_dir;
        const col_signed = start_col_signed + iter_num_signed * col_dir;

        if (row_signed < 0 or col_signed < 0) return false;

        const row: usize = @intCast(row_signed);
        const col: usize = @intCast(col_signed);

        if (row >= HEIGHT or col >= WIDTH) return false;
        if (data[row][col] != NEEDLE[iter_num]) return false;
    }

    return true;
}

fn arrayListToString(arrayList: *const std.ArrayList(u8), allocator: std.mem.Allocator) ![]u8 {
    const slice = arrayList.items; // Get the slice from the ArrayList
    const result = try allocator.alloc(u8, slice.len); // Allocate memory for the result
    std.mem.copyForwards(u8, result, slice); // Copy the data from the ArrayList slice to the allocated buffer
    return result;
}
