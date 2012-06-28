use "io.eh"
use "vector.eh"

use "ui.eh"
use "form.eh"
use "image.eh"
use "stdscreens.eh"

use "pkg.eh"

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
  screen_set_title(form, "Package info")
  form_add(form, new_textitem("Name:", pkgspec_get(spec, "Package")))
  
  var back = new_menu("Back", 2)
  screen_add_menu(form, back)
  if (instspec == null) {
    screen_add_menu(form, new_menu("Install", 3))
    form_add(form, new_textitem("Version:", pkgspec_get(spec, "Version")))
    form_add(form, new_textitem("Status:", "Not installed"))
  } else if (spec != instspec) {
    screen_add_menu(form, new_menu("Update", 3))
    form_add(form, new_textitem("Version:", pkgspec_get(instspec, "Version")))
    form_add(form, new_textitem("Status:", "Can be updated to "+pkgspec_get(spec, "Version")))
  } else {
    screen_add_menu(form, new_menu("Remove", 3))
    form_add(form, new_textitem("Version:", pkgspec_get(spec, "Version")))
    form_add(form, new_textitem("Status:", "Installed"))
  }
  
  var value = pkgspec_get(spec, "Depends")
  if (value != null) form_add(form, new_textitem("Depends:", value))
  value = pkgspec_get(spec, "Homepage")
  if (value != null) form_add(form, new_textitem("Homepage:", value))
  value = pkgspec_get(spec, "Summary")
  if (value != null) form_add(form, new_textitem("Summary:", value))
  show_modal(form) != back
}

def show_list(pkgs: Vector): Int {
  var strings = new Array(v_size(pkgs)/2)
  var images = new Array(strings.len)
  for (var i=0, i<strings.len, i=i+1) {
    var spec = cast (PkgSpec) v_get(pkgs, i*2)
    strings[i] = pkgspec_get(spec, "Package")
    var instspec = v_get(pkgs, i*2+1)
    if (instspec == null) images[i] = icon_del
    else if (instspec != spec) images[i] = icon_upd
    else images[i] = icon_inst
  }
  var box = new_listbox(strings, images, new_menu("Select", 1))
  var mback = new_menu("Back", 2)
  screen_add_menu(box, mback)
  if (show_modal(box) == mback) {
    -1
  } else {
    listbox_get_index(box)
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

def buildindex(pkgindex: Array, pm: PkgManager) {
  for (var i=0, i<pkgindex.len, i=i+1) pkgindex[i] = new_vector()
  var pkgs = pkg_list_all(pm)
  for (var i=0, i<pkgs.len, i=i+1) {
    var spec = pkg_query(pm, to_str(pkgs[i]), cast(String)null)
    var list = cast (Vector) pkgindex[catindex(pkgspec_get(spec, "Section"))]
    v_add(list, spec)
    v_add(list, pkg_query_installed(pm, pkgspec_get(spec, "Package")))
  }
}

def main(args: Array) {
  ui_set_screen(new_textbox("Building package index..."))
  // loading icons
  var in = fopen_r("/res/alpaca/installed.png")
  icon_inst = image_from_stream(in)
  fclose(in)
  in = fopen_r("/res/alpaca/update.png")
  icon_upd = image_from_stream(in)
  fclose(in)
  in = fopen_r("/res/alpaca/deleted.png")
  icon_del = image_from_stream(in)
  fclose(in)

  var catnames = new Array {
    "Administration",
    "Development",
    "Documentation",
    "Graphics",
    "Games",
    "User interface",
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
  var pm = pkg_init()
  var pkgindex = new Array(catnames.len)
  buildindex(pkgindex, pm)
  
  var catscr = new_listbox(catnames, cast(Array)null, new_menu("Select", 1))
  screen_set_title(catscr, "Alpaca")
  var mquit = new_menu("Quit", 5)
  screen_add_menu(catscr, mquit)
  ui_set_screen(catscr)
  
  var e = ui_wait_event()
  while (e.value != mquit) {
    if (e.kind == EV_MENU) {
      var list = cast (Vector) pkgindex[listbox_get_index(catscr)]
      var index = show_list(list)
      if (index >= 0) {
        var spec = cast(PkgSpec)v_get(list, index*2)
        var instspec = cast(PkgSpec)v_get(list, index*2+1)
        if (show_package(spec, instspec)) {
          var name = pkgspec_get(spec, "Package")
          if (instspec == null) {
            ui_set_screen(new_textbox("Installing package "+name+"..."))
            pkg_install(pm, new Array{name})
          } else if (instspec != spec) {
            ui_set_screen(new_textbox("Updating package "+name+"..."))
            pkg_install(pm, new Array{name})
          } else {
            ui_set_screen(new_textbox("Removing package "+name+"..."))
            pkg_remove(pm, new Array{name})
          }
          ui_set_screen(new_textbox("Building package index..."))
          buildindex(pkgindex, pm)
          ui_set_screen(catscr)
        }
      }
      ui_set_screen(catscr)
    }
    e = ui_wait_event()
  }
}
