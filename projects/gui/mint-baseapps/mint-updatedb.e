use "version"
use "textio"
use "string"
use "dict"
use "list"

use "desktop"

const HELP = "Updates database of applications."

def main(args: [String]): Int {
  var quit = false
  var exitcode = 0
  if (args.len != 0) {
    quit = true
    if (args[0] == "-h") {
      println(HELP)
    } else if (args[0] == "-v") {
      println(VERSION)
    } else {
      println("Unknown argument: " + args[0])
      exitcode = 2
    }
  }
  if (!quit) {
    // read database
    var db = new Dict()
    var checkContents = false
    if (exists(DESKTOPDB)) {
      var r = utfreader(fopen_r(DESKTOPDB))
      var line = r.readline()
      while (line != null) {
        if (line.len() != 0 && line[0] != '#') {
          var eq = line.indexof('=')
          if (eq > 0) {
            var key = line[:eq].trim()
            var value = line[eq+1:].trim()
            if (key == "Check-Contents") {
              checkContents = value == "true"
            } else {
              var list = new List()
              var desktops = value.split(';')
              list.addfrom(desktops, 0, desktops.len)
              db[key] = list
            }
          }
        }
        line = r.readline()
      }
      r.close()
    }
    // scan .desktop files
    var files = flist("/res/apps/")
    for (var i=0, i<files.len, i+=1) {
      var app = readApplication("/res/apps/" + files[i])
      if (app == null) stderr().println("Failed to parse /res/apps/" + files[i])
      if (app != null && app.extensions != null)
      for (var en=0, en<app.extensions.len, en+=1) {
        var ext = app.extensions[en]
        var list = db[ext].cast(List)
        if (list == null) {
          list = new List()
          db[ext] = list
        }
        if (list.indexof(files[i]) < 0) list.add(files[i])
      }
    }
    // write database
    var out = fopen_w(DESKTOPDB)
    out.println(
      "[Preferences]\n" +
      "Check-Contents=" + checkContents + '\n' +
      '\n' +
      "[Filetypes]")
    var keys = db.keys()
    for (var i=0, i<keys.len, i+=1) {
      var ext = keys[i].cast(String)
      var list = db[ext].cast(List)
      out.print(ext + '=')
      for (var n=0, n<list.len(), n+=1) {
        var desktop = list[n].cast(String)
        if (desktop != "") out.print(desktop + ';')
      }
      out.write('\n')
    }
    out.close()
  }
  exitcode
}
