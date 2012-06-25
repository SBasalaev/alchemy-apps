/* Alchemy coreutils
 * (C) 2011, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io"
use "string"

const BUF_SIZE = 1024

def _cat(in: IStream, buf: BArray) {
  var len = freadarray(in, buf, 0, BUF_SIZE)
  while (len > 0) {
    writearray(buf, 0, len)
    len = freadarray(in, buf, 0, BUF_SIZE)
  }
  flush()
}

def main(args: Array) {
  var buf = new BArray(BUF_SIZE)
  if (args.len == 0) {
    _cat(stdin(), buf)
  } else for (var i=0, i<args.len, i=i+1) {
    var in = fopen_r(to_str(args[i]))
    _cat(in, buf)
    fclose(in)
  }
}
