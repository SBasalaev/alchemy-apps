use "dialog.eh"
use "themeicon.eh"
use "config.eh"
use "stdscreens.eh"
use "form.eh"
use "sys.eh"
use "list.eh"
 
use "ui.eh"
use "ui_edit.eh"

def Screen.run(): Menu {
  var back = ui_get_screen()
  ui_set_screen(this)
  var e: UIEvent;
  do {
    e = ui_wait_event()
  } while (e.source != this || e.kind != EV_MENU)
  ui_set_screen(back)
  e.value.cast(Menu)
}

def dialogForm(title: String, msg: String, icon: String): Form {
  var box = new Form()
  box.title = title
  box.add(new ImageItem(null, themeIcon(icon, SIZE_DIALOG)))
  var textitem = new TextItem(null, msg)
  textitem.font = getConfig().dialogFont
  box.add(textitem)
  box
}

def showMessage(title: String, msg: String, icon: String = null, timeout: Int = 0) {
  var box = dialogForm(title, msg, icon)
  box.add_menu(new Menu("Close", 1, MT_OK))
  if (timeout <= 0) {
    box.run()
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

def showInfo(title: String, msg: String, timeout: Int = 0) {
  showMessage(title, msg, DIALOG_INFORMATION, timeout)
}

def showWarning(title: String, msg: String, timeout: Int = 0) {
  showMessage(title, msg, DIALOG_WARNING, timeout)
}

def showError(title: String, msg: String, timeout: Int = 0) {
  showMessage(title, msg, DIALOG_ERROR, timeout)
}

def showYesNo(title: String, msg: String, y: String = "Yes", n: String = "No"): Bool {
  var box = dialogForm(title, msg, DIALOG_QUESTION)
  var yesMenu = new Menu(y, 1, MT_OK)
  var noMenu = new Menu(n, 2, MT_CANCEL)
  box.add_menu(yesMenu)
  box.add_menu(noMenu)
  box.run() == yesMenu
}

def showOption(title: String, msg: String, variants: [String], icon: String = "dialog-question"): Int {
  var box = dialogForm(title, msg, icon)
  var mlist = new List()
  for (var i=0, i < variants.len, i+=1) {
    var menu = new Menu(variants[i], i+1, if (i==0) MT_OK else MT_CANCEL)
    box.add_menu(menu)
    mlist.add(menu)
  }
  mlist.indexof(box.run())
}

def showList(title: String, lines: [String], icons: [String] = null): Int {
  var okMenu = new Menu("Ok", 1, MT_OK)
  var cancelMenu = new Menu("Cancel", 2, MT_CANCEL)
  var images: [Image] = null
  if (icons != null) {
    images = new [Image](icons.len)
    for (var i=0, i<icons.len, i+=1) {
      images[i] = themeIcon(icons[i], SIZE_LIST)
    }
  }
  var box = new ListBox(lines, images, okMenu)
  box.title = title
  box.add_menu(cancelMenu)
  if (box.run() == okMenu) {
    box.index
  } else {
    -1
  }
}

def showInput(title: String, msg: String = null, text: String = "", mode: Int = EDIT_ANY, maxsize: Int = 50): String {
  var box = dialogForm(title, msg, null)
  var okMenu = new Menu("Ok", 1, MT_OK)
  var cancelMenu = new Menu("Cancel", 2, MT_CANCEL)
  box.add_menu(okMenu)
  box.add_menu(cancelMenu)
  var input = new EditItem(null, text, mode, maxsize)
  box.add(input)
  if (box.run() == okMenu) {
    input.text
  } else {
    null
  }
}
