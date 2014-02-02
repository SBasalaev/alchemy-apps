use "form.eh"
use "ui.eh"

type MessageScreen {
  scr: Form,
  message: TextItem
}

def MessageScreen.new(title: String) {
  this.scr = new Form()
  this.scr.title = title
  this.message = new TextItem("", "")
  this.scr.add(this.message)
}

def MessageScreen.show() {
  ui_set_screen(this.scr)
}

def MessageScreen.hide() {
  ui_set_screen(null)
}

def MessageScreen.setMessage(str: String) {
  this.message.text = str
}

type ProgressScreen < MessageScreen {
  progress: TextItem,
  package: TextItem
}

def ProgressScreen.new(title: String) {
  super(title)
  this.progress = new TextItem("", "")
  this.package = new TextItem("", "")
  this.scr.add(this.progress)
  this.scr.add(this.package)
}

def ProgressScreen.setProgress(current: Int, max: Int, package: String, version: String) {
  this.progress.text = "" + current + " of " + max
  this.package.text = "Installing " + package + ' ' + version
}
