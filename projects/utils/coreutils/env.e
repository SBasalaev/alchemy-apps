/* Alchemy coreutils
 * (C) 2011-2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "sys.eh"
use "version.eh"

const VERSION = "env " + C_VERSION
const HELP = "Run program in changed environment.\n" +
             "Usage: env KEY=VALUE ... program args..."

def main(args: [String]): Int {
  // pars args
  var len = args.len
  var ofs = 0
  var envread = false
  var quit = false
  var exitcode = 0
  for (var i=0, !envread && !quit && i < len, i+=1) {
    var arg = args[ofs]
    if (arg == "-v") {
      println(VERSION)
      quit = true
    } else if (arg == "-h") {
      println(HELP)
      quit = true
    } else {
      var eqindex = arg.indexof('=')
      if (eqindex < 0) {
        envread = true
        ofs = i
      } else {
        setenv(arg[:eqindex], arg[eqindex+1:])
      }
    }
  }
  if (ofs == len) {
    stderr().println("env: no command")
    exitcode = 1
  } else if (!quit) {
    var argbuf = new [String](len-ofs-1)
    acopy(args,ofs+1,argbuf,0,len-ofs-1)
    exec_wait(args[ofs], argbuf)
  }
  exitcode
}
