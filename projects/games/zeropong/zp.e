// ZERO Pong!
// Kyle Alexander Buan
// October 27, 2012

use "ui.eh"
use "canvas.eh"
use "graphics.eh"
use "rnd.eh"
use "sys.eh"
use "math.eh"
use "font.eh"
use "string.eh"

type Ball {
  x: Float,
  y: Float,
  dx: Float,
  dy: Float,
  size: Int
}

def Ball.init(scr: Canvas, gra: Graphics) {
  this.x = scr.get_width()/2-5;
  this.y = scr.get_height()/2-5;
  this.dx = 0;
  while (abs(this.dx) < 0.5) {
    this.dx = rnd(2)-1+rndfloat();
  }
  this.dy = 0;
  while (abs(this.dy) < 0.5) {
    this.dy = rnd(2)-1+rndfloat();
  }
  var count: Int = 3;
  gra.set_color(0x990000);
  gra.fill_rect(20, 20, 100, 60);
  gra.set_color(0xFF00);
  gra.draw_string("Get ready!", 30, 30);
  while (count > 0) {
    gra.set_color(0x990000);
    gra.fill_rect(45, 50, 25, 25);
    gra.set_color(0xFFFFFF);
    gra.draw_string(count.tostr(), 46, 51);
    scr.refresh();
    sleep(1000);
    count -= 1;
  }
}

def Ball.draw(gra: Graphics) {
  gra.set_color(0xFFFFFF);
  gra.fill_arc(this.x, this.y, this.size, this.size, 0, 359);
}

type VertPad {
  x: Int,
  y: Int,
  m: Int
}

def VertPad.draw(gra: Graphics) {
  gra.set_color(0xFFFFFF);
  gra.fill_rect(this.x, this.y, 5, 50);
}

def VertPad.move(can: Canvas) {
  if (this.m != 0) {
    if (this.m > 0 && this.y < can.get_height()-75)
      this.y += this.m;
    else if (this.m < 0 && this.y > 20)
      this.y += this.m;
  }
}

type HoriPad {
  x: Int,
  y: Int,
  m: Int
}

def HoriPad.draw(gra: Graphics) {
  gra.set_color(0xFFFFFF);
  gra.fill_rect(this.x, this.y, 50, 5);
}

def HoriPad.move(can: Canvas) {
  if (this.m != 0) {
    if (this.m > 0 && this.x < can.get_width()-60)
      this.x += this.m;
    else if (this.m < 0 && this.x > 10)
      this.x += this.m;
  }
}

def Ball.move(ud: HoriPad, lr: VertPad, can: Canvas): Bool {
  var ret: Bool = false;
  this.x += this.dx;
  this.y += this.dy;
  if ((this.x <= 10 || this.x >= can.get_width()-20) && (this.y >= lr.y-5 && this.y <= lr.y+55)) {
    if (this.dx < 0) {
      this.dx = abs(this.dx);
      this.x = 11
    }
    else {
      this.dx = 0 - abs(this.dx);
      this.x = can.get_width() - 21;
    }
    if (lr.m>0) this.dy += 0.25;
    else if (lr.m<0) this.dy -= 0.25;
    ret = true;
  }
  if ((this.y <= 20 || this.y >= can.get_height()-35) && (this.x >= ud.x-5 && this.x <= ud.x+55)) {
    if (this.dy < 0) {
      this.dy = abs(this.dy);
      this.y = 21;
    }
    else {
      this.dy = 0 - abs(this.dy);
      this.y = can.get_height() - 36;
    }
    if (ud.m>0) this.dx += 0.25;
    else if (lr.m<0) this.dx -= 0.25;
    ret = true;
  }
  ret;
}

def get_response(): Int {
  var ret: Int = -1;
  var e: UIEvent;
  while (ret == -1) {
    e = ui_wait_event()
    if (e != null) {
      if (e.kind == EV_KEY) ret = e.value;
    }
  }
  ret;
}

def exit(Canv: Canvas, Grap: Graphics): Bool {
  var ret: Bool = true;
  var r: Int;
  Grap.set_color(0x005500);
  Grap.fill_rect(20, 20, 100, 70);
  Grap.set_color(0xFF00);
  Grap.draw_string("End game?", 30, 30);
  Grap.set_color(0xFFFFFF);
  Grap.draw_string("[1]    Yes", 45, 50);
  Grap.draw_string("[any] No", 45, 70);
  Canv.refresh();
  r = get_response();
  if (r == KEY_1) ret = false;
  ret;
}

def about(Canv: Canvas, Grap: Graphics) {
  var d: Any;
  Grap.set_color(0x000099);
  Grap.fill_rect(20, 20, 190, 75);
  Grap.set_color(0xFF00);
  Grap.draw_string("About:", 30, 30);
  Grap.set_color(0xFFFFFF);
  Grap.draw_string("Kyle Alexander Buan", 30, 50);
  Grap.draw_string("October 27, 2012", 30, 70);
  Canv.refresh();
  d = get_response();
}

def draw(can: Canvas, gra: Graphics, b: Ball, up: HoriPad, dn: HoriPad, lt: VertPad, rt: VertPad, liv: Int, score: Int) {
  gra.set_color(0);
  gra.fill_rect(0, 0, can.get_width(), can.get_height());
  b.draw(gra);
  var spd = ((abs(b.dx)+abs(b.dy))/2.0).tostr();
  var spdlen: Int;
  if (spd.len() < 4) spdlen = spd.len(); else spdlen = 4;
  gra.draw_string("Speed: " + spd.substr(0, spdlen), 0, can.get_height()-font_height(0))
  up.draw(gra);
  dn.draw(gra);
  lt.draw(gra);
  rt.draw(gra);
  gra.draw_string(liv.tostr(), can.get_width()-str_width(0, "9"), 0);
  gra.draw_string(score.tostr(), 0, 0);
  sleep(10);
  can.refresh();
}

def in_game(Canv: Canvas, Grap: Graphics, b: Ball, u: HoriPad, d: HoriPad, l: VertPad, r: VertPad) {
  var e: UIEvent;
  var cont: Bool = true;
  var lives: Int = 3;
  var sco: Int = 0;
  draw(Canv, Grap, b, u, d, l, r, lives, sco);
  b.init(Canv, Grap)
  while (cont) {
    e = ui_read_event();
    if (e != null) {
      if (e.value == KEY_4 || e.value == KEY_NOKIA_LEFT) {
        if (e.kind == EV_KEY) {
          u.m = -3;
          d.m = -3;
        } else if (e.kind == EV_KEY_RELEASE) {
          u.m = 0;
          d.m = 0;
        }
      }
      else if (e.value == KEY_6 || e.value == KEY_NOKIA_RIGHT) {
        if (e.kind == EV_KEY) {
          u.m = 3;
          d.m = 3;
        } else if (e.kind == EV_KEY_RELEASE) {
          u.m = 0;
          d.m = 0;
        }
      }
      else if (e.value == KEY_2 || e.value == KEY_NOKIA_UP) {
        if (e.kind == EV_KEY) {
          l.m = -3;
          r.m = -3;
        } else if (e.kind == EV_KEY_RELEASE) {
          l.m = 0;
          r.m = 0;
        }
      }
      else if (e.value == KEY_8 || e.value == KEY_NOKIA_DOWN) {
        if (e.kind == EV_KEY) {
          l.m = 3;
          r.m = 3;
        } else if (e.kind == EV_KEY_RELEASE) {
          l.m = 0;
          r.m = 0;
        }
      }
      else if (e.value == KEY_3) {
        cont=exit(Canv, Grap);
      }
    }
    if (b.move(u, l, Canv)) sco += 100 + (abs(b.dx) + abs(b.dy))/2.0*10;
    u.move(Canv);
    d.move(Canv);
    l.move(Canv);
    r.move(Canv);
    draw(Canv, Grap, b, u, d, l, r, lives, sco);
    if (b.x < -10 || b.x > Canv.get_width() || b.y < -10 || b.y > Canv.get_height()) {
      lives -= 1;
      Grap.set_color(0x000055);
      Grap.fill_rect(20, 20, 100, 70);
      Grap.set_color(0xFF00);
      Grap.draw_string("It slipped!", 30, 30);
      Grap.set_color(0xFFFFFF);
      Grap.draw_string("Lives:", 45, 50);
      Grap.draw_string(lives.tostr(), 45, 70);
      sleep(2000);
      Canv.refresh()
      if (lives < 0) cont = false;
      b.init(Canv, Grap)
      }
  }
}

def main(args: [String]) {
  var Canv = new_canvas(false);
  ui_set_screen(Canv);
  Canv.set_title("ZERO Pong");
  var Grap = Canv.graphics();
  var e: UIEvent;
  var continue: Bool = true;
  var b = new Ball(128, 128, 0, 0, 10);
  var reply: Int;
  var l = new VertPad(5, Canv.get_height()/2-20, 0);
  var r = new VertPad(Canv.get_width()-10, Canv.get_height()/2-20, 0);
  var u = new HoriPad(Canv.get_width()/2-20, 15, 0);
  var d = new HoriPad(Canv.get_width()/2-20, Canv.get_height()-25, 0);
  while (continue) {
    Grap.set_color(0)
    Grap.fill_rect(0, 0, Canv.get_width(), Canv.get_height());
    Grap.set_color(0x550000);
    Grap.fill_rect(20, 20, 120, 90);
    Grap.set_color(0xFF00);
    Grap.draw_string("ZERO Pong!", 30, 30);
    Grap.set_color(0xFFFFFF);
    Grap.draw_string("[1] Start", 45, 50);
    Grap.draw_string("[2] About", 45, 70);
    Grap.draw_string("[3] Exit", 45, 90);
    Canv.refresh()
    reply = get_response();
    if (reply==KEY_1) in_game(Canv, Grap, b, u, d, l, r);
    if (reply==KEY_2) about(Canv, Grap);
    if (reply==KEY_3) continue = exit(Canv, Grap);
  }
}