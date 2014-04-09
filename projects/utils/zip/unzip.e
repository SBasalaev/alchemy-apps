use "io"

use "zip/ZipIStream"

const HELP =
  "unzip - list and extract ZIP archives\n" +
  "Use: unzip [options] file[.zip]\n" +
  "Options:\n" +
  "-l list archive files\n" +
  "-d extract under specified directory"
const VERSION = "unzip 0.2"

def main(args: [String]): Int {
  var quit = false
  var exitcode = 0
  var zipfile = ""
  var outdir = ""
  var extract = true
  // parse arguments
  for (var i=0, !quit && i<args.len, i+=1) {
    var arg = args[i]
    if (arg == "-h") {
      println(HELP)
      quit = true
    } else if (arg == "-v") {
      println(VERSION)
      quit = true
    } else if (arg == "-d") {
      if (i+1 == args.len) {
        quit = true
        exitcode = 1
        println("unzip: -d expects name")
      } else {
        i += 1
        outdir = args[i]
      }
    } else if (arg == "-l") {
      extract = false
    } else if (arg[0] == '-') {
      println("unzip: unknown option "+arg)
      quit = true
      exitcode = 1
    } else if (zipfile == "") {
      zipfile = arg
    } else {
      quit = true
      exitcode = 1
      println("unzip error: " + arg)
    }
  }
  // check options for correctness
  if (!quit) {
    if (zipfile == "") {
      println(HELP)
      quit = true
    } else if (!exists(zipfile)) {
      if (exists(zipfile + ".zip")) {
        zipfile += ".zip"
      } else if (exists(zipfile + ".ZIP")) {
        zipfile += ".ZIP"
      } else {
        printf("unzip: cannot find %0, %0.zip or %0.ZIP", [zipfile])
      }
    }
  }
  // process zip
  if (!quit) {
    println("Archive: " + zipfile)
    if (extract && outdir != "") {
      zipfile = abspath(zipfile)
      if (!exists(outdir)) {
        mkdir(outdir)
      }
      set_cwd(outdir)
    }
    var input = new ZipIStream(fopen_r(zipfile))
    var entry: ZipEntry
    var buf = new [Byte](512)
    while ({entry = input.getNextEntry(); entry != null}) {
      if (extract) {
        // never allow file to fall outside outdir
        var path = "." + abspath("/" + entry.name)
        if (entry.isdir()) {
          if (!is_dir(path)) {
            println(" creating: " + entry.name)
            mkdir(path)
          }
        } else {
          println(" inflating: " + entry.name)
          var out = fopen_w(path)
          var len: Int
          while ({len = input.readarray(buf, 0, 512); len > 0}) {
            out.writearray(buf, 0, len)
          }
          out.close()
        }
      } else {
        println(" " + entry.name)
      }
      input.closeEntry()
    }
    input.close()
  }
  exitcode
}
