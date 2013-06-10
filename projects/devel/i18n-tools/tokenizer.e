use "tokenizer.eh"
use "strbuf.eh"

const NO_CHAR = -2

type Tokenizer {
  r: Reader,
  ttype: Int,
  tval: String,
  nextch: Int = NO_CHAR,
  pushedback: Bool = false,
  lineno: Int = 1
}

def Tokenizer.new(r: Reader) {
  this.r = r
}

def Tokenizer.pushback() {
  this.pushedback = true
}

def Tokenizer.ttype(): Int = this.ttype
def Tokenizer.value(): String = this.tval
def Tokenizer.lineno(): Int = this.lineno

def Tokenizer.nextchar(): Int {
  var ch = this.nextch
  if (ch == NO_CHAR) {
    ch = this.r.read()
    if (ch == '\n') this.lineno += 1
  } else {
    this.nextch = NO_CHAR
  }
  ch
}

def is_wordchar(ch: Int): Bool {
  (ch >= '0' && ch <= '9') ||
  (ch >= 'A' && ch <= 'Z') ||
  (ch >= 'a' && ch <= 'z') ||
  (ch == '_')
}

def hexdigit(ch: Int): Int {
  if (ch >= '0' && ch <= '9') ch - '0'
  else if (ch >= 'a' && ch <= 'f') ch - ('a' - 10)
  else if (ch >= 'A' && ch <= 'F') ch - ('A' - 10)
  else -1
}

def Tokenizer.next(): Int {
  if (this.pushedback) {
    this.pushedback = false
  } else {
    var ch: Int
    
    // skip whitespaces
    do ch = this.nextchar()
    while (ch >= 0 && ch <= ' ')
    
    if (ch < 0) {
      this.tval = null
      this.ttype = TT_EOF
    } else if (ch == '/') {
      ch = this.nextchar()
      if (ch == '/') {
        // skip line comment
        do ch = this.nextchar()
        while (ch >= 0 && ch != '\n')
        this.ttype = this.next()
      } else if (ch == '*') {
        // skip block comment
        ch = this.nextchar()
        var ch2 = this.nextchar()
        while (ch2 >= 0 && (ch != '*' || ch2 != '/')) {
          ch = ch2
          ch2 = this.nextchar()
        }
        this.ttype = this.nextchar()
      } else {
        this.nextch = ch
        this.tval = null
        this.ttype = '/'
      }
    } else if (ch == '\'' || ch == '"' || ch == '`') {
      var bound = ch
      var buf = new StrBuf()
      ch = this.nextchar()
      while (ch >= 0 && ch != bound) {
        if (ch == '\\') {
          ch = this.nextchar()
          switch (ch) {
            'n': ch = '\n'
            't': ch = '\t'
            'r': ch = '\r'
            'b': ch = '\b'
            'f': ch = '\f'
            'u': { //four hex digits must follow
              var u1 = hexdigit(this.nextchar())
              var u2 = hexdigit(this.nextchar())
              var u3 = hexdigit(this.nextchar())
              var u4 = hexdigit(this.nextchar())
              ch = (u1 << 12) | (u2 << 8) | (u3 << 4) | u4
            }
          }
        }
        buf.addch(ch)
        ch = this.nextchar()
      }
      this.tval = buf.tostr()
      this.ttype = bound
    } else if (is_wordchar(ch)) {
      var buf = new StrBuf()
      do {
        buf.addch(ch)
        ch = this.nextchar()
      } while (ch >= 0 && is_wordchar(ch))
      this.nextch = ch
      this.tval = buf.tostr()
      this.ttype = TT_WORD
    } else {
      this.tval = null
      this.ttype = ch
    }
  }
  
  this.ttype
}
