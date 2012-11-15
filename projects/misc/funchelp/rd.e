def rd(ei: EditItem, scr: Screen)
{
  var evnt = ui_read_event()
  endtxt = ei.get_text()
  while (endtxt==srchtxt && evnt==null && n==1000) {
    evnt = ui_read_event()
    endtxt = ei.get_text()
  }
  if (evnt != null) {
    var ev = cast(Menu)evnt.value
    if (ev==me)
      cntrl=0
    if (ev==mab)
      abt(scr)
    if (ev==mst)
      set(scr)
  }
  if (endtxt=="00")
    cntrl=0
  if (endtxt=="2")
    cntrl=2
  if (endtxt=="1")
    cntrl=1
  if (cntrl==1)
    ei.set_label("function name")
  if(cntrl==2)
    ei.set_label("Header name")
}