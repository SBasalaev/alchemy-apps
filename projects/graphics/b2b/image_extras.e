// extra image routines for method simplification

use "image"

use "color_math.eh"

// image pixel access
def Image.get_pix_color_real(x: Int, y: Int): Color {
  var c: [Int] = [0]
  this.get_argb(c, 0, 1, x, y, 1, 1)
  new Color { r=(c[0] & 0x00FF0000)>>16, g=(c[0] & 0x0000FF00)>>8, b=c[0] & 0x000000FF } }

def Image.get_pix_color(x: Int, y: Int): Color {
  var c: [Int] = [0]
  if (x>=0 && x<img_x && y>=0 && y<img_y) this.get_argb(c, 0, 1, x, y, 1, 1)
  new Color { r=(c[0] & 0x00FF0000)>>16, g=(c[0] & 0x0000FF00)>>8, b=c[0] & 0x000000FF } }