use "themeicon.eh"
use "stdscreens.eh"
use "ui.eh"
use "list.eh"
use "error.eh"

use "actionlist.eh"

type ActionList {
  screen: ListBox,
  actions: List,
  select: Menu,
  cancel: Menu
}

def ActionList.new(title: String) {
  this.select = new Menu("Select", 1, MT_OK)
  this.cancel = new Menu("Cancel", 2, MT_CANCEL)
  this.screen = new ListBox([], null, this.select)
  this.screen.title = title
  this.actions = new List()
}

def ActionList.start(useCancel: Bool = true) {
  if (useCancel) {
    this.screen.add_menu(this.cancel)
  } else {
    this.screen.remove_menu(this.cancel)
  }
  var back = ui_get_screen()
  ui_set_screen(this.screen)
  var e: UIEvent
  do {
    e = ui_wait_event()
  } while (e.kind != EV_MENU || e.source != this.screen)
  ui_set_screen(back)
  if (e.value != this.cancel) {
    this.actions[this.screen.index].cast(())()
  }
}

def ActionList.clear() {
  this.screen.clear()
  this.actions.clear()
}

def ActionList.add(text: String, icon: String, action: ()) {
  if (action == null) error(ERR_ILL_ARG)
  this.screen.add(text, themeIcon(icon, SIZE_LIST))
  this.actions.add(action)
}

def ActionList.set(index: Int, text: String, icon: String, action: ()) {
  if (action == null) error(ERR_ILL_ARG)
  if (index < 0 || index > this.actions.len()) error(ERR_RANGE)
  this.screen.set(index, text, themeIcon(icon, SIZE_LIST))
  this.actions.set(index, action)
}
