use "zlib/gzistream.eh"
use "zlib/gzostream.eh"
use "list.eh"

const BUF_SIZE = 4096
const WARN = 2

const VERSION = "gzip 1.0"
const HELP = "Compress or decompess files.\n" +
             "Usage: gzip [options] files\n" +
             "Options:\n" +
             " -c   write on stdout, keep original files\n" +
             " -d   decompress\n" +
//             " -r   traverse directories recursively\n" +
             " -S<sfx> suffix for compressed files\n" +
             " -v   Show version\n" +
             " -h   Show this help"

// global vars
var catenate: Bool;
var suffix: String;

/* Tests if file has one of well known gzip extensions */
def has_gz_ext(file: String): Bool {
  var len = file.len()
  if (len > 4) {
    var last4 = file[len-4:len].lcase()
    return last4 == ".tgz"
  }
  if (len > 3) {
    var last3 = file[len-3:len].lcase()
    return last3 == ".gz" || last3 == "-gz"
  }
  if (len > 2) {
    var last2 = file[len-2:len].lcase()
    return last2 == ".z" || last2 == "-z"
  }
  return file.endsWith(suffix)
}

/* Returns file name without gzip extension. */
def name_nogzext(file: String): String {
  var len = file.len()
  if (file.endsWith(suffix)) {
    return file[0:len-suffix.len()]
  }
  if (len > 4) {
    var last4 = file[len-4:len]
    if (last4 == ".tgz") {
      return file[0:len-4] + ".tar"
    }
  }
  if (len > 3) {
    var last3 = file[len-3:len]
    if (last3 == ".gz" || last3 == "-gz") {
      return file[0:len-3]
    }
  }
  if (len > 2) {
    var last2 = file[len-2:len]
    if (last2 == ".z" || last2 == "-z") {
      return file[0:len-2]
    }
  }
  return file + ".unpacked"
}

def do_compress(file: String, buf: [Byte]): Int {
  if (isDir(file)) {
    stderr().println("gzip: " + file + " is a directory -- skipped")
    return WARN
  } else if (!exists(file)) {
    stderr().println("gzip: " + file + ": no such file or directory")
    return FAIL
  } else if (!catenate && has_gz_ext(file)) {
    stderr().println("gzip: " + file + " has gzip extension -- skipped")
    return WARN
  } else {
    var input = fread(file)
    var out = new GzOStream(
      if (!catenate) fwrite(file + suffix)
      else stdout())
    var len: Int;
    while (len = input.readArray(buf, 0, BUF_SIZE), len > 0) {
      out.writeArray(buf, 0, len)
    }
    input.close()
    if (catenate) {
      return SUCCESS
    }
    out.close()
    try {
      fremove(file)
      return SUCCESS
    } catch {
      stderr().println("gzip: failed to remove original file " + file)
      return WARN
    }
  }
}

def do_decompress(file: String, buf: [Byte]): Int {
  if (isDir(file)) {
    stderr().println("gzip: " + file + " is a directory -- skipped")
    return WARN
  } else if (!exists(file)) {
    stderr().println("gzip: " + file + ": no such file or directory")
    return FAIL
  } else if (!has_gz_ext(file)) {
    stderr().println("gzip: " + file + " has no gzip extension -- skipped")
    return WARN
  } else {
    var input = new GzIStream(fread(file))
    var out = if (!catenate)
      fwrite(name_nogzext(file))
      else stdout()
    var len: Int
    while (len = input.readArray(buf, 0, BUF_SIZE), len > 0) {
      out.writeArray(buf, 0, len)
    }
    input.close()
    if (catenate) {
      return SUCCESS
    }
    out.close()
    try {
      fremove(file)
      return SUCCESS
    } catch {
      stderr().println("gzip: failed to remove original file " + file)
      return WARN
    }
  }
}

def main(args: [String]): Int {
  var files = new List()
  suffix = ".gz"
  catenate = false
  var decompress = false
//  var recursive = false
  // parse arguments
  for (var arg in args) {
    if (arg == "-h") {
      println(HELP)
      return SUCCESS
    } else if (arg == "-v") {
      println(VERSION)
      return SUCCESS
    } else if (arg == "-c") {
      catenate = true
    } else if (arg == "-d") {
      decompress = true
//    } else if (arg == "-r") {
//      recursive = true
    } else if (arg.startsWith("-S")) {
      suffix = arg[2:]
      if (suffix == "") {
        stderr().println("gzip: no suffix given with -S")
        return FAIL
      }
    } else if (arg[0] == '-') {
      stderr().println("Unknown option: " + arg)
      return FAIL
    } else {
      files.add(arg)
    }
  }
  if (files.len() == 0) {
    stderr().println("gzip: no files given")
    return FAIL
  }
  // do the job
  var buf = new [Byte](BUF_SIZE)
  var exitcode = 0
  for (var i=0, i < files.len(), i += 1) {
    var fun = if (decompress) do_decompress else do_compress
    exitcode += fun(files[i].tostr(), buf)
  }
  return exitcode
}
