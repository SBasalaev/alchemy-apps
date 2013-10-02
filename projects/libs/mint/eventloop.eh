use "ui.eh"

type EventLoop;
type Item;

def EventLoop.new(scr: Screen);

def EventLoop.start();
def EventLoop.quit();

def EventLoop.onShow(handler: ());
def EventLoop.onHide(handler: ());
def EventLoop.onMenu(menu: Menu, handler: ());
def EventLoop.onItem(item: Item, handler: ());
def EventLoop.onStateChange(item: Item, handler: ());
def EventLoop.onKeyPress(handler: (Int));
def EventLoop.onKeyRelease(handler: (Int));
def EventLoop.onKeyHold(handler: (Int));
def EventLoop.onPtrPress(handler: (Int,Int));
def EventLoop.onPtrDrag(handler: (Int,Int));
def EventLoop.onPtrRelease(handler: (Int,Int));