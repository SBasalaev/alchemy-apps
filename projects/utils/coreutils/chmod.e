/* Alchemy coreutils
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "string.eh"
use "version.eh"

const VERSION = "chmod " + C_VERSION
const HELP = "Sets file attributes.\n" +
             "Options:\n" +
             " +r -r +w -w +x -x"

const UNSET = -1
const SKIP = 0
const SET = 1

def main(args: [String]): Int {
  var len = args.len
  var readflag = SKIP
  var writeflag = SKIP
  var execflag = SKIP
  // processing options
  var quit = false
  var exitcode = 0
  for (var i=0, i < len && !quit, i += 1) {
    var arg = args[i]
    if (arg=="-r") readflag = UNSET
    else if (arg=="+r") readflag = SET
    else if (arg=="-w") writeflag = UNSET
    else if (arg=="+w") writeflag = SET
    else if (arg=="-x") execflag = UNSET
    else if (arg=="+x") execflag = SET
    else if (arg=="-h") {
      println(HELP)
      quit = true
    } else if (arg=="-v") {
      println(VERSION)
      quit = true
    } else if (arg.ch(0) == '-' || arg.ch(0) == '+') {
      stderr().println("Unknown option: " + arg)
      quit = true
      exitcode = 1
    }
  }
  // setting attributes
  if (!quit)
  for (var i=0, i < len, i += 1) {
    var file = args[i]
    var first = file.ch(0)
    if (first != '-' && first != '+') {
      if (readflag == SET) {
        set_read(file, true)
      } else if (readflag == UNSET) {
        set_read(file, false)
      }
      if (writeflag == SET) {
        set_write(file, true)
      } else if (writeflag == UNSET) {
        set_write(file,false)
      }
      if (execflag == SET) {
        set_exec(file,true)
      } else if (execflag == UNSET) {
        set_exec(file,false)
      }
    }
  }
  exitcode
}
