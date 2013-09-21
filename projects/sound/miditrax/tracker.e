// MidiTrax
// August 18 2013 - Kyle Alexander Buan
// Made for Alchemy OS
// Licensed under GPL-3

/***
  * Main source
 **/
 
/* REMINDER ERRORS TO FIX:
    No syntax errors!
*/
 
 
use "ui.eh"
use "form.eh"
use "dialog.eh"
use "string.eh"

use "mod_editor.eh"
use "mod_file.eh"
use "easy_menu.eh"
use "module.eh"
use "image.eh"


const NAME         = "MidiTrax "
const CAPITAL_NAME = "MIDITRAX"
const VERSION      = "1.1 "
const DATE         = "August 21, 2013 "
const AUTHOR       = "Kyle Alexander Buan "
const CONTACT      = "tar.shoduze@gmail.com "

def ui_new_mod(mod: Module): Bool {
    var ui = new Form()
    ui.title = "New module"
    ui.add(new TextItem("", "Module metadata:"))
    var txtTitle = new EditItem("Title:", "New", EDIT_ANY, 64)
    ui.add(txtTitle)
    var txtAuthor = new EditItem("Author:", "", EDIT_ANY, 64)
    ui.add(txtAuthor)
    var txtComposer = new EditItem("Composer:", "", EDIT_ANY, 64)
    ui.add(txtComposer)
    var txtComment = new EditItem("Comment:", "", EDIT_ANY, 500)
    ui.add(txtComment)
    ui.add(new TextItem("", "Technical metadata:"))
    var txtChannels = new EditItem("Channels:", "8", EDIT_NUMBER, 64)
    ui.add(txtChannels)
    var txtTempo = new EditItem("Tempo:", "120", EDIT_NUMBER, 3)
    ui.add(txtTempo)
    var txtSteps = new EditItem("Steps per pattern", "64", EDIT_NUMBER, 3)
    ui.add(txtSteps)
    ui.add_menu(new Menu("Okay", 0))
    ui.add_menu(new Menu("Cancel", 1, MT_CANCEL))
    ui_set_screen(ui)
    var r = wait_menu()
    if (r == "Okay") {
        mod.title    = txtTitle.text
        mod.author   = txtAuthor.text
        mod.composer = txtComposer.text
        mod.comments = txtComment.text
        mod.channels = txtChannels.text.toint()
        mod.tempo = txtTempo.text.toint()
        mod.steps    = txtSteps.text.toint()
        true }
    else {
        false } }

def main(args: [String]) {
    ui_set_app_title(NAME + VERSION)
    ui_set_app_icon(image_from_file("/res/miditrax/icon.png"))
    var mod = new Module()
    var load_path: String
    if (args.len > 0) {
        mod.load(args[0])
        mod.edit(true) }
    else {
        var main_menu = new Form()
        main_menu.title = NAME
        main_menu.add(new ImageItem("", image_from_file("/res/miditrax/logo2.png")))
        main_menu.add(new ImageItem("", image_from_file("/res/miditrax/logo1.png")))
        main_menu.add(new TextItem(CAPITAL_NAME, VERSION + DATE))
        main_menu.add(new TextItem("", AUTHOR + "(" + CONTACT + ")"))
        main_menu.add_menu(new Menu("Load", 0))
        main_menu.add_menu(new Menu("New", 1))
        main_menu.add_menu(new Menu("Exit", 2, MT_CANCEL))
        var cont = true
        var r = ""
        ui_set_screen(main_menu)
        do {
            r = wait_menu()
            if (r == "Load") { 
                load_path = run_filechooser("Load module", "/home", ["*.MTM", "*.mtm"])
                if (load_path != null) {
                    try {
                        mod.load(load_path)
                        mod.edit(true) }
                    catch {
                        run_alert("File error", "The file is either not a MidiTrax file, or it is corrupted.", image_from_file("/res/miditrax/error.png"), 4000) } }
                ui_set_screen(main_menu) }
            else if (r == "New") {
                if (ui_new_mod(mod)) mod.edit(false)
                ui_set_screen(main_menu) }
            else if (r == "Exit") cont = false }
        while (cont) } }