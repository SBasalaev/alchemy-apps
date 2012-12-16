use "zlib/gzistream.eh"
use "zlib/gzostream.eh"
use "list.eh"
use "string.eh"
use "error.eh"

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

def String.starts(sub: String): Bool {
  this.len() >= sub.len() && this[0:sub.len()] == sub
}

def String.ends(sub: String): Bool {
  this.len() >= sub.len() && this[this.len()-sub.len():] == sub
}

/* Tests if file has one of well known gzip extensions */
def has_gz_ext(file: String): Bool {
  var result = false
  var len = file.len()
  if (len > 4) {
    var last4 = file[len-4:len].lcase()
    result = last4 == ".tgz"
  }
  if (!result && len > 3) {
    var last3 = file[len-3:len].lcase()
    result = last3 == ".gz" || last3 == "-gz"
  }
  if (!result && len > 2) {
    var last2 = file[len-2:len].lcase()
    result = last2 == ".z" || last2 == "-z"
  }
  result || file.ends(suffix)
}

/* Returns file name without gzip extension. */
def name_nogzext(file: String): String {
  var len = file.len()
  var name: String = file + ".unpacked"
  var found = false
  if (file.ends(suffix)) {
    found = true
    name = file[0:len-suffix.len()]
  }
  if (!found && len > 4) {
    var last4 = file[len-4:len]
    if (last4 == ".tgz") {
      found = true
      name = file[0:len-4] + ".tar"
    }
  }
  if (!found && len > 3) {
    var last3 = file[len-3:len]
    if (last3 == ".gz" || last3 == "-gz") {
      found = true
      name = file[0:len-3]
    }
  }
  if (!found && len > 2) {
    var last2 = file[len-2:len]
    if (last2 == ".z" || last2 == "-z") {
      found = true
      name = file[0:len-2]
    }
  }
  name
}

def do_compress(file: String, buf: BArray): Int {
  if (is_dir(file)) {
    stderr().println("gzip: " + file + "is a directory -- skipped")
    WARN
  } else if (!exists(file)) {
    stderr().println("gzip: " + file + ": no such file or directory")
    FAIL
  } else if (!catenate && has_gz_ext(file)) {
    stderr().println("gzip: " + file + " has gzip extension -- skipped")
    WARN
  } else {
    var in = fopen_r(file)
    var out = new_gzostream(
      if (!catenate) fopen_w(file + suffix)
      else stdout())
    var len: Int;
    while ({len = in.readarray(buf, 0, BUF_SIZE); len > 0}) {
      out.writearray(buf, 0, len)
    }
    in.close()
    if (catenate) {
      SUCCESS
    } else {
      out.close()
      try {
        fremove(file)
        SUCCESS
      } catch {
        stderr().println("gzip: failed to remove original file " + file)
        WARN
      }
    }
  }
}

def do_decompress(file: String, buf: BArray): Int {
  if (is_dir(file)) {
    stderr().println("gzip: " + file + "is a directory -- skipped")
    WARN
  } else if (!exists(file)) {
    stderr().println("gzip: " + file + ": no such file or directory")
    FAIL
  } else if (!has_gz_ext(file)) {
    stderr().println("gzip: " + file + " has no gzip extension -- skipped")
    WARN
  } else {
    var in = new_gzistream(fopen_r(file))
    var out = if (!catenate)
      fopen_w(name_nogzext(file))
      else stdout()
    var len: Int
    while ({len = in.readarray(buf, 0, BUF_SIZE); len > 0}) {
      out.writearray(buf, 0, len)
    }
    in.close()
    if (catenate) {
      SUCCESS
    } else {
      out.close()
      try {
        fremove(file)
        SUCCESS
      } catch {
        stderr().println("gzip: failed to remove original file " + file)
        WARN
      }
    }
  }
}

def main(args: [String]) {
  var files = new_list()
  suffix = ".gz"
  catenate = false
  var decompress = false
//  var recursive = false
  var quit = false
  var exitcode = SUCCESS
  // parse arguments
  for (var i=0, i<args.len, i += 1) {
    var arg = args[i]
    if (arg == "-h") {
      println(HELP)
      quit = true
    } else if (arg == "-v") {
      println(VERSION)
      quit = true
    } else if (arg == "-c") {
      catenate = true
    } else if (arg == "-d") {
      decompress = true
//    } else if (arg == "-r") {
//      recursive = true
    } else if (arg.starts("-S")) {
      suffix = arg[2:]
      if (suffix == "") {
        stderr().println("gzip: no suffix given with -S")
        exitcode = FAIL
        quit = true
      }
    } else if (arg[0] == '-') {
      stderr().println("Unknown option: " + arg)
      exitcode = FAIL
      quit = true
    } else {
      files.add(arg)
    }
  }
  if (!quit && files.len() == 0) {
    stderr().println("gzip: no files given")
    quit = true
    exitcode = FAIL
  }
  // do the job
  if (!quit) {
    var buf = new BArray(BUF_SIZE)
    for (var i=0, i < files.len(), i += 1) {
      var fun = if (decompress) do_decompress else do_compress
      exitcode += fun(files[i].tostr(), buf)
    }
  }
  exitcode
}
