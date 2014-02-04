/* Alchemy coreutils
 * (C) 2011-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "version.eh"

const VERSION = "chmod" + COREUTILS_VERSION
const HELP = "Sets file attributes.\n" +
             "Attribute options (read, write, execute):\n" +
             " +r -r +w -w +x -x"

const UNSET = -1
const SKIP = 0
const SET = 1

def main(args: [String]): Int {
  // parse args
  var readflag = SKIP
  var writeflag = SKIP
  var execflag = SKIP
  var files = new List()
  for (var arg in args) {
    if (arg=="-r") readflag = UNSET
    else if (arg=="+r") readflag = SET
    else if (arg=="-w") writeflag = UNSET
    else if (arg=="+w") writeflag = SET
    else if (arg=="-x") execflag = UNSET
    else if (arg=="+x") execflag = SET
    else if (arg=="-h") {
      println(HELP)
      return SUCCESS
    } else if (arg=="-v") {
      println(VERSION)
      return SUCCESS
    } else if (arg.ch(0) == '-' || arg.ch(0) == '+') {
      stderr().println("Unknown option: " + arg)
      return FAIL
    } else {
      files.add(arg)
    }
  }
  // setting attributes
  for (var i in 0 .. files.len()-1) {
    var file = files[i].cast(String)
    if (readflag == SET) {
      setRead(file, true)
    } else if (readflag == UNSET) {
      setRead(file, false)
    }
    if (writeflag == SET) {
      setWrite(file, true)
    } else if (writeflag == UNSET) {
      setWrite(file, false)
    }
    if (execflag == SET) {
      setExec(file, true)
    } else if (execflag == UNSET) {
      setExec(file, false)
    }
  }
  return SUCCESS
}
