/* Alchemy coreutils
 * (C) 2011-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "sys.eh"
use "version.eh"

const VERSION = "env" + COREUTILS_VERSION
const HELP =
  "Run program in changed environment.\n" +
  "Usage: env KEY=VALUE... program args..."

def main(args: [String]): Int {
  // parse args
  var cmd = ""
  var cmdargs = new List()
  for (var arg in args) {
    if (cmd != "") {
      cmdargs.add(arg)
    } else if (arg == "-v") {
      println(VERSION)
      return SUCCESS
    } else if (arg == "-h") {
      println(HELP)
      return SUCCESS
    } else {
      var eqindex = arg.indexof('=')
      if (eqindex < 0) {
        cmd = arg
      } else {
        setenv(arg[:eqindex], arg[eqindex+1:])
      }
    }
  }
  // run command
  if (cmd == "") {
    stderr().println("env: no command")
    return FAIL
  }
  var argbuf = new [String](cmdargs.len())
  cmdargs.copyInto(0, argbuf)
  return execWait(cmd, argbuf)
}
