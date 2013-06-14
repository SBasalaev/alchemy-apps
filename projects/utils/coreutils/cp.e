/* Alchemy coreutils
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "version.eh"

const VERSION = "cp" + COREUTILS_VERSION
const HELP = "Copies files and directories.\n" +
             "Usage:\n" +
             " cp <src> <dest>\n" +
             " cp <1> ... <n> <dir>\n" +
             "Options:\n" +
             " -r copy directories recursively"

def fcopytree(src: String, dest: String) {
  if (is_dir(src)) {
    if (!is_dir(dest)) mkdir(dest)
    var subs = flist(src)
    for (var i=0, i < subs.len, i+=1) {
      fcopytree(src+"/"+subs[i], dest+"/"+subs[i])
    }
  } else {
    fcopy(src, dest)
  }
}

def main(args: [String]): Int {
  var len = args.len
  // parse args
  var quit = false
  var exitcode = 0
  var recursive = false
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
    } else if (arg.ch(0) == '-') {
      stderr().println("Unknown option: "+arg)
      exitcode = 1
      quit = true
    } else {
      files.add(arg)
    }
  }
  // do copying
  if (!quit) {
    len = files.len()
    if (len == 0) {
      stderr().println("cp: missing argument")
      exitcode = 1
    } else if (len == 1) {
      stderr().println("cp: missing destination")
      exitcode = 1
    } else {
      var dest = files[len-1].tostr()
      if (is_dir(dest)) {
        for (var i=0, i<len-1, i+=1) {
          var srcfile = files[i].tostr()
          { if (recursive) fcopytree else fcopy }
          (srcfile, dest+"/"+pathfile(srcfile))
        }
      } else if (len == 2) {
        var src = files[0].tostr()
        { if (recursive) fcopytree else fcopy }
        (src, dest)
      } else {
        stderr().println("cp: many arguments but target is not directory")
        exitcode = 1
      }
    }
  }
  exitcode
}
