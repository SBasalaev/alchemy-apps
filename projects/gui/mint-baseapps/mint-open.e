use "version"
use "io"
use "string"
use "sys"

use "desktop"
use "mint/dialog"

const HELP = "Open file or URL in preferred application."

def main(args: [String]): Int {
  // parse arguments
  var quit = false
  var exitcode = 0
  if (args.len == 0 || args[0] == "-h") {
    println(HELP)
    quit = true
  } else if (args[0] == "-v") {
    println(VERSION)
    quit = true
  }
  if (!quit) {
    // search for suitable application
    var app: Application = null
    var db = new DesktopDB();
    var url = args[0]
    var slash = url.indexof('/')
    var colon = url.indexof(':')
    var protocol = "file"
    var path = url
    if ((colon > 0) && (slash < 0 || slash > colon)) {
      protocol = url[:colon]
      path = abspath(url[:colon+1])
    } else {
      path = abspath(path)
      url = "file://" + path
    }
    if (protocol == "file") {
      if (!exists(path)) {
        quit = true
        exitcode = 1
        showError("Not found", "File or directory does not exist: file:" + path)
      } else {
        app = db.defaultAppFor(db.typeForFile(path).extension)
      }
    } else {
      if (protocol == "http" || protocol == "https") {
        app = db.defaultAppFor("html")
      }
      if (app == null) {
        quit = true
        exitcode = 2
        showError("Unknown protocol", "No application was registered to handle protocol " + protocol)
      }
    }
    // run application
    if (!quit) {
      if (app == null) {
        exitcode = 2
        showError("Unknown type", "No suitable application found to open " + url)
      } else {
        var cmd = app.exec
        var sp = cmd.indexof(' ')
        if (sp < 0) sp = cmd.len()
        var cmdargs = cmd[sp:].trim().split(' ')
        cmd = cmd[:sp]
        for (var i=0, i<cmdargs.len, i+=1) {
          if (cmdargs[i] == "%u") {
            cmdargs[i] = url
          } else if (cmdargs[i] == "%f") {
            cmdargs[i] = path
          }
          exec(cmd, cmdargs)
        }
      }
    }
  }
  exitcode
}
