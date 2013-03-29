use "ui.eh"
use "stdscreens.eh"

def Screen.show_modal(): Menu {
  var back = ui_get_screen()
  ui_set_screen(this)
  var e: UIEvent;
  do {
    e = ui_wait_event()
  } while (e.kind != EV_MENU || e.source != this)
  ui_set_screen(back)
  cast (Menu) e.value
}

def run_listbox(title: String, strings: [String], ok: String, cancel: String): Int {
  var okmenu = new_menu(ok, 1)
  var cancelmenu = new_menu(cancel, 2)
  var list = new_listbox(strings, null, okmenu)
  list.title = title
  list.add_menu(okmenu)
  list.add_menu(cancelmenu)
  if (list.show_modal() == okmenu)
    list.index
  else
    -1
}

def run_editbox(title: String, text: String, mode: Int): String {
  var box = new_editbox(mode)
  box.title = title
  box.text = text
  var ok = new_menu("Ok", 1)
  var cancel = new_menu("Cancel", 2)
  box.add_menu(ok)
  box.add_menu(cancel)
  if (box.show_modal() == ok)
    box.text
  else
    null
}

def run_msgbox(title: String, msg: String) {
  var box = new MsgBox(msg, null)
  box.title = title
  box.add_menu(new Menu("Back", 1))
  box.show_modal()
}