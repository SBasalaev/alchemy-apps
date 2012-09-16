use "stdscreens"

def abt(sca: Screen)
{
  var scr = new_textbox("funchelp_1.0\n  A dictionary like programme to help programmer in alchemy os \n Developer :Ashish yadav\n ")
  var back = new_menu("back", 1)
  screen_add_menu(scr, back)
  ui_set_screen(scr)
  var evv: Menu
  while (evv != back) {
    var ev = ui_wait_event()
    evv = cast(Menu)ev.value
  }
  ui_set_screen(sca)
}