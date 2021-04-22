//! Direct-coded lexer.

const std = @import("std");
const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var allocator = &arena.allocator;


const Token = struct {
    tag: Tag = undefined,
    start: usize = undefined,
    end: usize = undefined,

    const Tag = enum {
        double_brace_open,
        double_brace_close,
        equals_sign,
        double_quote,
        keyword_end,
        comma,
        ident,
        text
    };
};


// This is some {{i}}test text{{end i}}.
// {{link url="https://example.com"}}Here{{end link}}
// {{ignore_tags id="it1"}} {{end ignore_tags id="it1"}}
// ^^^ Ignores all tags except its end with same ID.


const Lexer = struct {
    text_buff: []const u8,
    index: usize,
    line: u32,
    col: u32,
    mode: Mode = .start,

    const Mode = enum {
        single_brace_open,
        single_brace_close,
        equals_sign,
        start,              // LOOKAT: same as text?
        text,               // General text, not in tags.
        identifier,         // Tag and param names.
        double_brace_open,  // Tag open.
        double_brace_close, // Tag close.
        string,             // Argument for tag params.
    };

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

    /// Tokenize entire string in one pass.
    fn lex(self: *Lexer) !void {
        var tokens = std.ArrayList(Token).init(allocator);
        var last_token_end: usize = 0;

        while (self.index < self.text_buff.len) {
            if (self.mode == .normal) {

                // "{{"
                if (self.text_buff[self.index] == '{'
                    and self.index+1 < self.text_buff.len
                    and self.text_buff[self.index+1] == '{'
                ) {
                    if (self.index > last_token_end) {
                        // Push text, if it exists.
                        try tokens.append(
                            Token {.tag=.text, .start=last_token_end, .end=self.index}
                        );
                        last_token_end = self.index - 1;
                    }

                    // Push brace open.
                    self.index += 2;
                    try tokens.append(
                        Token {
                            .tag = .double_brace_open,
                            .start = last_token_end,
                            .end = self.index
                        }
                    );

                    self.mode = .in_tag;
                }
            }
            else if (self.mode == .in_tag) {
                if (self.text_buff[self.index] == '}'
                    and self.index+1 < self.text_buff.len
                    and self.text_buff[self.index+1] == '}'
                ) {
                    self.index += 2;
                    self.mode = .normal;
                    try tokens.append(
                        Token {
                            .tag = .double_brace_close,
                            .start = last_token_end,
                            .end = self.index
                        }
                    );
                }
            }
            print("{}", .{tokens.items});
        }
    }
};



pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us. 日本語,", .{});
    var l = Lexer.init("Hello, world!");
    try l.lex();
}


