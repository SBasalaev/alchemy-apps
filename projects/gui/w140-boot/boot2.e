use "ui"
use "canvas"
use "graphics"
use "sys"
use "font"
use "image"
use "imgArr.e"
use "noi.e"
use "boot.e"
use "error"

def boot(){
try {
var anim=image_from_file ("/res/w140-boot/primary0.png")
var anim2=image_from_file ("/res/w140-boot/primary1.png")
var a=0
  var cnv = new_canvas(true)
  ui_set_screen(cnv)
sleep(1500)
var w = cnv.get_width()
var h = cnv.get_height()
var g=cnv.graphics()
while(a<w){
g.draw_image(anim, a-16-(w/8), h/2-16)
g.draw_image(anim2, a+(w/16), h/2-16)
cnv.refresh()
a=a+w/4
sleep(200)
}
g.draw_image(anim,w-(w/4)+(w/16),h/2-16)
cnv.refresh()
sleep(200)
}catch{bootNoImg()}
}

def bootImg (imag: [Image]) {
var a=0
  var cnv = new_canvas(true)
  ui_set_screen(cnv)
  var g = cnv.graphics()
var len =imag.len
while (a <len) {
g.draw_image(imag[a],0,0)
cnv.refresh()
a=1+a
sleep(250)
}
}

def main (args: [String]){
var ba = imgArr()
try {
bootImg(ba)}
catch {boot()}
}