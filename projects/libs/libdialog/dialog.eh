use "ui.eh"
use "ui_edit.eh"

def Screen.show_modal(): Menu;

def run_alert(title: String, msg: String, img: Image = null, timeout: Int = 1500);
def run_yesno(title: String, msg: String, y: String = "Yes", n: String = "No", img: Image = null): Bool;
def run_msgbox(title: String, msg: String, variants: [String], img: Image = null): Int;
def run_listbox(title: String, lines: [String], images: [Image] = null): Int;
def run_editbox(title: String, text: String = "", mode: Int = EDIT_ANY, maxsize: Int = 50): String;
def run_colorchooser(title: String, color: Int = 0): Int;
def run_dirchooser(title: String, current: String): String;
def run_filechooser(title: String, current: String, filters: [String] = null): String;
