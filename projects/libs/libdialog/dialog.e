use "dialog.eh"
use "stdscreens.eh"
use "sys.eh"
use "list.eh"

def Screen.show_modal(): Menu {
  var back = ui_get_screen()
  ui_set_screen(this)
  var e: UIEvent;
  do {
    e = ui_wait_event()
  } while (e.source != this || e.kind != EV_MENU)
  ui_set_screen(back)
  e.value.cast(Menu)
}

def run_alert(title: String, msg: String, img: Image = null, timeout: Int = 1500) {
  var box = new MsgBox(msg, img)
  box.title = title
  box.add_menu(new Menu("Ok", 1, MT_OK))
  if (timeout <= 0) {
    box.show_modal()
  } else {
    var back = ui_get_screen()
    ui_set_screen(box)
    var e: UIEvent;
    do {
      sleep(100)
      timeout -= 100
      e = ui_read_event()
    } while (timeout > 0 && (e == null || e.source != box || e.kind != EV_MENU))
    ui_set_screen(back)
  }
}

def run_yesno(title: String, msg: String, y: String = "Yes", n: String = "No", img: Image = null): Bool {
  var box = new MsgBox(msg, img)
  box.title = title
  var myes = new Menu(y, 1, MT_OK)
  var mno = new Menu(n, 2, MT_CANCEL)
  box.add_menu(myes)
  box.add_menu(mno)
  box.show_modal() == myes
}

def run_msgbox(title: String, msg: String, variants: [String], img: Image = null): Int {
  var box = new MsgBox(msg, img)
  box.title = title
  var mlist = new List()
  for (var i=0, i < variants.len, i+=1) {
    var menu = new Menu(variants[i], i+1, if (i==0) MT_OK else MT_CANCEL)
    box.add_menu(menu)
    mlist.add(menu)
  }
  mlist.indexof(box.show_modal())
}

def run_listbox(title: String, lines: [String], images: [Image] = null): Int {
  var mok = new Menu("Ok", 1, MT_OK)
  var mcancel = new Menu("Cancel", 2, MT_CANCEL)
  var box = new ListBox(lines, images, mok)
  box.title = title
  box.add_menu(mcancel)
  if (box.show_modal() == mok) {
    box.index
  } else {
    -1
  }
}

def run_editbox(title: String, text: String = "", mode: Int = EDIT_ANY, maxsize: Int = 50): String {
  var box = new EditBox(mode)
  box.title = title
  box.text = text
  box.maxsize = maxsize
  var mok = new Menu("Ok", 1, MT_OK)
  var mcancel = new Menu("Cancel", 2, MT_CANCEL)
  box.add_menu(mok)
  box.add_menu(mcancel)
  if (box.show_modal() == mok) {
    box.text
  } else {
    null
  }
}
