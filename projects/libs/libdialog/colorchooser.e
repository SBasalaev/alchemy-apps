use "form.eh"
use "ui.eh"
use "image.eh"
use "graphics.eh"
use "strbuf.eh"
use "string.eh"
use "sys.eh"

def color2html(color: Int): String =
 "#" +
 "0123456789ABCDEF"[(color >> 20) & 0xf] +
 "0123456789ABCDEF"[(color >> 16) & 0xf] +
 "0123456789ABCDEF"[(color >> 12) & 0xf] +
 "0123456789ABCDEF"[(color >> 8) & 0xf] +
 "0123456789ABCDEF"[(color >> 4) & 0xf] +
 "0123456789ABCDEF"[color & 0xf]

def run_colorchooser(title: String, color: Int = 0): Int {
  var red = (color >> 16) & 0xff
  var green = (color >> 8) & 0xff
  var blue = color & 0xff
  // setting image
  var image = new Image(20, 20)
  var gr = image.graphics()
  gr.color = color
  gr.fill_rect(0, 0, 20, 20)
  // setting form
  var form = new Form()
  form.title = title
  var im = new ImageItem(null, image)
  form.add(im)
  var tx = new EditItem("HTML", color2html(color))
  form.add(tx)
  var rg = new GaugeItem("Red", 255, red)
  form.add(rg)
  var gg = new GaugeItem("Green", 255, green)
  form.add(gg)
  var bg = new GaugeItem("Blue", 255, blue)
  form.add(bg)
  var mok = new Menu("Ok", 1, MT_OK)
  var mcancel = new Menu("Cancel", 2, MT_CANCEL)
  form.add_menu(mok)
  form.add_menu(mcancel)
  // running form
  var back = ui_get_screen()
  ui_set_screen(form)
  var e: UIEvent
  do {
    e = ui_wait_event()
    if (e.kind == EV_ITEMSTATE) {
      if (e.value == tx) {
        try {
          color = tx.text[1:].tointbase(16)
          red = (color >> 16) & 0xff
          green = (color >> 8) & 0xff
          blue = color & 0xff
        } catch { }
      } else {
        red = rg.value
        green = gg.value
        blue = bg.value
      }
      if (e.value != tx) {
        tx.text = color2html((red << 16) | (green << 8) | blue)
      }
      rg.value = red
      gg.value = green
      bg.value = blue
      gr.color = (red << 16) | (green << 8) | blue
      gr.fill_rect(0, 0, 20, 20)
      im.image = image
    }
  } while (e.kind != EV_MENU || e.source != form)
  ui_set_screen(back)
  // returning value
  if (e.value == mok) {
    (rg.value << 16) | (gg.value << 8) | bg.value
  } else {
    -1
  }
}