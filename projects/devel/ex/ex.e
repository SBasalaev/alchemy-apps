/* Wrapper for compiler and linker
 * (C) 2012-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "sys.eh"

const VERSION = "ex 2.0"
const HELP = "Compiler for Alchemy OS\n" +
             "Options:\n" +
             "-o <name> Use this name for output\n" +
             "-I<path> Search headers also in this path\n" +
             "-l<lib> Link with given library\n" +
             "-L<path> Search libraries also in this path\n" +
             "-O<level> Use specified optimization level\n" +
             "-g Write debugging info\n" +
             "-s<soname> Add soname to library\n" +
             "-c Only compile, don't link\n" +
             "-W<cat> Turn on warning category\n" +
             "-Wno-<cat> Turn off warning category\n" +
             "-f<option> Turn on option\n" +
             "-fno-<option> Turn off option"

def main(args: [String]): Int {
  /* initializing */
  var sources = new List() // passed sources
  var objects = new List() // generated objects
  var compileFlags = new List() // compiler flags
  var linkFlags = new List() // linker flags and passed objects
  var outname = ""
  var onlyCompile = false
  /* parsing arguments */
  var waitout = false
  var result = 0
  for (var arg in args) {
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
        linkFlags.add(arg)
      } else {
        stderr().println("Unknown source: "+arg)
        return 1
      }
    } else {
      var opt = arg.ch(1)
      if (opt == 'h') {
        println(HELP)
        return 0
      } else if (opt == 'v') {
        println(VERSION)
        return 0
      } else if (opt == 'o') {
        waitout = true
      } else if ("lLs".indexof(opt) >= 0) {
        linkFlags.add(arg)
      } else if ("IOgWf".indexof(opt) >= 0) {
        compileFlags.add(arg)
      } else if (opt == 'c') {
        onlyCompile = true
      } else {
        stderr().println("Unknown option: "+arg)
        return 1
      }
    }
  }
  if (waitout) {
    stderr().println("-o requires name")
    return 1
  }
  if (onlyCompile) {
    if (sources.len() > 1 && outname != "") {
      stderr().println("Conflicting options: -c and -o with multiple sources")
      return 1
    }
  }
  if (outname == "") {
    if (onlyCompile) outname = objects[0].tostr()
    else outname = "a.out"
  }

  /* prepare ec flags */
  var opts = new [String](compileFlags.len() + 3)
  opts[1] = "-o"
  compileFlags.copyInto(0, opts, 3, compileFlags.len())
  /* compile sources */
  var count = sources.len()
  for (var i=0, i < count && result == 0, i+=1) {
    opts[0] = sources[i].tostr()
    opts[2] = if (onlyCompile) outname else objects[i].tostr()
    result = execWait("ec", opts)
  }
  /* link */
  if (!onlyCompile) {
    /* prepare el flags */
    if (result == 0) {
      opts = new [String](objects.len() + linkFlags.len() + 2)
      objects.copyInto(0, opts, 0, objects.len())
      linkFlags.copyInto(0, opts, objects.len(), linkFlags.len())
      opts[opts.len-2] = "-o"
      opts[opts.len-1] = outname
      result = execWait("el", opts)
    }
    /* clean generated objects */
    for (var i=objects.len()-1, i>=0, i-=1) {
      var obj = objects[i].tostr()
      if (exists(obj)) fremove(obj)
    }
  }
  return result
}
