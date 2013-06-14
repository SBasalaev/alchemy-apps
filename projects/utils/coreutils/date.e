/* Alchemy coreutils
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "string.eh"
use "time.eh"
use "version.eh"

const VERSION = "date" + COREUTILS_VERSION
const HELP = "Prints current date in default format."

def main(args: [String]): Int {
  // parse args
  var quit = false
  var exitcode = 0
  for (var i=0, i < args.len, i+=1) {
    var arg = args[i]
    if (arg == "-h") {
      println(HELP)
      quit = true
    } else if (arg == "-v") {
      println(VERSION)
      quit = true
    } else if (arg.ch(0) == '-') {
      stderr().println("Unknown option: "+arg)
      quit = true
      exitcode = 1
    }
  }
  // work!
  if (!quit) println(datestr(systime()))
  exitcode
}