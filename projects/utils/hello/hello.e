use "io"
use "i18n"

def main(args: [String]) {
  // set base name for translations
  settextdomain("hello")
  // print translated string
  println(_("Hello, world!"))
}
