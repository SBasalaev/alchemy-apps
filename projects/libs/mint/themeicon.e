use "config.eh"
use "io.eh"
use "list.eh"
use "string.eh"
use "themeicon.eh"

const THEME_ROOT = "/res/icons/"

type IconTheme {
  sizes: [Int],
  bases: [String],
  cache: Dict
}

var theme: IconTheme;

def loadIconTheme(): IconTheme {
  var cfg = getConfig()
  var themefiles = try {
    flistfilter(THEME_ROOT + "themes/", "*.theme")
  } catch {
    []
  }
  var sizes = new List()
  var bases = new List()
  for (var i=0, i<themefiles.len, i+=1) {
    var themedata = readCfgFile(THEME_ROOT + "themes/" + themefiles[i])
    if (themedata["Name"] == cfg.iconTheme) {
      var size = try {
        themedata["Size"].cast(String).toint()
      } catch { 0 }
      if (size > 0) {
        sizes.add(size)
        var base = themedata["Base-Folder"]
        if (base == null) base = ""
        bases.add(base)
      }
    }
  }
  var len = sizes.len()
  var th = new IconTheme {
    sizes = new [Int](len),
    bases = new [String](len),
    cache = new Dict()
  }
  sizes.copyinto(0, th.sizes, 0, len)
  bases.copyinto(0, th.bases, 0, len)
  theme = th
  th
}

def Int.abs(): Int = if (this < 0) -this else this

def themeIcon(name: String, size: Int = 0): Image {
  if (name == null || name == "") {
    null
  } else {
    var cfg = getConfig()
    if (size == 0) size = cfg.listIconSize
    else if (size < 0) size = cfg.dialogIconSize
    var th = theme
    if (th == null) th = loadIconTheme()
    var len = th.sizes.len
    var img: Image = null
    var idx = 0
    if (len > 0) {
      // determine best size
      var diff = (size - th.sizes[0]).abs()
      while (diff > 0 && idx < len-1) {
        var diff2 = (size - th.sizes[idx+1]).abs()
        if (diff2 < diff) { diff = diff2; idx += 1 }
        else diff = 0
      }
      // load image from theme
      var cachename = name + th.sizes[idx]
      img = th.cache[cachename].cast(Image)
      if (img == null) try {
        img = image_from_file(THEME_ROOT + th.bases[idx] + '/' + name + ".png")
        th.cache[cachename] = img
      } catch { }
    }
    // if image is not in theme, try to load from general location
    if (img == null) try {
      img = image_from_file(THEME_ROOT + size + '/' + name + ".png")
    } catch { }
    if (img == null) try {
      img = image_from_file(THEME_ROOT + name + ".png")
    } catch { }
    // finally try to load 'file-missing' icon
    if (img == null && len > 0) try {
      img = image_from_file(THEME_ROOT + th.bases[idx] + '/' + IMAGE_MISSING + ".png")
    } catch { }
    img
  }
}
