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
            if (col_val == 'X') {
                total += seek_xmas(input_matrix, row, col);
            }
        }
    }
    std.debug.print("RESULT: {d}\n", .{total});
}

fn seek_xmas(data: [HEIGHT][WIDTH]u8, start_row: usize, start_col: usize) usize {
    const results: [8]bool = .{
        check_direction(data, start_row, start_col, -1, -1),
        check_direction(data, start_row, start_col, -1, 0),
        check_direction(data, start_row, start_col, -1, 1),

        check_direction(data, start_row, start_col, 0, -1),
        check_direction(data, start_row, start_col, 0, 1),

        check_direction(data, start_row, start_col, 1, 1),
        check_direction(data, start_row, start_col, 1, 0),
        check_direction(data, start_row, start_col, 1, -1),
    };

    var total: usize = 0;
    for (results) |res| {
        if (res) total += 1;
    }

    return total;
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
