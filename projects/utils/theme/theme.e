
/*ex theme.e -o theme -lui -ldialog -lcolor -lmedia*/

use "canvas"
use "color"
use "dialog"
use "dataio"
use "font"
use "form"
use "graphics"
use "image"
use "io"
use "media"
use "stdscreens"
use "string"
use "sys"
use "textio"
use "ui"
use "time"

var currentPath:String
var options:ListBox
var c:Canvas
var g:Graphics
var old_position:Int
var new_position:Int
	//(old and new) position=
	//1=msg;2=contacts;3=calllog;4=settings;5=gallery
	//6=media;7=web;8=organiser;9=apps;10=ptt;11=sim
var new_icons:[String]
var final_icons:[String]
var final_icons_zip:[String]
var imagename:[String]
var addimg:Image
var records:[Int]
var records_count:Int
var memorycard:Bool
var backmenu:Menu
var theme_name:String

def Check_Drive()
{
 if(memorycard)
 {
  try
  {
   if(!exists("/tmp/memorycard")){mkdir("/tmp/memorycard")}
   exec_wait("mount",["/tmp/memorycard/","jsr75","E:/"])
   currentPath="/tmp/memorycard/"
  }catch{currentPath="/"}
 }
 else
 {
  currentPath="/"
 }
}

def Show_msbx(msg:String)
{
var msbx=new_msgbox(msg,null)
msbx.set_title("Please Wait...")
ui_set_screen(msbx)
}

def rodni_helper(x:Int,y:Int,imag:Image)//Remove_Old_Draw_New_Image_helper
{
g.fill_rect(x,y,64,64);g.draw_image(imag,x,y)
}

def Remove_Old_Draw_New_Image(imgname:Image)
{
 g.set_color(0xffffff)
 switch(old_position)
 {
 1:{rodni_helper(10,10,imgname)}
 2:{rodni_helper(84,10,imgname)}
 3:{rodni_helper(158,10,imgname)}
 4:{rodni_helper(10,84,imgname)}
 5:{rodni_helper(84,84,imgname)}
 6:{rodni_helper(158,84,imgname)}
 7:{rodni_helper(10,158,imgname)}
 8:{rodni_helper(84,158,imgname)}
 9:{rodni_helper(158,158,imgname)}
 10:{rodni_helper(10,232,imgname)}
 11:{rodni_helper(84,232,imgname)}
 }
 c.refresh()
}

def Draw_title(position:Int)
{
 var getfont=g.get_font()
 var title:String=null
 switch(position)
 {
  1:title=" Messages"
  2:title="  Contacts"
  3:title="   Call log"
  4:title="  Settings"
  5:title="   Gallery"
  6:title="   Media"
  7:title="     Web"
  8:title="Organizer"
  9:title="Applications"
  10:title="Push to Talk"
  11:title="    Sim"
 }
 g.set_color(0xffffff)
 g.fill_rect(75,300,110,20)
 g.set_font(SIZE_SMALL|STYLE_PLAIN)
 g.set_color(0xff0000)
 g.draw_string(title,80,300)
 g.set_font(getfont)
 g.set_color(0x000000)
}

def Drawrect(col:Int,position:Int)
{
g.set_color(col)
 switch(position)
 {
  1:{g.draw_rect(9,9,66,66)}
  2:{g.draw_rect(83,9,66,66)}
  3:{g.draw_rect(157,9,66,66)}
  4:{g.draw_rect(9,83,66,66)}
  5:{g.draw_rect(83,83,66,66)}
  6:{g.draw_rect(157,83,66,66)}
  7:{g.draw_rect(9,157,66,66)}
  8:{g.draw_rect(83,157,66,66)}
  9:{g.draw_rect(157,157,66,66)}
  10:{g.draw_rect(9,231,66,66)}
  11:{g.draw_rect(83,231,66,66)}
 }
}

def Switch_Action_Code(a_code:Int)
{
switch(a_code)
 {
 DOWN:
  {
   new_position=old_position+3
   if(new_position==12){new_position=3}
   else if(new_position==13){new_position=1}
   else if(new_position==14){new_position=2}
  }
 UP:
  {
   new_position=old_position-3
   if(new_position==0){new_position=9}
   else if(new_position==-1){new_position=11}
   else if(new_position==-2){new_position=10}
  }
 RIGHT:
  {
   new_position=old_position+1
   if(new_position>11){new_position=1}
  }
 LEFT:
  {
   new_position=old_position-1
   if(new_position<1){new_position=11}
  }
 }
 Drawrect(0xffffff,old_position)
 Drawrect(0xff0000,new_position)
 Draw_title(new_position)
}

//code written in next method is modified version of code written in indexed-b24
//now it returns only resize image
def load_and_resize_image(immgg: Image, width: Float, height: Float): Image
{
 var tempimg = immgg
 var x_size = get_image_x(tempimg)
 var y_size = get_image_y(tempimg)
 var img: Image
 var imgg: Graphics
 var x_step: Double = x_size / width
 var y_step: Double = y_size / height
 img = new Image(width,height)
 imgg = img.graphics()
 for (var j=0, j<y_size, j+=1)
 {
  for (var i=0, i<width, i+=1)
  {
   imgg.set_color(tempimg.get_pix(i*x_step, j*y_step, x_size, y_size).toint())
   imgg.draw_line(i, j, i, j)
  }
 }
 tempimg = null
 img
}

def drawimage_fromfile(i:Int,num:Int,x:Int,y:Int)
{
 var img=image_from_file(new_icons[num])
 if((get_image_x(img)<=64)&&(get_image_y(img)<=64))
 {
  g.draw_image(img,x,y)
 }
 else
 {
  g.draw_image(load_and_resize_image(img,64,64),x,y)
 }
 img=null
 imagename[i]=new_icons[num]
}

def fillrect_drawstring(num:Int,x:Int,y:Int,img:Image)
{
 var name=["","messag","contact","call log","setting","gallery","media","web","organiz","apps","ptt","sim"]
 g.set_color(0xffffff)
 g.fill_rect(x-1,y-1,65,65)
 g.set_color(0x0000ff)
 g.fill_rect(x,y,63,63)
 g.draw_image(img,x+24,y+24)
 g.set_color(0xffffff)
 g.draw_string(name[num],x,y)
}

def Init_canvas()
{
 c=new_canvas(true)
 g=c.graphics()
 g.set_font(SIZE_MED|STYLE_PLAIN)
}

def Select_icon_helper()
{
 var tempimagename=run_filechooser("Select image",currentPath,["*.jpg","*.jpeg","*.JPG","*.JPEG","*.bmp","*.BMP","*.png","*.PNG","*.gif","*.GIF"])
 if(tempimagename!=null)
 {
  imagename[old_position]=tempimagename
  var img=image_from_file(imagename[old_position])
  if((get_image_x(img)<=64)&&(get_image_y(img)<=64))
  {
   Remove_Old_Draw_New_Image(img)
   currentPath=imagename[old_position].substr(0,imagename[old_position].lindexof('/'))
  }
  else
  {
   Show_msbx("Resizing image to 64x64. Original image will not Change.")
   Remove_Old_Draw_New_Image(load_and_resize_image(img,64,64))
   currentPath=imagename[old_position].substr(0,imagename[old_position].lindexof('/'))
   ui_set_screen(c)
  }
  img=null
 }
}

def Draw_menu()
{
 var cl=g.get_color()
 g.set_color(0x000000)
 g.draw_string("Menu",0,300)
 g.draw_string("Menu",193,300)
 g.set_color(cl)
}

def Select_Icons(posn:Int)
{
 Init_canvas()
 var exit=new_menu("Cancel [#]",3,MT_CANCEL)
 var save=new_menu("Save [*]",2,MT_OK)
 var reset=new_menu("Reset icon",4)
 var resetall=new_menu("Reset all icons",5)
 var select =new_menu("Add icon [5]",1,MT_OK)
 c.add_menu(exit)
 c.add_menu(save)
 c.add_menu(reset)
 c.add_menu(resetall)
 c.add_menu(select)
 old_position=1
 Show_msbx("Generating preview of previously saved image/s (if any)")
 imagename=new [String](12)
 var px=11
 var py=11
 var j=posn
 for(var i=1,i<=11,i+=1)
 {
  if(new_icons[j]==null){addimg=image_from_file("/res/alpaca/installed.png");fillrect_drawstring(i,px,py,addimg);addimg=null}
  else {drawimage_fromfile(i,j,px,py)}
  px+=74
  if(i==3||i==6||i==9)
  {
   px=11
   py+=74
  }
  j+=1
 }
 px=null
 py=null
 g.set_color(0x000000)
 Draw_menu()
 g.draw_rect(9,9,66,66)
 Draw_title(old_position)
 c.set_title("Icon Chooser")
 c.refresh()
 ui_set_screen(c)
 var ev:UIEvent
 var act_code:Int
 do
 {
  ev=ui_wait_event()
  var k=0
  if(ev.kind==EV_KEY)
  {
   k=cast(Int)ev.value
   if(k!=0)
   {
    act_code=c.action_code(k)
    if(act_code==UP||act_code==DOWN||act_code==LEFT||act_code==RIGHT)
    {
     Switch_Action_Code(act_code)
     old_position=new_position
     c.refresh()
    }
    else if(act_code==FIRE)
    {
     Select_icon_helper()
    }
    else if(k==KEY_HASH)
    {
     ev.value=exit
    }
    else if(k==KEY_STAR)
    {
     ev.value=save
    }
   }
  }
  else if(ev.kind==EV_MENU)
  {
   if(ev.value==reset)
   {
    addimg=image_from_file("/res/alpaca/installed.png")
    switch(old_position)
    {
     1:{fillrect_drawstring(1,11,11,addimg);imagename[1]=null}
     2:{fillrect_drawstring(2,85,11,addimg);imagename[2]=null}
     3:{fillrect_drawstring(3,159,11,addimg);imagename[3]=null}
     4:{fillrect_drawstring(4,11,85,addimg);imagename[4]=null}
     5:{fillrect_drawstring(5,85,85,addimg);imagename[5]=null}
     6:{fillrect_drawstring(6,159,85,addimg);imagename[6]=null}
     7:{fillrect_drawstring(7,11,159,addimg);imagename[7]=null}
     8:{fillrect_drawstring(8,85,159,addimg);imagename[8]=null}
     9:{fillrect_drawstring(9,159,159,addimg);imagename[9]=null}
     10:{fillrect_drawstring(10,11,233,addimg);imagename[10]=null}
     11:{fillrect_drawstring(11,85,233,addimg);imagename[11]=null}
    }
    addimg=null
    c.refresh()
   }
   else if(ev.value==resetall)
   {
    addimg=image_from_file("/res/alpaca/installed.png")
    px=11
    py=11
    for(var i=1,i<=11,i+=1)
    {
     fillrect_drawstring(i,px,py,addimg)
     imagename[i]=null
     px+=74
     if(i==3||i==6||i==9)
     {
      px=11
      py+=74
     }
    }
    addimg=null
    px=null
    py=null
    c.refresh()
   }
   else if(ev.value==select)
   {
    Select_icon_helper()
   }
  }
 }while(ev.value!=exit&&ev.value!=save)
 if(ev.value==save)
 {
  j=posn
  for(var i=1,i<=11,i+=1)
  {
   new_icons[j]=imagename[i]
   j+=1
  }
  imagename=null
 }
c=null
g=null
ui_set_screen(options)
}

def Draw_image_in_center(img:Image,w:Int,h:Int)
{
 var x_p=(w/2)-(get_image_x(img)/2)
 var y_p=(h/2)-(get_image_y(img)/2)
 g.draw_image(img,x_p,y_p)
}

def Draw_help(msg:String,size:String)
{
 g.draw_string("Press 5 to select/change",0,180)
 g.draw_string(msg,0,210)
 g.draw_string("image of",0,240)
 g.draw_string("Size ("+size+")",0,270)
}

def Select_wallpaper_helper(msg:String,timagename:String,size:String)
{
 g.set_color(0xffffff)
 g.fill_rect(0,0,c.get_width(),c.get_height())
 var img:Image
 try{img=image_from_file(timagename)}catch{}
 if(timagename.endswith(".swf")||timagename.endswith(".SWF"))
 {
  img=null
  g.set_color(0x000000)
  g.draw_string(timagename.substr(timagename.lindexof('/')+1,timagename.len()),0,40)
  g.draw_string("is selected successfully.",0,160)
 }
 else if((get_image_x(img)<=c.get_width())&&(get_image_y(img)<=c.get_height()))
 {
  Draw_image_in_center(img,c.get_width(),c.get_height())
 }
 else
 {
  Show_msbx("Resizing image to 240x320 to fit screen. Original image will not change.")
  try{g.draw_image(load_and_resize_image(img,c.get_width(),c.get_height()),0,0)}catch{g.draw_image(img,0,0)}
  ui_set_screen(c)
 }
 img=null
 g.set_color(0x000000)
 g.draw_string("file="+timagename.substr(timagename.lindexof('/')+1,timagename.len()),0,10)
 Draw_help(msg,size)
 Draw_menu()
 c.refresh()
}

def Select_wallpaper(msg:String,size:String,num:Int)
{
 var prev_scr=ui_get_screen()
 Init_canvas()
 var exit=new_menu("Cancel [#]",3,MT_CANCEL)
 var save=new_menu("Save [*]",2,MT_OK)
 var remove=new_menu("Remove",4)
 var select =new_menu("Add icon [5]",1,MT_OK)
 c.add_menu(exit)
 c.add_menu(save)
 c.add_menu(remove)
 c.add_menu(select)
 g.draw_image(image_from_file("/res/alpaca/installed.png"),110,120)
 var timagename:String
 Show_msbx("Generating preview of previously saved image (if any)")
 g.set_color(0x000000)
 if(new_icons[num]!=null&&(new_icons[num].endswith(".swf")||new_icons[num].endswith(".SWF")))
 {
  timagename=new_icons[num]
  g.draw_string("You have selected :",0,60)
  g.draw_string(timagename.substr(timagename.lindexof('/')+1,timagename.len()),0,90)
 }
 else if(new_icons[num]!=null)
 {
  timagename=new_icons[num]
  var img=image_from_file(timagename)
  if((get_image_x(img)<=c.get_width())&&(get_image_y(img)<=c.get_height()))
  {
   Draw_image_in_center(img,c.get_width(),c.get_height())
  }
  else
  {
   try{g.draw_image(load_and_resize_image(img,c.get_width(),c.get_height()),0,0)}catch{g.draw_image(img,0,0)}
  }
  img=null
 }
 Draw_help(msg,size)
 c.set_title(msg+" Chooser")
 Draw_menu()
 c.refresh()
 ui_set_screen(c)
 var ev:UIEvent
 do
 {
  ev=ui_wait_event()
  var k=0
  if(ev.kind==EV_KEY)
  {
   k=cast(Int)ev.value
   if(k!=0)
   {
    if(k==KEY_5)
    {
     var tempimagename=run_filechooser("Select image",currentPath,["*.jpg","*.jpeg","*.JPG","*.JPEG","*.bmp","*.BMP","*.png","*.PNG","*.gif","*.GIF","*.swf","*.SWF"])
     if(tempimagename!=null)
     {
      timagename=tempimagename
      Select_wallpaper_helper(msg,timagename,size)
      currentPath=timagename.substr(0,timagename.lindexof('/'))
     }
    }
    else if(k==KEY_HASH)
    {
     ev.value=exit
    }
    else if(k==KEY_STAR)
    {
     ev.value=save
    }
   }
  }
  if(ev.kind==EV_MENU)
  {
   if(ev.value==remove)
   {
    g.set_color(0xffffff)
    g.fill_rect(0,0,c.get_width(),c.get_height())
    g.draw_image(image_from_file("/res/alpaca/installed.png"),110,120)
    g.set_color(0x000000)
    Draw_help(msg,size)
    timagename=null
    Draw_menu()
    c.refresh()
   }
   else if(ev.value==select)
   {
     var tempimagename=run_filechooser("Select image",currentPath,["*.jpg","*.jpeg","*.JPG","*.JPEG","*.bmp","*.BMP","*.png","*.PNG","*.gif","*.GIF","*.swf","*.SWF"])
     if(tempimagename!=null)
     {
      timagename=tempimagename
      Select_wallpaper_helper(msg,timagename,size)
      currentPath=timagename.substr(0,timagename.lindexof('/'))
     }
   }
  }
 }while(ev.value!=exit&&ev.value!=save)
 if(ev.value==save)
 {
  new_icons[num]=timagename
 }
 c=null
 g=null
 ui_set_screen(prev_scr)
}

def Other_Icons()//32 to 40
{
 var select=new_menu("Select",1,MT_OK)
 var exit=new_menu("Home",2,MT_CANCEL)
 var iconname=["Camera","Audio Messages","Brew","Cdmacust","Extras","Goto","Voice Portal","Instant Messenger","Sport"]
 var othericons=new_listbox(iconname,null,select)
 othericons.add_menu(exit)
 othericons.set_title("select Icons for : ")
 ui_set_screen(othericons)
 var ev:UIEvent
 do
 {
  ev=ui_wait_event()
  if(ev.value==select)
  {
   var index=othericons.get_index()
   switch(index)
   {
    0:Select_wallpaper(iconname[0],"=48x48",32)//camera
    1:Select_wallpaper(iconname[1],"=48x48",33)//audio msg
    2:Select_wallpaper(iconname[2],"=48x48",34)//brew
    3:Select_wallpaper(iconname[3],"=48x48",35)//cdnacust
    4:Select_wallpaper(iconname[4],"=48x48",36)//extra
    5:Select_wallpaper(iconname[5],"=48x48",37)//goto
    6:Select_wallpaper(iconname[6],"=48x48",38)//vice portal
    7:Select_wallpaper(iconname[7],"=48x48",39)//Instant Messenger
    8:Select_wallpaper(iconname[8],"=48x48",40)//sport
   }
  }
 }while(ev.value!=exit)
 iconname=null
 ui_set_screen(options)
}

def To_hex_helper(n:Int):String
{
 var nn:String
 nn=""+n
 switch(n)
 {
  10:nn="A"
  11:nn="B"
  12:nn="C"
  13:nn="D"
  14:nn="E"
  15:nn="F"
 }
 nn
}

def To_hex(n:Int):String
{
 var hexnum:String
 if(n==0||n==null){hexnum="00"}
 else if(n<16){hexnum="0"+""+To_hex_helper(n)}
 else
 {
  hexnum=""
  var num=n
  var d:Int
  var r:Int
  if(n>255){num=255} 
  do
  {
   d=num/16
   if(d!=0)
   {
    hexnum=hexnum+""+To_hex_helper(d)
   }
   else
   {
    hexnum=hexnum+""+To_hex_helper(num%16)
   }
   num=num%16
  }while(d!=0)
 }
 hexnum
}

//code written in next method original version of code written in indexed-b24
def square_img(c: Int, s: Int): Image {
    var i = new Image(s, s)
    var gg = i.graphics()
    gg.set_color(c)
    gg.fill_rect(0, 0, s, s)
    i 
}

//code written in next method is modified version of code written in indexed-b24
//now it returns color in hexadeciamal format (as String)
def get_color(title:String): String {
    var colpick = new Form()
    colpick.set_title(title)
    var red = new EditItem("Red:", "0", 2, 3)
    var green = new EditItem("Green:", "0", 2, 3)
    var blue = new EditItem("Blue:", "0", 2, 3)
    var previ = new ImageItem("Preview:", square_img((new Color(red.get_text().toint(), green.get_text().toint(), blue.get_text().toint()).correct().toint()), 128))
    var o = new Menu("Okay", 0)
    colpick.add_menu(o)
    colpick.add(red)
    colpick.add(green)
    colpick.add(blue)
    colpick.add(previ)
    ui_set_screen(colpick)
    var e = ui_wait_event()
    while (e.kind != EV_MENU) {
        previ.set_image(square_img((new Color(("0"+red.get_text()).toint(), ("0"+green.get_text()).toint(), ("0"+blue.get_text()).toint()).correct().toint()), 128))
        e = ui_wait_event() }
    if(red.get_text().len()==0){red.set_text("0")}
    if(green.get_text().len()==0){green.set_text("0")}
    if(blue.get_text().len()==0){blue.set_text("0")}
    ""+To_hex(red.get_text().toint())+""+To_hex(green.get_text().toint())+""+To_hex(blue.get_text().toint())
}


def Select_colors()//41 to 57
{
 var select=new_menu("Select",1,MT_OK)
 var exit=new_menu("Cancel",2,MT_CANCEL)
 var save=new_menu("Save",3)
 var color_list=["Header font","Status area font","Softkey font","Ideal font","Grid Menu font","Grid menu highlight font ","Calendar highlight","forms selected font","forms unselected font","Idle status area font","Idle softkey area font","Idle font outline color","Active idle active font","Active idle content background","Menu font","Menu highlight font","Reorder highlight color"]
 var selectcolor=new_listbox(color_list,null,select)
 selectcolor.add_menu(exit)
 selectcolor.add_menu(save)
 selectcolor.set_title("select Colors for : ")
 var tcolr=new [String](17)//temporary variable
 var k=0
 for(var i=41,i<=57,i+=1)
 {
  tcolr[k]=new_icons[i]
  k+=1
 }
 k=null
 ui_set_screen(selectcolor)
 var ev:UIEvent
 do
 {
  ev=ui_wait_event()
  if(ev.value==select)
  {
   var index=selectcolor.get_index()
   var colr=get_color(color_list[index])
   switch(index)
    {
     0:tcolr[0]=""+colr
     1:tcolr[1]=""+colr
     2:tcolr[2]=""+colr
     3:tcolr[3]=""+colr
     4:tcolr[4]=""+colr
     5:tcolr[5]=""+colr
     6:tcolr[6]=""+colr
     7:tcolr[7]=""+colr
     8:tcolr[8]=""+colr
     9:tcolr[9]=""+colr
     10:tcolr[10]=""+colr
     11:tcolr[11]=""+colr
     12:tcolr[12]=""+colr
     13:tcolr[13]=""+colr
     14:tcolr[14]=""+colr
     15:tcolr[15]=""+colr
     16:tcolr[16]=""+colr
    }
  ui_set_screen(selectcolor)
  }
 }while(ev.value!=exit&&ev.value!=save)
 if(ev.value==save)
 {
  var j=0
  for(var i=41,i<=57,i+=1)
  {
  new_icons[i]=tcolr[j]
  j+=1
  }
 }
 ui_set_screen(options)
 c=null
 g=null
}

def trim_name(num:Int):String
{
 var timagename:String
 if(new_icons[num]!=null)
 {
  timagename=new_icons[num]
  timagename=timagename.substr(timagename.lindexof('/')+1,timagename.len())
 }
 else
 {
  timagename=null
 }
 timagename
}

def Check_record(rn:Int)
{
 if(final_icons[rn]==null)
 {
  records[records_count]=rn
  records_count+=1
 }
}

def Pack_theme(savePath:String)
{
 //get total length
 var len=1
 for(var i=1,i<=40,i+=1)
 {
  if(new_icons[i]!=null)
  {
   len+=1
  }
 }
 for(var i=58,i<=68,i+=1)
 {
  if(new_icons[i]!=null)
  {
   len+=1
  }
 }
 //declare array of string of length = len
 final_icons_zip=new [String](len)
 var tempfilename=new [String](len+1)
 final_icons_zip[0]="/tmp/theme_descriptor.xml"
 tempfilename[0]=theme_name
 //put values in above array
 len=1
 for(var i=1,i<=40,i+=1)
 {
  if(new_icons[i]!=null)
  {
   final_icons_zip[len]=new_icons[i]
   len+=1
  }
 }
 for(var i=58,i<=68,i+=1)
 {
  if(new_icons[i]!=null)
  {
   final_icons_zip[len]=new_icons[i]
   len+=1
  }
 }
 //copy files to temporary directory
 for(var j=0,j<len,j+=1)
 {
  tempfilename[j+1]=final_icons_zip[j].substr(final_icons_zip[j].lindexof('/')+1,final_icons_zip[j].len())
  exec_wait("cp",[final_icons_zip[j],savePath])
 }
 //pack files
 var gcwd=get_cwd()
 set_cwd(savePath)
 exec_wait("zip",tempfilename)
 for(var j=1,j<=len,j+=1)
 {
  if(exists(tempfilename[j]))
  {
   exec_wait("rm",[tempfilename[j]])
  }
 }
 set_cwd(gcwd)
}

def ftc(n1:Int,n2:Int)
{
 final_icons[n1]=trim_name(n2)
 Check_record(n1)
}

def Create_theme_descriptor_helper()
{
 final_icons=new [String](200)
//grid menu simple icons
 var j=1
 for(var i=25,i<=87,i+=6)
 {
  var timagename=trim_name(j)
  if(timagename==null)
  {
   for(var k=i,k<=(i+1),k+=1)
   {
    records[records_count]=k
    records_count+=1
   }
  }
  for(var k=i,k<=(i+1),k+=1)
  {
   final_icons[k]=timagename
  }
  j+=1
 }

//if animated icons are not define
//then use simple icons as animated icons
 j=58
 for(var i=1,i<=11,i+=1)
 {
 if(new_icons[j]==null){new_icons[j]=new_icons[i]}
 j+=1
 }
 
//grid menu animated icons
 j=58
 for(var i=27,i<=87,i+=6)
 {
  var timagename=trim_name(j)
  final_icons[i]=timagename
  if(timagename==null)
  {
   records[records_count]=i
   records_count+=1
  }
  j+=1
 }
//colors
 j=41
 for(var i=5,i<=21,i+=1)
 {
   final_icons[i]=new_icons[j]
   j+=1
 }
 j=null
 ftc(118,12)
 ftc(95,13)
 ftc(90,14)
 ftc(124,15)
//calender bg imgs
 var timagename=trim_name(16)
 for(var i=100,i<=111,i+=1)
 {
  final_icons[i]=timagename
  if(timagename==null)
  {
   records[records_count]=i
   records_count+=1
  }
 }
 timagename=null
 ftc(94,17)
 final_icons[85]=final_icons[86]
 Check_record(85)
 ftc(115,18)
 ftc(114,19)
 ftc(96,20)
 ftc(97,21)
 ftc(127,22)
 ftc(128,23)
 ftc(129,24)
 ftc(132,25)
 ftc(119,26)
 ftc(120,27)
 ftc(121,28)
 ftc(189,29)
 ftc(192,30)
 ftc(93,31)
//other icons
 j=32
 for(var i=136,i<=186,i+=6)
 {
  timagename=trim_name(j)
  if(timagename==null)
  {
   for(var k=i,k<=(i+2),k+=1)
   {
    records[records_count]=k
    records_count+=1
   }
  }
  for(var k=i,k<=(i+2),k+=1)
  {
   final_icons[k]=timagename
  }
  j+=1
 }
 j=null
}

def skip_line(count:Int):Bool
{
 var sl:Bool
 sl=false
 var i=1
 while(sl==false&&i<200)
 {
  if(records[i]==count){sl=true}
  i+=1
 }
 sl
}

def Create_theme_descriptor(savePath:String)
{
 records=new [Int](200)
 records_count=1
 Show_msbx("Creating theme.\nplease wait.\n(it may take some time depending on number of files.)")
 Create_theme_descriptor_helper()
 var r=utfreader(fopen_r("/res/Themes/themecnfg"))
 var w=fopen_w("/tmp/theme_descriptor.xml")
 var count=1
 var line=r.readline()
 while(line!=null)
 {
  if(!skip_line(count))
  {
   if(final_icons[count]!=null)
   {
    line=line+final_icons[count]+"\""
   };
   for(var i=0,i<line.len(),i+=1)
    {
     var ch=line.ch(i)
     w.write(ch)
    }
   w.write('\n')
  }
  line=r.readline()
  count+=1
 }
 final_icons=null
 r.close()
 w.flush()
 w.close()
 Pack_theme(savePath)
 final_icons_zip=null
 fremove("/tmp/theme_descriptor.xml")
 try{play_tone(100,200,100)}catch{}
 sleep(100)
 run_alert("Theme Created","theme created successfully...\nclick 'ok' to go back.",null,60000)
 ui_set_screen(options)
}

def PreviewHelpMenu(Option:String,Open:String,Back:String)
{
 g.set_color(0x000000)
 g.set_font(SIZE_MED|STYLE_BOLD)
 g.draw_string(Open,95,297)
 g.set_font(SIZE_MED|STYLE_PLAIN)
 g.draw_string(Option,0,297)
 g.draw_string(Back,200,297)
 c.refresh()
}

def PreviewHelp(title:String)
{
 Init_canvas()
 c.set_title(title)
 ui_set_screen(c)
 backmenu=new_menu("Exit Preview [#]",1,MT_OK)
 c.add_menu(backmenu)
 imagename=new [String](50)
}

def PreviewWait()
{
 c.refresh()
 var ev:UIEvent
 do
 {
  ev=ui_wait_event()
  var k=0
  if(ev.kind==EV_KEY)
  {
   k=cast(Int)ev.value
   if(k==KEY_HASH)
   {
    ev.value=backmenu
   }
  }
 }while(ev.value!=backmenu)
 backmenu=null
 g=null
 c=null
}

def Clock_battery(hr:String,mnt:String)
{
 g.set_font(SIZE_MED|STYLE_PLAIN)
 g.set_color(0x00FF00)
 g.fill_roundrect(40,3,25,16,7,10)
 g.set_color(0x000000)
 g.draw_string(hr+":"+mnt,185,0)
 g.draw_rect(12,15,1,4)
 g.draw_rect(17,12,1,7)
 g.draw_rect(22,9,1,10)
 g.draw_rect(27,5,1,14)
 g.draw_roundrect(40,3,25,16,7,10)
}

def draw_status_and_key_area_bg()
{
 if(new_icons[21]!=null)
 {
  var i=image_from_file(new_icons[21])
  if(get_image_y(i)>48)
  {
   g.draw_image(load_and_resize_image(i,get_image_x(i),48),0,0)
  }
  else
  {
  g.draw_image(i,0,0)
  }
 i=null
 }
 var px=0
 if(new_icons[20]!=null){g.draw_image(image_from_file(new_icons[20]),px,294)}
 for(var i=22,i<=24,i+=1)
 {
  if(new_icons[i]!=null){g.draw_image(image_from_file(new_icons[i]),px,294)}
  px+=80
 }
 px=null
}

def MenuPreview()
{
 var prevscrn=ui_get_screen()
 PreviewHelp("Menu Preview")
 if(new_icons[17]!=null){g.draw_image(image_from_file(new_icons[17]),0,0);c.refresh()}
 draw_status_and_key_area_bg()
 if(new_icons[12]!=null)
 {
  var i=image_from_file(new_icons[12])
  if(get_image_x(i)>74||get_image_y(i)>80)
  {
   g.draw_image(load_and_resize_image(i,74,80),82,135)
  }
  else
  {
   g.draw_image(i,82,135)
  }
  c.refresh()
  i=null
 }
 if(new_icons[20]!=null){g.draw_image(image_from_file(new_icons[20]),0,294);c.refresh()}
 var px=0
 for(var i=22,i<=24,i+=1)
 {
  if(new_icons[i]!=null){g.draw_image(image_from_file(new_icons[i]),px,294)}
  px+=80
 }
 PreviewHelpMenu("Option","Open","Back")
 var t=systime()
 Clock_battery(""+hour(t),""+minute(t))
 g.draw_string("Menu",2,24)
 g.draw_string("5",225,25)
 px=10
 var py=50
 for(var i=1,i<=9,i+=1)
 {
  if(new_icons[i]!=null)
  {
   drawimage_fromfile(i,i,px,py);c.refresh()
  }
  px+=78
  if(i==3||i==6)
  {
   px=10
   py+=87
  }
 }
 imagename=null
 PreviewWait()
 ui_set_screen(prevscrn)
}

def CalPreview()
{
 var prevscrn=ui_get_screen()
 PreviewHelp("Calender Preview")
 if(new_icons[16]!=null){g.draw_image(image_from_file(new_icons[16]),0,0);c.refresh()}
 var px=0
 draw_status_and_key_area_bg()
 c.refresh()
 px=null
 var days=["","Su","Mo","Tu","W","Th","Fr","Sa"]
 var mon_days=[31,28,31,30,31,30,31,31,30,31,30,31]
 var mon=["JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE","JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"]
 var start_pos=[2,5,5,1,3,6,1,4,0,2,5,0]
 var t=systime()
 if(year(t)%4==0){mon_days[1]=29}
 if(year(t)>2013)
 {
  var nyr=year(t)
  for(var i=0,i<=11,i+=1)
  {
   var yr=2014
   while(yr<=nyr)
   {
    start_pos[i]+=1
    if(yr%4==0){start_pos[i]+=1}
    yr+=1
   }
   if(start_pos[i]>6)
   {
    do
    {
     start_pos[i]=start_pos[i]-7
    }while(start_pos[i]>6)
   }
  }
 }
 Clock_battery(""+hour(t),""+minute(t))
 g.set_font(SIZE_MED|STYLE_PLAIN)
 g.draw_string(mon[month(t)]+" "+year(t),2,26)
 px=2
 var py=50
 g.set_color(0xFF0000)
 for(var i=1,i<8,i+=1)
 {
  if(i==2) g.set_color(0x000000)
  g.draw_string(days[i],px,py)
  px+=35
 }
 g.set_color(0x000000)
 g.draw_line(5,50,235,50)
 g.draw_line(5,70,235,70)
 g.set_font(SIZE_MED|STYLE_BOLD)
 px=5+(35*start_pos[month(t)])
 py=75
 for(var i=1,i<=mon_days[month(t)],i+=1)
 {
  if(i==day(t)){g.set_color(0xFF0000);g.draw_rect(px-2,py,26,25)}
  if(px==2){g.set_color(0xFF0000)}
  else {g.set_color(0x000000)}
  g.draw_string(""+i,px,py)
  px+=35
  if(px>230){px=2;py+=25}
 }
 g.set_color(0x000000)
 g.draw_line(5,230,235,230)
 g.draw_string("(no notes)",75,240)
 PreviewHelpMenu("Option","View","Exit")
 PreviewWait()
 ui_set_screen(prevscrn)
}

def WallPreview()
{
 var prevscrn=ui_get_screen()
 PreviewHelp("Wallpaper Preview")
 if(new_icons[14]!=null)
 {
  if(!new_icons[14].endswith(".swf")&&!new_icons[14].endswith(".SWF"))
  {
  g.draw_image(image_from_file(new_icons[14]),0,0);c.refresh()
  }
 }
 var px=0
 draw_status_and_key_area_bg()
 px=null
 var t=systime()
 Clock_battery(""+hour(t),""+minute(t))
 PreviewHelpMenu("Go to","Menu","apps")
 g.draw_string("Operator Name",2,21)
 var mon=["JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE","JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"]
 g.draw_string(""+day(t)+" "+mon[month(t)]+" "+year(t),2,50)
 PreviewWait()
 ui_set_screen(prevscrn)
}

def Preview()
{
 var select=new_menu("Select",1,MT_OK)
 var exit=new_menu("Home",2,MT_CANCEL)
 var prevname=["Menu Preview","Calender Preview","Wallpaper Preview"]
 var preview=new_listbox(prevname,null,select)
 preview.add_menu(exit)
 preview.set_title("Select to see preview : ")
 ui_set_screen(preview)
 var ev:UIEvent
 do
 {
  ev=ui_wait_event()
  if(ev.value==select)
  {
   var index=preview.get_index()
   switch(index)
   {
    0:MenuPreview()
    1:CalPreview()
    2:WallPreview()
   }
  }
 }while(ev.value!=exit)
 ui_set_screen(options)
}

def main(args:[String])
{
c=new_canvas(true)
var wd=c.get_width()
var wh=""+wd+"x"+c.get_height()
c=null
currentPath="/"
memorycard=false
new_icons=new [String](69)
//set default font color
for(var i=41,i<=57,i+=1)
{
 new_icons[i]="000000"
}
new_icons[45]="FFFFFF"
new_icons[47]="FFFF00"
new_icons[49]="FFFFFF"
new_icons[56]="FFFFFF"
var select=new_menu("Select",1,MT_OK)
var exit=new_menu("Exit",2,MT_CANCEL)
var create=new_menu("Create theme",3)
var help=new_menu("Help",4)
var setting=new_menu("Setting",5)
var preview=new_menu("Theme Preview",6)
var nms=["Menu Icons","Animated Icons","Other Icons","Grid View Menu Highlight","Note Background","Main Default Background ","Wallpaper","Screensaver","Calender Background","Menu Background","MusicPlayer Background","Radio Background","Softkey Area Background","Left Softkey Background","Middle Softkey Background","Right Softkey Background","Status Area Background","Wait Graphics","List View Highlight","Forms Selected Highlight","Forms Unselected Highlight","Startup Image ","Shutdown Image","Font Colors"]
options=new_listbox(nms,null,select)
options.add_menu(exit)
options.add_menu(create)
options.add_menu(help)
options.add_menu(setting)
options.add_menu(preview)
options.set_title("Theme Creater")
var ev:UIEvent
ui_set_screen(options)
do
{
 ev=ui_wait_event()
 if(ev.value==select)
 {
  switch(options.get_index())
  {
   0:Select_Icons(1)//menu icons
   1:Select_Icons(58)//Animated Icons
   2:Other_Icons()
   3:Select_wallpaper(nms[3],"=74x80",12)		//Grid View Menu Highlight
   4:Select_wallpaper(nms[4],"=236x114",13)	//Note Background
   5:Select_wallpaper(nms[5],"="+wh,31)		//Main Default Background
   6:Select_wallpaper(nms[6],"="+wh,14)		//Wallpaper
   7:Select_wallpaper(nms[7],"="+wh,15)		//Screensaver
   8:Select_wallpaper(nms[8],"="+wh,16)		//Calender Background
   9:Select_wallpaper(nms[9],"="+wh,17)		//grid Menu Background
   10:Select_wallpaper(nms[10],"="+wh,18)		//MusicPlayer Background
   11:Select_wallpaper(nms[11],"="+wh,19)		//Radio Background
   12:Select_wallpaper(nms[12],"="+wd+"x26",20)	//Softkey Area Background
   13:Select_wallpaper(nms[13],"=80x22",22)	//Left Softkey Background
   14:Select_wallpaper(nms[14],"=80x22",23)	//Middle Softkey Background
   15:Select_wallpaper(nms[15],"=80x22",24)	//Right Softkey Background
   16:Select_wallpaper(nms[16],"="+wd+"x48",21)	//Status Area Background
   17:Select_wallpaper(nms[17],"=any",25)		//Wait Graphics
   18:Select_wallpaper(nms[18],"=224x48",26)	//List View Highlight
   19:Select_wallpaper(nms[19],"=224x48",27)	//Forms Selected Highlight
   20:Select_wallpaper(nms[20],"=224x48",28)	//Forms Unselected Highlight
   21:Select_wallpaper(nms[21],"="+wh,29)		//Startup Image
   22:Select_wallpaper(nms[22],"="+wh,30)		//Shutdown Image
   23:Select_colors()
  }
 }
 else if(ev.value==create)
 {
  var savePath=run_dirchooser("Select folder to save theme",currentPath)
  if(savePath!=null)
  {
   theme_name=run_editbox("Theme Name","Theme.nth",EDIT_ANY,30)
   if(theme_name!=null)
   {
    if(!theme_name.endswith(".nth"))
    {
     theme_name.concat(".nth")
    }
    Create_theme_descriptor(savePath)
   }
  }
 }
 else if(ev.value==help)
 {
  var helptext=new_textitem("","This software can create themes for nokia s40 devices.\n"+
  "It creates themes in '.nth' format.\n"+
  "\nWarning : Do not select images with same name for different icons or images.\n"+
  "\nResizing of images is for preview purpose only. Original image will not be resized.\n"+
  "\nMenu Icons : Icons for menu in grid view. Should be of size 43x43.\n"+
  "\nAnimated Icons : Icons to display selected menu in grid view. Should be of size 64x64.\n"+
  "If Animated Icons are not selected then 'Menu Icons' will be used as Animated Icons.\n"+
  "\nOther Icons : It contains icons for camera, IM, audio message, etc. Should be of size 43x43.\n"+
  "\nGrid View Menu Highlight : Image used to highlight selected menu in grid view. Should be of size 74x80.\n"+
  "\nNote Background : Image used behind popup menu, notification, etc.\n"+
  "\nCalender, MusicPlayer and Radio Background : Images shown behind calender, music player and radio applications.\n"+
  "\nGrid Menu Background : It is used as Menu Background Image. Should be of size 240x320.\n"+
  "\nSoftkey Area Background : Image to display behind softkey area. Should be of size 240x26.\n"+
  "\nStatus Area Background : Image to display behind status area (behind clock,etc). Should be of size 240x26.\n"+
  "\nStartup and Shutdown Images : Images Shown when phone is switched On/Off.\n\n")
  helptext.set_font(SIZE_MED|STYLE_PLAIN)
  var helpscreen=new_form()
  helpscreen.add(helptext)
  helpscreen.set_title("Help")
  var back=new_menu("Back",1,MT_CANCEL)
  helpscreen.add_menu(back)
  ui_set_screen(helpscreen)
  var evnt:UIEvent
  do
  {
   evnt=ui_wait_event()
  }while(evnt.value!=back)
  ui_set_screen(options)
 }
 else if(ev.value==setting)
 {
  var prvscr=ui_get_screen()
  var fom=new_form()
  fom.set_title("Setting")
  var back=new_menu("Back",2,MT_CANCEL)
  var save=new_menu("Save",1,MT_OK)
  fom.add_menu(back)
  fom.add_menu(save)
  var mrycrd=new_checkitem("Check if you want to select images from memory card","Use Memory Card.",memorycard)
  fom.add(mrycrd)
  var evnt:UIEvent
  ui_set_screen(fom)
  do
  {
   evnt=ui_wait_event()
  }while(evnt.value!=save&&evnt.value!=back)
  if(evnt.value==save)
  {
   memorycard=mrycrd.get_checked()
   Check_Drive()
  }
  fom=null
  ui_set_screen(prvscr)
 }
 else if(ev.value==preview)
 {
  Preview()
 }
}while(ev.value!=exit)
if(exists("/tmp/memorycard"))
{
 try
 {
  exec_wait("umount",["/tmp/memorycard/"])
  fremove("/tmp/memorycard")
 }catch{}
}
}