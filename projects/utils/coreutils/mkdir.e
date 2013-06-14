/* Alchemy coreutils
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "version.eh"

const VERSION = "mkdir" + COREUTILS_VERSION
const HELP = "Makes directories.\n" +
             "Options:\n" +
             "-p don't fail if exists, create parents as needed" 

def mkdirtree(dir: String) {
  if (!exists(dir)) {
    var parent = pathdir(dir)
    if (parent != null && !exists(parent))
      mkdirtree(parent)
    mkdir(dir)
  }
}

def main(args: [String]): Int {
  // parse args
  var len = args.len
  var quit = false
  var exitcode = 0
  var mkparents = false
  var files = new_list()
  for (var i=0, i < args.len && !quit, i += 1) {
    var arg = args[i]
    if (arg == "-h") {
      println(HELP)
      quit = true
    } else if (arg == "-v") {
      println(VERSION)
      quit = true
    } else if (arg == "-p") {
      mkparents = true
    } else if (arg.ch(0) == '-') {
      stderr().println("Unknown option: "+arg)
      quit = true
      exitcode = 1
    } else {
      files.add(arg)
    }
  }
  // make directories
  if (!quit) {
    len = files.len()
    if (len == 0) {
      stderr().println("mkdir: no arguments")
      exitcode = 1
    } else {
      for (var i=0, i < len && exitcode == 0, i += 1) {
        var dir = files[i].tostr()
        if (mkparents) {
          mkdirtree(dir)
        } else if (exists(dir)) {
          stderr().println("File already exists: "+dir)
          exitcode = 1
        } else {
          mkdir(dir)
        }
      }
    }
  }
  exitcode
}
