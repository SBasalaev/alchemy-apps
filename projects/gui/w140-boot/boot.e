use "ui"
use "canvas"
use "graphics"
use "sys"

def bootNoImg() {

var a=0
  var cnv = new_canvas(true)
  ui_set_screen(cnv)
var w= cnv.get_width()
  var g = cnv.graphics()
sleep(100)
while (a < w) {
g.set_color(0x0)
g.draw_rect(5+a, 130, 10, 60)
cnv.refresh()
a=a+20
sleep(200)
}
}
