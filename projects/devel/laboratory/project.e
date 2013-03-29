use "project.eh"
use "newfile.eh"
use "projectoptions.eh"
use "cfg.eh"
use "stdscreens.eh"
use "ui.eh"
use "sys.eh"
use "list.eh"
use "dialog.eh"
use "image.eh"
use "string.eh"
use "io.eh"
use "error.eh"

var mainsrc: Image
var esrc: Image
var ehdr: Image

def run_project(cfg: Dict, projcfg: Dict) {
  // build file list
  var files = new List()
  var strings = projcfg["SOURCES"].cast(String).split(' ')
  files.addfrom(strings, 0, strings.len)
  strings = projcfg["HEADERS"].cast(String).split(' ')
  files.addfrom(strings, 0, strings.len)
  files.sortself(`String.cmp`)
  // load icons
  var micon = mainsrc
  if (micon == null) {
    micon = image_from_file("/res/laboratory/icons/src-e-main.png")
    mainsrc = micon
  }
  var eicon = esrc
  if (eicon == null) {
    eicon = image_from_file("/res/laboratory/icons/src-e.png")
    esrc = eicon
  }
  var hicon = ehdr
  if (hicon == null) {
    hicon = image_from_file("/res/laboratory/icons/src-eh.png")
    ehdr = hicon
  }
  // build dialog
  var mselect = new Menu("Edit", 1, MT_OK)
  var mbuild = new Menu("Build", 2)
  var mrun = new Menu("Run", 3)
  var mclean = new Menu("Clean", 4)
  var mnew = new Menu("New file", 5)
  var moptions = new Menu("Options", 6)
  var mback = new Menu("Back", 7)
  var filesscr = new ListBox(new [String](0), null, mselect)
  filesscr.title = projcfg["TARGET"].cast(String)
  filesscr.add_menu(mbuild)
  filesscr.add_menu(mrun)
  filesscr.add_menu(mclean)
  filesscr.add_menu(mnew)
  filesscr.add_menu(moptions)
  filesscr.add_menu(mback)
  
  for (var i=0, i<files.len(), i+=1) {
    var name = files[i].cast(String)
    if (name == "main.e") {
      filesscr.add(name, micon)
    } else if (name.endswith(".e")) {
      filesscr.add(name, eicon)
    } else if (name.endswith(".eh")) {
      filesscr.add(name, hicon)
    }
  }
  
  // run dialog
  ui_set_screen(filesscr)
  var quit = false
  while (!quit) {
    var e = ui_wait_event()
    if (e.value == mback) {
      quit = true
    } else if (e.value == mselect) {
      exec(cfg["EDITOR"].cast(String), [filesscr.get_string(filesscr.index)])
    } else if (e.value == mbuild) {
      exec_wait("terminal", ["-k", "make", "all"])
    } else if (e.value == mrun) {
      exec_wait("terminal", ["-k", "make", "run"])
    } else if (e.value == mclean) {
      exec_wait("terminal", ["-k", "make", "clean"])
    } else if (e.value == mnew) {
      var fnames = run_newfile(projcfg)
      if (fnames != null) try {
        for (var i=0, i < fnames.len, i+=1) {
          var name = fnames[i]
          if (files.indexof(name) < 0) {
            if (!exists(name)) fcreate(name)
            files.add(name)
            if (name == "main.e") {
              filesscr.add(name, micon)
              projcfg["SOURCES"] = projcfg["SOURCES"].cast(String) + ' ' + name
            } else if (name.endswith(".e")) {
              filesscr.add(name, eicon)
              projcfg["SOURCES"] = projcfg["SOURCES"].cast(String) + ' ' + name
            } else if (name.endswith(".eh")) {
              filesscr.add(name, hicon)
              projcfg["HEADERS"] = projcfg["HEADERS"].cast(String) + ' ' + name
            }
          } else {
            run_msgbox("Error", "File already exists: " + name)
          }
        }
        save_cfg(projcfg, "project.lab")
      } catch (var er) {
        run_msgbox("I/O Error", if (er.msg() != null) er.msg() else "I/O error")
        println(e)
      }
    } else if (e.value == moptions) {
      run_projectoptions(projcfg)
      save_cfg(projcfg, "project.lab")
    }
  }
}
