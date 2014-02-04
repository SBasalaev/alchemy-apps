/* Alchemy coreutils
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "version.eh"

const VERSION = "cp" + COREUTILS_VERSION
const HELP = "Copies files and directories.\n" +
             "Usage:\n" +
             " cp <src> <dest>\n" +
             " cp <1> ... <n> <dir>\n" +
             "Options:\n" +
             " -r copy directories recursively"

def fcopyTree(src: String, dest: String) {
  if (isDir(src)) {
    if (!isDir(dest)) mkdir(dest)
    var files = flist(src)
    for (var file in files) {
      fcopyTree(src + "/" + file, dest + "/" + file)
    }
  } else {
    fcopy(src, dest)
  }
}

def main(args: [String]): Int {
  // parse args
  var recursive = false
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
    } else if (arg.ch(0) == '-') {
      stderr().println("Unknown option: "+arg)
      return FAIL
    } else {
      files.add(arg)
    }
  }
  // do copying
  var len = files.len()
  if (len == 0) {
    stderr().println("cp: missing argument")
    return FAIL
  }
  if (len == 1) {
    stderr().println("cp: missing destination")
    return FAIL
  }
  var dest = files[len-1].tostr()
  if (isDir(dest)) {
    for (var i=0, i<len-1, i+=1) {
      var srcfile = files[i].cast(String);
      ( if (recursive) fcopyTree else fcopy )
      (srcfile, dest + "/" + pathfile(srcfile))
    }
    return SUCCESS
  } else if (len == 2) {
    var src = files[0].cast(String);
    ( if (recursive) fcopyTree else fcopy )
    (src, dest)
    return SUCCESS
  } else {
    stderr().println("cp: many arguments but target is not directory")
    return FAIL
  }
}
