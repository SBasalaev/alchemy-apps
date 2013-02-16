/* Arh utility
 * Version 1.1.2
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "dataio.eh"

const VERSION = "arh 1.1.3"
const HELP = "Usage:\n" +
             "arh c archive files...\n" +
             "arh t archive\n" +
             "arh x archive"

const BUF_SIZE = 1024

//attribute flags
const A_DIR = 16
const A_READ = 4
const A_WRITE = 2
const A_EXEC = 1

//due to differences in file systems there are cases
//when one cannot open .arh created by someone else
//so file attributes are hardcoded now
// DIRECTORY drwx
// PROGRAM   -rwx
// FILE      -rw-

def arhpath(path: String): String
  = relpath("./"+abspath("/"+path))

def arhlist(in: IStream) {
  var f = try in.readutf() catch null
  while (f != null) {
    print(f)
    in.skip(8)
    var attrs = in.readubyte()
    if ((attrs & A_DIR) != 0) {
      println("/")
    } else {
      println("")
      in.skip(in.readint())
    }
    f = try in.readutf() catch null
  }
}

def unarh(in: IStream) {
  var f = try in.readutf() catch null
  var buf = new [Byte](BUF_SIZE)
  while (f != null) {
    f = arhpath(f)
    in.skip(8)
    var attrs = in.readubyte()
    if ((attrs & A_DIR) != 0) {
      if (!exists(f)) mkdir(f)
    } else {
      var out = fopen_w(f)
      var len = in.readint()
      if (len > 0) {
        while (len > BUF_SIZE) {
          in.readarray(buf, 0, BUF_SIZE)
          out.writearray(buf, 0, BUF_SIZE)
          len = len - BUF_SIZE
        }
        in.readarray(buf, 0, len)
        out.writearray(buf, 0, len)
      }
      out.flush()
      out.close()
    }
    set_exec(f, (attrs & A_EXEC) != 0)
    set_write(f, (attrs & A_WRITE) != 0)
    set_read(f, (attrs & A_READ) != 0)
    f = try in.readutf() catch null
  }
}

def arhwrite(out: OStream, f: String) {
  out.writeutf(arhpath(f))
  out.writelong(fmodified(f))
  var attrs = A_READ | A_WRITE
  if (is_dir(f)) {
    out.writebyte(attrs | A_DIR | A_EXEC)
    var subs = flist(f)
    for (var i=0, i<subs.len, i+=1) {
      arhwrite(out, f+"/"+subs[i])
    }
  } else {
    var filein = fopen_r(f)
    var magic = filein.readushort()
    filein.close()
    if (magic == 0xC0DE || magic == (('#' << 8)|'!')
     || magic == (('#' << 8)|'=') || magic == (('#' << 8)|'@')) {
      attrs |= A_EXEC
    }
    out.writebyte(attrs)
    var len = fsize(f)
    out.writeint(len)
    if (len > 0) {
      filein = fopen_r(f)
      var buf = new [Byte](BUF_SIZE)
      var l = filein.readarray(buf, 0, BUF_SIZE)
      while (l > 0) {
        out.writearray(buf, 0, l)
        l = filein.readarray(buf, 0, BUF_SIZE)
      }
      filein.close()
    }
  }
}

def main(args: [String]): Int {
  // parse options
  var quit = false
  var exitcode = 0
  if (args.len == 0) {
    stderr().println("arh: no command")
    exitcode = 1
  } else {
    var cmd = args[0]
    if (cmd == "v" || cmd == "-v") {
      println(VERSION)
    } else if (cmd == "h" || cmd == "-h") {
      println(HELP)
    } else if (args.len < 2) {
      stderr().println("arh: no archive")
      exitcode = 1
    } else if (cmd == "t" || cmd == "-t") {
      arhlist(fopen_r(args[1]))
    } else if (cmd == "x" || cmd == "-x") {
      unarh(fopen_r(args[1]))
    } else if (cmd == "c" || cmd == "-c") {
      var out = fopen_w(args[1])
      for (var i=2, i<args.len, i += 1) {
        arhwrite(out, args[i])
      }
      out.flush()
      out.close()
    } else {
      stderr().print("arh: unknown command: ")
      stderr().println(cmd)
      exitcode = 1
    }
  }
  exitcode
}
