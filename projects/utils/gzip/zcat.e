use "sys.eh"

def main(args: [String]): Int {
  var newargs = new [String](args.len + 2)
  newargs[0] = "-d"
  newargs[1] = "-c"
  acopy(args, 0, newargs, 2, args.len)
  exec_wait("gzip", newargs)
}