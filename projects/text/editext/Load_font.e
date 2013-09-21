def Setting()
{
 var form =new Form()
 form.set_title("Settings")
 var fnsz = [SIZE_SMALL|STYLE_BOLD,SIZE_SMALL|STYLE_PLAIN,SIZE_SMALL|STYLE_ITALIC,SIZE_MED|STYLE_BOLD,SIZE_MED|STYLE_PLAIN,SIZE_MED|STYLE_ITALIC,SIZE_LARGE|STYLE_BOLD,SIZE_LARGE|STYLE_PLAIN,SIZE_LARGE|STYLE_ITALIC]
 var fnszs = ["SMALL BOLD","SMALL PLAIN","SMALL ITALIC","MED BOLD","MED PLAIN","MED ITALIC","LARGE BOLD","LARGE PLAIN","LARGE ITALIC"]
 var fsz =new PopupItem("Select Font Size & Style",fnszs)
 form.add(fsz)
 var sav = new_menu("Save",1)
 var cancel  =new_menu("cancel",2)
 form.add_menu(sav)
 form.add_menu(cancel)
 ui_set_screen(form)
 var ok = true
 while(ok)
 {
  var event = ui_wait_event()
  if(event.value==sav)
  {
   font = fnsz[fsz.get_index()]
   fnsz = null
   fsz = null
   form = null
   ok = false
   Draw_text()
   ui_set_screen(c)
  }else if(event.value==cancel)
  {
   fnsz = null
   fsz = null
   form = null
   ok = false
   ui_set_screen(c)
  }
 }
}
