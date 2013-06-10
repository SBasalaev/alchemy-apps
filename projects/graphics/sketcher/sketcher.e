/*
 * SKETCHER
 * Kyle Alexander Buan
 * May 1 2013
 */

use "dialog.eh"
use "user_interface.eh"
use "dcm.eh"
use "easy_menu_event.eh"
use "image.eh"
use "form.eh"

const VERSION = "1.0.17"
const BUILD_DATE = "June 02, 2013"

def main(args: [String]) {
  ui_set_app_title("Sketcher")
  ui_set_app_icon(image_from_file("/res/icons/sketcher.png"))
  var frmTitle = new Form()
  frmTitle.add(new ImageItem("Sketcher "+VERSION, image_from_file("/res/sketcher/sketcher_logo.png")))
  frmTitle.add(new TextItem("", "DCM vector graphics editor"))
  frmTitle.add(new TextItem("Format specification", DCM_VERSION))
  frmTitle.add(new TextItem("Build date", BUILD_DATE))
  frmTitle.add(new TextItem("Builder/Programmer", "Kyle Alexander Buan (TarShoduze)"))
  frmTitle.add(new TextItem("Build platform", "Nokia N95 8GB/Alchemy OS 2.1.1"))
  frmTitle.add_menu(new Menu("New image", 0))
  frmTitle.add_menu(new Menu("Edit existing", 1))
  frmTitle.add_menu(new Menu("Exit", 2, MT_CANCEL))
  var response = ""
  var continue = true
  var file_path = ""
  do {
    ui_set_screen(frmTitle)
    response = wait_menu()
    if (response == "New image") {
      var created_image: DCMImage = null
      created_image = show_new_image()
      if (created_image != null) show_edit_layers(created_image) }
    else if (response == "Edit existing") {
      file_path = run_filechooser("Choose image", "/home", ["*.dcm", "*.DCM"/*, "*.jpg" , "*.JPG", "*.jpeg", "*.JPEG", "*.png", "*.PNG", "*.bmp", "*.BMP" */])
      if (file_path != null) {
        var opened_image = open_dcm_file(file_path)
        show_edit_layers(opened_image) } }
    else if (response == "Exit") {
      continue = false } }
  while (continue) }