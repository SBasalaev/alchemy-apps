/* Application menu for Alchemy GUI.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "image.eh"

type App {
  name: String,
  icon: Image,
  exec: String
}

def readdesktop(file: String): App {
  var in = fopen_r(file)
  var r = utfreader(in)
  var line = freadline(r)
  var app = new App()
  while (line != null) {
    var eq = strindex(line, '=')
    if (eq > 0) {
      var key = strtrim(substr(line, 0, eq))
      var value = strtrim(substr(line, eq+1, strlen(line)))
      if (key == "Name") {
        app.name = value
      } else if (key == "Exec") {
        app.exec = value
      } else if (key == "Icon") {
        if (strchr(value, 0) != '/') value = "/res/icons/"+value
        if (exists(value)) {
          var imgin = fopen_r(value)
          app.icon = image_from_stream(imgin)
          fclose(imgin)
        }
      }
    }
    line = freadline(r)
  }
  fclose(in)
  if (app.exec == null) {
    cast (App) null
  } else {
    if (app.name == null) app.name = app.exec
    app
  }
}

def readapps(): Array {
  var files = flist("/res/apps/")
  var apps = new_vector()
  for (var i=0, i < files.len, i=i+1) {
    var app = readdesktop("/res/apps/"+files[i])
    if (app != null) v_add(apps, app)
  }
  v_toarray(apps)
}

def makelist(apps: Array, select: Menu): Screen {
  var strings = new Array(apps.len)
  var icons = new Array(apps.len)
  for (var i=0, i < apps.len, i=i+1) {
    var app = cast (App) apps[i]
    strings[i] = app.name
    icons[i] = app.icon
  }
  var scr = new_listbox(strings, icons, select)
  screen_set_title(scr, "Applications")
  scr
}

def main(args: Array) {
  var mselect = new_menu("Launch", 1)
  var mrefresh = new_menu("Refresh", 2)
  var mquit = new_menu("Quit", 15)
  var apps = readapps()
  var scr = makelist(apps, mselect)
  screen_add_menu(scr, mrefresh)
  screen_add_menu(scr, mquit)
  ui_set_screen(scr)
  var e = ui_wait_event()
  while (e.value != mquit) {
    if (e.value == mrefresh) {
      apps = readapps()
      scr = makelist(apps, mselect)
      screen_add_menu(scr, mrefresh)
      screen_add_menu(scr, mquit)
      ui_set_screen(scr)
    } else if (e.value == mselect) {
      var index = listbox_get_index(scr)
      if (index >= 0) {
        var app = cast (App) apps[index]
        var cmd = strsplit(app.exec, ' ')
        var cmdargs = new Array(cmd.len-1)
        acopy(cmd, 1, cmdargs, 0, cmdargs.len)
        exec(to_str(cmd[0]), cmdargs)
      }
    }
    e = ui_wait_event()
  }
}
