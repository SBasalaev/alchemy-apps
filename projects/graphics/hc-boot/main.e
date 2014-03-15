use "sys"
use "ui"
use "canvas"
use "graphics"
use "font"
use "hcg"
use "image"
def main(args: [String]) {
var cv:Canvas = new Canvas(true);
var im:Image = image_from_file("/res/hc-boot/logo.png");
ui_set_screen(cv);
hcg_fade_in(cv);
var g:Graphics = cv.graphics();
g.draw_image(im,cv.get_width()/2-48,cv.get_height()/2-48);
g.set_color(0x00000000);
var font:Int = FACE_SYSTEM | STYLE_BOLD | SIZE_LARGE;
g.set_font(font);
g.draw_string("Alchemy OS",cv.get_width()/2-(str_width(font,"Alchemy OS")/2),cv.get_height()/2);
cv.refresh();
sleep(3000);
hcg_fade_out(cv);
}
