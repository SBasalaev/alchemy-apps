def Edit_line()
{
    var eb = new EditBox(0)
    eb.set_title(title+"("+tsp+")")
    eb.set_text(list.get(tsp).tostr())
    var sav = new_menu("Save",1)
    var cancel = new_menu("Cancel",2)
    eb.add_menu(sav)
    eb.add_menu(cancel)
    ui_set_screen(eb)
    var ok = true
    while(ok)
    {
     var event = ui_wait_event()
     if(event.value == sav)
     {
      list.set(tsp,eb.get_text())
      ok = false
      Draw_text()
      ui_set_screen(c)
     }else if(event.value == cancel)
     {
      ok = false
      ui_set_screen(c)
     }
    }
}

def Insert_line()
{
 list.insert(tsp," ")
 listlen = list.len()
 Draw_text()
}

def Delete_line()
{
 list.remove(tsp)
 listlen = list.len()
 if(tsp>=listlen&&listlen!=0)tsp=listlen-1
 else if(listlen==0)
 {
  list.add(" ")
  tsp=0
  listlen=1
 }
 Draw_text()
}

def Show_line(args0:String)
{
    var slc = new_canvas(true)
    var slg = slc.graphics()
    slg.set_font(font)
    var wid = wd-20
    var templist = Wrap_Text(args0,font,wid)
    var yp=23
    var tllen = templist.len()
    for(var i = 0,i < tllen,i+=1)
    {
     slg.draw_string(templist[i],1,yp)
     yp+=25
    }
    slg.set_color(0xffff00)
    slg.fill_rect(0,ht-20,wd,20)
    draw_status_area(slg)
    slg.draw_string("# to go Back",0,ht-20)
    slc.refresh()
    ui_set_screen(slc)
    var ok = true
    while(ok)
    {
     var event = ui_wait_event()
     if(event.kind != EV_KEY_HOLD && (event.kind == EV_KEY || event.kind == EV_KEY_RELEASE) )
     {
      if(event.value.cast(Int) == '#')
      {
       templist = null
       slg = null
       slc = null
       ok = false
       ui_set_screen(c)
      }
     }
    }
}

def Move_line_up()
{
       tclipboard=list.get(tsp).tostr()
       list.set(tsp,list.get(tsp-1).tostr())
       list.set(tsp-1,tclipboard)
       tsp-=1
       Draw_text()
}

def Move_line_down()
{
       tclipboard=list.get(tsp).tostr()
       list.set(tsp,list.get(tsp+1).tostr())
       list.set(tsp+1,tclipboard)
       tsp+=1
       Draw_text()
}