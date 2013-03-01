// (c) 2013 Kyle Alexander Buan
// This program aims to convert (true-color)
//     images to TECHNICALLY ACCURATE
//     images that old-school computers were
//     capable of producing.
// Computers planned to be supported are:
//     [   ] ZX Spectrum
//     [x!] NES
//     [   ] SMS
//     [   ] Sega Genesis
// JUST FOR FUN! :)

// Feb 19 2013 - Kyle Alexander Buan
// THIS PRGRAM IS STILL IN ALPHA DEVELOPMENT.
// PLEASE USE 240X240 IMAGES ONLY

use "io"
use "textio"
use "ui"
use "canvas"
use "image"
use "stdscreens"

use "defs.eh"
use "image_extras.e"
use "color_math.e"
use "initializer.e"

const version = "B2B v0.1.28"

def get_image_wh() {
   i = 0
   j = 0
   var b = false
   while (!b) {
      try {
         img.get_pix_color(i, 0)
         i += 1 }
      catch {
         b = true } }
   b = false
   while (!b) {
      try {
         img.get_pix_color(0, j)
         j += 1 }
      catch {
         b = true } }
   img_x = i
   img_y = j
   println(img_x)
   println(img_y) }

def msg(m: String) {
   canv_graph.set_color(0)
   canv_graph.fill_rect(0, 0, 240, 19)
   canv_graph.set_color(0xFF)
   canv_graph.draw_string(m, 0, 0)
   canv_graph.set_color(0xFF<<8)
   canv_graph.set_font(8)
   canv_graph.draw_string(version, 240-str_width(8, version), 0)
   canv_graph.set_font(0)
   canv.refresh() }

def gen_scr_pal() {
   var c: Color = new Color {r=0, g=0, b=0}
   scr_pal_votes.fill(sys_pal_size, 0)
   for (pix_y=0, pix_y<img_y, pix_y+=accuracy) {
      for (pix_x=0, pix_x<img_x,  pix_x+=accuracy) {
         c = img.get_pix_color(pix_x, pix_y)
         scr_pal_votes.increment(c.closest(sys_pal), 1) }
      msg("1: "+pix_y.tostr()+"/"+img_y.tostr()) }
   scr_pal = top_votes(scr_pal_votes, sys_pal, scr_pal_size)
   // Screen palette display
   canv_graph.set_color(0x30)
   canv_graph.fill_rect(0, 0, 240, 241)
   j=1
   h=290
   for (i=0,i<scr_pal_size, i+=1) {
      canv_graph.set_color((cast(Color)scr_pal[i]).rgb())
      canv_graph.fill_rect(j, h, 10, 10)
      j+=10
      if (j>230) {
         j=1
         h+=10 } } }

def gen_paper_color() {
   zx_paper_votes = new_list()
   var c: Color = new Color {r=0, g=0, b=0}
   zx_paper_votes.fill(sys_pal_size, 0)
   for (pix_y=0, pix_y<img_y, pix_y+=accuracy) {
      for (pix_x=0, pix_x<img_x,  pix_x+=accuracy) {
         c = img.get_pix_color(pix_x, pix_y)
         zx_paper_votes.increment(c.closest(sys_pal), 1) }
      msg("1: "+pix_y.tostr()+"/"+img_y.tostr()) }
   zx_paper_color = sys_pal[zx_paper_votes.highest()]
   // Screen palette display
   canv_graph.set_color(0x30)
   canv_graph.fill_rect(0, 0, 240, 241)
   j=1
   h=291
   for (i=0,i<sys_pal_size, i+=1) {
      canv_graph.set_color((cast(Color)sys_pal[i]).rgb())
      canv_graph.fill_rect(j, h, 10, 10)
      j+=10
      if (j>230) {
         j=1
         h+=10 } } }

def gen_tile_pal(tile_x: Int, tile_y: Int) {
   var c: Color = new Color {r=0, g=0, b=0}
   tile_pal_votes.fill(scr_pal_size, 0)
   for (pix_y=tile_y*tile_size, pix_y<(tile_y*tile_size+tile_size), pix_y+=1) {
      for (pix_x=tile_x*tile_size, pix_x<(tile_x*tile_size+tile_size),  pix_x+=1) {
         c = img.get_pix_color(pix_x, pix_y)
         tile_pal_votes.increment(c.closest(scr_pal), 1) } }
   tile_pal = top_votes(tile_pal_votes, scr_pal, tile_pal_size)
   if (tile_pal.len() == 1) tile_pal.add(new Color {r=0, g=0, b=0})
   if (tile_pal.len() == 2) tile_pal.add(new Color {r=0, g=0, b=0})
   // Tile pallette display
   for (i=0, i<tile_pal_size, i+=1) {
      canv_graph.set_color((cast(Color)tile_pal[i]).rgb())
      canv_graph.fill_rect(i*20+1, 311, 20, 10) } }

def gen_tile_color(tile_x: Int, tile_y: Int) {
   tile_pal = new_list()
   tile_color_votes = new_list()
   var c: Color = new Color {r=0, g=0, b=0}
   tile_color_votes.fill(sys_pal_size, 0)
   for (pix_y=tile_y*tile_size, pix_y<(tile_y*tile_size+tile_size), pix_y+=1) {
      for (pix_x=tile_x*tile_size, pix_x<(tile_x*tile_size+tile_size),  pix_x+=1) {
         c = img.get_pix_color(pix_x, pix_y)
         tile_color_votes.increment(c.closest(sys_pal), 1) } }
   tile_pal.add(sys_pal[tile_color_votes.highest()])
   tile_pal.add(zx_paper_color)
   // Tile pallette display
   for (i=0, i<tile_pal_size, i+=1) {
      canv_graph.set_color((cast(Color)tile_pal[i]).rgb())
      canv_graph.fill_rect(i*20+1, 311, 20, 10) } }

def proc_tile(): Image {
   var res = new_image(tile_size, tile_size)
   var cl: Color
   var res_graph = res.graphics()
   for (pix_y=tile_y*tile_size, pix_y<(tile_y*tile_size+tile_size), pix_y+=1) {
      for (pix_x=tile_x*tile_size, pix_x<(tile_x*tile_size+tile_size),  pix_x+=1) {
         k = img.get_pix_color(pix_x, pix_y)
         cl = tile_pal[k.closest(tile_pal)]
         res_graph.set_color(cl.rgb())
         res_graph.draw_line(pix_x%tile_size, pix_y%tile_size, pix_x%tile_size, pix_y%tile_size) } }
   res }

def about() {
   var old = ui_get_screen()
   ui_set_screen(about_scr)
   ui_wait_event()
   ui_set_screen(old) }

def go() {
    accuracy = gauAcc.get_value() + 1
    var systems=["zx", "nes", "nes_mmc5", "sms"]
    var system: String = systems[radSystem.get_index()]
    load_specs(system)
    ui_set_screen(canv)
    // display sys pal
    i=0
    j=20
    for (h=0, h<sys_pal_size, h+=1) {
       canv_graph.set_color((cast(Color)sys_pal[h]).rgb())
       canv_graph.fill_rect(i, j, 20, 20)
       i+=21
       if (i>210) {
          i=0
          j+=21 } }
    canv.refresh()
    img = image_from_file(txtFile.get_text())
    get_image_wh()
    // ---   NES MODE   ---
    if (system=="nes" || system=="nes_mmc5") {
       gen_scr_pal()
       msg("Processing...")
       for (tile_y=0, tile_y<img_y/tile_size, tile_y+=1) {
          for (tile_x=0, tile_x<img_x/tile_size, tile_x+=1) {
             gen_tile_pal(tile_x, tile_y)
             canv_graph.draw_image(proc_tile(), tile_x*tile_size, tile_y*tile_size+20)
             msg(tile_y.tostr()+"/"+(img_y/tile_size).tostr()) } } }
    // ---   SMS MODE   ---
    else if (system=="sms") {
      gen_scr_pal()
      msg("Processing...")
      tile_pal = scr_pal
      for (tile_y=0, tile_y<img_y/tile_size, tile_y+=1) {
         for (tile_x=0, tile_x<img_x/tile_size, tile_x+=1) {
            canv_graph.draw_image(proc_tile(), tile_x*tile_size, tile_y*tile_size+20)
            msg(tile_y.tostr()+"/"+(img_y/tile_size).tostr()) } } }
   // ---   ZX SPECTRUM MODE ---
   else if (system=="zx") {
      gen_paper_color()
      msg("Processing...")
      for (tile_y=0, tile_y<img_y/tile_size, tile_y+=1) {
         for (tile_x=0, tile_x<img_x/tile_size, tile_x+=1) {
            gen_tile_color(tile_x, tile_y)
            canv_graph.draw_image(proc_tile(), tile_x*tile_size, tile_y*tile_size+20)
            msg(tile_y.tostr()+"/"+(img_y/tile_size).tostr()) } } }
   canv_graph.set_color(0)
   canv_graph.fill_rect(0, 300, 240, 20)
   canv_graph.set_color(0xFF<<8)
   canv_graph.draw_string(txtCaption.get_text(), 0, 300)
   msg(txtFile.get_text())
   ev = ui_wait_event()
   while (ev.kind != EV_MENU) ev= ui_wait_event()
   ui_set_screen(main_menu) }

def main(args: [String]) {
    ui_set_app_title("Back2Bbasics")
    initialize_vars()
    load_ui()
    ui_set_screen(main_menu)
    ev = ui_wait_event()
    while (ev.value != mnuExit) {
       if (ev.value == mnuOK) go()
       if (ev.value == mnuAbout) about()
       ev = ui_wait_event() } }