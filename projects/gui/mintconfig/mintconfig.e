use "mint/config"
use "mint/dialog"
use "io"
use "form"
use "ui"
use "dict"
use "list"
use "string"
use "strbuf"
use "graphics"
use "image"

type IconTheme {
  sizes: List,
  bases: List,
  author: String
}

def readIconThemes(): Dict {
  var themefiles = try {
    flistfilter("/res/icons/themes/", "*.theme")
  } catch {
    []
  }
  var themes = new Dict()
  for (var i=0, i<themefiles.len, i+=1) {
    var themedata = readCfgFile("/res/icons/themes/" + themefiles[i])
    var name = themedata["Name"]
    if (name != null) {
      var theme = themes[name].cast(IconTheme)
      if (theme == null) {
        theme = new IconTheme {
          sizes = new List(),
          bases = new List()
        }
        themes[name] = theme
      }
      var size = try {
        themedata["Size"].cast(String).toint()
      } catch { 0 }
      if (size > 0 && theme.sizes.indexof(size) < 0) {
        theme.sizes.add(size)
        var base = themedata["Base-Folder"]
        if (base == null) base = ""
        theme.bases.add(base)
      }
      if (theme.author == null) {
        theme.author = themedata["Author"].cast(String)
      }
    }
  }
  themes
}

def drawPreview(theme: IconTheme): Image {
  var size = theme.sizes[0].cast(Int)
  var base = theme.bases[0].cast(String)
  var img = new Image(size*4, size)
  var g = img.graphics()
  var icon = try {
    image_from_file("/res/icons/" + base + "/file-executable.png")
  } catch try {
    image_from_file("/res/icons/" + base + "/image-missing.png")
  } catch {
    null
  }
  if (icon != null) g.draw_image(icon, 0, 0)
  icon = try {
    image_from_file("/res/icons/" + base + "/folder.png")
  } catch try {
    image_from_file("/res/icons/" + base + "/image-missing.png")
  } catch {
    null
  }
  if (icon != null) g.draw_image(icon, size *3 / 2, 0)
  icon = try {
    image_from_file("/res/icons/" + base + "/file-text.png")
  } catch try {
    image_from_file("/res/icons/" + base + "/image-missing.png")
  } catch {
    null
  }
  if (icon != null) g.draw_image(icon, size * 3, 0)
  img
}

def fontString(font: Int): String {
  {
    if ((font & SIZE_SMALL) != 0) "Small"
    else if ((font & SIZE_LARGE) != 0) "Large"
    else "Medium"
  } + {
    if ((font & FACE_MONO) != 0) " Monospace"
    else if ((font & FACE_PROP) != 0) " Proportional"
    else " System"
  } + {
    if ((font & STYLE_BOLD) != 0) " Bold" else ""
  } + {
    if ((font & STYLE_ITALIC) != 0) " Italic" else ""
  }
}

def IconTheme.infoString(): String {
  var sb = new StrBuf()
  if (this.author != null) {
    sb.append("Author: ").append(this.author).append('\n')
  }
  sb.append("Installed sizes:")
  for (var i=0, i < this.sizes.len(), i+=1) {
    sb.append(' ').append(this.sizes[i])
  }
  sb.tostr()
}

def main(args: [String]) {
  // reading theme files
  var themes = readIconThemes()
  var themenames = new [String](themes.size()+1)
  themenames[0] = "<none>"
  var namelist = new List()
  namelist.addall(themes.keys())
  namelist.sortself(`String.cmp`)
  namelist.copyinto(0, themenames, 1, themenames.len-1)
  // reading config
  var cfg = getConfig()
  var idx = namelist.indexof(cfg.iconTheme)
  // preparing components
  var themeChooser = new PopupItem("Theme", themenames)
  if (idx >= 0) {
    themeChooser.index = idx+1
  }
  var themeInfo = new TextItem("", "")
  if (idx >= 0) {
    themeInfo.text = themes[namelist[idx]].cast(IconTheme).infoString()
  }
  var previewImage: Image = null
  if (idx >= 0) {
    previewImage = drawPreview(themes[namelist[idx]].cast(IconTheme))
  }
  var themePreview = new ImageItem("Preview", previewImage)
  var lIconSize = new EditItem("List icon size", cfg.listIconSize.tostr(), EDIT_NUMBER)
  var dIconSize = new EditItem("Dialog icon size", cfg.dialogIconSize.tostr(), EDIT_NUMBER)
  var fontChooser = new HyperlinkItem("Dialog font", null)
  fontChooser.font = cfg.dialogFont
  fontChooser.text = fontString(cfg.dialogFont)
  // preparing form
  var form = new Form()
  form.add_menu(new Menu("Close", 1, MT_EXIT))
  form.title = "Appearance"
  form.add(themeChooser)
  form.add(themeInfo)
  form.add(themePreview)
  form.add(lIconSize)
  form.add(dIconSize)
  form.add(fontChooser)
  // running form
  ui_set_screen(form)
  var e: UIEvent
  var changed = false
  do {
    e = ui_wait_event()
    if (e.value == fontChooser) {
      var font = showFontDialog("Dialog font", cfg.dialogFont)
      if (font >= 0) {
        fontChooser.font = font
        fontChooser.text = fontString(font)
        cfg.dialogFont = font
        changed = true
      }
    } else if (e.value == themeChooser) {
      idx = themeChooser.index-1
      if (idx >= 0) {
        themePreview.image = drawPreview(themes[namelist[idx]].cast(IconTheme))
        themeInfo.text = themes[namelist[idx]].cast(IconTheme).infoString()
        cfg.iconTheme = namelist[idx].cast(String)
      } else {
        themePreview.image = null
        themeInfo.text = ""
        cfg.iconTheme = ""
      }
      changed = true
    } else if (e.value == lIconSize) {
      var str = lIconSize.text
      if (str.len() > 0) {
        var size = str.toint()
        if (size > 0) cfg.listIconSize = size
        changed = true
      }
    } else if (e.value == dIconSize) {
      var str = dIconSize.text
      if (str.len() > 0) {
        var size = str.toint()
        if (size > 0) cfg.dialogIconSize = size
        changed = true
      }
    }
  } while (e.kind != EV_MENU)
  if (changed) {
    var cfgfile = fopen_w("/cfg/mintprefs")
    cfgfile.println("Icon-Theme=" + cfg.iconTheme)
    cfgfile.println("List-Icon-Size=" + cfg.listIconSize)
    cfgfile.println("Dialog-Icon-Size=" + cfg.dialogIconSize)
    cfgfile.println("Dialog-Font=" + cfg.dialogFont)
    cfgfile.flush()
    cfgfile.close()
    showInfo("Appearance", "These settings will apply to newly opened applications.", 3000)
  }
}
