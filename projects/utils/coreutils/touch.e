/* Alchemy coreutils
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "version.eh"

const VERSION = "touch" + COREUTILS_VERSION
const HELP = "Update file timestamp."

def main(args: [String]): Int {
  // parse args
  var quit = false
  var exitcode = 0
  var files = new List()
  for (var i=0, i < args.len, i += 1) {
    var arg = args[i]
    if (arg == "-h") {
      println(HELP)
      quit = true
    } else if (arg == "-v") {
      println(VERSION)
      quit = true
    } else if (arg[0] == '-') {
      stderr().println("Unknown option: "+arg)
      exitcode = 1
      quit = true
    } else {
      files.add(arg)
    }
  }
  // touch files
  if (!quit) {
    var len = files.len()
    if (len == 0) {
      stderr().println("touch: no arguments")
      exitcode == 1
    } else {
      for (var i=0, i<len, i += 1) {
        var out = fopen_a(files[i].cast(String))
        out.flush()
        out.close()
      }
    }
  }
  exitcode
}