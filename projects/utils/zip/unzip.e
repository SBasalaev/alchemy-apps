use "io"

use "zip/ZipIStream"

const HELP =
  "unzip - list and extract ZIP archives\n" +
  "Use: unzip [options] file[.zip]\n" +
  "Options:\n" +
  "-l list archive files\n" +
  "-d extract under specified directory"
const VERSION = "unzip 0.2.1"

def main(args: [String]): Int {
  var zipfile = ""
  var outdir = ""
  var extract = true
  // parse arguments
  for (var i=0, i<args.len, i+=1) {
    var arg = args[i]
    if (arg == "-h") {
      println(HELP)
      return SUCCESS
    } else if (arg == "-v") {
      println(VERSION)
      return SUCCESS
    } else if (arg == "-d") {
      if (i+1 == args.len) {
        println("unzip: -d expects name")
        return 1
      } else {
        i += 1
        outdir = args[i]
      }
    } else if (arg == "-l") {
      extract = false
    } else if (arg[0] == '-') {
      println("unzip: unknown option "+arg)
      return 1
    } else if (zipfile == "") {
      zipfile = arg
    } else {
      println("unzip error: " + arg)
      return 1
    }
  }
  // check options for correctness
  if (zipfile == "") {
    println(HELP)
    return SUCCESS
  } else if (!exists(zipfile)) {
    if (exists(zipfile + ".zip")) {
      zipfile += ".zip"
    } else if (exists(zipfile + ".ZIP")) {
      zipfile += ".ZIP"
    } else {
      printf("unzip: cannot find %0, %0.zip or %0.ZIP", [zipfile])
    }
  }
  // process zip
  println("Archive: " + zipfile)
  if (extract && outdir != "") {
    zipfile = abspath(zipfile)
    if (!exists(outdir)) {
      mkdir(outdir)
    }
    setCwd(outdir)
  }
  var input = new ZipIStream(fread(zipfile))
  var buf = new [Byte](512)
  while (var entry = input.getNextEntry(), entry != null) {
    if (extract) {
      // never allow file to fall outside outdir
      var path = "." + abspath("/" + entry.name)
      if (entry.isDir()) {
        if (!isDir(path)) {
          println(" creating: " + entry.name)
          mkdir(path)
        }
      } else {
        println(" inflating: " + entry.name)
        var out = fwrite(path)
        while (var len = input.readArray(buf, 0, 512), len > 0) {
          out.writeArray(buf, 0, len)
        }
        out.close()
      }
    } else {
      println(" " + entry.name)
    }
    input.closeEntry()
  }
  input.close()
  return SUCCESS
}
