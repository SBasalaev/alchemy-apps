/* File manager for Alchemy.
 * Copyright (c) 2012-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

/* TODO:
 * 1) rewrite this whole mess
 *   There is no need to generate new
 *   window for every directory, menus
 *   can be local vars then
 * 2) Sort file list, make sorting
 *   configurable
 * 3) Make submenus
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
var icon_web: Image;
var icon_archive: Image;
var icon_other: Image;

var mselect: Menu;
var mprops: Menu;
var mrename: Menu;
var mdelete: Menu;
var mnewfile: Menu;
var mnewdir: Menu;
var mrefresh: Menu;
var mcut: Menu;
var mcopy: Menu;
var mpaste: Menu;
var mquit: Menu;

def show_modal(scr: Screen): Menu {
  var back = ui_get_screen()
  ui_set_screen(scr)
  var e = ui_wait_event()
  while (e.kind != EV_MENU) {
    e = ui_wait_event()
  }
  ui_set_screen(back)
  e.value.cast(Menu)
}

def text_dialog(title: String, default: String): String {
  var ok = new_menu("Ok", 1)
  var cancel = new_menu("Cancel", 2)
  var box = new_editbox(EDIT_ANY)
  box.set_title(title)
  box.set_text(default)
  box.add_menu(ok)
  box.add_menu(cancel)
  if (show_modal(box) == ok)
    box.get_text()
  else
    null
}

def yesno_dialog(title: String, msg: String): Bool {
  var yes = new_menu("Yes", 1)
  var no = new_menu("No", 2)
  var box = new_msgbox(msg, null)
  box.set_title(title)
  box.add_menu(yes)
  box.add_menu(no)
  show_modal(box) == yes
}

def filelist(): [String] {
  var files = flist(get_cwd())
  var strings: [String];
  // TODO: sort/filter file list
  if (get_cwd() == "") {
    strings = files
  } else {
    strings = new [String](files.len+1)
    strings[0] = ".."
    acopy(files, 0, strings, 1, files.len)
  }
  strings
}

def showfilelist(strings: [String]): ListBox {
  var icons = new [Image](strings.len)
  for (var i=0, i<strings.len, i=i+1) {
    var str = strings[i]
    if (str == "..") {
      icons[i] = icon_up
    } else if (str[str.len()-1] == '/') {
      icons[i] = icon_dir
    } else {
      var ftype: FileType
      var dot = str.indexof('.')
      if (dot > 0) ftype = ftype_for_ext(ftypedb, str[dot+1:])
      if (ftype == null) ftype = ftype_for_file(ftypedb, str)
      icons[i] =
      if (ftype.category == DIR) icon_dir
      else if (ftype.category == TEXT) icon_text
      else if (ftype.category == LIB) icon_lib
      else if (ftype.category == EXEC) icon_exec
      else if (ftype.category == IMAGE) icon_image
      else if (ftype.category == AUDIO) icon_audio
      else if (ftype.category == VIDEO) icon_video
      else if (ftype.category == WEB) icon_web
      else if (ftype.category == ARCHIVE) icon_archive
      else icon_other
    }
  }
  var box = new_listbox(strings, icons, mselect)
  box.set_title(pathfile(get_cwd())+" - Navigator")
  box.add_menu(mprops)
  box.add_menu(mrename)
  box.add_menu(mdelete)
  box.add_menu(mnewfile)
  box.add_menu(mnewdir)
  box.add_menu(mcut)
  box.add_menu(mcopy)
  box.add_menu(mpaste)
  box.add_menu(mrefresh)
  box.add_menu(mquit)
  ui_set_screen(box)
  box
}

def main(args: [String]) {
  // load db
  ftypedb = ftype_loaddb()
  // load icons
  icon_archive=image_from_file("/res/navigator/archive.png")
  icon_audio = image_from_file("/res/navigator/audio.png")
  icon_dir   = image_from_file("/res/navigator/dir.png")
  icon_exec  = image_from_file("/res/navigator/exec.png")
  icon_image = image_from_file("/res/navigator/image.png")
  icon_lib   = image_from_file("/res/navigator/lib.png")
  icon_text  = image_from_file("/res/navigator/text.png")
  icon_video = image_from_file("/res/navigator/video.png")
  icon_web   = image_from_file("/res/navigator/web.png")
  icon_other = image_from_file("/res/navigator/unknown.png")
  icon_up    = image_from_file("/res/navigator/up.png")
  // init menus
  mselect = new_menu("Open", 1)
  mprops = new_menu("Properties", 2)
  mrename = new_menu("Rename", 3)
  mdelete = new_menu("Delete", 4)
  mnewfile = new_menu("New file", 5)
  mnewdir = new_menu("New directory", 6)
  mcut = new_menu("Cut", 7)
  mcopy = new_menu("Copy", 8)
  mpaste = new_menu("Paste", 9)
  mrefresh = new_menu("Refresh", 10)
  mquit = new_menu("Quit", 15)
  // showing file list
  var list = filelist()
  var scr = showfilelist(list)
  // main cycle
  var e = ui_wait_event()
  var clipboard = ""
  var cut = false
  while (e.value != mquit) {
    var path = list[scr.get_index()]
    if (e.value == mselect) {
      if (path == ".." || path.indexof('/') > 0) {
        set_cwd(path)
        list = filelist()
        scr = showfilelist(list)
      } else {
        var ftype = ftype_for_file(ftypedb, path)
        if (ftype.command != "") {
          exec(ftype.command, new [String]{path})
        } else if (ftype.category == "text") {
          exec("edit", new [String]{path})
        } else if (ftype.category == "image") {
          exec("imgview", new [String]{path})
        } else if (ftype.category == "exec") {
          exec(abspath(path), new [String](0))
        }
      }
    } else if (e.value == mprops) {
      exec("fileinfo", new [String]{path})
    } else if (e.value == mrename && path != "..") {
      var newpath = text_dialog("Rename file", path)
      if (newpath != null) {
        exec_wait("mv", [path, pathfile(newpath)])
        list = filelist()
        scr = showfilelist(list)
      }
    } else if (e.value == mdelete && yesno_dialog("Delete file", "Delete "+path+"?")) {
      exec_wait("rm", ["-r", path])
      list = filelist()
      scr = showfilelist(list)
    } else if (e.value == mnewfile) {
      var newfile = text_dialog("New file", "")
      if (newfile != null && newfile.indexof('/') < 0 && !exists(newfile)) {
        fcreate(newfile)
      }
      list = filelist()
      scr = showfilelist(list)
    } else if (e.value == mnewdir) {
      var newdir = text_dialog("New directory", "")
      if (newdir != null && newdir.indexof('/') < 0 && !exists(newdir)) {
        mkdir(newdir)
      }
      list = filelist()
      scr = showfilelist(list)
    } else if (e.value == mcut) {
      cut = true
      clipboard = abspath(path)
    } else if (e.value == mcopy) {
      cut = false
      clipboard = abspath(path)
    } else if (e.value == mpaste) {
      if (clipboard.len() == 0) {
        show_modal(new_msgbox("No files to " + if (cut) "cut." else "copy." ))
      } else if (clipboard == abspath(path)) {
        show_modal(new_msgbox("File already exists."))
      } else {
        exec_wait("cp", ["-r", clipboard, get_cwd() + '/' + pathfile(clipboard)])
        if (cut) exec_wait("rm", ["-r", clipboard])
        clipboard = ""
      }
    } else if (e.value == mrefresh) {
      list = filelist()
      scr = showfilelist(list)
    }
    e = ui_wait_event()
  }
}
