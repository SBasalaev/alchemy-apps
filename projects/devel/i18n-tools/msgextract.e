use "tokenizer.eh"
use "list.eh"
use "strbuf.eh"
use "version.eh"

const HELP = "Extracts translatable strings from sources."
const VERSION = "msgextract 0.1" + I18N_TOOLS_VERSION

def hexchar(n: Int): Char {
  n &= 0xF
  if (n <= 9) n + '0' else n + ('A'-10)
}

def escape(str: String): String {
  var buf = new StrBuf()
  for (var i=0, i<str.len(), i+=1) {
    var ch = str[i]
    if (ch >= ' ' && ch < 127) {
      buf.addch(ch)
    } else if (ch == '\n') {
      buf.append("\\n")
    } else if (ch == '\r') {
      buf.append("\\r")
    } else if (ch == '\t') {
      buf.append("\\t")
    } else {
      buf.append("\\u")
      .addch(hexchar(ch >> 24))
      .addch(hexchar(ch >> 16))
      .addch(hexchar(ch >> 8))
      .addch(hexchar(ch))
    }
  }
  buf.tostr()
}

def main(args: [String]): Int {
  // parse args
  var output = "messages.txt"
  var files = new List()
  var quit = false
  var exitcode = 0
  var waitout = false
  for (var i=0, i<args.len, i+=1) {
    var arg = args[i]
    if (waitout) {
      output = arg
      waitout = false
    } else if (arg == "-h") {
      println(HELP)
      quit = true
    } else if (arg == "-v") {
      println(VERSION)
      quit = true
    } else if (arg == "-o") {
      waitout = true
    } else {
      files.add(arg)
    }
  }
  if (waitout) {
    stderr().println("Option -o expects filename")
    exitcode = 1
    quit = true
  }
  
  // process files
  if (!quit && files.len() > 0) {
    // parse files and extract strings
    var strings = new List()
    var positions = new List()
    for (var i=0, i<files.len(), i+=1) {
      var fname = files[i].cast(String)
      var r = utfreader(fopen_r(fname))
      var tok = new Tokenizer(r)
      var tt = tok.next()
      while (tt != TT_EOF) {
        // we are expecting: _ ( "string1" + ... + "stringN" )
        if (tt == TT_WORD && tok.value() == "_" && tok.next() == '(' && tok.next() == '"') {
          var str = tok.value()
          var good = true
          while ({tt = tok.next(); tt != ')' && tt != TT_EOF}) {
            if (tt == '+' && tok.next() == '"') {
              str += tok.value()
            } else {
              good = false
            }
          }
          if (good && str != "") {
            var idx = strings.indexof(str)
            if (idx < 0) {
              strings.add(str)
              positions.add(fname + ':' + tok.lineno())
            } else {
              positions[idx] = "" + positions[idx] + '\n' + fname + ':' + tok.lineno()
            }
          }
        }
        tt = tok.next()
      }
      r.close()
    }
    
    // write strings
    var out = if (output == "-") stdout() else fopen_w(output)
    for (var i=0, i<strings.len(), i+=1) {
      var escstr = escape(strings[i].cast(String))
      out.println("\"" + escstr + "\" = \"\"")
    }
    if (out != stdout()) out.close()
  }

  exitcode
}