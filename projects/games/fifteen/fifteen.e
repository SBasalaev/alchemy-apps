/* Fifteen game.
 * Version 1.0.1
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "ui.eh"
use "canvas.eh"
use "stdscreens.eh"
use "graphics.eh"
use "font.eh"
use "rnd.eh"

const BLACK = 0x000000
const WHITE = 0xffffff
const GREY  = 0x808080

def solvable(state: [Byte]): Bool {
  var sum = 1
  for (var i=0, i<16, i += 1) {
    if (state[i] == 0) {
      sum = sum + i%4
    } else for (var j=i+1, j<16, j += 1) {
      if (state[j] != 0 && state[j] < state[i])
        sum += 1
    }
  }
  sum % 2 == 0
}

def solved(state: [Byte]): Bool {
  var result = true
  for (var i=0, i<15 && result, i+=1)
    result = state[i] == i+1
  result
}

def main(args: [String]) {
  var cnv = new Canvas(false)
  var g = cnv.graphics()
  cnv.title = "Fifteen"
  var mclose = new_menu("Close", 1)
  cnv.add_menu(mclose)
  
  var w = cnv.width / 4
  {
    var h = cnv.height / 4
    if (w > h) w = h
  }
  // initialize game state
  var state = new [Byte](16)
  for (var n=1, n<16, n+=1) {
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
  while (state[pos] != 0) pos += 1
  // draw entire field
  for (var i=0, i<16, i+=1) {
    if (state[i] == 0) {
      g.color = GREY
      g.fill_rect(i%4*w, i/4*w, w, w)
    } else {
      g.color = BLACK
      g.fill_rect(i%4*w, i/4*w, w, w)
      g.color = WHITE
      g.fill_rect(i%4*w+2, i/4*w+2, w-4, w-4)
      g.color = BLACK
      var ofsx = w/2 - str_width(0, state[i].tostr())
      var ofsy = w/2 - font_height(0)
      g.draw_string(state[i].tostr(),  i%4*w+ofsx, i/4*w+ofsy)
    }
  }
  g.color = GREY
  cnv.refresh()
  // main cycle
  ui_set_screen(cnv)
  var e = ui_wait_event()
  while (e.value != mclose) {
    if (e.kind == EV_KEY) {
      var action = cnv.action_code(e.value.cast(Int))
      if (action == DOWN && pos > 3) {
        g.copy_area(pos%4*w, (pos/4-1)*w, w, w, pos%4*w, pos/4*w)
        state[pos] = state[pos-4]
        pos = pos-4
        state[pos] = 0
        g.fill_rect(pos%4*w, pos/4*w, w, w)
        cnv.refresh()
      } else if (action == UP && pos < 12) {
        g.copy_area(pos%4*w, (pos/4+1)*w, w, w, pos%4*w, pos/4*w)
        state[pos] = state[pos+4]
        pos = pos+4
        state[pos] = 0
        g.fill_rect(pos%4*w, pos/4*w, w, w)
        cnv.refresh()
      } else if (action == RIGHT && pos%4 != 0) {
        g.copy_area((pos%4-1)*w, pos/4*w, w, w, pos%4*w, pos/4*w)
        state[pos] = state[pos-1]
        pos = pos-1
        state[pos] = 0
        g.fill_rect(pos%4*w, pos/4*w, w, w)
        cnv.refresh()
      } else if (action == LEFT && pos%4 != 3) {
        g.copy_area((pos%4+1)*w, pos/4*w, w, w, pos%4*w, pos/4*w)
        state[pos] = state[pos+1]
        pos = pos+1
        state[pos] = 0
        g.fill_rect(pos%4*w, pos/4*w, w, w)
        cnv.refresh()
      }
      if (solved(state)) {
        var box = new MsgBox("Congratulations, you have won!")
        box.title = "Fifteen"
        box.add_menu(mclose)
        ui_set_screen(box)
      }
    }
    e = ui_wait_event()
  }
}
