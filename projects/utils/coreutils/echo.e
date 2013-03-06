/* Alchemy coreutils
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "version.eh"

const VERSION = "echo " + C_VERSION
const HELP = "Prints strings to the stdout."

def main(args: [String]): Int {
  // parse args
  var len = args.len
  var quit = false
  var exitcode = 0
  var strings = new_list()
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
    } else {
      strings.add(arg)
    }
  }
  // print strings
  if (!quit) {
    len = strings.len()
    for (var i=0, i < len, i += 1) {
      if (i != 0) write(' ')
      print(strings[i])
    }
    write('\n')
    flush()
  }
  exitcode
}
