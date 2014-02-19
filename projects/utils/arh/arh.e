/* Arh utility
 * Version 1.2
 * (C) 2011-2014, Sergey Basalaev
 * Licensed under GPL v3
 */

use "dataio"

const VERSION = "arh 1.2"
const HELP =
  "Usage:\n" +
  "To create archive\n" +
  " arh c archive files...\n" +
  "To list archive\n" +
  " arh t archive\n" +
  "To extract archive\n" +
  " arh x archive"

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

def arhlist(input: IStream) {
  var f = try input.readUTF() catch null
  while (f != null) {
    print(f)
    input.skip(8)
    var attrs = input.readUByte()
    if ((attrs & A_DIR) != 0) {
      println("/")
    } else {
      println("")
      input.skip(input.readInt())
    }
    f = try input.readUTF() catch null
  }
}

def unarh(input: IStream) {
  var f = try input.readUTF() catch null
  var buf = new [Byte](BUF_SIZE)
  while (f != null) {
    f = arhpath(f)
    input.skip(8)
    var attrs = input.readUByte()
    if ((attrs & A_DIR) != 0) {
      if (!exists(f)) mkdir(f)
    } else {
      var out = fwrite(f)
      var len = input.readInt()
      if (len > 0) {
        while (len > BUF_SIZE) {
          input.readArray(buf, 0, BUF_SIZE)
          out.writeArray(buf, 0, BUF_SIZE)
          len = len - BUF_SIZE
        }
        input.readArray(buf, 0, len)
        out.writeArray(buf, 0, len)
      }
      out.flush()
      out.close()
    }
    setExec(f, (attrs & A_EXEC) != 0)
    setWrite(f, (attrs & A_WRITE) != 0)
    setRead(f, (attrs & A_READ) != 0)
    f = try input.readUTF() catch null
  }
}

def arhwrite(out: OStream, f: String) {
  out.writeUTF(arhpath(f))
  out.writeLong(fmodified(f))
  var attrs = A_READ | A_WRITE
  if (isDir(f)) {
    out.writeByte(attrs | A_DIR | A_EXEC)
    var subs = flist(f)
    for (var i=0, i<subs.len, i+=1) {
      arhwrite(out, f+"/"+subs[i])
    }
  } else {
    var filein = fread(f)
    var magic = filein.readUShort()
    filein.close()
    if (magic == 0xC0DE || magic == (('#' << 8)|'!')
     || magic == (('#' << 8)|'=') || magic == (('#' << 8)|'@')) {
      attrs |= A_EXEC
    }
    out.writeByte(attrs)
    var len = fsize(f)
    out.writeInt(len)
    if (len > 0) {
      filein = fread(f)
      var buf = new [Byte](BUF_SIZE)
      var l = filein.readArray(buf, 0, BUF_SIZE)
      while (l > 0) {
        out.writeArray(buf, 0, l)
        l = filein.readArray(buf, 0, BUF_SIZE)
      }
      filein.close()
    }
  }
}

def main(args: [String]): Int {
  // parse options
  if (args.len == 0) {
    stderr().println("arh: no command")
    return FAIL
  }
  var cmd = args[0]
  if (cmd == "v" || cmd == "-v") {
    println(VERSION)
  } else if (cmd == "h" || cmd == "-h") {
    println(HELP)
  } else if (args.len < 2) {
    stderr().println("arh: no archive")
    return FAIL
  } else if (cmd == "t" || cmd == "-t") {
    arhlist(fread(args[1]))
  } else if (cmd == "x" || cmd == "-x") {
    unarh(fread(args[1]))
  } else if (cmd == "c" || cmd == "-c") {
    var out = fwrite(args[1])
    for (var i in 2 .. args.len-1) {
      arhwrite(out, args[i])
    }
    out.flush()
    out.close()
  } else {
    stderr().print("arh: unknown command: ")
    stderr().println(cmd)
    return FAIL
  }
  return SUCCESS
}
