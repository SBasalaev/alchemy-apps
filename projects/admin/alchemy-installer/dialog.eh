use "ui.eh"
use "ui_edit.eh"

def Screen.run(): Menu;

def showMessage(title: String, msg: String);
def showYesNo(title: String, msg: String): Bool;
def showOption(title: String, variants: [String], descriptions: [String]): Int;
//def showList(title: String, lines: [String], icons: [String] = null): Int;
//def showInput(title: String, msg: String = "", text: String = "", mode: Int = EDIT_ANY, maxsize: Int = 50): String;
//def showFontDialog(title: String, font: Int = 0): Int;
//def showColorDialog(title: String, color: Int = 0): Int;
//def showFolderDialog(title: String, dir: String = null): String;
//def showOpenFileDialog(title: String, dir: String = null, filters: [String] = null): String;
//def showSaveFileDialog(title: String, dir: String = null, filters: [String] = null): String;
