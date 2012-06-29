/* Simple image viewer.
 * (c) 2012, Sergey Basalaev
 * Licensed under GPLv3
 */

use "form.eh"
use "image.eh"
use "io.eh"
use "ui.eh"

const HELP = "Usage:\nimgview file"
const VERSION = "imgview\nSimple image viewer\nVersion 0.1"

def main(args: Array) {
  if (args.len != 1 || args[0] == "-h") {
    println(HELP)
  } else if (args[0] == "-v") {
    println(VERSION)
  } else {
    var view = new_form()
    screen_set_title(view, "Image view")
    var mclose = new_menu("Close", 1)
    screen_add_menu(view, mclose)
    var file = to_str(args[0])
    var in = fopen_r(file)
    var img = image_from_stream(in)
    fclose(in)
    form_add(view, new_imageitem("", img))
    form_add(view, new_textitem("", pathfile(file)))
    ui_set_screen(view)
    var e = ui_wait_event()
    while (e.value != mclose) {
      e = ui_wait_event()
    }
  }
}
