use "stdscreens.eh"
use "form.eh"
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

def showMessage(title: String, msg: String) {
  var box = new MsgBox(msg)
  box.title = title
  box.add_menu(new Menu("Next", 1, MT_OK))
  box.run()
}

def showYesNo(title: String, msg: String): Bool {
  var box = new MsgBox(msg)
  box.title = title
  var yesMenu = new Menu("Yes", 1, MT_OK)
  var noMenu = new Menu("No", 2, MT_CANCEL)
  box.add_menu(yesMenu)
  box.add_menu(noMenu)
  box.run() == yesMenu
}

def showOption(title: String, variants: [String], descriptions: [String]): Int {
  var box = new Form()
  box.title = title
  var choice = new RadioItem("", variants)
  var desc = new TextItem("", descriptions[0])
  box.add(choice)
  box.add(desc)
  box.add_menu(new Menu("Next", 1, MT_OK))
  choice.index = 0
  var back = ui_get_screen()
  ui_set_screen(box)
  var e: UIEvent;
  do {
    e = ui_wait_event()
    if (e.kind == EV_ITEMSTATE) {
      desc.text = descriptions[choice.index]
    }
  } while (e.source != box || e.kind != EV_MENU)
  ui_set_screen(back)
  choice.index
}
