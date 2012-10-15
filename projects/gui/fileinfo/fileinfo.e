/* Shows properties of given file.
 * (c) 2012, Sergey Basalaev
 * Licensed under GPLv3
 */

use "io.eh"
use "ui.eh"
use "time.eh"
use "form.eh"
use "filetype.eh"

def fillform(form: Form, file: String) {
  var item:Item = new_textitem("File:", file)
  form.add(item)
  item = new_textitem("Type:", ftype_for_file(ftype_loaddb(), file).description)
  form.add(item)
  item = new_textitem("Size:", fsize(file).tostr())
  form.add(item)
  item = new_textitem("Modified:", datestr(fmodified(file)))
  form.add(item)
  item = new_checkitem("Access:", "Read", can_read(file))
  form.add(item)
  item = new_checkitem("", "Write", can_write(file))
  form.add(item)
  item = new_checkitem("", "Execute", can_exec(file))
  form.add(item)
}

def main(args: [String]) {
  if (args.len == 0) {
    println("Syntax: fileinfo file")
  } else {
    var form = new_form()
    form.set_title("File info")
    fillform(form, args[0])
    var mclose = new_menu("Close", 1)
    form.add_menu(mclose)
    ui_set_screen(form)
    var e = ui_wait_event()
    while (e.value != mclose) {
      e = ui_wait_event()
    }
  }
}
