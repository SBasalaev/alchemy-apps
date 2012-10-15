/* Alchemy coreutils
 * (C) 2011-2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "strbuf.eh"
use "string.eh"
use "version.eh"

const VERSION = "install " + C_VERSION
const HELP = "Copy files in directory and set their permissions."

def finstalltree(src: String, dest: String) {
  if (is_dir(src)) {
    if (!is_dir(dest)) mkdir(dest)
    var subs = flist(src)
    for (var i=0, i < subs.len, i+=1) {
      finstalltree(src+"/"+subs[i], dest+"/"+subs[i])
    }
  } else {
    fcopy(src, dest)
  }
  set_read(dest, can_read(src))
  set_exec(dest, can_exec(src))
  set_write(dest, can_write(src))
}

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
  // installing files
  if (!quit) {
    len = files.len()
    if (len == 0) {
      stderr().println("install: missing argument")
      exitcode = 1
    } else if (len == 1) {
      stderr().println("install: missing destination")
      exitcode = 1
    } else {
      var destdir = files[len-1].tostr()
      for (var i=0, i<len-1, i += 1) {
        var src = files[i].tostr()
        var dest = destdir+"/"+pathfile(src)
        finstalltree(src, dest)
      }
    }
  }
  exitcode
}
