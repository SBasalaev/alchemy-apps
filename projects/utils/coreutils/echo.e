/* Alchemy coreutils
 * (C) 2011-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "version.eh"

const VERSION = "echo" + COREUTILS_VERSION
const HELP =
  "Prints strings to the stdout.\n" +
  "Options:\n" +
  " -n  do not add newline"

def main(args: [String]): Int {
  // parse args
  var strings = new List()
  var addNl = true
  for (var arg in args) {
    if (arg == "-h") {
      println(HELP)
      return SUCCESS
    } else if (arg == "-v") {
      println(VERSION)
      return SUCCESS
    } else if (arg == "-n") {
      addNl = false
    } else if (arg[0] == '-') {
      stderr().println("Unknown option: "+arg)
      return FAIL
    } else {
      strings.add(arg)
    }
  }
  // print strings
  for (var i in 0 .. strings.len()-1) {
    if (i != 0) write(' ')
    print(strings[i])
  }
  if (addNl) write('\n')
  flush()
  return SUCCESS
}
