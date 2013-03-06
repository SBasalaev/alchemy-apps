// variable initializer

use "textio"
use "list"
use "canvas"
use "ui"
use "string"

use "defs"

const version = "B2B v0.1.33"

def initialize_vars() {
   sys_pal = new_list()
   sys_pal_votes = new_list()
   scr_pal = new_list()
   scr_pal_votes = new_list()
   tile_pal = new_list()
   tile_pal_votes = new_list()
   zx_paper_votes = new_list()
   tile_color_votes = new_list() }

def load_ui() {
   txtFile = new_edititem("File URI:", "/home/", 0, 100)
   gauAcc = new_gaugeitem("Accuracy (0=best):", 20, 4)
   radSystem = new_radioitem("System emulation:", ["ZX Spectrum", "NES", "NES (with MMC5)", "Sega Master System", "Custom"])
   txtCaption = new_edititem("Caption:", "", 0, 100)
   chkDither = new_checkitem("Dithering", "Activated", true)
   canv = new_canvas(true)
   mnuAdd = new_menu("Add color", 1)
   mnuRemove = new_menu("Remove color", 2)
   mnuOK = new_menu("OK", 0)
   mnuAbout = new_menu("About",1)
   mnuExit = new_menu("Exit", 2)
   main_menu = new_form()
   main_menu.set_title("Back2Basics")
   main_menu.add_menu(mnuExit)
   main_menu.add_menu(mnuOK)
   main_menu.add_menu(mnuAbout)
   main_menu.add(txtFile)
   main_menu.add(radSystem)
   main_menu.add(gauAcc)
   main_menu.add(chkDither)
   main_menu.add(txtCaption)   
   canv.add_menu(mnuOK)
   canv.add_menu(mnuAdd)
   canv.add_menu(mnuRemove)
   ui_set_screen(canv)
   canv_graph = canv.graphics()
   canv_graph.set_color(0)
   canv_graph.fill_rect(0, 0, 240, 320) }

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

def load_specs(c: String) {
   if (c!="custom") {
      var m: [String]
      var s = utfreader(fopen_r("/res/b2b/"+c+".conf"))
      tile_size_x = s.readline().toint()
      tile_size_y = s.readline().toint()
      sys_pal_size = s.readline().toint()
      scr_pal_size = s.readline().toint()
      tile_pal_size = s.readline().toint()
      for (i=0, i<sys_pal_size, i+=1) {
         m = s.readline().split(',')
         k = new Color {r=m[0].toint(), g=m[1].toint(), b=m[2].toint() }
         sys_pal.add(k) }
       s.close() }
   else {
      var colc = new_form()
      var txtRed = new_edititem("Red", "", 2, 3)
      var txtGreen = new_edititem("Green", "", 2, 3)
      var txtBlue = new_edititem("Blue", "", 2, 3)
      colc.add(txtRed)
      colc.add(txtGreen)
      colc.add(txtBlue)
      colc.add_menu(mnuOK)
      ui_set_screen(canv)
      msg("Add colors")
      var cont = true
      while (cont) {
         ev = ui_wait_event()
         if (ev.value == mnuOK) cont = false
         else if (ev.value == mnuAdd) {
            ui_set_screen(colc)
            ev = ui_wait_event()
            while (ev.kind != EV_MENU) ev = ui_wait_event()
            sys_pal.add(new Color {r=txtRed.get_text().toint(), g=txtGreen.get_text().toint(), b=txtBlue.get_text().toint() })
            ui_set_screen(canv) }
         else if (ev.value == mnuRemove) sys_pal.remove(sys_pal.len()-1)
         // display sys pal
         i=0
         j=20
         canv_graph.set_color(0)
         canv_graph.fill_rect(0, 20, 240, 320)
         for (h=0, h<sys_pal.len(), h+=1) {
            canv_graph.set_color((cast(Color)sys_pal[h]).rgb())
            canv_graph.fill_rect(i, j, 20, 20)
            i+=21
            if (i>210) {
               i=0
               j+=21 } }
         canv.refresh() }
      sys_pal_size = sys_pal.len()
      tile_size_x = 1
      tile_size_y = 1
      canv.remove_menu(mnuAdd)
      canv.remove_menu(mnuRemove)
      canv.add_menu(mnuExit) } }