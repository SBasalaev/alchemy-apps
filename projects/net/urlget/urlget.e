/* urlget 1.3
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "string.eh"

const VERSION = "urlget 1.3"
const HELP = "Retrieve file by its URL.\n" +
             "Usage: urlget url [file]"

def main(args: [String]): Int {
  // parse arguments
  var quit = false
  var exitcode = 0
  var file: String = null
  var url: String = null
  for (var i=0, i < args.len, i+=1) {
    var arg = args[i]
    if (arg == "-h") {
      println(HELP)
      quit = true
    } else if (arg == "-v") {
      println(VERSION)
      quit = true
    } else if (arg[0] == '-') {
      stderr().println("urlget: unknown option " + arg)
      quit = true
      exitcode = 1
    } else if (url == null) {
      url = arg
    } else {
      file = arg
    }
  }
  // process
  if (!quit) {
    if (url == null) {
      stderr().println("urlget: No URL specified")
      exitcode = 1
    } else {
      var in = readurl(url)
      var out = if (file != null) fopen_w(file) else stdout()
      out.writeall(in)
      in.close()
      out.flush()
      if (file != null) out.close()
    }
  }
  exitcode
}
