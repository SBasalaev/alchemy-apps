use "projectoptions.eh"
use "form.eh"
use "io.eh"
use "string.eh"
use "ui.eh"

type Options {
  optimize: Bool = true,
  dbginfo: Bool = false,
  libs: String = "",
  other: String = ""
}

def run_projectoptions(projcfg: Dict) {
  // parse options
  var optstring = ""
  if (projcfg["CFLAGS"] != null) optstring += projcfg["CFLAGS"]
  if (projcfg["LFLAGS"] != null) optstring += projcfg["LFLAGS"]
  var opts = optstring.split(' ')
  var options = new Options { }
  for (var i=0, i<opts.len, i+=1) {
    var opt = opts[i]
    if (opt == "-O" || opt == "-O1") {
      options.optimize = true
    } else if (opt == "-O0") {
      options.optimize = false
    } else if (opt == "-g") {
      options.dbginfo = true
    } else if (opt.startswith("-l")) {
      options.libs = options.libs + ' ' + opt
    } else {
      options.other = options.other + ' ' + opt
    }
  }
  // create form
  var form = new Form()
  form.title = "Options"
  form.add(new TextItem(null, "Build options"))
  var optflag = new CheckItem(null, "Optimize", options.optimize)
  form.add(optflag)
  var dbgflag = new CheckItem(null, "Debug info", options.dbginfo)
  form.add(dbgflag)
  var libs = new EditItem("Libraries", options.libs)
  form.add(libs)
  var other = new EditItem("Custom flags", options.other.trim())
  form.add(other)
  var ok = new Menu("Ok", 1, MT_OK)
  var cancel = new Menu("Cancel", 2, MT_CANCEL)
  form.add_menu(ok)
  form.add_menu(cancel)
  // show form
  var back = ui_get_screen()
  ui_set_screen(form)
  var e: UIEvent
  do {
    e = ui_wait_event()
  } while (e.source != form || e.kind != EV_MENU)
  // write options back
  ui_set_screen(back)
  if (e.value == ok) {
    options.optimize = optflag.checked
    options.dbginfo = dbgflag.checked
    options.libs = libs.text
    options.other = other.text
    optstring = if (options.optimize) " " else "-O0 "
    if (options.dbginfo) optstring += "-g "
    optstring += options.other.trim()
    projcfg["CFLAGS"] = optstring
    projcfg["LFLAGS"] = options.libs.trim()
  }
}