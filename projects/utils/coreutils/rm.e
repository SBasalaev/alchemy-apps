/* Alchemy coreutils
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "version.eh"

const VERSION = "rm" + COREUTILS_VERSION
const HELP = "Removes files and directories.\n" +
             "Options:\n" +
             "-r remove directories recursively\n" +
             "-f don't fail if missing"

def fremoveTree(file: String) {
  if (isDir(file)) {
    var subs = flist(file)
    for (var sub in subs) {
      fremoveTree(file + "/" + sub)
    }
  }
  fremove(file)
}

def main(args: [String]): Int {
  var len = args.len
  // parse args
  var recursive = false
  var nofail = false
  var files = new List()
  for (var arg in args) {
    if (arg == "-h") {
      println(HELP)
      return SUCCESS
    } else if (arg == "-v") {
      println(VERSION)
      return SUCCESS
    } else if (arg == "-r") {
      recursive = true
    } else if (arg == "-f") {
      nofail = true
    } else if (arg == "-rf" || arg == "-fr") {
      nofail = true
      recursive = true
    } else if (arg.ch(0) == '-') {
      stderr().println("Unknown option: "+arg)
      return FAIL
    } else {
      files.add(arg)
    }
  }
  // remove files
  len = files.len()
  if (len == 0) {
    stderr().println("rm: no arguments")
    return FAIL
  }
  for (var i in 0 .. len-1) {
    var file = files[i].tostr()
    if (exists(file)) {
      if (recursive) fremoveTree(file)
      else fremove(file)
    } else if (!nofail) {
      stderr().println("rm: file doesn't exist: "+file)
      return FAIL
    }
  }
  return SUCCESS
}
