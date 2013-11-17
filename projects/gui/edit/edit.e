/* Simple text editor
 * (C) 2012-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io"
use "string"
use "stdscreens"
use "ui"

use "mint/dialog"
use "mint/actionlist"
use "mint/eventloop"

const HELP = "Usage: edit [file]"
const VERSION = "edit 1.0"

var edit: EditBox;
var file = "";

def save(ask: Bool) {
  var fname = file
  if (fname == "" || ask) {
    fname = showSaveFileDialog("Save as", file)
  }
  if (fname != null && fname != "") try {
    var out = fopen_w(fname)
    var buf = edit.text.utfbytes()
    out.writearray(buf, 0, buf.len)
    out.close()
    edit.title = pathfile(file) + " - Edit"
    file = fname
  } catch (var e) {
    showError("I/O Error", "Failed to save file "+file + ". Cause: " + e)
  }
}

def main(args: [String]): Int {
  // parse arguments
  var quit = false
  var exitcode = 0
  if (args.len > 0) {
    if (args[0] == "-h") {
      println(HELP)
      quit = true
    } else if (args[0] == "-v") {
      println(VERSION)
      quit = true
    } else {
      file = abspath(args[0])
    }
  }

  // loading file
  if (!quit) {
    edit = new EditBox(EDIT_ANY)
    if (file == "" || !exists(file)) {
      edit.title = "[NEW] - Edit"
    } else {
      edit.title = pathfile(file) + " - Edit"
      var size = fsize(file)
      if (size > edit.maxsize) {
        showError("I/O Error", "The file " + file + " is too big for edit.")
        exitcode = 1
        quit = true
      }
      if (!quit) {
        try {
          var input = fopen_r(file)
          var buf = input.readfully()
          input.close()
          edit.text = ba2utf(buf)
        } catch (var e) {
          showError("I/O Error", "Failed to load file "+file + ". Cause: " + e)
          exitcode = 1
          quit = true
        }
      }
    }
  }

  // processing
  if (!quit) {
    var list = new ActionList("Menu")
    list.add("Save", "document-save", save.curry(false))
    list.add("Save as", "document-save-as", save.curry(true))

    var loop = new EventLoop(edit)
    loop.onMenu(new Menu("Menu", 1), list.start.curry(true))
    list.add("Quit", "app-exit", loop.quit)
    loop.start()
  }
  exitcode
}
