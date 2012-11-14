/* Example of application using canvas.
 * To compile: ex canvasinput.e -o canvasinput -lui
 * To run: ./canvasinput
 */

use "ui"
use "canvas"
use "graphics"
use "strbuf"
use "string"
use "sys"

/* Returns descriptive string for the pressed key. */
def keystr(key: Int): String {
  var sb = new_strbuf()
  sb.append("Key code: ")
  sb.append(key)
  if (key >= ' ') {
    sb.append(", Char: '")
    sb.addch(key)
    sb.addch('\'')
  }
  sb.tostr()
}

def main(args: [String]) {
  /* Create canvas screen */
  var cnv = new_canvas(false)
  cnv.set_title("Key input example")
  ui_set_screen(cnv)
  /* Draw initial text */
  var g = cnv.graphics()
  g.set_color(0)
  g.draw_string("No key pressed", 5, 5)
  g.draw_string("To quit press #", 5, 30)
  cnv.refresh()
  /* Read keys in a loop */
  var key = canvas.read_key()
  while (key != '#') {
    var newkey = cnv.read_key()
    if (newkey != 0 && newkey != key) {
      /* Clear screen */
      g.set_color(0xffffff)
      g.fill_rect(0, 0, cnv.width, cnv.height)
      /* Draw new text */
      g.set_color(0)
      g.draw_string(keystr(newkey), 5, 5)
      g.draw_string("To quit press #", 5, 30)
      cnv.refresh()
      key = newkey
    }
    sleep(100)
  }
}
