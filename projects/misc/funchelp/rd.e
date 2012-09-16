def rd(ei: Item, scr: Screen)
{
  var evnt = ui_read_event()
  endtxt = edititem_get_text(ei)
  while (endtxt==srchtxt && evnt==null && n==1000) {
    evnt = ui_read_event()
    endtxt = edititem_get_text(ei)
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
    item_set_label(ei,"function name")
  if(cntrl==2)
    item_set_label(ei,"Header name")
}