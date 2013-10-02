use "eventloop.eh"
use "dict.eh"

type EventLoop {
  scr: Screen,
  quit: Bool = false,
  showHandler: (),
  hideHandler: (),
  menuHandlers: Dict,
  itemHandlers: Dict,
  itemStateHandlers: Dict,
  keyPressHandler: (Int),
  keyHoldHandler: (Int),
  keyReleaseHandler: (Int),
  ptrPressHandler: (Int,Int),
  ptrReleaseHandler: (Int,Int),
  ptrDragHandler: (Int,Int)
}

def EventLoop.new(scr: Screen) {
  this.scr = scr
  this.menuHandlers = new Dict()
  this.itemHandlers = new Dict()
  this.itemStateHandlers = new Dict()
}

def EventLoop.quit() {
  this.quit = true
}

def EventLoop.start() {
  var back = ui_get_screen()
  ui_set_screen(this.scr)
  this.quit = false
  do {
    var e = ui_wait_event()
    switch (e.kind) {
      EV_SHOW: {
        var handler = this.showHandler
        if (handler != null) handler()
      }
      EV_HIDE: {
        var handler = this.hideHandler
        if (handler != null) handler()
      }
      EV_MENU: {
        var handler = this.menuHandlers[e.value].cast(())
        if (handler != null) handler()
      }
      EV_ITEM: {
        var handler = this.itemHandlers[e.value].cast(())
        if (handler != null) handler()
      }
      EV_ITEMSTATE: {
        var handler = this.itemStateHandlers[e.value].cast(())
        if (handler != null) handler()
      }
      EV_KEY: {
        var handler = this.keyPressHandler
        if (handler != null) handler(e.value.cast(Int))
      }
      EV_KEY_HOLD: {
        var handler = this.keyHoldHandler
        if (handler != null) handler(e.value.cast(Int))
      }
      EV_KEY_RELEASE: {
        var handler = this.keyReleaseHandler
        if (handler != null) handler(e.value.cast(Int))
      }
      EV_PTR_PRESS: {
        var handler = this.ptrPressHandler
        var point = e.value.cast(Point)
        if (handler != null) handler(point.x, point.y)
      }
      EV_PTR_DRAG: {
        var handler = this.ptrDragHandler
        var point = e.value.cast(Point)
        if (handler != null) handler(point.x, point.y)
      }
      EV_PTR_RELEASE: {
        var handler = this.ptrReleaseHandler
        var point = e.value.cast(Point)
        if (handler != null) handler(point.x, point.y)
      }
    }
  } while (!this.quit)
  ui_set_screen(back)
}

def EventLoop.onShow(handler: ()) {
  this.showHandler = handler
}

def EventLoop.onHide(handler: ()) {
  this.hideHandler = handler
}

def EventLoop.onMenu(menu: Menu, handler: ()) {
  if (handler != null) {
    this.scr.add_menu(menu)
    this.menuHandlers[menu] = handler
  } else {
    this.scr.remove_menu(menu)
    this.menuHandlers.remove(menu)
  }
}

def EventLoop.onItem(item: Item, handler: ()) {
  if (handler != null) this.itemHandlers[item] = handler
  else this.itemHandlers.remove(item)
}

def EventLoop.onStateChange(item: Item, handler: ()) {
  if (handler != null) this.itemStateHandlers[item] = handler
  else this.itemStateHandlers.remove(item)
}

def EventLoop.onKeyPress(handler: (Int)) {
  this.keyPressHandler = handler
}

def EventLoop.onKeyRelease(handler: (Int)) {
  this.keyReleaseHandler = handler
}

def EventLoop.onKeyHold(handler: (Int)) {
  this.keyHoldHandler = handler
}

def EventLoop.onPtrPress(handler: (Int,Int)) {
  this.ptrPressHandler = handler
}

def EventLoop.onPtrDrag(handler: (Int,Int)) {
  this.ptrDragHandler = handler
}

def EventLoop.onPtrRelease(handler: (Int,Int)) {
  this.ptrReleaseHandler = handler
}
