/* Alchemy coreutils
 * (C) 2011-2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "list.eh"
use "string.eh"
use "version.eh"

const VERSION = "cat " + C_VERSION
const HELP = "Prints given files or stdin to the stdout."

const BUF_SIZE = 1024

def _cat(in: IStream, buf: BArray) {
  var len = in.readarray(buf, 0, BUF_SIZE)
  while (len > 0) {
    writearray(buf, 0, len)
    len = in.readarray(buf, 0, BUF_SIZE)
  }
  flush()
}

def main(args: [String]): Int {
  // parse args
  var quit = false
  var exitcode = 0
  var files = new_list()
  for (var i=0, i<args.len && !quit, i+=1) {
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
  // copy to the output
  if (!quit) {
    var buf = new BArray(BUF_SIZE)
    if (files.len() == 0) {
      _cat(stdin(), buf)
    } else for (var i=0, i<files.len(), i+=1) {
      var in = fopen_r(files[i].tostr())
      _cat(in, buf)
      in.close()
    }
  }
  exitcode
}
