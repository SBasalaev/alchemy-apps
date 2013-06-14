/* Alchemy coreutils
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "version.eh"

const VERSION = "mv" + COREUTILS_VERSION
const HELP = "Moves/renames files."

def main(args: [String]): Int {
  var len = args.len
  // parse args
  var quit = false
  var exitcode = 0
  var files = new_list()
  for (var i=0, i < len, i += 1) {
    var arg = args[i]
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
  // do moving
  if (!quit) {
    len = files.len()
    if (len == 0) {
      stderr().println("mv: missing argument")
      exitcode = 1
    } else if (len == 1) {
      stderr().println("mv: missing destination")
      exitcode = 1
    } else {
      var dest = files[len-1].tostr()
      if (is_dir(dest)) {
        for (var i=0, i<len-1, i+=1) {
          var srcfile = files[i].tostr()
          fmove(srcfile, dest+"/"+pathfile(srcfile))
        }
      } else if (len == 2) {
        var src = files[0].tostr()
        fmove(src, dest)
      } else {
        stderr().println("mv: many arguments but target is not directory")
        exitcode = 1
      }
    }
  }
  exitcode
}
