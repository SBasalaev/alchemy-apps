/* Alchemy coreutils
 * (C) 2011-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "strbuf.eh"
use "string.eh"
use "version.eh"

const VERSION = "install" + COREUTILS_VERSION
const HELP =
  "Copy files with their permissions.\n" +
  "Destination directory is created if does not exist."

def installTree(src: String, dest: String) {
  if (isDir(src)) {
    if (!isDir(dest)) mkdir(dest)
    var files = flist(src)
    for (var file in files) {
      installTree(src + "/" + file, dest + "/" + file)
    }
  } else {
    fcopy(src, dest)
  }
  setExec(dest, canExec(src))
  setWrite(dest, canWrite(src))
  setRead(dest, canRead(src))
}

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
    } else if (arg[0] == '-') {
      stderr().println("Unknown option: "+arg)
      return FAIL
    } else {
      files.add(arg)
    }
  }
  // installing files
  var len = files.len()
  if (len == 0) {
    stderr().println("install: missing argument")
    return FAIL
  }
  if (len == 1) {
    stderr().println("install: missing destination")
    return FAIL
  }
  var destdir = files[len-1].cast(String)
  mkdirTree(destdir)
  for (var i in 0 .. len-2) {
    var src = abspath(files[i].cast(String))
    var dest = abspath(destdir + "/" + pathfile(src))
    installTree(src, dest)
  }
  return SUCCESS
}
