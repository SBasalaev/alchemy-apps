/* Fifteen game.
 * Version 1.0
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "ui.eh"
use "canvas.eh"
use "stdscreens.eh"
use "graphics.eh"
use "rnd.eh"

const BLACK = 0x000000
const WHITE = 0xffffff
const GREY  = 0x808080

def solvable(state: BArray): Bool {
  var sum = 1
  for (var i=0, i<16, i=i+1) {
    if (state[i] == 0) {
      sum = sum + i%4
    } else for (var j=i+1, j<16, j=j+1) {
      if (state[j] != 0 && state[j] < state[i])
        sum = sum+1
    }
  }
  sum % 2 == 0
}

def solved(state: BArray): Bool {
  var result = true
  for (var i=0, i<15 && result, i=i+1)
    result = state[i] == i+1
  result
}

def main(args: Array) {
  var cnv = new_canvas(false)
  var g = canvas_graphics(cnv)
  screen_set_title(cnv, "Fifteen")
  var mclose = new_menu("Close", 1)
  screen_add_menu(cnv, mclose)
  
  var w = screen_width(cnv)/4
  {
    var h = screen_height(cnv)/4
    if (w > h) w = h
  }
  // initialize game state
  var state = new BArray(16)
  for (var n=1, n<16, n=n+1) {
    var pos = rnd(16)
    while (state[pos] != 0) pos = (pos+1)%16
    state[pos] = n
  }
  if (!solvable(state)) {
    if (state[14]*state[15] == 0) {
      var tmp = state[0]
      state[0] = state[1]
      state[1] = tmp
    } else {
      var tmp = state[14]
      state[14] = state[15]
      state[15] = tmp
    }
  }
  var pos = 0
  while (state[pos] != 0) pos = pos+1
  // draw entire field
  for (var i=0, i<16, i=i+1) {
    if (state[i] == 0) {
      set_color(g, GREY)
      fill_rect(g, i%4*w, i/4*w, w, w)
    } else {
      set_color(g, BLACK)
      fill_rect(g, i%4*w, i/4*w, w, w)
      set_color(g, WHITE)
      fill_rect(g, i%4*w+2, i/4*w+2, w-4, w-4)
      set_color(g, BLACK)
      var ofsx = w/2 - str_width(0, to_str(state[i]))
      var ofsy = w/2 - font_height(0)
      draw_string(g, to_str(state[i]),  i%4*w+ofsx, i/4*w+ofsy)
    }
  }
  set_color(g, GREY)
  canvas_refresh(cnv)
  // main cycle
  ui_set_screen(cnv)
  var e = ui_wait_event()
  while (e.value != mclose) {
    if (e.kind == EV_KEY) {
      if (e.value == '8' && pos > 3) {
        copy_area(g, pos%4*w, (pos/4-1)*w, w, w, pos%4*w, pos/4*w)
        state[pos] = state[pos-4]
        pos = pos-4
        state[pos] = 0
        fill_rect(g, pos%4*w, pos/4*w, w, w)
        canvas_refresh(cnv)
      } else if (e.value == '2' && pos < 12) {
        copy_area(g, pos%4*w, (pos/4+1)*w, w, w, pos%4*w, pos/4*w)
        state[pos] = state[pos+4]
        pos = pos+4
        state[pos] = 0
        fill_rect(g, pos%4*w, pos/4*w, w, w)
        canvas_refresh(cnv)
      } else if (e.value == '6' && pos%4 != 0) {
        copy_area(g, (pos%4-1)*w, pos/4*w, w, w, pos%4*w, pos/4*w)
        state[pos] = state[pos-1]
        pos = pos-1
        state[pos] = 0
        fill_rect(g, pos%4*w, pos/4*w, w, w)
        canvas_refresh(cnv)
      } else if (e.value == '4' && pos%4 != 3) {
        copy_area(g, (pos%4+1)*w, pos/4*w, w, w, pos%4*w, pos/4*w)
        state[pos] = state[pos+1]
        pos = pos+1
        state[pos] = 0
        fill_rect(g, pos%4*w, pos/4*w, w, w)
        canvas_refresh(cnv)
      }
      if (solved(state)) {
        var box = new_textbox("Congratulations, you have won!")
        screen_set_title(box, "Fifteen")
        screen_add_menu(box, mclose)
        ui_set_screen(box)
      }
    }
    e = ui_wait_event()
  }
}
