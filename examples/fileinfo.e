/* Example of using form.
 * Shows properties of given file.
 * To compile: ex fileinfo.e -o fileinfo -lui
 * To run: ./fileinfo
 */

use "io"
use "ui"
use "form"

def fillform(form: Form, file: String) {
  form.add(new_textitem("File:", file))
  form.add(new_textitem("Type:",
    if (is_dir(file)) "Directory" else "Normal file"))
  form.add(new_textitem("Size:", fsize(file).tostr()))
  var dtitem = new_dateitem("Modified:", DATE_TIME)
  dtitem.set_date(fmodified(file))
  form.add(dtitem) 
  form.add(new_checkitem("Access:","Read", can_read(file)))
  form.add(new_checkitem("", "Write", can_write(file))) 
  form.add(new_checkitem("", "Execute", can_exec(file)))
}

def main(args: [String]) {
  if (args.len == 0) {
    println("Syntax: fileinfo file")
  } else {
    // create new form
    var form = new_form()
    // fill it with information
    form.set_title("File info")
    fillform(form, args[0])
    // add "Close" menu
    var mclose = new_menu("Close", 1)
    form.add_menu(mclose)
    // show on the screen
    ui_set_screen(form)
    // read events until "Close" menu is selected
    var e = ui_wait_event()
    while (e.value != mclose) {
      e = ui_wait_event()
    }
  }
}
