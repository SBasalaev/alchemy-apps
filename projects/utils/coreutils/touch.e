/* Alchemy coreutils
 * (C) 2011-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "version.eh"

const VERSION = "touch" + COREUTILS_VERSION
const HELP = "Update file timestamp."

def main(args: [String]): Int {
  // parse args
  var files = new List()
  for (var arg in args) {
    if (arg == "-h") {
      println(HELP)
      return SUCCESS
    } else if (arg == "-v") {
      println(VERSION)
      return SUCCESS
    } else if (arg[0] == '-') {
      stderr().println("Unknown option: "+arg)
      return FAIL
    } else {
      files.add(arg)
    }
  }
  // touch files
  var len = files.len()
  if (len == 0) {
    stderr().println("touch: no arguments")
    return FAIL
  }
  for (var i in 0 .. len-1) {
    var out = fappend(files[i].cast(String))
    out.flush()
    out.close()
  }
  return SUCCESS
}
