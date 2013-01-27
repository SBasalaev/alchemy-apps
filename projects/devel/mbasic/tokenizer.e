use "tokenizer.eh"
use "string.eh"
use "strbuf.eh"

type Tokenizer {
  source: String,
  len: Int,
  offset: Int,
  ttype: Int,
  tvalue: String,
  pushback: Bool,
  raw: Bool
}

/* Creates new tokenizer. */
def new_tokenizer(): Tokenizer {
  new Tokenizer {
    len = 0,
    offset = 0,
    ttype = TT_EOF,
    tvalue = "<EOF>",
    pushback = false
  }
}

/* Sets new source to parse. */
def Tokenizer.set_source(source: String) {
  this.source = source
  this.len = source.len()
  this.offset = 0
  this.pushback = false
  this.raw = false
}

/* Returns type of the current token. */
def Tokenizer.get_type(): Int {
  this.ttype
}

/* Returns value of the current token. */
def Tokenizer.get_value(): String {
  this.tvalue
}

/* Pushes last token back to be read again by next(). */
def Tokenizer.pushback() {
  this.pushback = true
}

/* The tail of the source will be returned unparsed.
 * This is needed for commands like REM and DATA
 */
def Tokenizer.set_raw() {
  this.raw = true
}

/* Tests whether character is a word character. */
def is_wordchar(ch: Int): Bool {
  (ch >= 'a' && ch <= 'z') ||
  (ch >= 'A' && ch <= 'Z') ||
  (ch >= '0' && ch <= '9') ||
  (ch == '%') || (ch == '$')
}

/* Reads next token and returns its type. */
def Tokenizer.next(): Int {
  var source = this.source
  var len = this.len
  var offset = this.offset
  if (this.pushback) {
    this.pushback = false
    this.ttype
  } else if (offset >= len) {
    this.ttype = TT_EOF
    this.tvalue = "<EOF>"
    TT_EOF
  } else if (this.raw) {
    this.raw = false
    this.ttype = TT_STRING
    this.tvalue = source[offset:len].trim()
    this.offset = len
    TT_STRING
  } else {
    var ch = source[offset]
    
    // skip whitespaces
    while (offset < len-1 && ch == ' ') {
      offset += 1
      ch = source[offset]
    }
    
    if (ch == ' ') {
      // space at the end of source
      this.ttype = TT_EOF
      this.tvalue = null
    } else if (ch == '"') {
      // quoted string
      this.ttype = TT_STRING
      var sb = new_strbuf()
      var end = offset + 1
      while (end < len && {ch = source[end]; ch != '"'}) {
        if (ch == '\\' && end < len-1) {
          end += 1
          ch = source[end]
          switch (ch) {
            'n': ch = '\n';
            't': ch = '\t';
            'r': ch = '\r';
            'f': ch = '\f';
            'u': if (end < len-4) {
              ch = source[end+1:end+5].tointbase(16)
              end += 4
            }
            'x': if (end < len-2) {
              ch = source[end+1:end+3].tointbase(16)
              end += 2
            }
          }
          sb.addch(ch)
        } else {
          sb.addch(ch)
        }
        end += 1
      }
      this.tvalue = sb.tostr()
      offset = end
    } else if ((ch >= '0' && ch <= '9') || ch == '.') {
      // number or just dot
      if (ch == '.' && (offset >= len-1 || source[offset+1] < '0' || source[offset+1] > '9')) {
        this.ttype = TT_OPERATOR
        this.tvalue = "."
      } else {
        var dotseen = ch == '.'
        var end = offset + 1
        while (end < len &&
            {ch = source[end];; (ch >= '0' && ch <= '9') || (!dotseen && ch == '.')}) {
          if (ch == '.') dotseen = true
          end += 1
        }
        this.ttype = if (dotseen) TT_FLOAT else TT_INT
        this.tvalue = source[offset:end]
        offset = end-1
      }
    } else if (is_wordchar(ch)) {
      // identifier
      this.ttype = TT_WORD
      var end = offset+1
      while (end < len && is_wordchar(source[end])) {
        end += 1
      }
      this.tvalue = source[offset:end].ucase()
      offset = end-1
    } else {
      // operator
      this.ttype = TT_OPERATOR
      if (offset < len-1 && ch == '<' &&
          {var ch1 = source[offset+1]; ch1 == '>' || ch1 == '='}) {
        this.tvalue = source[offset:offset+2]
        offset += 1
      } else if (offset < len-1 && ch == '>' && source[offset+1] == '=') {
        this.tvalue = source[offset:offset+2]
        offset += 1        
      } else {
        this.tvalue = source[offset:offset+1]
      }
    }
    this.offset = offset + 1
    this.ttype
  }
}
