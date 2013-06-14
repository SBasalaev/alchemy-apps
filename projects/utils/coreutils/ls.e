/* Alchemy coreutils
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "version.eh"

const VERSION = "ls" + COREUTILS_VERSION
const HELP = "List contents of given directory."

def _ls(f: String): Int {
  if (is_dir(f)) {
    var list = flist(f)
    for (var i=0, i < list.len, i = i+1) {
      println(list[i])
    }
    1
  } else if (exists(f)) {
    println(pathfile(f))
    1
  } else {
    stderr().println("ls: file not found: "+f)
    0
  }
}

def main(args: [String]): Int {
  // parse args
  var len = args.len
  var exitcode = 0
  var quit = false
  var files = new_list()
  for (var i=0, i < len, i += 1) {
    var arg  = args[i]
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
  // list files
  if (!quit) {
    if (files.len() == 0) {
      _ls(get_cwd())
    } else {
      for (var i=0, i<args.len && exitcode == 0, i += 1) {
        exitcode = _ls(files[i].tostr())
      }
    }
  }
  exitcode
}

