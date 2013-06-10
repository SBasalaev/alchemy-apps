use "version.eh"
use "tokenizer.eh"
use "textio.eh"
use "dataio.eh"
use "list.eh"

const HELP = "Compiles translation files."
const VERSION = "msgfmt 0.1" + I18N_TOOLS_VERSION

// magic for format v1 ('L' 10 'N' 1)
const MAGIC_1 = ('L' << 24) | (10 << 16) | ('N' << 8) | 1

def main(args: [String]): Int {
  // parse args
  var exitcode = 0
  var quit = false
  if (args.len == 0) {
    quit = true
    exitcode = 2
    stderr().println("msgfmt: missing input name")
  } else if (args[0] == "-v") {
    quit = true
    println(VERSION)
  } else if (args[0] == "-h") {
    quit = true
    println(HELP)
  } else if (args.len < 2) {
    quit = true
    exitcode = 2
    stderr().println("msgfmt: missing output name")
  }
  // process translation
  if (!quit) {
    var srcstrings = new List()
    var trstrings = new List()

    // reading input
    var r = utfreader(fopen_r(args[0]))
    var tok = new Tokenizer(r)
    var tt = tok.next()
    while (exitcode == 0 && tt != TT_EOF) {
      if (tt == '#') {
        r.readline()
      } else if (tt != '"') {
        stderr().println(args[0] + ':' + tok.lineno() + ": syntax error, string expected")
        exitcode = 1
      } else {
        var src = tok.value()
        if (srcstrings.indexof(src) >= 0) {
          stderr().println(args[0] + ':' + tok.lineno() + ": syntax error, duplicate string")
          exitcode = 1
        } else if (tok.next() != '=') {
          stderr().println(args[0] + ':' + tok.lineno() + ": syntax error, = expected")
          exitcode = 1
        } else if (tok.next() != '"') {
          stderr().println(args[0] + ':' + tok.lineno() + ": syntax error, string expected")
          exitcode = 1
        } else {
          var tr = tok.value()
          if (tr != "") {
            srcstrings.add(src)
            trstrings.add(tr)
          }
        }
      }
      tt = tok.next()
    }
    r.close()

    // writing output
    var out = fopen_w(args[1])
    var count = srcstrings.len()
    out.writeint(MAGIC_1)
    out.writeshort(count)
    for (var i=0, i<count, i+=1) {
      out.writeutf(srcstrings[i].cast(String))
      out.writeutf(trstrings[i].cast(String))
    }
    out.close()
  }
  exitcode
}