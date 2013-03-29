use "newfile.eh"
use "form.eh"
use "ui.eh"

def run_newfile(projcfg: Dict): [String] {
  var form = new Form()
  form.title = "New file"
  var name = "newfile"
  var edit = new EditItem("Name:", name)
  var ename = new TextItem("Files:", name + ".e")
  var hname = new TextItem(null, name + ".eh")
  form.add(edit)
  form.add(ename)
  form.add(hname)
  var mok = new Menu("Ok", 1, MT_OK)
  var mcancel = new Menu("Cancel", 2, MT_CANCEL)
  form.add_menu(mok)
  form.add_menu(mcancel)
  var choice: Any = null
  var back = ui_get_screen()
  ui_set_screen(form)
  while (choice == null) {
    var e = ui_wait_event()
    if (e.source == form) {
      if (e.kind == EV_MENU) {
        choice = e.value
      } else if (e.kind == EV_ITEMSTATE) {
        name = edit.text
        ename.text = name + ".e"
        hname.text = name + ".eh"
      }
    }
  }
  ui_set_screen(back)
  if (choice == mok) [name + ".e", name + ".eh"]
  else null
}