use"stdscreens"

def set(scs: Screen)
{
  var scr = new_form()
  var ok = new_menu("ok", 1)
  screen_add_menu(scr, ok)
  var ri = new_radioitem("mode", new Array{"function","header"})
  var txt = "Choose a option here or you can use shortcut to change mode\n 1-type '1' in input field for function mode\n2-type '2' for header mode\n 00-type '00' to quite\n Header mode: search for matching headers, if there is only one result,shows full text of that header,for example just type 'm' to see text of 'math.eh'"
  var ti = new_textitem("info", txt)
  form_add(scr, ri)
  form_add(scr, ti)
  ui_set_screen(scr)
  var evv: Menu
  while (evv != ok) {
    var ev = ui_wait_event()
    evv = cast(Menu)ev.value
  }
  var i = radioitem_get_index(ri)
  cntrl = i+1
  ui_set_screen(scs)
}