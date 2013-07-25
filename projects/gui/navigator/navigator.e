/* File manager for Alchemy OS.
 * Copyright (c) 2012-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

const HELP = "File browser for Alchemy OS"
const VERSION = "navigator 0.4"

use "io"
use "string"
use "list"
use "sys"
use "ui"
use "stdscreens"
use "image"
use "filetype"
use "dialog"

type NavData {
  ftypedb: FTypeDB,
  icon_archive: Image,
  icon_audio: Image,
  icon_dir: Image,
  icon_exec: Image,
  icon_image: Image,
  icon_lib: Image,
  icon_text: Image,
  icon_video: Image,
  icon_web: Image,
  icon_other: Image,
  icon_up: Image
}

// sorts files alphabetically, directories first
def filecmp(f1: String, f2: String): Int {
  var isdir1 = f1[f1.len()-1] == '/'
  var isdir2 = f2[f2.len()-1] == '/'
  if (isdir1 ^ isdir2) {
    if (isdir1) -1 else 1
  } else {
    f1.lcase().cmp(f2.lcase())
  }
}

// returns icon for given file
def NavData.iconfor(fname: String): Image {
  var ftype: FileType = null
  var dot = fname.lindexof('.')
  if (dot > 0) ftype = ftype_for_ext(this.ftypedb, fname[dot+1:])
  if (ftype == null) ftype = ftype_for_file(this.ftypedb, fname)
  if (ftype.category == DIR) this.icon_dir
  else if (ftype.category == TEXT) this.icon_text
  else if (ftype.category == LIB) this.icon_lib
  else if (ftype.category == EXEC) this.icon_exec
  else if (ftype.category == IMAGE) this.icon_image
  else if (ftype.category == AUDIO) this.icon_audio
  else if (ftype.category == VIDEO) this.icon_video
  else if (ftype.category == WEB) this.icon_web
  else if (ftype.category == ARCHIVE) this.icon_archive
  else this.icon_other
}

def navupdate(scr: ListBox, data: NavData) {
  scr.clear()
  var cwd = get_cwd()
  scr.title = (if (cwd == "") "/" else pathfile(cwd)) + " - Navigator"
  if (cwd != "") {
    scr.add("..", data.icon_up)
  }
  var filestrings = flist(cwd)
  var files = new List()
  files.addfrom(filestrings, 0, filestrings.len)
  files.sortself(filecmp)
  for (var i=0, i<files.len(), i+=1) {
    var fname = files[i].cast(String)
    if (fname[fname.len()-1] == '/') {
      scr.add(fname, data.icon_dir)
    } else {
      scr.add(fname, data.iconfor(fname))
    }
  }
}

def copyname(file: String): String {
  if (!exists(file)) {
    file
  } else {
    var dot = file.lindexof('.')
    var name = if (dot > 0) file[:dot] else file
    var ext = if (dot > 0) file[dot:] else ""
    var idx = 1
    file = name + "(copy)" + ext
    while (exists(file)) {
      idx += 1
      file = name + "(copy " + idx + ')' + ext
    }
    file
  }
}

def navmain() {
  var mselect = new Menu("Open", 1)
  var navscreen = new ListBox(["Loading..."], null, mselect)
  navscreen.title = "Navigator"
  ui_set_screen(navscreen)
  // load file types and icons
  var navdata = new NavData {
    ftypedb = ftype_loaddb(),
    icon_archive=image_from_file("/res/navigator/icons/archive.png"),
    icon_audio = image_from_file("/res/navigator/icons/audio.png"),
    icon_dir   = image_from_file("/res/navigator/icons/dir.png"),
    icon_exec  = image_from_file("/res/navigator/icons/exec.png"),
    icon_image = image_from_file("/res/navigator/icons/image.png"),
    icon_lib   = image_from_file("/res/navigator/icons/lib.png"),
    icon_text  = image_from_file("/res/navigator/icons/text.png"),
    icon_video = image_from_file("/res/navigator/icons/video.png"),
    icon_web   = image_from_file("/res/navigator/icons/web.png"),
    icon_other = image_from_file("/res/navigator/icons/unknown.png"),
    icon_up    = image_from_file("/res/navigator/icons/up.png")
  }
  // initialize UI
  var mprops = new Menu("Properties", 2)
  var mrename = new Menu("Rename", 3)
  var mdelete = new Menu("Delete", 4)
  var mnewfile = new Menu("New file", 5)
  var mnewdir = new Menu("New directory", 6)
  var mcut = new Menu("Cut", 7)
  var mcopy = new Menu("Copy", 8)
  var mpaste = new Menu("Paste", 9)
  var mrefresh = new Menu("Refresh", 10)
  var mquit = new Menu("Quit", 15, MT_EXIT)
  navscreen.add_menu(mprops)
  navscreen.add_menu(mrename)
  navscreen.add_menu(mdelete)
  navscreen.add_menu(mnewfile)
  navscreen.add_menu(mnewdir)
  navscreen.add_menu(mcut)
  navscreen.add_menu(mcopy)
  navscreen.add_menu(mpaste)
  navscreen.add_menu(mrefresh)
  navscreen.add_menu(mquit)
  // initialize clipboard
  var clipboard = ""
  var cut = false
  // run
  navupdate(navscreen, navdata)
  var e = ui_wait_event()
  while (e.value != mquit) {
    var fname = navscreen.get_string(navscreen.get_index())
    if (e.value == mselect) {
      // open selected file
      if (fname == ".." || fname[fname.len()-1] == '/') {
        set_cwd(fname)
        navupdate(navscreen, navdata)
      } else {
        var ftype = ftype_for_file(navdata.ftypedb, fname)
        if (ftype.command != "") {
          try exec(ftype.command, [fname]) catch { }
        } else if (ftype.category == "text") {
          try exec("edit", [fname]) catch { }
        } else if (ftype.category == "image") {
          try exec("imgview", [fname]) catch { }
        } else if (ftype.category == "exec") {
          try exec(abspath(fname), []) catch { }
        }
      }
    } else if (e.value == mprops) {
      // show properties of the selected file
      try exec("fileinfo", [fname]) catch { }
    } else if (e.value == mrename && fname != "..") {
      // rename selected file
      var newpath = run_editbox("Rename file", fname)
      if (newpath != null) {
        newpath = pathfile(newpath)
        var exitcode = try {
          exec_wait("mv", [fname, pathfile(newpath)])
        } catch { -1 }
        if (exitcode == 0) {
          navscreen.set(navscreen.get_index(), newpath, navdata.iconfor(newpath))
        } else {
          run_alert("I/O error", "Error accessing file " + fname)
        }
      }
    } else if (e.value == mdelete) {
      // remove selected file
      if (is_dir(fname) && try { flist(fname).len > 0 } catch {true}) {
        if (run_yesno("Delete file", "Directory " + fname + " is not empty. Are you sure you want to delete it?")) {
          var exitcode = try {
            exec_wait("rm", ["-r", fname])
          } catch { -1 }
          if (exitcode == 0) {
            navscreen.delete(navscreen.get_index())
          } else {
          run_alert("I/O error", "Error accessing file " + fname)
          }
        }
      } else if (run_yesno("Delete file", "Delete " + fname + '?')) {
        try {
          fremove(fname)
          navscreen.delete(navscreen.get_index())
        } catch {
          run_alert("I/O error", "Error accessing file " + fname)
        }
      }
    } else if (e.value == mnewfile) {
      // create new empty file
      var newfile = run_editbox("New file", "")
      if (newfile != null && newfile.indexof('/') < 0 && !exists(newfile)) {
        try {
          fcreate(newfile)
          navupdate(navscreen, navdata)
        } catch {
          run_alert("I/O error", "Error accessing file " + newfile)
        }
      }
    } else if (e.value == mnewdir) {
      // create new directory
      var newdir = run_editbox("New directory", "")
      if (newdir != null && newdir.indexof('/') < 0 && !exists(newdir)) {
        try {
          mkdir(newdir)
          navupdate(navscreen, navdata)
        } catch {
          run_alert("I/O error", "Error accessing file " + newdir)
        }
      }
    } else if (e.value == mcut) {
      // copy file name to the clipboard
      cut = true
      clipboard = abspath(fname)
    } else if (e.value == mcopy) {
      // copy file name to the clipboard
      cut = false
      clipboard = abspath(fname)
    } else if (e.value == mpaste) {
      // copy/cut file from the clipboard
      if (clipboard == "") {
        run_alert("Clipboard", "No files to " + if (cut) "cut" else "copy")
      } else if (pathdir(clipboard) == get_cwd()) {
        var exitcode = try {
          exec_wait("cp", ["-r", clipboard, get_cwd() + '/' + copyname(pathfile(clipboard))])
        } catch { -1 }
        if (exitcode != 0) {
          run_alert("I/O error", "Error accessing file " + clipboard)
        } else if (cut) {
          exitcode = try {
            exec_wait("rm", ["-r", clipboard])
          } catch { -1 }
          if (exitcode != 0) {
            run_alert("I/O error", "Error accessing file " + clipboard)
          }
        }
        navupdate(navscreen, navdata)
      }
    } else if (e.value == mrefresh) {
      navupdate(navscreen, navdata)
    }
    e = ui_wait_event()
  }
}

def main(args: [String]) {
  // process command line arguments
  var quit = false
  if (args.len > 0) {
    var arg = args[0]
    if (arg == "-h") {
      println(HELP)
      quit = true
    } else if (arg == "-v") {
      println(VERSION)
      quit = true
    } else {
      try set_cwd(arg) catch { }
    }
  }
  if (!quit) navmain()
}
