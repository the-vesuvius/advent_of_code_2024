const std = @import("std");
const input = @embedFile("./input.txt");

const loc_num = 1000;
const N = 17708;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var num_buf = std.ArrayList(u8).init(allocator);

    var sum: u64 = 0;
    var num_pair: [2]i32 = undefined;

    var do: bool = true;

    var i: usize = 0;
    while (input[i] != 0) : (i += 1) {
        i = skip_until("md", input, i) catch break;

        if (input[i] == 'd') {
            if (std.mem.eql(u8, "do()", input[i .. i + 4])) {
                do = true;
            }

            if (std.mem.eql(u8, "don't()", input[i .. i + 7])) {
                do = false;
            }

            continue;
        }

        if (!std.mem.eql(u8, "mul(", input[i .. i + 4])) continue;

        i += 4;
        i = try read_number(&num_buf, input, i);
        defer num_buf.clearAndFree();
        defer num_pair = undefined;

        if (num_buf.items.len == 0) continue;
        num_pair[0] = try parse_number(&num_buf, allocator);

        if (input[i] != ',') continue;
        i += 1;

        num_buf.clearAndFree();
        i = try read_number(&num_buf, input, i);

        if (num_buf.items.len == 0) continue;
        num_pair[1] = try parse_number(&num_buf, allocator);

        if (input[i] != ')') continue;

        if (do) {
            sum += @intCast(num_pair[0] * num_pair[1]);
        }
    }
    std.debug.print("SUM: {d}\n", .{sum});
}

fn read_number(buf: *std.ArrayList(u8), data: *const [N:0]u8, idx: usize) !usize {
    var i: usize = idx;
    while (data[i] >= 48 and data[i] <= 57) : (i += 1) {
        try buf.*.append(data[i]);
    }

    return i;
}

fn skip_until(chars: []const u8, data: *const [N:0]u8, idx: usize) FileError!usize {
    var i: usize = idx;
    while (data[i] != 0) : (i += 1) {
        for (chars) |char| {
            if (char == data[i]) {
                return i;
            }
        }
    }

    return FileError.Eof;
}

const FileError = error{Eof};

fn parse_number(arrayList: *const std.ArrayList(u8), allocator: std.mem.Allocator) !i32 {
    const num_str = try arrayListToString(arrayList, allocator);
    return try std.fmt.parseInt(i32, num_str, 10);
}

fn arrayListToString(arrayList: *const std.ArrayList(u8), allocator: std.mem.Allocator) ![]u8 {
    const slice = arrayList.items; // Get the slice from the ArrayList
    const result = try allocator.alloc(u8, slice.len); // Allocate memory for the result
    std.mem.copyForwards(u8, result, slice); // Copy the data from the ArrayList slice to the allocated buffer
    return result;
}
