use "io.eh"
use "list.eh"
use "zip/ZipEntry.eh"
use "zip/ZipOStream.eh"

const HELP =
  "zip - compress and archive files\n" +
  "Use: zip [options] file.zip [files]\n" +
  "Options:\n" +
  " -r travel directories recursively"
const VERSION = "zip 0.2.1"

def List.addfile(fname: String, recursive: Bool) {
  if (isDir(fname) && fname[fname.len()-1] != '/') fname += '/'
  if (this.indexof(fname) < 0) {
    this.add(fname)
    if (recursive && isDir(fname)) {
      var list = flist(fname)
      for (var i=0, i<list.len, i+=1) {
        this.addfile(fname + list[i], true)
      }
    }
  }
}

def main(args: [String]): Int {
  var inpaths = new List()
  var recursive = false
  var zipfile = ""
  // parse arguments
  for (var i=0, i<args.len, i+=1) {
    var arg = args[i]
    if (zipfile == "") {
      if (arg == "-h") {
        println(HELP)
        return SUCCESS
      } else if (arg == "-v") {
        println(VERSION)
        return SUCCESS
      } else if (arg == "-r") {
        recursive = true
      } else if (arg[0] == '-') {
        println("zip error: unknown option "+arg)
        return 16
      } else {
        zipfile = arg
      }
    } else {
      inpaths.addfile(arg, recursive)
    }
  }
  // check options for correctness
  if (zipfile == "") {
    println(HELP)
    return SUCCESS
  } else if (exists(zipfile)) {
    println("Adding files to existing zip archive is not [yet] supported.")
    return 1
  } else if (inpaths.len() == 0) {
    println("No files specified.")
    return 12
  }
  // process files
  var out = new ZipOStream(fwrite(zipfile))
  for (var i=0, i<inpaths.len(), i+=1) {
    var fname = inpaths[i].cast(String)
    if (!exists(fname)) {
      println("zip warning: " + fname + " not found")
    } else {
      var isdir = isDir(fname)
      var entry = new ZipEntry(fname)
      entry.time = fmodified(fname)
      var method = if (isdir || fsize(fname) == 0) ZIP_STORED else ZIP_DEFLATED
      if (method == ZIP_STORED) {
        entry.size = 0
        entry.CRC = 0
      }
      entry.method = method
      out.putNextEntry(entry)
      if (!isdir) {
        var inp = fread(fname)
        var buf = inp.readFully()
        inp.close()
        out.writeArray(buf, 0, buf.len)
      }
      out.closeEntry()
      printf("add: %0 (%1 %2%%)\n", [
        fname,
        if (method == ZIP_STORED) "stored" else "deflated",
        if (method == ZIP_STORED) 0
        else (entry.size - entry.compressedSize) * 100 / entry.size
      ])
    }
  }
  out.close()
  return SUCCESS
}
