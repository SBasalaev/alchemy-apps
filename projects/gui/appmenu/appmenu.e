/* Application menu for Alchemy GUI.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "image.eh"
use "list.eh"
use "string.eh"
use "textio.eh"
use "stdscreens.eh"
use "sys.eh"
use "ui.eh"

type App {
  name: String,
  icon: Image,
  exec: String
}

def readdesktop(file: String): App {
  var r = utfreader(fopen_r(file))
  var line = r.readline()
  var app = new App { }
  while (line != null) {
    var eq = line.indexof('=')
    if (eq > 0) {
      var key = line.substr(0, eq).trim()
      var value = line.substr(eq+1, line.len()).trim()
      if (key == "Name") {
        app.name = value
      } else if (key == "Exec") {
        app.exec = value
      } else if (key == "Icon") {
        if (value.ch(0) != '/') value = "/res/icons/"+value
        if (exists(value)) {
          app.icon = image_from_file(value)
        }
      }
    }
    line = r.readline()
  }
  r.close()
  if (app.exec == null) {
    null
  } else {
    if (app.name == null) app.name = app.exec
    app
  }
}

def readapps(): Array {
  var files = flist("/res/apps/")
  var apps = new_list()
  for (var i=0, i < files.len, i=i+1) {
    var app = readdesktop("/res/apps/"+files[i])
    if (app != null) apps.add(app)
  }
  apps.toarray()
}

def makelist(apps: Array, select: Menu): ListBox {
  var strings = new [String](apps.len)
  var icons = new [Image](apps.len)
  for (var i=0, i < apps.len, i=i+1) {
    var app = cast (App) apps[i]
    strings[i] = app.name
    icons[i] = app.icon
  }
  var scr = new_listbox(strings, icons, select)
  scr.set_title("Applications")
  scr
}

def main(args: [String]) {
  var mselect = new_menu("Launch", 1)
  var mrefresh = new_menu("Refresh", 2)
  var mquit = new_menu("Quit", 15)
  var apps = readapps()
  var scr = makelist(apps, mselect)
  scr.add_menu(mrefresh)
  scr.add_menu(mquit)
  ui_set_screen(scr)
  var e = ui_wait_event()
  while (e.value != mquit) {
    if (e.value == mrefresh) {
      apps = readapps()
      scr = makelist(apps, mselect)
      scr.add_menu(mrefresh)
      scr.add_menu(mquit)
      ui_set_screen(scr)
    } else if (e.value == mselect) {
      var index = scr.get_index()
      if (index >= 0) {
        var app = cast (App) apps[index]
        var cmd = app.exec.split(' ')
        var cmdargs = new [String](cmd.len-1)
        acopy(cmd, 1, cmdargs, 0, cmdargs.len)
        exec(cmd[0], cmdargs)
      }
    }
    e = ui_wait_event()
  }
}
