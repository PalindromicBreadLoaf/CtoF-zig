const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    const line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;
    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

fn getConversion() !?[]const u8 {
    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();
    var buffer: [2]u8 = undefined;

    try stdout.writeAll("Would you like to convert from [C]elsius or [F]ahrenheit?\n");
    const input = (try nextLine(stdin.reader(), &buffer)).?;

    return input;
}

fn convertCToF(temp_c: f16) !?f16 {
    const temp_f = (temp_c * (9.0 / 5.0)) + 32;

    return temp_f;
}

fn convertFToC(temp_f: f16) !?f16 {
    const temp_c = (temp_f - 32) * (5.0 / 9.0);

    return temp_c;
}

pub fn main() !void {
    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();
    var buffer: [5]u8 = undefined;
    var celsius: bool = undefined;

    var temp_input = (try getConversion()).?;

    if (eql(u8, temp_input, "C")) {
        try stdout.writeAll("Your input was Celsius\n");
        celsius = true;
    } else if (eql(u8, temp_input, "F")) {
        try stdout.writeAll("Your input was Fahrenheit\n");
        celsius = false;
    } else {
        try stdout.writeAll("Your input was neither C or F...\n");
        try stdout.writeAll("Aborting\n");
        return;
    }

    try stdout.writeAll("Is this acceptable?\n");
    var correct_input = (try nextLine(stdin.reader(), &buffer)).?;

    while (!eql(u8, correct_input, "Y")) {
        temp_input = (try getConversion()).?;

        try stdout.writeAll("Is this acceptable?\n");
        correct_input = (try nextLine(stdin.reader(), &buffer)).?;
    }

    if (celsius) {
        try stdout.writeAll("Please input the temperature in celsius\n");
        const temp_c_str = (try nextLine(stdin.reader(), &buffer)).?;
        const temp_c = try std.fmt.parseFloat(f16, temp_c_str);
        const temp_f: f16 = (try convertCToF(temp_c)).?;
        try stdout.writer().print("The temp {d:.1}°F in fahrenheit is {d:.1}°C\n", .{ temp_c, temp_f });
    } else {
        try stdout.writeAll("Please input the temperature in fahrenheit\n");
        const temp_f_str: []const u8 = (try nextLine(stdin.reader(), &buffer)).?;
        const temp_f = try std.fmt.parseFloat(f16, temp_f_str);
        const temp_c: f16 = (try convertFToC(temp_f)).?;
        try stdout.writer().print("The temp {d:.1}°C is {d:.1}°F\n", .{ temp_f, temp_c });
    }

    try stdout.writeAll("Goodbye!\n");
}
