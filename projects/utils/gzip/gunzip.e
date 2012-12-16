use "sys.eh"

def main(args: [String]): Int {
  var newargs = new [String](args.len + 1)
  newargs[0] = "-d"
  acopy(args, 0, newargs, 1, args.len)
  exec_wait("gzip", newargs)
}