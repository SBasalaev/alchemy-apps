// extra image routines for method simplification

use "image"

use "color_math.eh"

// image pixel access
def Image.get_pix_color(x: Int, y: Int): Color {
  var c: [Int] = [0]
  this.get_argb(c, 0, 1, x, y, 1, 1)
  var rs= (c[0] & 0x00FF0000)>>16
  var gs= (c[0] & 0x0000FF00)>>8
  var bs= c[0] & 0x000000FF
  new Color { r=rs, g=gs, b=bs } }
	
// 