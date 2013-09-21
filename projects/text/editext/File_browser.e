var fbg:Graphics
var fbc:Canvas
var filelist:[String]
var filelistlen:Int
var ht40:Int
var fh:Int
var clp:Int
var path:String
var maxht:Int

def Show_msg(msg:String,canvas:Canvas,graphics:Graphics)
{
 var msgs = Wrap_Text(msg,small_font,wd-30)
 graphics.set_color(0xffffff)
 graphics.fill_rect(0,fh,wd,ht40)
 graphics.set_color(0x00ff00)
 graphics.draw_rect(9,fh+2,wd-18,((msgs.len()+1)*fh))
 graphics.set_color(0xff0000)
 var yp = 23
 for(var i = 0,i<msgs.len(),i+=1)
 {
  graphics.draw_string(msgs[i],10,yp)
  yp += 20
 }
 canvas.refresh()
}

def get_files()
{
 filelist=flist(path)
 filelistlen=filelist.len
 fbg.set_color(0xffff00)
 fbg.fill_rect(0,0,wd,fh)
 fbg.set_color(0)
 var sppos=0
 var pathwidth=str_width(small_font,path)
 if(pathwidth>wd)sppos=wd-pathwidth
 fbg.draw_string(path,sppos,0)
}

def draw_files(j:Int)
{
 fbg.set_color(0xffffff)
 fbg.fill_rect(0,fh,wd,ht)
 fbg.set_color(0)
 var ypnt=fh+2
 for(var i=j,i<filelistlen && ypnt<maxht,i+=1)
 {
  fbg.draw_string(""+(i+1)+". "+filelist[i],0,ypnt)
  ypnt+=20
 }
 fbg.set_color(0xffff00)
 var htfh= ht-fh
 fbg.fill_rect(0,htfh,wd,fh)
 fbg.set_color(0)
 if(filelistlen>0)
 {
  fbg.draw_rect(0,fh+1,(str_width(small_font,""+(j+1)+". "+filelist[j])),fh-1)
 }
 fbg.draw_string("0=Select , #=cancel",10,htfh)
 fbc.refresh()
}

def String.is_folder():Bool
{
 if(this.endswith("/"))true
 else false
}

def File_browser(args0:String)
{
 fbc=new_canvas(true)
 fbc.set_title("File chooser")
 var openfolder = new_menu("Open [>]",1)
 var back = new_menu("Back [<]",2)
 var cancel = new_menu("Cancel [#]",4)
 var selectfile = new_menu("Select File [0]",3)
 fbc.add_menu(selectfile)
 fbc.add_menu(openfolder)
 fbc.add_menu(back)
 fbc.add_menu(cancel)
 fbg=fbc.graphics()
 fbg.set_font(small_font)
 fh = font_height(font)
 maxht=ht-fh
 clp=0
 path=args0
 ht40 = ht-40
 get_files()
 draw_files(clp)
 ui_set_screen(fbc)
 var ok=true
 var event:UIEvent
 var curntps=new [Int](50) 
 var crntps=0
 var ek:Bool
 var ekh:Bool
 var em:Bool
 var evci:Int
 var kp:Int
 while(ok)
 {
  ek=false
  ekh=false
  em=false
  kp=0
  event=ui_wait_event()
  if(event.kind==EV_KEY)ek=true
  else if(event.kind==EV_KEY_HOLD)ekh=true
  else if(event.kind==EV_MENU)em=true
  if(ek||ekh||em)
  {
   if(ek||ekh)
   {
    kp=fbc.action_code(event.value.cast(Int))
    evci=event.value.cast(Int)
   }
   else if(em)
   {
    if(event.value==openfolder)kp=RIGHT
    else if(event.value==back)kp=LEFT
    else if(event.value==cancel)evci='#'
    else if(event.value==selectfile)evci='0'
   }
   if(kp==RIGHT)
   {
     if(filelistlen>0)
     {
     path+=filelist[clp]
     if(exists(path))
     {
      if(path.is_folder())
      {
       curntps[crntps]=clp
       crntps+=1
       get_files()
       clp=0
       draw_files(clp)
      }
     }
     }
   }else if(kp==LEFT)
   {
     if(path!="/")
     {
      path = path.substr(0,path.lindexof('/'))
      path = path.substr(0,path.lindexof('/')+1)
      if(exists(path))
      {
       get_files()
       crntps-=1
       clp=curntps[crntps]
       draw_files(clp)
      }
     }
   }else if(kp==UP)
   {
    if(filelistlen>0)
    {
     clp-=1
     if(clp<0)clp=filelistlen-1
     draw_files(clp)
    }
   }else if(kp==DOWN)
   {
    if(filelistlen>0)
    {
     clp+=1
     if(clp>=filelistlen)clp=0
     draw_files(clp)
    }
   }else if(!ekh && evci=='#')
   {
    fbg=null
    fbc=null
    filelist=null
    ok=false
   }else if(!ekh && evci=='0')
   {
    var newfilename = path+filelist[clp]
    if(!newfilename.is_folder())
    {
     c.set_title(filelist[clp])
     Show_msg("Loading File : \""+filelist[clp]+"\", It may take some time depending on file size or number of lines. Please Wait...",fbc,fbg)
     save_as=newfilename
     Reload_file(newfilename)
     title = filelist[clp]
     draw_status_area(g)
     fbg=null
     fbc=null
     filelist=null
     ok=false
    }
   }
  }
 }
 ui_set_screen(c)
}
