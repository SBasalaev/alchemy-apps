/* Simple editor
 * (C) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "string.eh"
use "sys.eh"
use "ui.eh"
use "stdscreens.eh"

const HELP = "Usage: edit file"
const VERSION = "edit 0.9"

def readfile(f: String): String {
  if (exists(f)) {
    var buf = new BArray(fsize(f))
    var in = fopen_r(f)
    in.readarray(buf, 0, buf.len)
    in.close()
    ba2utf(buf)
  } else {
    ""
  }
}

def writefile(f: String, text: String) {
  var buf = text.utfbytes()
  var out = fopen_w(f)
  out.writearray(buf, 0, buf.len)
  out.close()
}

const ALERT_TIMEOUT = 1500

def show_alert(msg: String) {
  var alert = new_textbox(msg)
  alert.set_title("Edit")
  alert.add_menu(new_menu("Close", 1))
  var back = ui_get_screen()
  ui_set_screen(alert)
  for (var i=0, i< ALERT_TIMEOUT / 100, i=i+1) {
    var e = ui_read_event()
    if (e != null && e.source == alert && e.kind == EV_MENU) {
      i = ALERT_TIMEOUT / 100 // quit
    } else {
      sleep(100) // wait a little
    }
  }
  ui_set_screen(back)
}

def main(args: [String]) {
  if (args.len == 0 || args[0] == "-h") {
    println(HELP)
  } else if (args[0] == "-v") {
    println(VERSION)
  } else {
    var f = args[0]
    var edit = new_editbox(EDIT_ANY)
    edit.set_title(f + "- Edit")
    edit.set_text(readfile(f))
    var msave = new_menu("Save", 1)
    var mquit = new_menu("Quit", 2)
    edit.add_menu(msave)
    edit.add_menu(mquit)
    ui_set_screen(edit)
    var e = ui_wait_event()
    while (e.value != mquit) {
      if (e.value == msave) {
        writefile(f, edit.get_text())
        show_alert("File "+f+" is saved.")
      }
      e = ui_wait_event()
    }
  }
}
