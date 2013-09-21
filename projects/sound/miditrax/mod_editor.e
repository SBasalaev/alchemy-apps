// MidiTrax
// August 18 2013 - Kyle Alexander Buan
// Made for Alchemy OS
// Licensed under GPL-3

/***
  * Module editor
 **/

use "string.eh"
use "form.eh"
use "ui.eh"
use "stdscreens.eh"
use "dialog.eh"
use "media.eh"
use "image.eh"

use "mod_renderer.eh"
use "mod_file.eh"
use "module.eh"
use "easy_menu.eh"
use "pattern_editor.eh"

def Module.display_render() {
    var player: Player
    var ui = new Form()
    ui.title = "Render module"
    var txtPath = new EditItem("MIDI path:", "/mnt/"+this.title.replace(' ', '_')+".mid", EDIT_ANY, 100)
    ui.add(txtPath)
    var txtStart = new EditItem("First order index:", "0", EDIT_NUMBER, 4)
    ui.add(txtStart)
    var txtEnd = new EditItem("Last order index:", (this.orderlist.len()-1).tostr(), EDIT_NUMBER, 4)
    ui.add(txtEnd)
    var chkMetadata = new CheckItem("Write metadata:", "Enabled", false)
    ui.add(chkMetadata)
    var chkPlay = new CheckItem("Play after render:", "Enabled", true)
    ui.add(chkPlay)
    ui.add_menu(new Menu("Okay", 0))
    ui.add_menu(new Menu("Cancel", 1, MT_CANCEL))
    var r = ""
    var c = true
    do {
        ui_set_screen(ui)
        r = wait_menu()
        if (r == "Okay") {
            if (txtStart.text.toint()<this.orderlist.len() && txtEnd.text.toint()<this.orderlist.len()) {
                this.render(txtStart.text.toint(), txtEnd.text.toint()+1, txtPath.text, chkMetadata.checked)
                if (chkPlay.checked) {
                    player = new Player(fopen_r(txtPath.text), "audio/midi")
                    player.start() }
                run_alert("Success", "MIDI file has been created.", image_from_file("/res/miditrax/okay.png")) }
            else run_alert("Error", "First or Last order index is out of bounds!", image_from_file("/res/miditrax/error.png"), 2000) }
        else {
            c = false } }
    while (c)
    if (player != null) {
        player.stop()
        player.close() } }

def Module.display_details(): Bool {
    var changed = false
    var ui = new Form()
    ui.title = "Module details"
    ui.add(new TextItem("", "Module metadata:"))
    var txtTitle = new EditItem("Title:", this.title, EDIT_ANY, 64)
    ui.add(txtTitle)
    var txtAuthor = new EditItem("Author:", this.author, EDIT_ANY, 64)
    ui.add(txtAuthor)
    var txtComposer = new EditItem("Composer:", this.composer, EDIT_ANY, 64)
    ui.add(txtComposer)
    var txtComments = new EditItem("Comments:", this.comments, EDIT_ANY, 200)
    ui.add(txtComments)
    ui.add(new TextItem("", "Technical metadata:"))
    var txtChannels = new EditItem("Channels:", this.channels.tostr(), EDIT_NUMBER, 2)
    ui.add(txtChannels)
    var txtTempo = new EditItem("Tempo:", this.tempo.tostr(), EDIT_NUMBER, 3)
    ui.add(txtTempo)
    var txtSteps = new EditItem("Steps per pattern", this.steps.tostr(), EDIT_NUMBER, 3)
    ui.add(txtSteps)
    ui.add_menu(new Menu("Okay", 0))
    ui.add_menu(new Menu("Cancel", 1, MT_CANCEL))
    ui_set_screen(ui)
    var r = wait_menu()
    if (r == "Okay") {
        this.title    = txtTitle.text
        this.author   = txtAuthor.text
        this.composer = txtComposer.text
        this.comments = txtComments.text
        this.channels = txtChannels.text.toint().cast(Byte)
        this.tempo = txtTempo.text.toint()
        this.steps    = txtSteps.text.toint()
        changed = true } 
    changed }

def Module.edit_order(i: Int) {
    var ui = new Form()
    ui.title = "Edit order"
    var txtPatternNumber = new EditItem("Edit pattern number", this.orderlist[i].cast(Int).tostr(), EDIT_NUMBER, 3)
    ui.add(txtPatternNumber)
    ui.add_menu(new Menu("Okay", 0))
    ui.add_menu(new Menu("Cancel", 1, MT_CANCEL))
    var r = ""
    var c = true
    do {
        ui_set_screen(ui)
        r = wait_menu()
        if (r == "Okay") {
            if (txtPatternNumber.text.toint() < this.patterns.len()) {
                this.orderlist[i] = txtPatternNumber.text.toint()
                c = false }
            else {
                 run_alert("Error", "Pattern index does not exist!", image_from_file("/res/miditrax/error.png"), 2000) } }
        else {
            c = false } }
    while (c) }

def Module.add_order() {
    var ui = new Form()
    ui.title = "Add order"
    var txtPatternNumber = new EditItem("New pattern number", this.orderlist.len().tostr(), EDIT_NUMBER, 3)
    ui.add(txtPatternNumber)
    ui.add_menu(new Menu("Okay", 0))
    ui.add_menu(new Menu("Cancel", 1, MT_CANCEL))
    var r = ""
    var c = true
    do {
        ui_set_screen(ui)
        r = wait_menu()
        if (r == "Okay") {
            if (txtPatternNumber.text.toint() < this.patterns.len()) {
                this.orderlist.add(txtPatternNumber.text.toint())
                c = false }
            else {
                 run_alert("Error", "Pattern index does not exist!", image_from_file("/res/miditrax/error.png")) } }
        else {
            c = false } }
    while (c) }

def Module.display_orders(): Bool {
    var changed = false
    var orderlist = new ListBox([], [], new Menu("Edit", 0))
    orderlist.title = "Order list"
    orderlist.add_menu(new Menu("Add order", 1))
    orderlist.add_menu(new Menu("Remove order", 2))
    orderlist.add_menu(new Menu("Cancel", 3, MT_CANCEL))
    for (var i = 0, i < this.orderlist.len(), i += 1) {
        orderlist.add(this.orderlist[i].cast(Int).tostr()+" - "+this.patterns[this.orderlist[i].cast(Int)].cast(Pattern).name, null) }
    ui_set_screen(orderlist)
    var cont = true
    var response: String
    do {
        response = wait_menu()
        if (response == "Edit" && orderlist.len() > 0) {
            changed = true
            this.edit_order(orderlist.index)
            orderlist.clear()
            for (var i = 0, i < this.orderlist.len(), i += 1) {
                orderlist.add(this.orderlist[i].cast(Int).tostr()+" - "+this.patterns[this.orderlist[i].cast(Int)].cast(Pattern).name, null) }
            ui_set_screen(orderlist) }
        else if (response == "Add order") {
            changed = true
            this.add_order()
            orderlist.clear()
            for (var i = 0, i < this.orderlist.len(), i += 1) {
                orderlist.add(this.orderlist[i].cast(Int).tostr()+" - "+this.patterns[this.orderlist[i].cast(Int)].cast(Pattern).name, null) }
            ui_set_screen(orderlist) }
        else if (response == "Remove order" && orderlist.len() > 0) {
            changed = true
            this.orderlist.remove(orderlist.index)
            orderlist.clear()
            for (var i = 0, i < this.orderlist.len(), i += 1) {
                orderlist.add(this.orderlist[i].cast(Int).tostr()+" - "+this.patterns[this.orderlist[i].cast(Int)].cast(Pattern).name, null) } }
        else if (response == "Cancel") cont = false }
    while (cont)
    changed }

def Module.add_pattern() {
    var ui = new EditItem("Pattern name:", "", EDIT_ANY, 64)
    var sc = new Form()
    sc.title = "Add pattern"
    sc.add(ui)
    sc.add_menu(new Menu("Okay", 0))
    sc.add_menu(new Menu("Cancel", 1, MT_CANCEL))
    ui_set_screen(sc)
    if (wait_menu() == "Okay") this.patterns.add(new Pattern(ui.text, this.channels, this.steps)) }

def Module.rename_pattern(i: Int) {
    var ui = new EditItem("Pattern name:", this.patterns[i].cast(Pattern).name, EDIT_ANY, 64)
    var sc = new Form()
    sc.add(ui)
    sc.add_menu(new Menu("Okay", 0))
    sc.add_menu(new Menu("Cancel", 1, MT_CANCEL))
    ui_set_screen(sc)
    if (wait_menu() == "Okay") this.patterns[i].cast(Pattern).name = ui.text }

def Module.display_patterns(): Bool {
    var changed = false
    var patternlist = new ListBox([], [], new Menu("Edit", 0))
    patternlist.title = "Patterns"
    patternlist.add_menu(new Menu("New pattern", 1))
    patternlist.add_menu(new Menu("Rename pattern", 2))
    patternlist.add_menu(new Menu("Remove pattern", 3))
    patternlist.add_menu(new Menu("Cancel", 4, MT_CANCEL))
    for (var i = 0, i < this.patterns.len(), i += 1) {
        patternlist.add(i.tostr()+" - "+this.patterns[i].cast(Pattern).name, null) }
    ui_set_screen(patternlist)
    var cont = true
    var response: String
    do {
        response = wait_menu()
        if (response == "Edit" && patternlist.len() > 0) {
            changed = this.edit_pattern(patternlist.index)
            ui_set_screen(patternlist) }
        else if (response == "New pattern") {
            changed = true
            this.add_pattern()
            patternlist.clear()
            for (var i = 0, i < this.patterns.len(), i += 1) {
                patternlist.add(i.tostr()+" - "+this.patterns[i].cast(Pattern).name, null) }
            ui_set_screen(patternlist) }
        else if (response == "Rename pattern" && patternlist.len() > 0) {
            changed = true
            this.rename_pattern(patternlist.index)
            patternlist.clear()
            for (var i = 0, i < this.patterns.len(), i += 1) {
                patternlist.add(i.tostr()+" - "+this.patterns[i].cast(Pattern).name, null) }
            ui_set_screen(patternlist) }
        else if (response == "Remove pattern" && patternlist.len() > 0) {
            changed = true
            this.patterns.remove(patternlist.index)
            patternlist.delete(patternlist.index) }
        else if (response == "Cancel") cont = false }
    while (cont)
    changed }
 
def Module.edit(loaded: Bool) {
    var changed = !loaded
    var menu = new ListBox(["Patterns", "Order list", "This module"], null, new Menu("Select", 0))
    menu.title = "Module menu"
    menu.add_menu(new Menu("Save", 1))
    menu.add_menu(new Menu("Render", 2))
    menu.add_menu(new Menu("Close", 3, MT_CANCEL))
    ui_set_screen(menu)
    var save_ui = new Form()
    save_ui.title = "Save module"
    var txtSave = new EditItem("File path and name:", "/home/new.wtm", EDIT_ANY, 100)
    save_ui.add(txtSave)
    save_ui.add_menu(new Menu("Save", 0))
    save_ui.add_menu(new Menu("Cancel", 1, MT_CANCEL))
    var cont = true
    var r: String
    do {
        r = wait_menu()
        if (r == "Select") {
            switch (menu.index) {
                0: { changed = this.display_patterns() }
                1: { changed = this.display_orders() }
                2: { changed = this.display_details() } }
            ui_set_screen(menu) }
        else if (r == "Save") {
            var s = run_dirchooser("Choose folder", "/home")
            if (s != null) {
                txtSave.text = s + "/" + this.title.replace(' ', '_') + ".mtm"
                ui_set_screen(save_ui)
                if (wait_menu() == "Save") {
                    this.save(txtSave.text)
                    run_alert("Success", "MidiTrax module has been saved.", image_from_file("/res/miditrax/okay.png"))
                    changed = false } }
            ui_set_screen(menu) }
        else if (r == "Render") {
            this.display_render()
            ui_set_screen(menu) }
        else if (r == "Close") {
            if (changed) {
                cont = !run_yesno("Warning", "File may have been changed. Exiting without saving will lose changes. Do you still want to exit?", "Exit", "Cancel", image_from_file("/res/miditrax/warning.png")) }
            else {
                cont = false } } }
    while (cont) }