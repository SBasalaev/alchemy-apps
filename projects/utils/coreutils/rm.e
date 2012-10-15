/* Alchemy coreutils
 * (C) 2011-2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "version.eh"

const VERSION = "cp " + C_VERSION
const HELP = "Removes files and directories.\n" +
             "Options:\n" +
             "-r remove directories recursively" +
             "-f don't fail if missing"

def fremovetree(file: String) {
  if (is_dir(file)) {
    var subs = flist(file)
    for (var i=0, i < subs.len, i+=1) {
      fremovetree(file+"/"+subs[i])
    }
  }
  fremove(file)
}

def main(args: [String]): Int {
  var len = args.len
  // parse args
  var quit = false
  var exitcode = 0
  var recursive = false
  var nofail = false
  var files = new_list()
  for (var i=0, i < len, i += 1) {
    var arg = args[i]
    if (arg == "-h") {
      println(HELP)
      quit = true
    } else if (arg == "-v") {
      println(VERSION)
      quit = true
    } else if (arg == "-r") {
      recursive = true
    } else if (arg == "-f") {
      nofail = true
    } else if (arg.ch(0) == '-') {
      stderr().println("Unknown option: "+arg)
      exitcode = 1
      quit = true
    } else {
      files.add(arg)
    }
  }
  // remove files
  if (!quit) {
    len = files.len()
    if (len == 0) {
      stderr().println("rm: no arguments")
      exitcode == 1
    } else {
      for (var i=0, i<len && exitcode == 0, i += 1) {
        var file = files[i].tostr()
        if (exists(file)) {
          if (recursive) fremovetree(file)
          else fremove(file)
        } else if (!nofail) {
          stderr().println("rm: file doesn't exist: "+file)
          exitcode = 1
        }
      }
    }
  }
  exitcode
}

