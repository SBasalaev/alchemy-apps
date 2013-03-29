use "ui.eh"

def Screen.show_modal(): Menu;

def run_listbox(title: String, strings: [String], ok: String, cancel: String): Int;
def run_editbox(title: String, text: String, mode: Int): String;
def run_msgbox(title: String, msg: String);