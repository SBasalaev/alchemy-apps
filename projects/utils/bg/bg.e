/* bg - run command in background
 * Version 1.0.2
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "sys.eh"

def main(args: [String]) {
 if (args.len == 0 || args[0] == "-h") {
  println("bg - run command in background")
  println("Usage: bg program args...")
 } else {
  var params = new [String](args.len-1)
  acopy(args, 1, params, 0, params.len)
  exec(args[0], params)
 }
}
