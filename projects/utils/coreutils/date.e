/* Alchemy coreutils
 * (C) 2011-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "sys.eh"
use "time.eh"
use "version.eh"

const VERSION = "date" + COREUTILS_VERSION
const HELP = "Prints current date in default format."

def main(args: [String]): Int {
  // parse args
  var format: String = null
  for (var arg in args) {
    if (arg == "-h") {
      println(HELP)
      return SUCCESS
    } else if (arg == "-v") {
      println(VERSION)
      return SUCCESS
    } else {
      stderr().println("Unknown option: "+arg)
      return FAIL
    }
  }
  // work!
  println(datestr(systime()))
  return SUCCESS
}
