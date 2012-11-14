/* Example of drawing on canvas.
 * To compile: ex drawing.e -o drawing -lui
 * To run: ./drawing
 */

use "ui"
use "canvas"
use "graphics"
use "sys"

def main(args: [String]) {
  /* Creating canvas screen */
  var cnv = new_canvas(false)
  cnv.set_title("Drawing example")
  ui_set_screen(cnv)
  /* Drawing */
  var g = cnv.graphics()
  g.set_color(0xffff00) // yellow
  g.fill_arc(20, 20, 50, 50, 0, 360)
  g.set_color(0) // black
  g.draw_arc(20, 20, 50, 50, 0, 360)
  g.draw_arc(30, 30, 30, 30, 225, 90)
  g.fill_rect(33, 34, 4, 4)
  g.fill_rect(53, 34, 4, 4)
  g.draw_string("Press any key", 15, 70)
  cnv.refresh()
  /* Waiting for key press */
  while (cnv.read_key() == 0) {
    sleep(50)
  }
}
