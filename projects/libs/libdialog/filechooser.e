use "io.eh"
use "stdscreens.eh"
use "ui.eh"
use "list.eh"

def run_filechooser(title: String, current: String, filters: [String] = null): String {
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
    if (current != "") list.add("..")
    var files = flist(current)
    for (var i=0, i<files.len, i+=1) {
      var file = files[i]
      if (file[file.len()-1] == '/') {
        // always add directory
        list.add(file)
      } else {
        // check against filters
        var matches = filters == null
        for (var j=0, !matches && j<filters.len, j+=1) {
          matches = matches_glob(file, filters[j])
        }
        if (matches) list.add(file)
      }
    }
    var e: UIEvent
    do {
      e = ui_wait_event()
    } while (e.source != list || e.kind != EV_MENU)
    if (e.value == cancel) {
      current = null
      quit = true
    } else {
      current = abspath(current + '/' + list.get_string(list.index))
      if (!is_dir(current)) quit = true
    }
  }
  // returning
  ui_set_screen(back)
  current
}
