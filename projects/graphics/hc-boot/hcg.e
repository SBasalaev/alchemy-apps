use "graphics"
use "canvas"
use "ui"
use "sys"
def hcg_fade_in(cv:Canvas,from:Int = 0x00000000,to:Int = 0x00FFFFFF,step:Int = 0x00333333,speed:Int = 0x2F) {
var g:Graphics = cv.graphics();
for (var i:Int=from,i<=to,i+=step) {
g.set_color(from+i);
g.fill_rect(0,0,cv.get_width(),cv.get_height());
cv.refresh();
sleep(speed);
}
}
def hcg_fade_out(cv:Canvas,from:Int = 0x00FFFFFF,to:Int = 0x00000000,step:Int = 0x00333333,speed:Int = 0x2F) {
var g:Graphics = cv.graphics();
for (var i:Int=from,i>=to,i-=step) {
g.set_color(from+i);
g.fill_rect(0,0,cv.get_width(),cv.get_height());
cv.refresh();
sleep(speed);
}
}