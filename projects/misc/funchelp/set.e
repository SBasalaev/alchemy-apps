use"stdscreens"

def set(scs: Screen)
{
  var scr = new_form()
  var ok = new_menu("ok", 1)
  scr.add_menu(ok)
  var ri = new_radioitem("mode", new [String]{"function","header"})
  var txt = "Choose a option here or you can use shortcut to change mode\n 1-type '1' in input field for function mode\n2-type '2' for header mode\n 00-type '00' to quite\n Header mode: search for matching headers, if there is only one result,shows full text of that header,for example just type 'm' to see text of 'math.eh'"
  var ti = new_textitem("info", txt)
  scr.add(ri)
  scr.add(ti)
  ui_set_screen(scr)
  var evv: Menu
  while (evv != ok) {
    var ev = ui_wait_event()
    evv = cast(Menu)ev.value
  }
  var i = ri.get_index()
  cntrl = i+1
  ui_set_screen(scs)
}