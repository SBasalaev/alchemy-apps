use "dialog.eh"
use "config.eh"
use "form.eh"
use "string.eh"
use "image.eh"
use "graphics.eh"

def color2html(color: Int): String =
 "#" +
 "0123456789ABCDEF"[(color >> 20) & 0xf] +
 "0123456789ABCDEF"[(color >> 16) & 0xf] +
 "0123456789ABCDEF"[(color >> 12) & 0xf] +
 "0123456789ABCDEF"[(color >> 8) & 0xf] +
 "0123456789ABCDEF"[(color >> 4) & 0xf] +
 "0123456789ABCDEF"[color & 0xf]

def showColorDialog(title: String, color: Int = 0): Int {
  // create form
  var form = new Form()
  form.title = title
  var okMenu = new Menu("Ok", 1, MT_OK)
  var cancelMenu = new Menu("Cancel", 2, MT_CANCEL)
  form.add_menu(okMenu)
  form.add_menu(cancelMenu)
  // init supplementary vars
  var red  = (color >> 16) & 0xff
  var green = (color >> 8) & 0xff
  var blue = color & 0xff
  var imgSize = getConfig().dialogIconSize
  var img = new Image(imgSize, imgSize)
  var g = img.graphics()
  g.color = color
  g.fill_rect(0, 0, imgSize, imgSize)
  // init items
  var colorPreview = new ImageItem("Preview", img)
  var redInput = new EditItem("Red", red.tostr(), EDIT_NUMBER)
  var greenInput = new EditItem("Green", green.tostr(), EDIT_NUMBER)
  var blueInput = new EditItem("Blue", blue.tostr(), EDIT_NUMBER)
  var htmlInput = new EditItem("HTML", color2html(color), EDIT_ANY)
  form.add(colorPreview)
  form.add(redInput)
  form.add(greenInput)
  form.add(blueInput)
  form.add(htmlInput)
  // run dialog
  var back = ui_get_screen()
  ui_set_screen(form)
  var e: UIEvent
  do {
    e = ui_wait_event()
    if (e.kind == EV_ITEMSTATE) {
      if (e.value == redInput) {
        red = try redInput.text.toint() catch -1
        if (red == null || red < 0 || red > 255) {
          red = 0
          redInput.text = "0"
        }
        htmlInput.text = color2html((red << 16) | (green << 8) | blue)
      } else if (e.value == greenInput) {
        green = try greenInput.text.toint() catch -1
        if (green == null || green < 0 || green > 255) {
          green = 0
          greenInput.text = "0"
        }
        htmlInput.text = color2html((red << 16) | (green << 8) | blue)
      } else if (e.value == blueInput) {
        blue = try blueInput.text.toint() catch -1
        if (blue == null || blue < 0 || blue > 255) {
          blue = 0
          blueInput.text = "0"
        }
        htmlInput.text = color2html((red << 16) | (green << 8) | blue)
      } else if (e.value == htmlInput) {
        try {
          color = htmlInput.text[1:].tointbase(16)
          red = (color >> 16) & 0xff
          green = (color >> 8) & 0xff
          blue = color & 0xff
          redInput.text = red.tostr()
          greenInput.text = green.tostr()
          blueInput.text = blue.tostr()
        } catch { }
      }
      g.color = (red << 16) | (green << 8) | blue
      g.fill_rect(0, 0, imgSize, imgSize)
      colorPreview.image = img
    }
  } while (e.kind != EV_MENU || e.source != form)
  ui_set_screen(back)
  if (e.value == okMenu) {
    (red << 16) | (green << 8) | blue
  } else {
    -1
  }
}
