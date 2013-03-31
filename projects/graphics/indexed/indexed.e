/*
     "Indexed"
     Convert standard RGB image to indexed
     format
     Made specifically for Alchemy 2.1
     I stopped Back2Basics because it is totally
     useless. I replaced it with this because this is
     much more useful. With less clutter,
     I hope this will run faster.
    (c) Kyle Alexander Buan - March 3, 2013
*/

/*
Version history:
b15 - Supports loading palettes
b17 - Can save both indexed and 24-bit RGB bitmap files.
b18 - Code cleanup, implement save_palette
b19 - Shows processing speed, can cancel processing
b20 - Image scaling options
b21 - Various usability improvements
b22 - Human error tolerance, some bugfixes
b23 - Subpixel antialiasing for greyscale images, ordered dithering
*/

use "io"
use "textio"
use "ui"
use "stdscreens"
use "form"
use "canvas"
use "image"
use "graphics"
use "list"
use "string"
use "math"
use "time"

use "extras.e"
use "bmpwrite.e"

const VERSION = "b23"

def square_img(c: Int, s: Int): Image {
    var i = new Image(s, s)
    var g = i.graphics()
    g.set_color(c)
    g.fill_rect(0, 0, s, s)
    i }

def get_color(): Color {
    var colpick = new Form()
    colpick.set_title("Color picker")
    var red = new EditItem("Red:", "0", 2, 3)
    var green = new EditItem("Green:", "0", 2, 3)
    var blue = new EditItem("Blue:", "0", 2, 3)
    var previ = new ImageItem("Preview:", square_img((new Color(red.get_text().toint(), green.get_text().toint(), blue.get_text().toint()).correct().toint()), 128))
    var o = new Menu("Okay", 0)
    colpick.add_menu(o)
    colpick.add(red)
    colpick.add(green)
    colpick.add(blue)
    colpick.add(previ)
    ui_set_screen(colpick)
    var e = ui_wait_event()
    while (e.kind != EV_MENU) {
        previ.set_image(square_img((new Color(("0"+red.get_text()).toint(), ("0"+green.get_text()).toint(), ("0"+blue.get_text()).toint()).correct().toint()), 128))
        e = ui_wait_event() }
    new Color(("0"+red.get_text()).toint(), ("0"+green.get_text()).toint(), ("0"+blue.get_text()).toint()).correct() }

def wait_menu(): String {
    var e = ui_wait_event()
    while (e.kind != EV_MENU) e = ui_wait_event()
    e.value.cast(Menu).get_text() }

def msg(m: String, g: Graphics) {
    g.set_color(0)
    g.fill_rect(0, 0, 240, 20)
    g.set_color(0xFF)
    g.draw_string(m, 0, 0)
    g.set_font(8)
    g.draw_string("Indexed "+VERSION, 240-str_width(8, "Indexed "+VERSION), 0)
    g.set_font(0) }

// menu drivers
def add_color(pal: List, palEdit: ListBox) {
    var c = get_color()
    pal.insert(palEdit.get_index(), c)
    palEdit.insert(palEdit.get_index(), c.tohtml(), square_img(c.toint(), 32))
    ui_set_screen(palEdit) }

def edit_color(pal: List, palEdit: ListBox) {
    var c = get_color()
    pal[palEdit.get_index()] = c
    palEdit.set(palEdit.get_index(), c.tohtml(), square_img(c.toint(), 32))
    ui_set_screen(palEdit) }

def remove_color(pal: List, palEdit: ListBox) {
    pal.remove(palEdit.get_index())
    palEdit.delete(palEdit.get_index()) }

def load_palette(palEdit: ListBox): List {
    var okay = new Menu("Okay", 0)
    var loadpal = new ListBox([""], null, okay)
    loadpal.delete(0)
    loadpal.add_menu(okay)
    loadpal.set_title("Load palette")
    var palettes = flistfilter("/res/indexed", "*.pal")
    var pal = new List()
    for (var i = 0, i<palettes.len, i+=1) {
        loadpal.add(palettes[i], null) }
    ui_set_screen(loadpal)
    wait_menu()
    var f = utfreader(fopen_r("/res/indexed/"+loadpal.get_string(loadpal.get_index())))
    var line = ["", "", ""]
    palEdit.clear()
    var amount = f.readline().toint()
    for (var i=0, i<amount, i+=1) {
        line = f.readline().split(',')
        pal.add(new Color(line[0].toint(), line[1].toint(), line[2].toint()))
        palEdit.add(pal[i].cast(Color).tohtml(), square_img(pal[i].cast(Color).toint(), 32)) }
    f.close()
    ui_set_screen(palEdit)
    pal }

def load_and_resize_image(filepath: String, width: Float, height: Float, mode: Int): [Any] {
    var tempimg = image_from_file(filepath)
    var x_size = get_image_x(tempimg)
    var y_size = get_image_y(tempimg)
    var img: Image
    var imgg: Graphics
    if ((x_size>width) && (mode != 2)) {
        var x_step: Double = x_size / width
        img = new Image(x_size/x_step, y_size/x_step)
        imgg = img.graphics()
        for (var j=0, j<(y_size/x_step), j+=1) {
            for (var i=0, i<width, i+=1) {
                imgg.set_color(tempimg.get_pix(i*x_step, j*x_step, x_size, y_size).toint())
                imgg.draw_line(i, j, i, j) } }
        x_size /= x_step
        y_size /= x_step }
    else if ((y_size>height) && (mode != 2)) {
        var y_step: Float = x_size / height
        img = new Image(x_size/y_step, y_size/y_step)
        imgg = img.graphics()
        for (var j=0, j<(y_size/y_step), j+=1) {
            for (var i=0, i<width, i+=1) {
                imgg.set_color(tempimg.get_pix(i*y_step, j*y_step, x_size, y_size).toint())
                imgg.draw_line(i, j, i, j) } }
        x_size /= y_step
        y_size /= y_step }
    else {
        img = new Image(x_size, y_size)
        imgg = img.graphics()
        imgg.draw_image(tempimg, 0, 0) }
    tempimg = null
    var result: [Any] = [img, imgg, x_size, y_size]
    result }

def reduce_image(img: Image, imgg: Graphics, x_size: Int, y_size: Int, disp: Canvas, dg: Graphics, dithering: Bool, pal: List) {
    var oldpixel = new Color(0, 0, 0)
    var newpixel = new Color(0, 0, 0)
    var quant_error = new Color(0, 0, 0)
    var t: Long
    var e: UIEvent
    var cont = true
    for (var y=0, (y<y_size) && cont, y+=1) {
        t = systime()
        e = ui_read_event()
        if (e != null) if (e.kind == EV_MENU) cont = false
        for (var x=0, x<x_size, x+=1) {
// dithering start
            oldpixel = img.get_pix(x, y, x_size, y_size)
            newpixel = oldpixel.closest(pal)
            quant_error = oldpixel.sub(newpixel)
// First
            imgg.set_color(newpixel.toint())
            imgg.draw_line(x, y, x, y)
// second and after: only done if dithering is on
            if (dithering) {
                imgg.set_color((img.get_pix(x+1, y, x_size, y_size).add(quant_error.frac(7, 16))).correct().toint())
                imgg.draw_line(x+1, y, x+1, y)
// third
                imgg.set_color((img.get_pix(x-1, y+1, x_size, y_size).add(quant_error.frac(3, 16))).correct().toint())
                imgg.draw_line(x-1, y+1, x-1, y+1)
// fourth
                imgg.set_color((img.get_pix(x, y+1, x_size, y_size).add(quant_error.frac(5, 16))).correct().toint())
                imgg.draw_line(x, y+1, x, y+1)
// fifth
                imgg.set_color((img.get_pix(x+1, y+1, x_size, y_size).add(quant_error.frac(1, 16))).correct().toint())
                imgg.draw_line(x+1, y+1, x+1, y+1) } }
        msg(((y*100)/y_size).tostr()+"%, "+(systime()-t).tostr()+"ms/line", dg)
        dg.draw_image(img, 0, 20)
        disp.refresh() }
    if (cont) msg("100%", dg) else msg("Cancelled", dg) }

def ordered_image(img: Image, imgg: Graphics, x_size: Int, y_size: Int, disp: Canvas, dg: Graphics, pal: List) {
    var map = [[-112, 15, -80, 47], [79, -48, 111, -16], [-64, 63, -96, 31], [127, 0, 95, -32]]
    var oldpixel = new Color(0, 0, 0)
    var newpixel = new Color(0, 0, 0)
    var t: Long
    var e: UIEvent
    var cont = true
    for (var y=0, (y<y_size) && cont, y+=1) {
        t = systime()
        e = ui_read_event()
        if (e != null) if (e.kind == EV_MENU) cont = false
        for (var x=0, x<x_size, x+=1) {
// dithering start
            oldpixel = (img.get_pix(x, y, x_size, y_size)).add_int(map[y%4][x%4])
            newpixel = oldpixel.closest(pal)
// First
            imgg.set_color(newpixel.toint())
            imgg.draw_line(x, y, x, y) }
        msg(((y*100)/y_size).tostr()+"%, "+(systime()-t).tostr()+"ms/line", dg)
        dg.draw_image(img, 0, 20)
        disp.refresh() }
    if (cont) msg("100%", dg) else msg("Cancelled", dg) }


def bnw_image(img: Image, imgg: Graphics, x_size: Int, y_size: Int, disp: Canvas, dg: Graphics) {
    var oldpixel = new Color(0, 0, 0)
    var newpixel = new Color(0, 0, 0)
    var t: Long
    var e: UIEvent
    var cont = true
    for (var y=0, (y<y_size) && cont, y+=1) {
        t = systime()
        e = ui_read_event()
        if (e != null) if (e.kind == EV_MENU) cont = false
        for (var x=0, x<x_size, x+=1) {
            oldpixel = img.get_pix(x, y, x_size, y_size)
            newpixel = oldpixel.luminosity()
            imgg.set_color(newpixel.toint())
            imgg.draw_line(x, y, x, y) }
        msg(((y*100)/y_size).tostr()+"%, "+(systime()-t).tostr()+"ms/line", dg)
        dg.draw_image(img, 0, 20)
        disp.refresh() }
    if (cont) msg("100%", dg) else msg("Cancelled", dg) }

def subpixel_image(srcimg: Image, dstimg: Image, dstimgg: Graphics, x_size: Int, y_size: Int, disp: Canvas, dg: Graphics) {
    var oldpixel = new Color(0, 0, 0)
    var newpixel = new Color(0, 0, 0)
    var t: Long
    var e: UIEvent
    var cont = true
    for (var y=0, (y<y_size) && cont, y+=3) {
        t = systime()
        e = ui_read_event()
        if (e != null) if (e.kind == EV_MENU) cont = false
        for (var x=0, x<x_size, x+=3) {
            oldpixel.r = 0xFF & (srcimg.get_pix(x, y, x_size, y_size).toint())
            oldpixel.g = 0xFF & (srcimg.get_pix(x+1, y+1, x_size, y_size).toint())
            oldpixel.b = 0xFF & (srcimg.get_pix(x+2, y+2, x_size, y_size).toint())
            dstimgg.set_color(oldpixel.toint())
            dstimgg.draw_line(x/3, y/3, x/3, y/3)
            dg.set_color(oldpixel.r.tocolor())
            dg.draw_line(x, y+20, x, y+22)
            dg.set_color(oldpixel.g.tocolor())
            dg.draw_line(x+1, y+20, x+1, y+22)
            dg.set_color(oldpixel.b.tocolor())
            dg.draw_line(x+2, y+20, x+2, y+22) }
        msg(((y*100)/y_size).tostr()+"%, "+(systime()-t).tostr()+"ms/line", dg)
        disp.refresh() }
    if (cont) msg("100%", dg) else msg("Cancelled", dg) }

def save_palette(pal: List) {
    var savepal = new Form()
    var okay = new Menu("Okay", 0)
    var cancel = new Menu("Cancel", 1)
    var savepath = new EditItem("Name:", "")
    savepal.set_title("Save palette")
    savepal.add_menu(okay)
    savepal.add_menu(cancel)
    savepal.add(savepath)
    ui_set_screen(savepal)
    if (wait_menu() == "Okay") {
        var f = utfwriter(fopen_w("/res/indexed/"+savepath.get_text()+".pal"))
        var c: Color
        f.println(pal.len().tostr())
        for (var i=0, i<pal.len(), i+=1) {
            c = pal[i]
            f.println(c.r.tostr()+","+c.g.tostr()+","+c.b.tostr()) }
        f.flush()
        f.close() } }

def main(args: [String]) {
    //-----INITIALIZATION
    var col7 = new Color(7, 7, 7)
    var col3 = new Color(3, 3, 3)
    var col5 = new Color(5, 5, 5)
    var col16 = new Color(16, 16, 16)
    var tempimg: Image
    var tempimgg: Graphics
    var pal = new List()
    pal.add(new Color(0, 0, 0))
    pal.add(new Color(255, 255, 255))
    ui_set_app_title("Indexed")
    
    // Menus
    var add = new Menu("Add", 0)
    var edit = new Menu("Edit", 1)
    var remove = new Menu("Remove", 2)
    var load = new Menu("Load", 3)
    var save = new Menu("Save", 4)
    var okay = new Menu("Okay", 5)
    var exit = new Menu("Exit", 6)
    
    // filename input
    var fName = new Form()
    var fNamepath = new EditItem("Image path:", "/home/", 0, 100)
    var fNamemode = new RadioItem("Mode:", ["Indexed color", "Sub-pixel monochrome"])
    var fNamedithermode = new RadioItem("Dithering:", ["Floyd-Steinberg", "Ordered", "None"])
    var fNamewidth = new EditItem("Scale to width:", "240", 2, 4)
    var fNameheight = new EditItem("Scale to height:", "300", 2, 4)
    var fNamescale = new RadioItem("Scaling:", ["Downscale only", "Always", "Never"])
    fNamescale.set_index(0)
    fName.set_title("Indexed "+VERSION)
    fName.add_menu(okay)
    fName.add_menu(exit)
    fName.add(fNamepath)
    fName.add(fNamemode)
    fName.add(fNamedithermode)
    fName.add(fNamewidth)
    fName.add(fNameheight)
    fName.add(fNamescale)
    
    // Palette editor
    var palEdit = new ListBox(["#000000", "#FFFFFF"], [square_img(0, 32), square_img(0xFFFFFF, 32)], edit)
    palEdit.set_title("Edit palette")
    palEdit.add_menu(add)
    palEdit.add_menu(edit)
    palEdit.add_menu(remove)
    palEdit.add_menu(load)
    palEdit.add_menu(save)
    palEdit.add_menu(okay)
    palEdit.add_menu(exit)    
    
    // Image display
    var disp = new Canvas(true)
    disp.add_menu(exit)
    
    // Save dialog
    var saved = new Form()
    saved.set_title("Save image")
    var savepath = new EditItem("Save path:", "/home/", 0, 100)
    var chkIndexed = new CheckItem("Pixel format:", "Indexed", true)
    saved.add(savepath)
    saved.add(chkIndexed)
    saved.add_menu(okay)
    saved.add_menu(exit)
    
    //------MAIN ROUTINE
    var maincont = true
    var colcont = true
    var dispcont = true
    var c = new Color(0, 0, 0)
    var response = ""
    ui_set_screen(fName)
    while (maincont) {
       colcont = true
        if (wait_menu() == "Okay") {
            ui_set_screen(palEdit)
            while (colcont) {
                response = wait_menu()
                if (response == "Add") {
                    add_color(pal, palEdit) }
                else if (response == "Edit") {
                    edit_color(pal, palEdit) }
                else if (response == "Remove") {
                    remove_color(pal, palEdit) }
                else if (response == "Load") {
                    pal = load_palette(palEdit) }
                else if (response == "Save") {
                    save_palette(pal)
                    ui_set_screen(palEdit) }
                else if (response == "Okay") {
                    dispcont = true
                    ui_set_screen(disp)
                    var dg = disp.graphics()
                    dg.set_color(0)
                    dg.fill_rect(0, 0, 240, 320)
                    msg("Loading image...", dg)
                    disp.refresh()
                    var specs = load_and_resize_image(fNamepath.get_text(), fNamewidth.get_text().toint(), fNameheight.get_text().toint(), fNamescale.get_index())
                    var img: Image = specs[0]
                    var imgg: Graphics = specs[1]
                    var x_size: Int = specs[2]
                    var y_size: Int = specs[3]
                    specs = null
                    dg.draw_image(img, 0, 20)
                    msg("Processing image...", dg)
                    disp.refresh()
                    if (fNamemode.get_index() == 0) {
                        if (fNamedithermode.get_index() == 0) reduce_image(img, imgg, x_size, y_size, disp, dg, true, pal)
                        else if (fNamedithermode.get_index() == 1) ordered_image(img, imgg, x_size, y_size, disp, dg, pal)
                        else reduce_image(img, imgg, x_size, y_size, disp, dg, false, pal) }
                    else {
                        bnw_image(img, imgg, x_size, y_size, disp, dg)
                        tempimg = new Image(x_size, y_size)
                        tempimgg = tempimg.graphics()
                        tempimgg.draw_image(img, 0, 0)
                        img = new Image(x_size/3, y_size/3)
                        imgg = img.graphics()
                        subpixel_image(tempimg, img, imgg, x_size, y_size, disp, dg)
                        x_size /= 3
                        y_size /= 3 }
                    disp.add_menu(save)
                    while (dispcont) {
                        response = wait_menu()
                        if (response == "Exit") {
                            dispcont = false
                            colcont = false }
                        else if (response == "Save") {
                            ui_set_screen(saved)
                            response = wait_menu()
                            if (response == "Okay") {
                                msg("Saving...", dg)
                                ui_set_screen(disp)
                                disp.refresh()
                                save_bmp(img, chkIndexed.get_checked(), pal, savepath.get_text(), true)
                                msg("Done!", dg)
                                disp.refresh() }
                            else ui_set_screen(disp) } }
                    disp.remove_menu(save) }
                else if (response == "Exit") {
                    colcont = false } }
            ui_set_screen(fName) }
        else maincont = false } }
