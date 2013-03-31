// BMP writer library
// Kyle Alexander Buan
// Mar 6 2013
// v2.5

use "dataio"
use "image"
use "list"
use "ui"
use "canvas"
use "graphics"

use "extras.e"

var scr: Canvas
var scrg: Graphics


def OStream.writebytes(i: Int, n: Int) { // writes a number in little-endian format
    for (var j=0, j<n, j+=1) {
        this.writebyte(i & 0xFF)
        i = i>>8 } }

def init_screen() {
    scr = new Canvas(true)
    ui_set_screen(scr)
    scrg = scr.graphics()
    scrg.set_color(0)
    scrg.fill_rect(0, 0, 240, 320)
    scr.refresh() }

def display_progress(a: Int, b: Int) {
    scrg.set_color(0)
    scrg.fill_rect(0, 20, 240, 40)
    scrg.set_color(0xFF)
    scrg.draw_string(a.tostr()+"/"+b.tostr()+" ("+((a*100)/b).tostr()+"%)", 0, 20)
    scrg.fill_rect(0, 40, (a*240)/b, 20)
    scr.refresh() }

def save_bmp(i: Image, indexed: Bool, pal: List, fname: String, display: Bool) {
    var previous = ui_get_screen()
    if (display) init_screen()
// calculations
    const img_x = get_image_x(i)
    const img_y = get_image_y(i)
    var bpp: Int
    if (indexed) {
        bpp = 0
        if (pal.len()==2) bpp = 1
        if (pal.len()<=16 && pal.len()>2) bpp = 4
        if (pal.len()<=256 && pal.len()>16) bpp = 8 }
    else {
        bpp = 24 }
    const row_size = ((bpp*img_x+31)/32)*4
    const pix_arr_size = row_size * img_y
    var bmp_size: Int
    if (indexed) {
        bmp_size = 14+40+(pal.len()*4)+pix_arr_size }
    else {
        bmp_size = 14+40+pix_arr_size }
// open file
    var f = fopen_w(fname)
// BMP Header
    f.writebytes(0x4D42, 2) // "BM"
    f.writebytes(bmp_size, 4) // bmp size
    f.writebytes(0, 4) // reserved
    if (indexed) {
        f.writebytes(14+40+(pal.len()*4), 4) } // pixel table offset
    else {
        f.writebytes(14+40, 4) } // pixel table offset
// DIB (Bitmap Info Header)
    f.writebytes(40, 4) // DIB header size
    f.writebytes(img_x, 4) // width
    f.writebytes(img_y, 4) // height
    f.writebytes(1, 2) // num of color planes
    f.writebytes(bpp, 2) // bits per pixel
    f.writebytes(0, 4) // no compression
    f.writebytes(pix_arr_size, 4) // pixel array size
    f.writebytes(1, 4) // pix/meter width   \
    f.writebytes(1, 4) // pix/meter height  / I do not know the right values for this :\
    if (indexed) {
        f.writebytes(pal.len(), 4) }// palette size 
    else {
        f.writebytes(0, 4) }// palette not used? I do not know what value to use
    f.writebytes(0, 4) // all colors important - generally ignored
// Color table! LOL
    if (indexed) {
        for (var n=0, n<pal.len(), n+=1) {
            f.writebytes(pal[n].cast(Color).toint(), 4) } }
// raw image bitmap!!! I hate BMP... :(
    var written: Int
    var buffer: Byte = 0
    var buf_count: Byte = 0
    for (var y=img_y-1, y>=0, y-=1) {
        // OMG REVERSED?!?!
        written = 0
        for (var x=0, x<img_x, x+=1) {
            if (bpp==24) {
                f.writebytes((i.get_pix_real(x, y)).toint(), 3)
                written += 3 }
            if (bpp==8) {
                f.writebytes((i.get_pix_real(x, y)).closest_index(pal), 1)
                written += 1 }
            else if (bpp==4) {
                if (buf_count <2) {
                    buffer += (i.get_pix_real(x, y)).closest_index(pal) << (4*(1-buf_count))
                    buf_count += 1 }
                if (buf_count == 2 || x==img_x-1) {
                    f.writebytes(buffer, 1)
                    written += 1
                    buffer = 0
                    buf_count = 0 } }
            else if (bpp==1) {
                if (buf_count < 8) {
                    buffer += (i.get_pix_real(x, y)).closest_index(pal) << (7-buf_count)
                    buf_count += 1 }
                if (buf_count == 8 || x==img_x-1) {
                    f.writebytes(buffer, 1)
                    written += 1
                    buffer = 0
                    buf_count = 0 } } }
        // foolish padding
        while (written < row_size) {
            f.writebytes(0, 1)
            written += 1 }
        f.flush()
        if (display) display_progress(y, img_y) }
    f.flush()
    f.close()
    if (display) ui_set_screen(previous) }