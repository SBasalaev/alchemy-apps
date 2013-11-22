use "textio.eh"

type Lexer;

// token types
const TT_EOF = -1
const TT_WORD = -2
const TT_INT = -3
const TT_FLOAT = -4

// lexer options
const PARSE_DECIMAL = 1
const PARSE_SLASHSLASH_COMMENTS = 4
const PARSE_SLASHSTAR_COMMENTS = 8

// constructor
def Lexer.new(r: Reader, options: Int);
def Lexer.resetSyntax(options: Int);

def Lexer.wsChars(from: Char, to: Char);
def Lexer.wsChar(ch: Char);
def Lexer.wordChars(from: Char, to: Char);
def Lexer.wordChar(ch: Char);
def Lexer.commentChar(ch: Char);
def Lexer.quoteChar(ch: Char);

def Lexer.next(): Int;
def Lexer.tokenType(): Int;
def Lexer.value(): String;
def Lexer.lineNumber(): Int;
def Lexer.pushBack();
