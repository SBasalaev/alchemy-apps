/* base64 encoder/decoder
 * Version 1.2
 * (C) 2011-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io"
use "string"

const VERSION = "base64 1.2"
const HELP = "base64 encoder/decoder\n" +
             "Usage: base64 [file]\n" +
             " if no file given, stdin is used\n" +
             "Options:\n" +
             "-d  decode" +
             "-i  ignore garbage" +
             "-w<num>  wrap line after num chars"

const CODING = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

def enc(b: Int): Int = CODING.ch(b)

def dec(ch: Int): Int = CODING.indexof(ch)

def encode(wrap: Int): Int {
  var buf = new [Byte](3)
  var len = readarray(buf, 0, 3)
  var column = 0
  while (len > 0) {
    // 1
    write(enc((buf[0]>>2) & 0x3f))
    column += 1
    if (wrap > 0 && column >= wrap) {
      write('\n')
      column = 0
    }
    // 2
    write(enc((buf[0]<<4) & 0x30 | (buf[1]>>4) & 0x0f))
    column += 1
    if (wrap > 0 && column >= wrap) {
      write('\n')
      column = 0
    }
    // 3
    if (len <= 1) {
      write('=')
    } else {
      write(enc((buf[1]<<2) & 0x3c | (buf[2]>>6) & 0x03))
    }
    column += 1
    if (wrap > 0 && column >= wrap) {
      write('\n')
      column = 0
    }
    // 4
    if (len <= 2) {
      write('=')
    } else {
      write(enc(buf[2] & 0x3f))
    }
    column += 1
    if (wrap > 0 && column >= wrap) {
      write('\n')
      column = 0
    }
    // next
    buf[1] = 0
    buf[2] = 0
    len = readarray(buf, 0, 3)
  }
  0
}

def decode(ignore: Bool): Int {
  var buf = new [Byte](4)
  var eof = false
  var err = false
  while (!eof && !err) {
    var len = 0
    // reading four characters
    while (len < 4 && !eof && !err) {
      var ch = read()
      if (ch < 0) eof = true
      else if (dec(ch) >= 0 || ch == '=') {
        buf[len] = ch
        len += 1
      } else if (ch != '\n' && ch != '\r' && !ignore) {
        err = true
        stderr().println("base64: invalid input")
      }
    }
    // testing on completeness
    if (eof && len != 0) {
      err = true
      stderr().println("base64: invalid input")
    }
    // decoding
    if (!err && !eof) {
      var b1 = dec(buf[0])
      var b2 = dec(buf[1])
      var b3 = dec(buf[2])
      var b4 = dec(buf[3])
      if ((b1 | b2) >= 0) {
        write((b1<<2) | ((b2>>4) & 0x03))
        if (b3 >= 0) {
          write((b2<<4) | ((b3>>2) & 0x0f))
          if (b4 >= 0) {
            write((b3<<6) | (b4 & 0x3f))
          }
        }
      }
    }
  }
  if (err) 1 else 0
}

def main(args: [String]): Int {
  // parse args
  var quit = false
  var dodecode = false
  var input = "-"
  var wrap = 40
  var exitcode = 0
  var ignore = false
  for (var i=0, i < args.len, i+=1) {
    var arg = args[i]
    if (arg == "-h") {
      println(HELP)
      quit = true
    } else if (arg == "-v") {
      println(VERSION)
      quit = true
    } else if (arg == "-d") {
      dodecode = true
    } else if (arg == "-i") {
      ignore = true
    } else if (arg.startswith("-w")) {
      try {
        wrap = arg[2:].toint()
      } catch {
        quit = true
        stderr().println("base64: incorrect wrap number")
        exitcode = 1
      }
    } else {
      input = arg
    }
  }
  // process
  if (!quit) {
    if (input != "-") setin(fopen_r(input))
    if (dodecode) exitcode = decode(ignore)
    else exitcode = encode(wrap)
    flush()
  }
  exitcode
}
