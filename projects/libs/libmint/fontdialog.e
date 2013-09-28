use "font.eh"
use "form.eh"
use "dialog.eh"

const FACE_MASK = FACE_MONO | FACE_PROP
const SIZE_MASK = SIZE_SMALL | SIZE_LARGE
const PREVIEW_STRING = "ABCabc"

def showFontDialog(title: String, font: Int = 0): Int {
  // create form
  var form = new Form()
  form.title = title
  var okMenu = new Menu("Ok", 1, MT_OK)
  var cancelMenu = new Menu("Cancel", 2, MT_CANCEL)
  form.add_menu(okMenu)
  form.add_menu(cancelMenu)
  // init items
  var faceInput = new PopupItem("Face", ["System", "Monospace", "Proportional"])
  faceInput.index = switch (font & FACE_MASK) {
    FACE_MONO: 1
    FACE_PROP: 2
    else: 0
  }
  var sizeInput = new PopupItem("Size", ["Small", "Medium", "Large"])
  sizeInput.index = switch (font & SIZE_MASK) {
    SIZE_SMALL: 0
    SIZE_LARGE: 2
    else: 1
  }
  var boldInput = new CheckItem(null, "Bold", (font & STYLE_BOLD) != 0)
  var italicInput = new CheckItem(null, "Italic", (font & STYLE_ITALIC) != 0)
  var fontPreview = new TextItem("Preview", PREVIEW_STRING)
  fontPreview.font = font
  form.add(faceInput)
  form.add(sizeInput)
  form.add(boldInput)
  form.add(italicInput)
  form.add(fontPreview)
  // run dialog
  var back = ui_get_screen()
  ui_set_screen(form)
  var e: UIEvent
  do {
    e = ui_wait_event()
    if (e.kind == EV_ITEMSTATE) {
      if (e.value == faceInput) {
        font = (font & ~FACE_MASK) | switch (faceInput.index) {
          0: FACE_SYSTEM
          1: FACE_MONO
          else: FACE_PROP
        }
      } else if (e.value == sizeInput) {
        font = (font & ~SIZE_MASK) | switch (sizeInput.index) {
          0: SIZE_SMALL
          1: SIZE_MED
          else: SIZE_LARGE
        }
      } else if (e.value == boldInput) {
        if (boldInput.checked) {
          font |= STYLE_BOLD
        } else {
          font &= ~STYLE_BOLD
        }
      } else if (e.value == italicInput) {
        if (italicInput.checked) {
          font |= STYLE_ITALIC
        } else {
          font &= ~STYLE_ITALIC
        }
      }
      fontPreview.font = font
      fontPreview.text = PREVIEW_STRING
    }
  } while (e.kind != EV_MENU || e.source != form)
  ui_set_screen(back)
  if (e.value == okMenu) font else -1
}
