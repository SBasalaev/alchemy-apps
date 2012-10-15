/* Wrapper for ec/el
 * Version 1.0.2
 * (C) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "sys.eh"

const VERSION = "ex v1.0.2"

def main(args: [String]): Int {
  /* initializing */
  var sources = new_list()
  var objects = new_list()
  var ecflags = new_list()
  var elflags = new_list()
  var outname = "a.out"
  /* parsing arguments */
  var mode = 0
  // 0 - normal
  // 1 - waiting outname
  // 2 - help / version
  // 3 - error
  for (var i=0, i < args.len, i += 1) {
    var arg = args[i]
    var len = arg.len()
    if (mode == 1) {
      outname = arg
      mode = 0
    } else if (len < 2 || arg.ch(0) != '-') {
      var ext = arg[len-2 : len]
      if (ext == ".e") {
        sources.add(arg)
        objects.add(arg[:arg.len()-2] +".o")
      } else if (ext == ".o") {
        objects.add(arg)
      } else {
        stderr().println("Unknown source: "+arg)
        mode = 2
      }
    } else {
      var opt = arg.ch(1)
      if (opt == 'h') {
        exec_wait("ec", new [String] {"-h"})
        exec_wait("el", new [String] {"-h"})
        mode = 2
      } else if (opt == 'v') {
        println(VERSION)
        exec_wait("ec", new [String] {"-v"})
        exec_wait("el", new [String] {"-v"})
        mode = 2
      } else if (opt == 'o') {
        mode = 1
      } else if ("lLs".indexof(opt) >= 0) {
        elflags.add(arg)
      } else if ("ItO".indexof(opt) >= 0) {
        ecflags.add(arg)
      } else {
        stderr().println("Unknown option: "+arg)
        mode = 3
      }
    }
  }
  if (mode == 1) {
    stderr().println("-o requires name")
    mode = 3
  }
  /* if mode != 0 exit else process */
  if (mode != 0) {
    mode-2
  } else {
    var exitcode = 0
    /* prepare ec flags */
    var opts = new [String](ecflags.len() + 3)
    opts[1] = "-o"
    acopy(ecflags.toarray(), 0, opts, 3, ecflags.len())
    /* compile sources */
    var count = sources.len()
    for (var i=0, i < count && exitcode == 0, i=i+1) {
      var srcname = sources.get(i).tostr()
      opts[0] = srcname
      opts[2] = srcname[:srcname.len()-2] + ".o"
      exitcode = exec_wait("ec", opts)
    }
    /* prepare el flags */
    if (exitcode == 0) {
      opts = new [String](objects.len() + elflags.len() + 2)
      acopy(objects.toarray(), 0, opts, 0, objects.len())
      acopy(elflags.toarray(), 0, opts, objects.len(), elflags.len())
      opts[opts.len-2] = "-o"
      opts[opts.len-1] = outname
      exec_wait("el", opts)
    } else {
      exitcode
    }
  }
}
