use "mbasic.eh"
use "ui.eh"
use "canvas.eh"
use "graphics.eh"
use "font.eh"

var cnv: Canvas;
var g: Graphics;

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

def mbui_cls() {
  var color = g.color
  g.color = 0xffffff
  g.draw_rect(0, 0, cnv.width, cnv.height)
  g.color = color
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

def mbui_drawroundrect(x: Int, y: Int, w: Int, h: Int, sta: Int, a: Int) {
  g.draw_roundrect(x, y, w, h, sta, a)
  cnv.refresh()
}

def mbui_fillroundrect(x: Int, y: Int, w: Int, h: Int, sta: Int, a: Int) {
  g.fill_roundrect(x, y, w, h, sta, a)
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
  cnv = new_canvas(false)
  g = cnv.graphics()
  cnv.title = "mbasic window"
  // canvas drawing commands
  vm.addcommand("CLS", "", mbui_cls)
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
  // info functions
  vm.addfunction("SCREENHEIGHT", "i", 'i', cnv.get_height)
  vm.addfunction("SCREENWIDTH", "i", 'i', cnv.get_width)
  vm.addfunction("STRINGHEIGHT", "s", 'i', def (): Int = font_height(FACE_SYSTEM))
  vm.addfunction("STRINGWIDTH", "s", 'i', def(s:String): Int = str_width(FACE_SYSTEM, s))
  
  ui_set_screen(cnv)
}