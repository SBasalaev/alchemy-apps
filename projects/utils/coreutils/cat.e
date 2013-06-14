/* Alchemy coreutils
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "version.eh"

const VERSION = "cat" + COREUTILS_VERSION
const HELP = "Prints given files or stdin to the stdout."

def main(args: [String]): Int {
  // parse args
  var quit = false
  var exitcode = 0
  var files = new List()
  for (var i=0, i<args.len && !quit, i+=1) {
    var arg = args[i]
    if (arg == "-h") {
      println(HELP)
      quit = true
    } else if (arg == "-v") {
      println(VERSION)
      quit = true
    } else if (arg.ch(0) == '-') {
      stderr().println("Unknown option: "+arg)
      exitcode = 1
      quit = true
    } else {
      files.add(arg)
    }
  }
  // copy to the output
  if (!quit) {
    if (files.len() == 0) {
      stdout().writeall(stdin())
      stdout().flush()
    } else for (var i=0, i<files.len(), i+=1) {
      var in = fopen_r(files[i].cast(String))
      stdout().writeall(in)
      stdout().flush()
      in.close()
    }
  }
  exitcode
}
