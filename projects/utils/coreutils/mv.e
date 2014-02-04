/* Alchemy coreutils
 * (C) 2011-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "version.eh"

const VERSION = "mv" + COREUTILS_VERSION
const HELP = "Moves/renames files."

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
    } else if (arg.ch(0) == '-') {
      stderr().println("Unknown option: " + arg)
      return FAIL
    } else {
      files.add(arg)
    }
  }
  // do moving
  var len = files.len()
  if (len == 0) {
    stderr().println("mv: missing argument")
    return FAIL
  }
  if (len == 1) {
    stderr().println("mv: missing destination")
    return FAIL
  }
  var dest = files[len-1].cast(String)
  if (isDir(dest)) {
    for (var i in 0 .. len-2) {
      var srcfile = files[i].cast(String)
      fmove(srcfile, dest+"/"+pathfile(srcfile))
    }
    return SUCCESS
  } else if (len == 2) {
    var src = files[0].cast(String)
    fmove(src, dest)
    return SUCCESS
  } else {
    stderr().println("mv: many arguments but target is not directory")
    return FAIL
  }
}
