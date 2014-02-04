/* Alchemy coreutils
 * (C) 2011-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "dict.eh"
use "version.eh"

const VERSION = "ls" + COREUTILS_VERSION

const HELP =
  "List contents of given directory.\n" +
  "Options:\n" +
  " -d list directories as items, not their contents"

def main(args: [String]): Int {
  // parse args
  var names = new List()
  var expandDirs = true
  for (var arg in args) {
    if (arg == "-h") {
      println(HELP)
      return SUCCESS
    } else if (arg == "-v") {
      println(VERSION)
      return SUCCESS
    } else if (arg == "-d") {
      expandDirs = false
    } else if (arg.ch(0) == '-') {
      stderr().println("Unknown option: "+arg)
      return FAIL
    } else {
      names.add(arg)
    }
  }
  if (names.len() == 0) {
    names.add(".")
  }
  // sort names
  var files = new List()
  var dirlists = new Dict()
  var exitcode = SUCCESS
  for (var i in 0 .. names.len()-1) {
    var f = names[i].cast(String)
    if (expandDirs && isDir(f)) {
      var dirList = new List(flist(f))
      dirList.sortself(`String.cmp`)
      dirlists[f] = dirList
    } else if (exists(f)) {
      files.add(f)
    } else {
      stderr().println("ls: file not found: "+f)
      exitcode = FAIL
    }
  }
  // print files
  files.sortself(`String.cmp`)
  for (var i in 0 .. files.len()-1) {
    println(files[i])
  }
  // print dirs
  var dirnames = new List(dirlists.keys())
  dirnames.sortself(`String.cmp`)
  var printNames = dirnames.len() > 1 || files.len() > 0
  for (var dirI in 0 .. dirnames.len()-1) {
    if (printNames) println("\n" + dirnames[dirI] + ":")
    var filelist = dirlists[dirnames[dirI]].cast(List)
    for (var i in 0 .. filelist.len()-1) {
      println(filelist[i])
    }
  }
  return exitcode
}
