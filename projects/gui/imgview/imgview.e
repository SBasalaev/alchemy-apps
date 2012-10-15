/* Simple image viewer.
 * (c) 2012, Sergey Basalaev
 * Licensed under GPLv3
 */

use "form.eh"
use "image.eh"
use "io.eh"
use "ui.eh"

const HELP = "Usage:\nimgview file"
const VERSION = "imgview\nSimple image viewer\nVersion 0.1.1"

def main(args: [String]) {
  if (args.len != 1 || args[0] == "-h") {
    println(HELP)
  } else if (args[0] == "-v") {
    println(VERSION)
  } else {
    var view = new_form()
    view.set_title("Image view")
    var mclose = new_menu("Close", 1)
    view.add_menu(mclose)
    var img = image_from_file(args[0])
    view.add(new_imageitem("", img))
    view.add(new_textitem("", pathfile(args[0])))
    ui_set_screen(view)
    var e = ui_wait_event()
    while (e.value != mclose) {
      e = ui_wait_event()
    }
  }
}
