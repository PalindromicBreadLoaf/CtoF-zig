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

    try stdout.writeAll("Would you like to convert to [C]elsius or [F]ahrenheit?\n");
    const input = (try nextLine(stdin.reader(), &buffer)).?;

    return input;
}

pub fn main() !void {
    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();
    var buffer: [2]u8 = undefined;

    var temp_input = (try getConversion()).?;

    if (eql(u8, temp_input, "C")) {
        try stdout.writeAll("Your input was Celsius\n");
    } else if (eql(u8, temp_input, "F")) {
        try stdout.writeAll("Your input was Fahrenheit\n");
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
}
