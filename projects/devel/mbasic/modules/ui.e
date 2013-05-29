use "mbasic.eh"
use "ui.eh"
use "canvas.eh"
use "graphics.eh"
use "font.eh"

const BT_UP    = 1
const BT_DOWN  = 2
const BT_LEFT  = 4
const BT_RIGHT = 8
const BT_FIRE  = 16
const BT_GAMEA = 32
const BT_GAMEB = 64
const BT_GAMEC = 128
const BT_GAMED = 256

var cnv: Canvas;
var g: Graphics;
var buttons: Int;

def readbuttons(): Int {
  var e: UIEvent
  while ({e = ui_read_event(); e != null}) {
    if (e.kind == EV_KEY) {
      switch (cnv.action_code(e.value.cast(Int))) {
        UP: buttons |= BT_UP
        DOWN: buttons |= BT_DOWN
        LEFT: buttons |= BT_LEFT
        RIGHT: buttons |= BT_RIGHT
        FIRE: buttons |= BT_FIRE
        ACT_A: buttons |= BT_GAMEA
        ACT_B: buttons |= BT_GAMEB
        ACT_C: buttons |= BT_GAMEC
        ACT_D: buttons |= BT_GAMED
      }
    } else if (e.kind == EV_KEY_RELEASE) {
      switch (cnv.action_code(e.value.cast(Int))) {
        UP: buttons &= ~BT_UP
        DOWN: buttons &= ~BT_DOWN
        LEFT: buttons &= ~BT_LEFT
        RIGHT: buttons &= ~BT_RIGHT
        FIRE: buttons &= ~BT_FIRE
        ACT_A: buttons &= ~BT_GAMEA
        ACT_B: buttons &= ~BT_GAMEB
        ACT_C: buttons &= ~BT_GAMEC
        ACT_D: buttons &= ~BT_GAMED
      }
    }
  }
  buttons
}

/*
def showdialog(scr: Screen): Bool {
  var ok = new_menu("Ok", 1)
  var cancel = new_menu("Cancel", 2)
  scr.add_menu(ok)
  scr.add_menu(cancel)
  ui_set_screen(scr)
  var e: UIEvent;
  do {
    e = ui_wait_event()
  } while (e.kind != EV_MENU);
  ui_set_screen(cnv)
  e.value == ok
}
*/

def mbui_cls() {
  var color = g.color
  g.color = 0xffffff
  g.draw_rect(0, 0, cnv.width, cnv.height)
  g.color = color
  cnv.refresh()
}

def mbui_plot(x: Int, y: Int) {
  g.fill_rect(x, y, 1, 1)
  cnv.refresh()
}

def mbui_drawline(x1: Int, y1: Int, x2: Int, y2: Int) {
  g.draw_line(x1, y1, x2, y2)
  cnv.refresh()
}

def mbui_drawrect(x: Int, y: Int, w: Int, h: Int) {
  g.draw_rect(x, y, w, h)
  cnv.refresh()
}

def mbui_fillrect(x: Int, y: Int, w: Int, h: Int) {
  g.fill_rect(x, y, w, h)
  cnv.refresh()
}

def mbui_drawroundrect(x: Int, y: Int, w: Int, h: Int, arcw: Int, arch: Int) {
  g.draw_roundrect(x, y, w, h, arcw, arch)
  cnv.refresh()
}

def mbui_fillroundrect(x: Int, y: Int, w: Int, h: Int, arcw: Int, arch: Int) {
  g.fill_roundrect(x, y, w, h, arcw, arch)
  cnv.refresh()
}

def mbui_drawarc(x: Int, y: Int, w: Int, h: Int, sta: Int, a: Int) {
  g.draw_arc(x, y, w, h, sta, a)
  cnv.refresh()
}

def mbui_fillarc(x: Int, y: Int, w: Int, h: Int, sta: Int, a: Int) {
  g.fill_arc(x, y, w, h, sta, a)
  cnv.refresh()
}

def mbui_drawstring(str: String, x: Int, y: Int) {
  g.draw_string(str, x, y)
  cnv.refresh()
}

def mbui_blit(x: Int, y: Int, w: Int, h: Int, tox: Int, toy: Int) {
  g.copy_area(x, y, w, h, tox, toy)
  cnv.refresh()
}

def mbui_setcolor(red: Int, green: Int, blue: Int) {
  g.color = ((red & 0xff) << 24) | ((green & 0xff) << 16) | (blue & 0xff)
}

def Init_ui(vm: BasicVM) {
  cnv = new Canvas(false)
  g = cnv.graphics()
  cnv.title = "mbasic window"
  // canvas drawing commands
  vm.addcommand("CLS", "", mbui_cls)
  vm.addcommand("PLOT", "ii", mbui_plot)
  vm.addcommand("DRAWLINE", "iiii", mbui_drawline)
  vm.addcommand("DRAWRECT", "iiii", mbui_drawrect)
  vm.addcommand("FILLRECT", "iiii", mbui_fillrect)
  vm.addcommand("DRAWROUNDRECT", "iiiiii", mbui_drawroundrect)
  vm.addcommand("FILLROUNDRECT", "iiiiii", mbui_fillroundrect)
  vm.addcommand("DRAWARC", "iiiiii", mbui_drawarc)
  vm.addcommand("FILLARC", "iiiiii", mbui_fillarc)
  vm.addcommand("DRAWSTRING", "sii", mbui_drawstring)
  vm.addcommand("BLIT", "iiiiii", mbui_blit)
  vm.addcommand("SETCOLOR", "iii", mbui_setcolor)
  // button functions
  vm.addfunction("UP", "i", 'i', def(i:Int): Int = readbuttons() & BT_UP)
  vm.addfunction("DOWN", "i", 'i', def(i:Int): Int = readbuttons() & BT_DOWN)
  vm.addfunction("LEFT", "i", 'i', def(i:Int): Int = readbuttons() & BT_LEFT)
  vm.addfunction("RIGHT", "i", 'i', def(i:Int): Int = readbuttons() & BT_RIGHT)
  vm.addfunction("FIRE", "i", 'i', def(i:Int): Int = readbuttons() & BT_FIRE)
  vm.addfunction("GAMEA", "i", 'i', def(i:Int): Int = readbuttons() & BT_GAMEA)
  vm.addfunction("GAMEB", "i", 'i', def(i:Int): Int = readbuttons() & BT_GAMEB)
  vm.addfunction("GAMEC", "i", 'i', def(i:Int): Int = readbuttons() & BT_GAMEC)
  vm.addfunction("GAMED", "i", 'i', def(i:Int): Int = readbuttons() & BT_GAMED)
  // info functions
  vm.addfunction("SCREENHEIGHT", "i", 'i', cnv.get_height)
  vm.addfunction("SCREENWIDTH", "i", 'i', cnv.get_width)
  vm.addfunction("STRINGHEIGHT", "s", 'i', def(s:String): Int = font_height(FACE_SYSTEM))
  vm.addfunction("STRINGWIDTH", "s", 'i', def(s:String): Int = str_width(FACE_SYSTEM, s))
  
  ui_set_screen(cnv)
}