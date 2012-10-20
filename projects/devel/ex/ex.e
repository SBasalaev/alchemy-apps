/* Wrapper for ec/el
 * Version 1.0.2
 * (C) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "sys.eh"

const VERSION = "ex 1.1"
const HELP = ""

def main(args: [String]): Int {
  /* initializing */
  var sources = new_list() // passed sources
  var objects = new_list() // generated objects
  var ecflags = new_list() // compiler flags
  var elflags = new_list() // linker flags and passed objects
  var outname = "a.out"
  /* parsing arguments */
  var waitout = false
  var quit = false
  var result = 0
  for (var i=0, i < args.len && !quit, i += 1) {
    var arg = args[i]
    var len = arg.len()
    if (waitout) {
      outname = arg
      waitout = false
    } else if (len < 2 || arg.ch(0) != '-') {
      var dot = arg.lindexof('.')
      var ext = if (dot < 0) "" else arg[dot:]
      if (ext == ".e") {
        sources.add(arg)
        objects.add(arg+".o")
      } else if (ext == ".o") {
        elflags.add(arg)
      } else {
        stderr().println("Unknown source: "+arg)
        quit = true
        result = 1
      }
    } else {
      var opt = arg.ch(1)
      if (opt == 'h') {
        println(HELP)
        quit = true
      } else if (opt == 'v') {
        println(VERSION)
        quit = true
      } else if (opt == 'o') {
        waitout = true
      } else if ("lLs".indexof(opt) >= 0) {
        elflags.add(arg)
      } else if ("ItO".indexof(opt) >= 0) {
        ecflags.add(arg)
      } else {
        stderr().println("Unknown option: "+arg)
        quit = true
        result = 1
      }
    }
  }
  if (waitout) {
    stderr().println("-o requires name")
    quit = true
    result = 1
  }
  
  if (!quit) {
    /* prepare ec flags */
    var opts = new [String](ecflags.len() + 3)
    opts[1] = "-o"
    acopy(ecflags.toarray(), 0, opts, 3, ecflags.len())
    /* compile sources */
    var count = sources.len()
    for (var i=0, i < count && result == 0, i+=1) {
      opts[0] = sources[i].tostr()
      opts[2] = objects[i].tostr()
      result = exec_wait("ec", opts)
    }
    /* prepare el flags */
    if (result == 0) {
      opts = new [String](objects.len() + elflags.len() + 2)
      acopy(objects.toarray(), 0, opts, 0, objects.len())
      acopy(elflags.toarray(), 0, opts, objects.len(), elflags.len())
      opts[opts.len-2] = "-o"
      opts[opts.len-1] = outname
      result = exec_wait("el", opts)
    }
    /* clean generated objects */
    for (var i=objects.len(), i>=0, i-=1) {
      var obj = objects[i].tostr()
      if (exists(obj)) fremove(obj)
    }
  }
  result
}
