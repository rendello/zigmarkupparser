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


const Lexer = struct {
    text_buff: []const u8,
    index: usize,
    line: u32,
    col: u32,
    mode: Mode = .normal,

    const Mode = enum {
        normal,
        in_tag,
        in_str,
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

    /// Safe index, null == string end.
    fn look_ahead(self: Lexer, relative_index: u32) ?u8 {
        const new_index = self.index + relative_index;
        if (new_index < self.text_buff.len) {
            return self.text_buff[new_index];
        } else {
            return null;
        }
    }

    /// Tokenize entire string in one pass.
    fn lex(self: Lexer) void {
        var tokens = std.ArrayList(Token).init(allocator);
        var last_token_end: usize = 0;

        while (self.index < self.text_buff.len) {
            if (mode == .normal) {
                if (self.text_buffer[self.index] == '{'
                    and self.look_ahead(1) == '{'
                    and self.look_ahead(2) != '{'
                ) {
                    // Push text.
                    tokens.append(
                        Token {
                            .tag = .text,
                            .start = last_token_end,
                            .end = self.index
                        }
                    );

                    // Push brace open.
                    self.index += 2;
                    self.mode = in_tag;
                    t.tag = .double_brace_open;
                    t.end = self.index;
                    return t;
                }
            }
            else if (mode == .in_tag) {
                if (self.text_buffer[self.index] == '}'
                    and self.look_ahead(1) == '}'
                ) {
                    self.index += 2;
                    self.mode = normal;
                    t.tag = .double_brace_close;
                    t.end = self.index;
                    return t;
                }
            }
        }
    }
};



pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us. 日本語,", .{});
    var l = Lexer.init("Hello, world!");
}


