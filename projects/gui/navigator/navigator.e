/* File manager for Alchemy.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "io.eh"
use "sys.eh"
use "string.eh"
use "stdscreens.eh"
use "ui.eh"
use "image.eh"
use "filetype.eh"

var ftypedb: FTypeDB;

// category icons
var icon_up: Image;
var icon_dir: Image;
var icon_text: Image;
var icon_exec: Image;
var icon_lib: Image;
var icon_image: Image;
var icon_audio: Image;
var icon_video: Image;
var icon_other: Image;

var mselect: Menu;
var mprops: Menu;
var mrename: Menu;
var mdelete: Menu;
var mnewfile: Menu;
var mnewdir: Menu;
var mrefresh: Menu;
var mquit: Menu;

def show_modal(scr: Screen): Menu {
  var back = ui_get_screen()
  ui_set_screen(scr)
  var e = ui_wait_event()
  while (e.kind != EV_MENU) {
    e = ui_wait_event()
  }
  ui_set_screen(back)
  cast(Menu)e.value
}

def text_dialog(title: String, default: String): String {
  var ok = new_menu("Ok", 1)
  var cancel = new_menu("Cancel", 2)
  var box = new_editbox(EDIT_ANY)
  screen_set_title(box, title)
  editbox_set_text(box, default)
  screen_add_menu(box, ok)
  screen_add_menu(box, cancel)
  if (show_modal(box) == ok)
    editbox_get_text(box)
  else
    cast(String)null
}

def yesno_dialog(title: String, msg: String): Bool {
  var yes = new_menu("Yes", 1)
  var no = new_menu("No", 2)
  var box = new_textbox(msg)
  screen_set_title(box, title)
  screen_add_menu(box, yes)
  screen_add_menu(box, no)
  show_modal(box) == yes
}

def filelist(): Array {
  var files = flist(get_cwd())
  var strings: Array;
  // TODO: sort/filter file list
  if (get_cwd() == "") {
    strings = files
  } else {
    strings = new Array(files.len+1)
    strings[0] = ".."
    acopy(files, 0, strings, 1, files.len)
  }
  strings
}

def showfilelist(strings: Array): Screen {
  var icons = new Array(strings.len)
  for (var i=0, i<strings.len, i=i+1) {
    var str = to_str(strings[i])
    if (str == "..") {
      icons[i] = icon_up
    } else {
      var ftype = ftype_for_file(ftypedb, str)
      icons[i] =
      if (ftype.category == DIR) icon_dir
      else if (ftype.category == TEXT) icon_text
      else if (ftype.category == LIB) icon_lib
      else if (ftype.category == EXEC) icon_exec
      else if (ftype.category == IMAGE) icon_image
      else if (ftype.category == AUDIO) icon_audio
      else if (ftype.category == VIDEO) icon_video
      else icon_other
    }
  }
  var box = new_listbox(strings, icons, mselect)
  screen_set_title(box, get_cwd()+"/ - Navigator")
  screen_add_menu(box, mprops)
  screen_add_menu(box, mrename)
  screen_add_menu(box, mdelete)
  screen_add_menu(box, mnewfile)
  screen_add_menu(box, mnewdir)
  screen_add_menu(box, mrefresh)
  screen_add_menu(box, mquit)
  ui_set_screen(box)
  box
}

def image_from_file(file: String): Image {
  var in = fopen_r(file)
  var image = image_from_stream(in)
  fclose(in)
  image
}

def main(args: Array) {
  // load db
  ftypedb = ftype_loaddb()
  // load icons
  icon_dir   = image_from_file("/res/navigator/dir.png")
  icon_text  = image_from_file("/res/navigator/text.png")
  icon_exec  = image_from_file("/res/navigator/exec.png")
  icon_lib   = image_from_file("/res/navigator/lib.png")
  icon_image = image_from_file("/res/navigator/image.png")
  icon_audio = image_from_file("/res/navigator/audio.png")
  icon_video = image_from_file("/res/navigator/video.png")
  icon_other = image_from_file("/res/navigator/unknown.png")
  // init menus
  mselect = new_menu("Open", 1)
  mprops = new_menu("Properties", 2)
  mrename = new_menu("Rename", 3)
  mdelete = new_menu("Delete", 4)
  mnewfile = new_menu("New file", 5)
  mnewdir = new_menu("New directory", 6)
  mrefresh = new_menu("Refresh", 7)
  mquit = new_menu("Quit", 15)
  // showing file list
  var list = filelist()
  var scr = showfilelist(list)
  // main cycle
  var e = ui_wait_event()
  while (e.value != mquit) {
    var path = to_str(list[listbox_get_index(scr)])
    if (e.value == mselect) {
      if (path == ".." || strindex(path, '/') > 0) {
        set_cwd(path)
        list = filelist()
        scr = showfilelist(list)
      } else {
        var ftype = ftype_for_file(ftypedb, path)
        if (ftype.command != "") {
          exec(ftype.command, new Array{path})
        } else if (ftype.category == "text") {
          exec("edit", new Array{path})
        } else if (ftype.category == "image") {
          exec("imgview", new Array{path})
        } else if (ftype.category == "exec") {
          exec(path, new Array(0))
        }
      }
    } else if (e.value == mprops) {
      exec("fileinfo", new Array{path})
    } else if (e.value == mrename && path != "..") {
      var newpath = text_dialog("Rename file", path)
      if (newpath != null) {
        exec_wait("mv", new Array{path, pathfile(newpath)})
        list = filelist()
        scr = showfilelist(list)
      }
    } else if (e.value == mdelete && yesno_dialog("Delete file", "Delete "+path+"?")) {
      exec_wait("rm", new Array{path})
      list = filelist()
      scr = showfilelist(list)
    } else if (e.value == mnewfile) {
      var newfile = text_dialog("New file", "")
      if (newfile != null && strindex(newfile, '/') < 0 && !exists(newfile)) {
        fcreate(newfile)
      }
      list = filelist()
      scr = showfilelist(list)
    } else if (e.value == mnewdir) {
      var newdir = text_dialog("New directory", "")
      if (newdir != null && strindex(newdir, '/') < 0 && !exists(newdir)) {
        mkdir(newdir)
      }
      list = filelist()
      scr = showfilelist(list)
    } else if (e.value == mrefresh) {
      list = filelist()
      scr = showfilelist(list)
    }
    e = ui_wait_event()
  }
}
