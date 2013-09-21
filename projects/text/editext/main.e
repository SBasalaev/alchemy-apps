/*ex main.e -o text -lui*/
use "ui"
use "canvas"
use "graphics"
use "font"
use "io"
use "list"
use "builtin"
use "string"
use "textio"
use "stdscreens"
use "form"
use "time"

var wd:Int
var ht:Int
var tsp:Int
var list:List
var g:Graphics
var c:Canvas
var font:Int
var small_font:Int
var fontstyle:Int
var fontsize:Int
var x:Int
var listlen:Int
var done:Bool
var title:String
var exit:Menu
var save:Menu
var status:String
var clipboard:String
var tclipboard:String
var save_as:String

use "draw_status_area.e"
use "Wrap_Text.e"
use "Draw_text.e"
use "edit_line.e"
use "Save_file.e"
use "Set_font.e"
use "Read_file.e"
use "Draw_menu.e"
use "Load_font.e"
use "File_browser.e"

def main(args: [String])
{
if(args.len!=0)
{
if(exists(args[0]))
{
 println("Loading : "+args[0])
 var stime = systime()
 var lindx = args[0].lindexof('/')
 if(lindx!=-1) title=args[0].substr(lindx+1,args[0].len())
 else title = args[0]
 save_as=args[0]
 fontstyle=STYLE_PLAIN
 fontsize=SIZE_MED
 font=fontstyle|fontsize
 Read_file(args[0])
 c=new_canvas(true)
 c.set_title(args[0])
 ui_set_screen(c)
 exit = new_menu("Exit",16)
 save = new_menu("Save File [0]",14)
 var edit = new_menu("Edit Line [5]",2)
 var insert = new_menu("New Line [7]",3)
 var delete = new_menu("Delete Line [8]",4)
 var reload = new_menu("Reload File [9]",13)
 var help = new_menu("Help",15)
 var gotoline = new_menu("Goto Line",1)
 var viewline = new_menu("View Line [#]",5)
 var mlup = new_menu("Move Line Up [4]",6)
 var mldn = new_menu("Move Line Down [6]",7)
 var fontset = new_menu("Settings [*]",12)
 var filebrows = new_menu("Select File",11)
 c.add_menu(filebrows)
 c.add_menu(fontset)
 c.add_menu(mlup)
 c.add_menu(mldn)
 c.add_menu(viewline)
 c.add_menu(gotoline)
 c.add_menu(help)
 c.add_menu(reload)
 c.add_menu(insert)
 c.add_menu(delete)
 c.add_menu(exit)
 c.add_menu(edit)
 c.add_menu(save)
 wd=c.get_width()
 ht=c.get_height()
 g=c.graphics()
 Draw_menu()
 tsp=0
 x=0
 Draw_text()
 println("Time : "+((systime()-stime)/1000)+" sec")
 stime=null
 done = true
 var key=0
 var ev : UIEvent
 while(done)
 {
  ev = ui_wait_event()
  if((ev.kind==EV_KEY||ev.kind==EV_KEY_HOLD)&&listlen>0)
  {
   key = ev.value.cast(Int)
   if(key!=0)
   {
    var actcode = c.action_code(key)
    if(ev.kind==EV_KEY)
    {
     if(actcode==LEFT&&key!='4')
     {
       if(x<0)
       {
        x+=25
        Draw_text()
       }
     }else if(actcode==RIGHT&&key!='6')
     {
       x-=25
       Draw_text()
     }else if(key=='#')
     {
      Show_line(list.get(tsp).tostr())
     }else if(actcode==UP&&key!='2')
     {
       if(tsp-1>=0)
       {
        tsp-=1
        Draw_text()
       }else
       {
        tsp=listlen-1
        Draw_text()
       }
     }else if(actcode==DOWN&&key!='8')
     {
       if(tsp+1<listlen)
       {
        tsp+=1
        Draw_text()
       }else
       {
        tsp=0
        Draw_text()
       }
     }else if(key=='1')
     {
      clipboard=list.get(tsp).tostr() 
     }else if(key=='2'&&clipboard!=null)
     {
      list.insert(tsp,clipboard)
      listlen=list.len()
      Draw_text()
     }else if(key=='3'&&clipboard!=null)
     {
      list.set(tsp,clipboard)
      Draw_text()
     }else if(key=='4')
     {
      if(tsp>0)
      {
	 Move_line_up()
      }
     }else if(key=='5')
     {
	 Edit_line()
     }else if(key=='6')
     {
      if(tsp<listlen-1)
      {
       Move_line_down()
      }
     }else if(key=='*')
     {
      Setting()
     }else if(key=='0')
     {
      Save_file(save_as)
     }else if(key=='7')
     {
      Insert_line()
     }else if(key=='8')
     {
      if(listlen>0)
      {
       Delete_line()
      }
     }else if(key=='9')
     {
      Reload_file(save_as)
     }
    }else if(ev.kind==EV_KEY_HOLD)
    {
     if(actcode==LEFT&&key!='4')
     {
       if(x<0)
       {
        x+=100
        if(x>0)x=0
        Draw_text()
       }
     }else if(actcode==RIGHT&&key!='6')
     {
       x-=100
       Draw_text()
     }else if(actcode==UP&&key!='2')
     {
      if(tsp-11>=0)
      {
       tsp-=11
       Draw_text()
      }
     }else if(actcode==DOWN&&key!='8')
     {
      if(tsp+11<listlen)
      {
       tsp+=11
       Draw_text()
      }
     }else if(key=='7')
     {
      Insert_line()
     }else if(key=='8')
     {
      if(listlen>0)
      {
       Delete_line()
      }
     }else if(key=='4')
     {
      if(tsp>0)
      {
	 Move_line_up()
      }
     }else if(key=='6')
     {
      if(tsp<listlen-1)
      {
       Move_line_down()
      }
     }
    }
    key=0
   }
  }else if(ev.kind==EV_MENU)
  {
   var menu =ev.value.cast(Menu)
   if(menu==exit)
   {
    done = false
   }else if(menu==filebrows)
   {
    File_browser("/")
 
   }else if(menu==fontset)
   {
    Setting()
   }else if(menu==mlup)
   {
     if(tsp>0) Move_line_up()
   }else if(menu==mldn)
   {
     if(tsp<listlen-1) Move_line_down()
   }else if(menu==edit)
   {
    Edit_line()
   }else if(menu==save)
   {
      Save_file(save_as)
   }else if(menu==insert)
   {
    Insert_line()
   }else if(menu==delete)
   {
    if(listlen>0)
    {
     Delete_line()
    }
   }else if(menu==reload)
   {
    Reload_file(save_as)
   }else if(menu==help)
   {
    var hc = new_canvas(true)
    var back = new_menu("Back",1)
    hc.add_menu(back)
    var hg = hc.graphics()
    hg.set_font(font)
    var shortcuts = ["1 : Copy Line","2 : Paste Line","3 : Paste & Replace Line","4 : Move Line up","5 : Edit","6 : Move Line Down","7 : New Line","8 : Delete Line","9 : Reload File","* : Font Settings","0 : Save File","# : View Line"]
    var yp=0
    for(var i = 0,i<shortcuts.len,i+=1)
    {
     hg.draw_string(shortcuts[i],0,yp)
     yp+=25
    }
    hg.set_color(0xffff00)
    hg.fill_rect(0,ht-20,wd,20)
    hg.set_color(0)
    hg.draw_string("Menu",0,ht-25)
    hc.refresh()
    ui_set_screen(hc)
    var ok = true
    while(ok)
    {
     var event = ui_wait_event()
     if(event.value == back)
     {
      back = null
      shortcuts = null
      hg = null
      hc = null
      ok = false
      ui_set_screen(c)
     }
    }
   }else if(menu == viewline)
   {
    Show_line(list.get(tsp).tostr())
   }else if(menu == gotoline)
   {
    var eb = new EditBox(2)
    eb.set_text(""+(tsp+1))
    eb.set_title("0 < Enter Line Number <="+(listlen))
    var sav = new_menu("Show",1)
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
     try{
      var ebtext = eb.get_text()
      if(ebtext!=null)
      {
       var ebtextint =  ebtext.toint()
       if((ebtextint > 0 ) && (ebtextint <=listlen))
       {
        tsp = ebtextint-1
        Draw_text()
       }
      }
      }catch{}
      ok = false
      ui_set_screen(c)
      eb = null
     }else if(event.value == cancel)
     {
      ok = false
      ui_set_screen(c)
      eb = null
     }
    }
   }
  }
 }
}else println("\""+args[0]+"\" does not exists?\n Enter valid file path ?")
}else println("Enter valid file path ?")
}
