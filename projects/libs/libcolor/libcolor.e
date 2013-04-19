// color, image & list operations
// v1.0 - first lib release
// v1.1 - more accurate colors and a bit faster

use "list"
use "math"
use "image"
use "string"

type Color {
    r: Int = 0,
    g: Int = 0,
    b: Int = 0 }

def Color.abs(): Int {
    ((this.r)*(this.r)) + 
    ((this.g)*(this.g)) + 
    ((this.b)*(this.b)) }

def Color.sub(c: Color): Color {
    new Color(this.r-c.r, this.g-c.g, this.b-c.b) }

def Color.toint(): Int {
    (this.r << 16) + (this.g << 8) + this.b }

def List.lowest(): Int {
    var r: Int=this[0]
    var index=0
    var s=this.len()
    for (var i=0, i<s, i+=1) {
        if (r>(this[i].cast(Int))) {
            r=this[i]
            index=i } }
   index }

def Color.luminosity(): Color {
    var l = (0.21*this.r)+(0.71*this.g)+(0.07*this.g)
    new Color(l, l, l) }

def Color.closest_index(pal: List): Int {
// differences
    var pl = pal.len()
    var diff = new [Int](pl)
    for (var i=0, i<pl, i+=1) {
        diff[i] = (this.sub(pal[i].cast(Color))).abs() }
    var r: Int=diff[0]
    var index=0
    var s=diff.len
    for (var i=0, i<s, i+=1) {
        if (r>diff[i]) {
            r=diff[i]
            index=i } }
   index }

def Color.closest(pal: List): Color {
// differences
    var pl = pal.len()
    var diff = new [Int](pl)
    for (var i=0, i<pl, i+=1) {
        diff[i] = this.sub(pal[i].cast(Color)).abs() }
    pal[ {
        var r: Int=diff[0]
        var index=0
        var s=diff.len
        for (var i=0, i<s, i+=1) {
            if (r>diff[i]) {
                r=diff[i]
                index=i } }
        index } ] }

def Image.get_pix_real(x: Int, y: Int): Color {
    var a = [0]
    this.get_argb(a, 0, 1, x, y, 1, 1)
    new Color(((a[0])&0xFF0000)>>16, ((a[0])&0xFF00)>>8, ((a[0])&0xFF)) }

def get_image_x(i: Image): Int {
    var c = true
    var x = 0
    while (c) {
        try {
            i.get_pix_real(x, 0) }
        catch {
            c = false }
        x += 1 }
    x - 1}

def get_image_y(i: Image): Int {
    var c = true
    var y = 0
    while (c) {
        try {
            i.get_pix_real(0, y) }
        catch {
            c = false }
        y += 1 }
   y - 1 }

def List.highest(): Int {
    var r = 0
    var index=0
    var s = this.len()
    for (var i=0, i<s, i+=1) {
        if (r < this[i].cast(Int)) {
            r = this[i]
            index=i } }
    index }

def Color.correct(): Color {
    new Color(
        if (this.r<0) {0} else if (this.r>255) {255} else {this.r},
        if (this.g<0) 0 else if (this.g>255) 255 else this.g,
        if (this.b<0) 0 else if (this.b>255) 255 else this.b ) }

def Color.add(c: Color): Color {
    var r = new Color(this.r+c.r, this.g+c.g, this.b+c.b)
    r }

def Color.add_int(i: Int): Color {
    var r = new Color(this.r+i, this.g+i, this.b+i)
    r.correct() }

def Color.frac(a: Int, b: Int): Color {
    new Color((this.r*a)/b, (this.g*a)/b, (this.b*a)/b) }

def Image.get_pix(x: Int, y: Int, x_s: Int, y_s: Int): Color {
    var a = [0]
    if ((x>=0 && x<x_s) && (y>=0 && y<y_s)) {
        this.get_argb(a, 0, 1, x, y, 1, 1)
        new Color((a[0]&0xFF0000)>>16, (a[0]&0xFF00)>>8, a[0]&0xFF) }
    else {
        new Color(0, 0, 0) } }

def Color.tohtml(): String {
    var r = this.toint().tohex()
    while (r.len()<6) r="0"+r
    "#"+r.ucase() }

def Int.tocolor(): Int {
    (this<<16)+(this<<8)+this }