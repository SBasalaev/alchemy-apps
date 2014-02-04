/* Alchemy coreutils
 * (C) 2011-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "version.eh"

const VERSION = "mkdir" + COREUTILS_VERSION
const HELP = "Makes directories.\n" +
             "Options:\n" +
             "-p don't fail if exists, create parents as needed" 

def main(args: [String]): Int {
  // parse args
  var mkparents = false
  var files = new List()
  for (var arg in args) {
    if (arg == "-h") {
      println(HELP)
      return SUCCESS
    } else if (arg == "-v") {
      println(VERSION)
      return SUCCESS
    } else if (arg == "-p") {
      mkparents = true
    } else if (arg.ch(0) == '-') {
      stderr().println("Unknown option: "+arg)
      return FAIL
    } else {
      files.add(arg)
    }
  }
  // make directories
  var len = files.len()
  if (len == 0) {
    stderr().println("mkdir: no arguments")
    return FAIL
  }
  for (var i in 0 .. len-1) {
    var dir = files[i].cast(String)
    if (mkparents) {
      mkdirTree(dir)
    } else if (exists(dir)) {
      stderr().println("File already exists: "+dir)
      return FAIL
    } else {
      mkdir(dir)
    }
  }
  return SUCCESS
}
