// variable initializer

use "textio"
use "list"
use "canvas"
use "ui"
use "string"

use "defs"

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
   gauAcc = new_gaugeitem("Accuracy (0=best):", 20, 5)
   radSystem = new_radioitem("System emulation:", ["ZX Spectrum", "NES", "NES (with MMC5)", "Sega Master System"])
   txtCaption = new_edititem("Caption:", "", 0, 100)
   canv = new_canvas(true)
   mnuOK = new_menu("OK", 0)
   mnuAbout = new_menu("About",1)
   mnuExit = new_menu("Exit", 2)
   main_menu = new_form()
   main_menu.set_title("Back2Basics")
   main_menu.add_menu(mnuOK)
   main_menu.add_menu(mnuAbout)
   main_menu.add_menu(mnuExit)
   main_menu.add(txtFile)
   main_menu.add(radSystem)
   main_menu.add(gauAcc)
   main_menu.add(txtCaption)   
   ui_set_screen(canv)
   canv.add_menu(new_menu("Exit", 0))
   canv_graph = canv.graphics()
   canv_graph.set_color(0)
   canv_graph.fill_rect(0, 0, 240, 320) }

def load_specs(c: String) {
   var m: [String]
   var s = utfreader(fopen_r("/res/b2b/"+c+".conf"))
   tile_size = s.readline().toint()
   sys_pal_size = s.readline().toint()
   scr_pal_size = s.readline().toint()
   tile_pal_size = s.readline().toint()
   for (i=0, i<sys_pal_size, i+=1) {
      m = s.readline().split(',')
      k = new Color {r=m[0].toint(), g=m[1].toint(), b=m[2].toint() }
      sys_pal.add(k) } 
   s.close()}