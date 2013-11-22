use "lexer.eh"
use "error.eh"
use "strbuf.eh"

/* Character categories. */
const CAT_WORD = 1
const CAT_COMMENT = 2
const CAT_QUOTE = 3
const CAT_WS = 4

const NO_CHAR = -2
const EOF_CHAR = -1

type Lexer {
  r: Reader,
  types: [Byte],
  line: Int = 1,
  pushedBack: Bool = false,
  options: Int,
  nextchar: Int = NO_CHAR,
  ttype: Int,
  tvalue: String
}

def Lexer.new(r: Reader, options: Int) {
  this.r = r
  this.types = new [Byte](128)
  this.options = options
  this.wsChars('\0', ' ')
  this.wordChars('0', '9')
  this.wordChars('a', 'z')
  this.wordChars('A', 'Z')
  this.wordChar('_')
  this.quoteChar('"')
  this.quoteChar('\'')
}

def Lexer.resetSyntax(options: Int) {
  for (var i=0, i<128, i+=1) this.types[i] = 0
  this.options = options
}

def Lexer.wsChars(from: Char, to: Char) {
  if (from > 128 || to > 128)
    error(ERR_ILL_ARG, "Non-ASCII character")
  for (var i=from, i<=to, i+=1)
    this.types[i] = CAT_WS
}

def Lexer.wsChar(ch: Char) {
  if (ch > 128)
    error(ERR_ILL_ARG, "Non-ASCII character")
  this.types[ch] = CAT_WS
}

def Lexer.wordChars(from: Char, to: Char) {
  if (from > 128 || to > 128)
    error(ERR_ILL_ARG, "Non-ASCII character")
  for (var i=from, i<=to, i+=1)
    this.types[i] = CAT_WORD
}

def Lexer.wordChar(ch: Char) {
  if (ch > 128)
    error(ERR_ILL_ARG, "Non-ASCII character")
  this.types[ch] = CAT_WORD
}

def Lexer.commentChar(ch: Char) {
  if (ch > 128)
    error(ERR_ILL_ARG, "Non-ASCII character")
  this.types[ch] = CAT_COMMENT
}

def Lexer.quoteChar(ch: Char) {
  if (ch > 128)
    error(ERR_ILL_ARG, "Non-ASCII character")
  this.types[ch] = CAT_QUOTE
}

def Lexer.lineNumber(): Int {
  this.line
}

def Lexer.pushBack() {
  this.pushedBack = true
}

def Lexer.tokenType(): Int {
  this.ttype
}

def Lexer.value(): String {
  this.tvalue
}

def Lexer.nextChar(): Int {
  var ch = this.nextchar
  if (ch == NO_CHAR) {
    ch = this.r.read()
    if (ch == '\n') this.line += 1
  } else {
    this.nextchar = NO_CHAR
  }
  ch
}

def hexdigit(ch: Int): Int {
  if (ch >= '0' && ch <= '9') ch-'0'
  else if (ch >= 'A' && ch <= 'F') ch-'A'+10
  else if (ch >= 'a' && ch <= 'f') ch-'a'+10
  else -1
}

const SKIP_END = 0
const SKIP_WS = 1
const SKIP_LINE = 2
const SKIP_BLOCK = 3

def Lexer.next(): Int {
  if (this.pushedBack) {
    this.pushedBack = false
    this.ttype
  } else {
    var ch = this.nextChar()
    var types = this.types

    // skip whitespaces and comments
    var skipmode: Int
    do {
      skipmode = SKIP_END
      if (ch >= 0 && ch < 128) {
        if (types[ch] == CAT_WS) {
          skipmode = SKIP_WS
        } else if (types[ch] == CAT_COMMENT) {
          skipmode = SKIP_LINE
        } else if (ch == '/') {
          ch = this.nextChar()
          if (ch == '/' && (this.options & PARSE_SLASHSLASH_COMMENTS) != 0) {
            skipmode = SKIP_LINE
          } else if (ch == '*' && (this.options & PARSE_SLASHSTAR_COMMENTS) != 0) {
            skipmode = SKIP_BLOCK
          } else {
            this.nextchar = ch
            ch = '/'
          }
        }
      }

      switch (skipmode) {
        SKIP_WS: {
          while (ch >= 0 && ch < 128 && types[ch] == CAT_WS) {
            ch = this.nextChar()
          }
        }
        SKIP_LINE: {
          do {
            ch = this.nextChar()
          } while (ch > 0 && ch != '\n')
          if (ch == '\n') ch = this.nextChar()
        }
        SKIP_BLOCK: {
          ch = this.nextChar()
          var ch2 = this.nextChar()
          while (ch2 > 0 && (ch != '*' || ch2 != '/')) {
            ch = ch2
            ch2 = this.nextChar()
          }
          ch = ch2
        }
      }
    } while (skipmode != SKIP_END)

    if (ch < 0) {
      // EOF
      this.ttype = TT_EOF
      this.tvalue = "<EOF>"
    } else if ((this.options & PARSE_DECIMAL) != 0 && (ch >= '0' && ch <= '9' || ch == '.')) {
      // dot and numbers
      var dotseen = ch == '.'
      var justdot = false
      if (dotseen) {
        ch = this.nextChar()
        if (ch < '0' || ch > '9') {
          justdot = true
          this.nextchar = ch
        }
      }

      if (justdot) {
        this.ttype = '.'
        this.tvalue = "."
      } else {
        var buf = new StrBuf()
        if (dotseen) buf.append("0.")
        while (ch >= '0' && ch <= '9') {
          buf.append(ch.cast(Char))
          ch = this.nextChar()
        }
        if (!dotseen && ch == '.') {
          buf.append('.')
          ch = this.nextChar()
          while (ch >= '0' && ch <= '9') {
            buf.append(ch.cast(Char))
            ch = this.nextChar()
          }
        }
        if (ch == 'e' || ch == 'E') {
          dotseen = true
          buf.append('e')
          ch = this.nextChar()
          if (ch == '-' || ch == '+') {
            buf.append(ch.cast(Char))
            ch = this.nextChar()
          }
          while (ch >= '0' && ch <= '9') {
            buf.append(ch.cast(Char))
            ch = this.nextChar()
          }
        }
        this.nextchar = ch
        this.ttype = if (dotseen) TT_FLOAT else TT_INT
        this.tvalue = buf.tostr()
      }
    } else if (ch >= 128 || types[ch] == CAT_WORD) {
      // parse word
      var buf = new StrBuf()
      do {
        buf.append(ch.cast(Char))
        ch = this.nextChar()
      } while (ch >= 0 && (ch >= 128 || types[ch] == CAT_WORD))
      this.nextchar = ch
      this.ttype = TT_WORD
      this.tvalue = buf.tostr()
    } else if (types[ch] == CAT_QUOTE) {
      // parse quoted string
      var quotech = ch
      var buf = new StrBuf()
      ch = this.nextChar()
      while (ch >= 0 && ch != quotech) {
        if (ch == '\\') {
          ch = this.nextChar()
          switch (ch) {
            'n':
              ch = '\n'
            'r':
              ch = '\r'
            't':
              ch = '\t'
            'f':
              ch = '\f'
            'b':
              ch = '\b'
            '0', '1', '2', '3',
            '4', '5', '6', '7': {
              var num = ch-'0'
              ch = this.nextChar()
              if (ch >= '0' && ch <= '7') {
                num = (num << 3) + ch-'0'
                if (num <= '\37') {
                  ch = this.nextChar()
                  if (ch >= '0' && ch <= '7') {
                    num = (num << 3) + ch-'0'
                  } else {
                    this.nextchar = ch
                  }
                }
              } else {
                this.nextchar = ch
              }
              ch = num
            }
            'x': {
              ch = (hexdigit(this.nextChar()) << 4)
                 | hexdigit(this.nextChar())
            }
            'u': {
              ch = (hexdigit(this.nextChar()) << 12)
                 | (hexdigit(this.nextChar()) << 8)
                 | (hexdigit(this.nextChar()) << 4)
                 | hexdigit(this.nextChar())
            }
          }
          buf.append(ch.cast(Char))
        } else if (ch >= 0) {
          buf.append(ch.cast(Char))
        }
        ch = this.nextChar()
      }
      this.ttype = quotech
      this.tvalue = buf.tostr()
    } else {
      // ordinary character
      this.ttype = ch
      this.tvalue = ch.cast(Char).tostr()
    }

    this.ttype
  }
}
