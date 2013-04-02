use "io.eh"
use "stdscreens.eh"
use "ui.eh"
use "list.eh"

def run_dirchooser(title: String, current: String): String {
  // searching applicable folder
  current = abspath(current)
  while (!is_dir(current)) current = pathdir(current)
  // initializing UI
  var select = new Menu("Select", 1)
  var cancel = new Menu("Cancel", 2)
  var list = new ListBox(new [String](0), null, select)
  list.title = title
  list.add_menu(cancel)
  // starting UI
  var quit = false
  var back = ui_get_screen()
  ui_set_screen(list)
  while (!quit) {
    list.clear()
    list.add("<this dir>")
    if (current != "") list.add("..")
    var files = flist(current)
    for (var i=0, i<files.len, i+=1) {
      var file = files[i]
      if (file[file.len()-1] == '/') list.add(file)
    }
    var e: UIEvent
    do {
      e = ui_wait_event()
    } while (e.source != list || e.kind != EV_MENU)
    if (e.value == cancel) {
      current = null
      quit = true
    } else if (list.index == 0) {
      quit = true
    } else {
      current = abspath(current + '/' + list.get_string(list.index))
    }
  }
  // returning
  ui_set_screen(back)
  current
}
