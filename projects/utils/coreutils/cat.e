/* Alchemy coreutils
 * (C) 2011-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "version.eh"

const VERSION = "cat" + COREUTILS_VERSION
const HELP = "Prints given files or stdin to the stdout."

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
    } else if (arg[0] == '-' && arg != "-") {
      stderr().println("Unknown option: "+arg)
      return FAIL
    } else {
      files.add(arg)
    }
  }
  // copy to the output
  if (files.len() == 0) {
    stdout().writeAll(stdin())
    stdout().flush()
  } else for (var i in 0 .. files.len()-1) {
    var file = files[i].cast(String)
    if (file == "-") {
      stdout().writeAll(stdin())
    } else {
      var input = fread(files[i].cast(String))
      stdout().writeAll(input)
      input.close()
    }
    stdout().flush()
  }
  return SUCCESS
}
