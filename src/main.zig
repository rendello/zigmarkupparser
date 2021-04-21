const std = @import("std");
const print = std.debug.print;

const Tk = enum {
    double_brace_open,
    double_brace_close,
    equals_sign,
    double_quote,
    comma,
    text
};

const LexState = enum {
    in_text,
    in_tag,
    in_str
}

const Lexer = struct {
    text_buff: []const u8,
    index: usize,
    line: u32,
    col: u32,

    fn init(text: []const u8) Lexer {
        // Skip the UTF-8 BOM if present; adapted from Zig lexer.
        const src_start = if (std.mem.startsWith(u8, text, "\xEF\xBB\xBF")) 3 else @as(usize, 0);
        return Lexer {
            .text_buff = text,
            .index = @intCast(u32, src_start),
            .line = 0,
            .col = @intCast(u32, src_start)
        };
    }

    fn peek(self: Lexer, index: u32) u8 {
        if (index < self.text_buff.len) {
            return self.text_buff[index];
        } else {
            return 1;
        }
    }

    fn lex(self: Lexer) void {
    }

};



pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us. 日本語,", .{});
    var l = Lexer.init("Hello, world!");
    print("{c}", .{l.peek(100)});
}

// {{i}} {{end i}}
// {{link url="https://example.com"}}Here{{end link}}


