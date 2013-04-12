// color, image & list operations

use "list"
use "image"
use "canvas"

type Color {
    r: Int = 0,
    g: Int = 0,
    b: Int = 0 }

def Color.abs(): Int;
def Color.sub(c: Color): Color;
def Color.toint(): Int;
def Color.luminosity(): Color;
def Color.closest_index(pal: List): Int;
def Color.closest(pal: List): Color;
def Image.get_pix_real(x: Int, y: Int): Color; // wil produce out-of-bounds error
def get_image_x(i: Image): Int; // width
def get_image_y(i: Image): Int; // height
def List.highest(): Int;
def Color.correct(): Color; // make sure that it is a valid RGB color
def Color.add(c: Color): Color;
def Color.add_int(i: Int): Color; // same with add, but add new Color(i, i, i) instead of just add i
def Color.frac(a: Int, b: Int): Color; // result = (this * a) / b
def Image.get_pix(x: Int, y: Int, x_s: Int, y_s: Int): Color;
def Color.tohtml(): String;
def Int.tocolor(): Int;