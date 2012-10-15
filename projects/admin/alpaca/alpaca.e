use "io.eh"
use "list.eh"
use "sys.eh"

use "ui.eh"
use "form.eh"
use "image.eh"
use "stdscreens.eh"

use "pkg.eh"

// TODO: use pkg.eh API once it is guarded

var icon_inst: Image;
var icon_del: Image;
var icon_upd: Image;

def show_modal(scr: Screen): Menu {
  var back = ui_get_screen()
  ui_set_screen(scr)
  var e = ui_wait_event()
  while (e.source != scr || e.kind != EV_MENU) {
    e = ui_wait_event()
  }
  ui_set_screen(back)
  cast (Menu) e.value
}

def show_package(spec: PkgSpec, instspec: PkgSpec): Bool {
  var form = new_form()
  form.set_title("Package info")
  form.add(new_textitem("Name:",spec.get("Package")))
  
  var back = new_menu("Back", 2)
  form.add_menu(back)
  if (instspec == null) {
    form.add_menu(new_menu("Install", 3))
    form.add(new_textitem("Version:", spec.get("Version")))
    form.add(new_textitem("Status:", "Not installed"))
  } else if (spec != instspec) {
    form.add_menu(new_menu("Update", 3))
    form.add(new_textitem("Version:", instspec.get("Version")))
    form.add(new_textitem("Status:", "Can be updated to "+spec.get("Version")))
  } else {
    form.add_menu(new_menu("Remove", 3))
    form.add(new_textitem("Version:", spec.get("Version")))
    form.add(new_textitem("Status:", "Installed"))
  }
  
  var value = spec.get("Depends")
  if (value != null) form.add(new_textitem("Depends:", value))
  value = spec.get("Homepage")
  if (value != null) form.add(new_textitem("Homepage:", value))
  value = spec.get("Summary")
  if (value != null) form.add(new_textitem("Summary:", value))
  show_modal(form) != back
}

def show_list(pkgs: List): Int {
  var strings = new [String](pkgs.len()/2)
  var images = new [Image](strings.len)
  for (var i=0, i<strings.len, i += 1) {
    var spec = cast (PkgSpec) pkgs.get(i*2)
    strings[i] = spec.get("Package")
    var instspec = pkgs.get(i*2+1)
    if (instspec == null) images[i] = icon_del
    else if (instspec != spec) images[i] = icon_upd
    else images[i] = icon_inst
  }
  var box = new_listbox(strings, images, new_menu("Select", 1))
  var mback = new_menu("Back", 2)
  box.add_menu(mback)
  if (show_modal(box) == mback) {
    -1
  } else {
    box.get_index()
  }
}

def catindex(cat: String): Int {
  if (cat == "admin") 0
  else if (cat == "devel") 1
  else if (cat == "doc") 2
  else if (cat == "graphics") 3
  else if (cat == "games") 4
  else if (cat == "gui") 5
  else if (cat == "libdevel") 6
  else if (cat == "libs") 7
  else if (cat == "misc") 8
  else if (cat == "net") 9
  else if (cat == "sound") 10
  else if (cat == "text") 11
  else if (cat == "utils") 12
  else if (cat == "video") 13
  else 14
}

def buildindex(pkgindex: [List], pm: PkgManager) {
  for (var i=0, i<pkgindex.len, i=i+1) pkgindex[i] = new_list()
  var pkgs = pkg_list_all(pm)
  for (var i=0, i<pkgs.len, i=i+1) {
    var spec = pkg_query(pm, pkgs[i].tostr(), null)
    var list = pkgindex[catindex(spec.get("Section"))]
    list.add(spec)
    list.add(pkg_query_installed(pm, spec.get("Package")))
  }
}

def main(args: [String]) {
  ui_set_screen(new_textbox("Building package index..."))
  // loading icons
  icon_inst = image_from_file("/res/alpaca/installed.png")
  icon_upd = image_from_file("/res/alpaca/update.png")
  icon_del = image_from_file("/res/alpaca/deleted.png")

  var catnames = new [String] {
    "Administration",
    "Development",
    "Documentation",
    "Graphics",
    "Games",
    "Graphical interface",
    "Library headers",
    "Libraries",
    "Miscellaneous",
    "Internet",
    "Sound",
    "Text editors",
    "Utilities",
    "Video",
    "Other/Unknown"
  }
  //var pm = pkg_init()
  var pkgindex = new [List](catnames.len)
  buildindex(pkgindex, pkg_init())

  var mselect = new_menu("Select", 1)
  var mrefresh = new_menu("Refresh lists", 2)
  var mupdate = new_menu("Update all", 3)
  var mquit = new_menu("Quit", 5)
  var catscr = new_listbox(catnames, null, mselect)
  catscr.set_title("Alpaca")
  catscr.add_menu(mrefresh)
  catscr.add_menu(mupdate)
  catscr.add_menu(mquit)
  ui_set_screen(catscr)
  
  var e = ui_wait_event()
  while (e.value != mquit) {
    if (e.kind == EV_MENU) {
      if (e.value == mselect) {
        var list = pkgindex[catscr.get_index()]
        var index = show_list(list)
        if (index >= 0) {
          var spec = cast(PkgSpec)list.get(index*2)
          var instspec = cast(PkgSpec)list.get(index*2+1)
          if (show_package(spec, instspec)) {
            var name = spec.get("Package")
            if (instspec == null) {
              ui_set_screen(new_textbox("Installing package "+name+"..."))
              //pkg_install(pm, new Array{name})
              exec_wait("terminal", new [String]{"-k", "pkg", "install", name})
            } else if (instspec != spec) {
              ui_set_screen(new_textbox("Updating package "+name+"..."))
              //pkg_install(pm, new Array{name})
              exec_wait("terminal", new [String]{"-k", "pkg", "install", name})
            } else {
              ui_set_screen(new_textbox("Removing package "+name+"..."))
              //pkg_remove(pm, new Array{name})
              exec_wait("terminal", new [String]{"-k", "pkg", "remove", name})
            }
            ui_set_screen(new_textbox("Building package index..."))
            buildindex(pkgindex, pkg_init())
            ui_set_screen(catscr)
          }
        }
      } else if (e.value == mrefresh) {
        ui_set_screen(new_textbox("Downloading package lists..."))
        //pkg_refresh(pm)
        exec_wait("terminal", new [String]{"-k", "pkg", "refresh"})
        ui_set_screen(new_textbox("Building package index..."))
        buildindex(pkgindex, pkg_init())
        ui_set_screen(catscr)
      } else if (e.value == mupdate) {
        ui_set_screen(new_textbox("Updating all packages..."))
        //pkg_install(pm, pkg_list_installed())
        exec_wait("terminal", new [String]{"-k", "pkg", "update"})
        ui_set_screen(new_textbox("Building package index..."))
        buildindex(pkgindex, pkg_init())
        ui_set_screen(catscr)
      }
    }
    e = ui_wait_event()
  }
}
