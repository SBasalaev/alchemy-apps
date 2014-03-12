/*ex player.e -o mpl -lui -lmedia*/
use "canvas"
use "dataio"
use "graphics"
use "font"
use "form"
use "image"
use "io"
use "media"
use "stdscreens"
use "sys"
use "string"
use "ui"
use "ui_edit"

var mounted:Bool

use "SelectFolder.e"

var ckiv:Bool
var cklp:Bool
var ok:Bool
var okk:Bool
var pp:Bool
var canv:Canvas
var shrtcts:Canvas
var fom:Form
var graphic:Graphics
var scgra:Graphics
var img:Image
var img1:Image
var img2:Image
var img3:Image
var img4:Image
var gtn:Int
var h:Int
var lislen:Int
var lisn:Int
var mnpstn:Int
var position:Int
var stringlen:Int
var spleffect:Int
var rk:Int
var w:Int
var x:Int
var lis:ListBox
var player_duration:Long
var bck:Menu
var exit:Menu
var go1:Menu
var play:Menu
var scanFolder:Menu
var msbx:MsgBox
var p:Player
var wd:String
var TDur:String
var typ:String
var fn:String
var substrng:String
var ls1:[String]
var cType:[String]
var tFlist:[String]
var Menulist:[String]
var MenuKey:[String]
var e:UIEvent

//get audio file type
def get_type(fnn:String)
{
if(fnn.endswith(".mp3")){typ="audio/mp3"}
else if(fnn.endswith(".aac")){typ="audio/aac"}
else if(fnn.endswith(".wav")){typ="audio/wav"}
else if(fnn.endswith(".m4a")){typ="audio/m4a"}
else if(fnn.endswith(".amr")){typ="audio/amr"}
else if(fnn.endswith(".mid")){typ="audio/mid"}
}

//initiate form
def InitForm(tstrng:String,gstrng:String,bstrng:String)
{
fom=new_form()
if(tstrng!=null){fom.set_title(tstrng)}
if(gstrng!=null){go1=new_menu(gstrng,1,MT_OK);fom.add_menu(go1)}
if(bstrng!=null){bck=new_menu(bstrng,2,MT_CANCEL);fom.add_menu(bck)}
}

def Loadimages()
{
try{img=image_from_file("/res/mpl/audio.png")}catch{img=null}
try{img1=image_from_file("/res/mpl/previous.png")}catch{img1=img}
try{img2=image_from_file("/res/mpl/play.png")}catch{img2=img}
try{img3=image_from_file("/res/mpl/next.png")}catch{img3=img}
try{img4=image_from_file("/res/mpl/pause.png")}catch{img4=img}
}

def SetScreen(scr:Screen){ui_set_screen(scr)}

def Show_msbx(msg:String,image:Image)
{
msbx=new_msgbox(msg,image)
msbx.set_title("Wait...")
SetScreen(msbx)
}

//creates main playlist containing all songs in folder
def CreateAllSongList()
{
lis.clear()
cType=["*.aac","*.mp3","*.wav","*.m4a","*.amr","*.mid"]
lislen=0
var i:Int
var j:Int
for(i=0,i<cType.len,i=i+1)
{
 ls1=flistfilter(wd,cType[i])
 lislen=lislen+ls1.len
 for(j=0,j<ls1.len,j=j+1)
  {
  lis.add(ls1[j],img)
  }
}
lis.add_menu(exit)
if(lislen!=0)
{
 lis.add_menu(play)
}
lis.add_menu(scanFolder)
lis.set_title("Music Player") lis
if(okk==false){SetScreen(lis)}
}

//creates temporary playlist from all songs list
def CreatePlayList()
{
var prvscr=ui_get_screen()
Show_msbx("Creating list...",null)
var lsplempty=flistfilter(wd,"*.lsplempty")
var lispl=new_listbox(lsplempty,null,null)
lsplempty=null
lispl.set_title("Select Songs") lispl
var cki:CheckItem
var imgs:Image
var imgus:Image
var selsts=0
try{imgus=image_from_file("/res/mpl/ck.png")}catch{imgus=null}
try{imgs=image_from_file("/res/mpl/kc.png")}catch{imgs=img}
for(var i=0,i<lislen,i+=1)
{
 lispl.add(lis.get_string(i),imgus)
}
var select=new_menu("Select",1,MT_OK)
var Mark_all=new_menu("Mark all",3)
var Unmark_all=new_menu("Unmark all",4)
var create=new_menu("Create",2)
var cancel=new_menu("Cancel",5,MT_CANCEL)
lispl.add_menu(select)
lispl.add_menu(create)
lispl.add_menu(cancel)
lispl.add_menu(Mark_all)
lispl.add_menu(Unmark_all)
SetScreen(lispl)
var plgi:Int
var ev:UIEvent
do
{
 ev=ui_wait_event()
 if(ev.value==Mark_all)
 {
  Show_msbx("Marking...",imgs)
  selsts=lislen
  for(var i=0,i<lispl.len(),i+=1)
 {
  lispl.set(i,lispl.get_string(i),imgs)
 }
  SetScreen(lispl)
 }
 if(ev.value==Unmark_all)
 {
  Show_msbx("Unmarking...",imgus)
  selsts=0
  for(var i=0,i<lispl.len(),i+=1)
  {
   lispl.set(i,lispl.get_string(i),imgus)
  }
  SetScreen(lispl)
 }
 if(ev.value==select)
 {
  plgi=lispl.get_index()
  if(lispl.get_image(plgi)==imgus)
  {selsts=selsts+1;lispl.set(plgi,lispl.get_string(plgi),imgs)}
  else {selsts=selsts-1;lispl.set(plgi,lispl.get_string(plgi),imgus)}
 }
}while(ev.value!=create&&ev.value!=cancel);
if(ev.value==create)
{
 if(selsts!=0)
 {
  try{p.close()}catch{p=null}
  Show_msbx("Creating Playlist...",null)
  lis.clear()
  for(var i=0,i<lislen,i+=1)
  {
   if(lispl.get_image(i)==imgs)
   {
   lis.add(lispl.get_string(i),img)
   }
  }
  lislen=lis.len()
  if(lislen==0){lis.remove_menu(play)}
  e.value=null
  okk=true
 }
 else
 {
  Show_msbx("No song selected...",null)
  sleep(1000)
  SetScreen(prvscr)
 }
}
else if(ev.value==cancel){SetScreen(prvscr)}
}

//scan the given folder for songs
def ScanFolder()
{
var prvscr=ui_get_screen()
try{
 var getfoldername=SelectFolder()
 if(getfoldername!=null)
 {
  try{p.close()}catch{p=null}
  wd=getfoldername
  set_cwd(wd)
  try
  {
   lis.remove_menu(play)
  }catch{}
  Show_msbx("Scanning "+wd,null)
  if(e.value!=scanFolder){okk=true}
  e.value=null
  CreateAllSongList()
 }
 else{SetScreen(prvscr)}
}catch{SetScreen(lis)}
}

//Option menu for user
def Options()
{
var prvscr=ui_get_screen()
InitForm("Music Player : Options","Save","Back")
var cki=new_checkitem(null,"Do not repeat playlist.",ckiv)
var ckl=new_checkitem(null,"Repeat current song.",cklp)
fom.add(cki)
fom.add(ckl)
SetScreen(fom)
var ev:UIEvent
do
{
 ev=ui_wait_event()
}while(ev.value!=go1&&ev.value!=bck)
if(ev.value==go1)
{
 ckiv=cki.get_checked()
 cklp=ckl.get_checked()
 var optn:String
 if(ckiv){optn=""+1}else{optn=""+0}
 if(cklp){optn=optn+""+1}else{optn=optn+""+0}
 var fileo=fopen_w("/cfg/mplcfg")
 fileo.writeutf(optn)
 fileo.close()
}
fom=null
SetScreen(prvscr)
}

//goto track number
def PlayTrackNumber()
{
var prvscr=ui_get_screen()
InitForm("Music Player : Play Track Number","Play","Back")
var sedit=new_edititem("Enter track number.\n  [ 1 to "+lislen+" ]",""+(lis.get_index()+1),EDIT_NUMBER,4)
fom.add_menu(exit)
fom.add(sedit)
var fomsize=fom.size()
SetScreen(fom)
var ev:UIEvent
var ndone:Bool
ndone=false
do
{
 ev=ui_wait_event()
 if(ev.value==go1)
 {
  try{fom.remove(fomsize)}catch{}
  try{gtn=sedit.get_text().toint()}catch{}
  if((sedit.get_size()==0)||(gtn>lislen)||(gtn<=0))
  {
   var ti=new_textitem("","\nEnter valid track number <="+lislen)
   fom.add(ti)
  }
  else {ndone=true}
 }
 else if(ev.value==exit)
 {
  ndone=true
  e.value=exit
 }
}while((!ndone)&&ev.value!=bck)
if(ev.value==go1)
{
 okk=true
 fom=null
 fom.clear()
 SetScreen(prvscr)
}
else if(ev.value==bck)
{
 fom=null
 okk=false
 SetScreen(prvscr)
}
}

def Showmsg(mssg:String)
{
graphic.set_color(0x000000)
graphic.fill_rect(0,((h*9)+(h/4)),w*10,h)
graphic.set_color(0xffffff)
graphic.draw_string(" "+mssg,0,((h*9)+(h/4)))
}

//initiate graphical(Canvas) user interface
def Init_GUI()
{
w=canv.get_width()/10
h=canv.get_height()/10
graphic.set_color(0x606060)
graphic.fill_rect(0,0,canv.get_width(),canv.get_height())
graphic.set_color(0x000000)
graphic.fill_rect(0,0,w*10,h*3/4)
graphic.fill_rect(0,((h*9)+(h/4)),w*10,h)
graphic.fill_roundrect(w,h*2,w*8,h,w,w)
graphic.set_font(SIZE_MED|STYLE_PLAIN)
graphic.set_color(0xffffff)
graphic.draw_string(" Music Player",0,0)
graphic.draw_string(" Press 8 to view shortcuts",0,((h*9)+(h/4)))
graphic.draw_image(img1,w*2,h*7)
graphic.draw_image(img4,w*4,h*7)
graphic.draw_image(img3,w*6,h*7)
graphic.set_color(0xff0000)
graphic.draw_line(w*7/2,0,w*13/2,0)
graphic.draw_roundrect(w,h*2,w*8,h,w,w)
}

def Load_song()
{
try{p.close()}catch{}
get_type(fn)
try{
  // fix by Sergey Basalaev
  // for compatibility with older versions
  var cfunc = create_player
  if (cfunc != null) {
    p=cfunc(fn,typ)
  } else {
    p=new_player(fopen_r(fn),typ)
  }
}catch{}
}

def get_duration()
{
if(typ=="audio/wav")
{
 player_duration=p.get_duration()/100000000
 if(player_duration==0){player_duration=1}
}
else
{
 player_duration=p.get_duration()/1000000
}
if(player_duration>59)
{
 var lmin=player_duration/60
 var lsec=player_duration%60
 TDur=""+lmin+":"+lsec
}
else{TDur=""+player_duration}
}

def Set_title()
{
stringlen=fn.len()
if(stringlen<(w-w/4)){substrng=fn}
else{substrng=fn.substr(0,(w-w/4))}
pp=false;
lis.set_index(x)
graphic.set_color(0x606060)
graphic.fill_rect(0,h*2,w*10,h*3)
graphic.set_color(0x000000)
graphic.fill_roundrect(w,h*2,w*8,h,w,w)
graphic.fill_rect(((w*6)+(w/2)),0,w*10,h*3/4)
try{p.start()}catch{if(cklp){x=x+1}}
get_duration()
graphic.set_color(0xffffff)
graphic.draw_string(substrng.lcase(),w+2,((h*2)+2))
graphic.set_color(0xff0000)
graphic.draw_roundrect(w,h*2,w*8,h,w,w)
graphic.draw_string(""+(x+1)+"/"+lislen,((w*6)+(w/2)),0)
graphic.set_color(0x606060)
graphic.fill_rect(w*9+1,h*2,w,h)
canv.refresh()
}

def set_image()
{
graphic.set_color(0x606060)
graphic.fill_rect(w*4,h*7,48,48)
graphic.draw_image(img4,w*4,h*7)
canv.refresh()
}

def SplEfct(Strng:String,Tmpwidth:Int,Tmphgt:Int):Int
{
 var tempwidth=Tmpwidth
 var ic=w*10
 var tempevent:Int
 do
 {
  tempevent=shrtcts.read_key()
  scgra.set_color(0x000000)
  scgra.fill_rect(0,Tmphgt,w*10,h)
  scgra.set_color(0xffffff)
  scgra.draw_string(Strng,ic,Tmphgt)
  ic-=5
  shrtcts.refresh()
  sleep(1)
 }while(tempevent==0&&ic>=tempwidth)
 tempevent
}

def Canvas_Menu(Menunum:Int)
{
scgra.set_color(0xffffff)
scgra.fill_rect(0,h*9/2,w*5,h*9/2+(h/3))
scgra.set_font(SIZE_SMALL|STYLE_PLAIN)
scgra.set_color(0x00ff00)
scgra.fill_rect(0,((h*9/2)+(Menunum*h/2))+1,w*5,h/2+1)
scgra.set_color(0xff0000)
for(var mlen=0,mlen<Menulist.len,mlen+=1)
{
 scgra.draw_string(Menulist[mlen],0,((h*9/2)+(mlen*h/2)))
 scgra.draw_string(MenuKey[mlen],w*4,((h*9/2)+(mlen*h/2)))
}
shrtcts.refresh()
}

def Canvas_Playlist(tracknum:Int)
{
scgra.set_color(0x000000)
scgra.fill_rect(0,0,w*10,h*10)
scgra.set_font(SIZE_SMALL|STYLE_BOLD)
scgra.set_color(0xff0000)
scgra.fill_rect(0,0,w*10,h)
scgra.set_color(0xffffff)
lisn=0
for(lisn=tracknum,(lisn<lislen&&(lisn-tracknum)<10),lisn+=1)
{
 if(lisn==x){scgra.set_color(0x00ff00)}
 scgra.draw_string(""+(lisn+1)+"."+lis.get_string(lisn),0,h*(lisn-tracknum))
 if(lisn==x){scgra.set_color(0xffffff)}
}
scgra.fill_rect(0,h*28/3,w*10,h)
scgra.fill_rect((w*10)-3,0,3,h*10)
scgra.set_color(0x000000)
scgra.draw_string("1-Menu",0,h*28/3)
scgra.draw_string("5-SELECT",w*7/2,h*28/3)
scgra.draw_string("-BACK",w*8,h*28/3)
scgra.set_font(SIZE_MED|STYLE_PLAIN)
scgra.draw_string("*",w*15/2,h*28/3)
position=tracknum
scgra.set_color(0xff0000)
scgra.fill_rect((w*10)-3,((canv.get_height()*position)/(lislen-1)),3,h/2)
shrtcts.refresh()
ui_set_screen(shrtcts)
}

def mPlayer()
{
okk=false
var actcd:Int
var sccnt=1
var mncnt=1
var tempevent=0
spleffect=1
Init_GUI()
x=lis.get_index()
fn=lis.get_string(x)
stringlen=fn.len()
if(stringlen<(w-w/4)){substrng=fn}
else{substrng=fn.substr(0,(w-w/4))}
graphic.set_color(0xffffff)
graphic.draw_string(substrng.lcase(),w+2,((h*2)+2))
graphic.set_color(0x606060)
graphic.fill_rect(w*9+1,h*2,w,h)
canv.refresh()
Load_song()
ui_set_screen(canv)
try{p.start()}catch{}
pp=false
get_duration()
graphic.set_color(0xff0000)
graphic.draw_roundrect(w,h*2,w*8,h,w,w)
graphic.draw_string(""+(x+1)+"/"+lislen,((w*6)+(w/2)),0)
canv.refresh()
do
{
var du=p.get_time()/1000000
var title:String
if(du>59)
{
 var min=du/60
 var sec=du%60
 title=""+min+":"+sec
}
else{title=""+du}
graphic.set_color(0x606060)
graphic.fill_rect(w,h*3/4,w*9,h-3)
graphic.set_color(0x000000)
graphic.set_font(SIZE_MED|STYLE_BOLD)
graphic.draw_string("[ "+title+" ] [ "+TDur+" ]",w+w/2,(h*3/4+h/6))
canv.refresh()
graphic.set_font(SIZE_MED|STYLE_PLAIN)
var gt=p.get_time()
sleep(200)
var gt1=p.get_time()
if(!okk)
{
 if(sccnt==1)
 {
  rk=canv.read_key()
 }
 else
 {
  if(sccnt==3&&tempevent!=0)
  {
  rk=tempevent
  tempevent=0
  }
  else
  {
  rk=shrtcts.read_key()
  }
 }
 if((gt==gt1)&&(!pp)){rk=KEY_6;if(cklp){x=x-1}}
}
if(rk!=0)
{
 if(rk==KEY_5)
 {
  if(sccnt==4)
  {
   if(mncnt==2)
   {
    switch(mnpstn)
    {
     0:{x=position-1;mncnt=1;rk=KEY_6;Canvas_Playlist(position)}
     1:{rk=KEY_1}
     2:{rk=KEY_2}
     3:{rk=KEY_3}
     4:{mncnt=1;rk=KEY_9}
     5:{mncnt=1;Canvas_Playlist(position);rk=KEY_7}
     6:{mncnt=1;rk=KEY_8}
     7:{mncnt=1;okk=true;rk=0;actcd=FIRE}
     8:{mncnt=1;rk=KEY_HASH}
    }
   }
   else{x=position-1;rk=KEY_6}
  }
  else
  {
   var imag:Image
   if(!pp)
   {
    Showmsg("Press * to view playlist")
    imag=img2
    pp=true
    p.stop()
   }
   else
   {
    Showmsg("Press 8 to view shortcuts")
    imag=img4
    pp=false
    p.start()
   }
   graphic.set_color(0x606060)
   graphic.fill_rect(w*4,h*7,48,48)
   graphic.draw_image(imag,w*4,h*7)
   canv.refresh()
  }
}
if(rk==KEY_1)
{
 if(sccnt==4&&mncnt!=2)
 {
  mnpstn=0
  mncnt=2
  scgra.set_color(0xffffff)
  scgra.fill_rect(0,h*9/2,w*5,h*9/2+(h/3))
  scgra.set_color(0x00ff00)
  scgra.fill_rect(0,h*9/2,w*5,h/2+1)
  scgra.set_font(SIZE_SMALL|STYLE_PLAIN)
  scgra.set_color(0xff0000)
  for(var mlen=0,mlen<Menulist.len,mlen+=1)
  {
   scgra.draw_string(MenuKey[mlen],w*4,((h*9/2)+(mlen*h/2)))
   scgra.draw_string(Menulist[mlen],0,((h*9/2)+(mlen*h/2)))
  }
  shrtcts.refresh()
 }
 else
 {
  PlayTrackNumber()
  if(okk){if(mncnt==2){mncnt=1;Canvas_Playlist(position)};rk=KEY_6;x=gtn-2}
 }
}
if(rk==KEY_6)
{
 if(okk){okk=false}
 Showmsg("Press 8 to view shortcuts")
 if(pp){pp=false}
 x=x+1
 if(x==lislen&&ckiv){rk=KEY_HASH}
 else
 {
  if(x==lislen&&!ckiv)
  {
   x=0
   lis.set_index(0)
  }
  fn=lis.get_string(x)
  Load_song()
  Set_title()
 }
 set_image()
}else if(rk==KEY_0)
{
 if(okk){okk=false}
 if(mncnt==2){mncnt=1}
 if(sccnt!=1)
 {
  sccnt=1
  ui_set_screen(canv)
 }
}else if(rk==KEY_2)
{
 ScanFolder()
 if(okk)
 {
  if(mncnt==2)
  {
   mncnt=1
   Canvas_Playlist(position)
  }
  okk=false
  rk=KEY_HASH
 }
}else if(rk==KEY_3)
{
 CreatePlayList()
 if(okk)
 {
  if(mncnt==2)
  {
  mncnt=1
  Canvas_Playlist(position)
  }
  okk=false
  rk=KEY_HASH
 }
}else if(rk==KEY_4)
{
 Showmsg("Press * to view playlist")
 if(pp){pp=false}
 x=x-1
 if(x<0){x=lislen-1}
 fn=lis.get_string(x)
 Load_song()
 Set_title()
 set_image()
}else if(rk==KEY_7)
{
 Options()
}else if(rk==KEY_8)
{
 if(okk){okk=false}
 if(mncnt==2){mncnt=1}
 if(sccnt==2)
 {
  sccnt=1
  ui_set_screen(canv)
 }
 else
 {
  if(spleffect==2)
  {
   spleffect=1
   var tempwidth=w*3-(w*10)
   var tempint=0
   do
   {
    scgra.set_color(0x000000)
    scgra.fill_rect(0,0,w*10,h*10)
    scgra.set_font(SIZE_SMALL|STYLE_BOLD)
    scgra.set_color(0xffffff)
    scgra.draw_string(" 1 : Goto track number",tempwidth,0)
    scgra.draw_string(" 2 : Scan Folder",tempwidth,h/2)
    scgra.draw_string(" 3 : Create PlayList",tempwidth,h)
    scgra.draw_string(" 4 : Previous Song",tempwidth,h*3/2)
    scgra.draw_string(" 5 : Play-Pause Song",tempwidth,h*2)
    scgra.draw_string(" 6 : Next Song",tempwidth,h*5/2)
    scgra.draw_string(" 7 : Options",tempwidth,h*3)
    scgra.draw_string(" 8 : View-Hide SHORTCUTS",tempwidth,h*7/2)
    scgra.draw_string(" 9 : All Songs List",tempwidth,h*4)
    scgra.draw_string(" * : View-Hide PlayList",tempwidth+w,h*9/2)
    scgra.draw_string(" 0 : View Player",tempwidth,h*5)
    scgra.draw_string(" # : Close Player",tempwidth,h*11/2)
    scgra.draw_string("Call button : View-Hide About",tempwidth,h*6)
    shrtcts.refresh()
    ui_set_screen(shrtcts)
    tempwidth+=10
    sleep(1)
    tempint=shrtcts.read_key()
   }while(tempint==0&&tempwidth<=0)
  }
  sccnt=2
  scgra.set_color(0x000000)
  scgra.fill_rect(0,0,w*10,h*10)
  scgra.set_font(SIZE_SMALL|STYLE_BOLD)
  scgra.set_color(0xffffff)
  scgra.draw_string(" 1 : Goto track number",0,0)
  scgra.draw_string(" 2 : Scan Folder",0,h/2)
  scgra.draw_string(" 3 : Create PlayList",0,h)
  scgra.draw_string(" 4 : Previous Song",0,h*3/2)
  scgra.draw_string(" 5 : Play-Pause Song",0,h*2)
  scgra.draw_string(" 6 : Next Song",0,h*5/2)
  scgra.draw_string(" 7 : Options",0,h*3)
  scgra.draw_string(" 8 : View-Hide SHORTCUTS",0,h*7/2)
  scgra.draw_string(" 9 : All Songs List",0,h*4)
  scgra.draw_string(": View-Hide PlayList",w,h*9/2)
  scgra.draw_string(" # : Close Player",0,h*11/2)
  scgra.draw_string("Call button : View-Hide About",0,h*6)
  scgra.set_color(0xff0000)
  scgra.draw_string(" 0 : View Player",0,h*5)
  scgra.draw_line(0,0,w*7/2,0)
  scgra.set_color(0x00ff00)
  scgra.draw_line(0,h*7,w*10,h*7)
  scgra.set_color(0xffffff)
  scgra.draw_string("Note: Pressing 5 while viewing",0,h*7)
  scgra.draw_string("playlist will play selected song.",0,h*15/2)
  scgra.draw_string("Note: Pressing 1 while viewing",0,h*8)
  scgra.draw_string("playlist will open MENU.",0,h*17/2)
  scgra.draw_string("Note: Pressing 9 will clear the",0,h*9)
  scgra.draw_string("current playlist.",0,h*19/2)
  scgra.set_font(SIZE_MED|STYLE_PLAIN)
  scgra.draw_string(" *",0,h*9/2)
  shrtcts.refresh()
  ui_set_screen(shrtcts)
 }
}else if(rk==KEY_9)
{
 try{p.close()}catch{}
 Show_msbx("Creating list...",null)
 okk=true
 CreateAllSongList()
 okk=false
 rk=KEY_HASH
}else if(rk==KEY_STAR)
{
 if(okk){okk=false}
 if(mncnt==2){mncnt=1}
 if(sccnt==4)
 {
  sccnt=1
  ui_set_screen(canv)
 }
 else
 {
  if(spleffect==2)
  {
   spleffect=1
   var tempwidth=w*7
   var tempint=0
   do
   {
    scgra.set_color(0x000000)
    scgra.fill_rect(0,0,w*10,h*10)
    scgra.set_font(SIZE_SMALL|STYLE_BOLD)
    scgra.set_color(0xffffff)
    position=x
    for(lisn=x,(lisn<lislen&&(lisn-x)<10),lisn+=1)
    {
     scgra.draw_string(""+(lisn+1)+"."+lis.get_string(lisn),tempwidth,h*(lisn-x))
    }
    shrtcts.refresh()
    ui_set_screen(shrtcts)
    tempwidth-=10
    sleep(1)
    tempint=shrtcts.read_key()
   }while(tempint==0&&tempwidth>0)
  }
  sccnt=4
  scgra.set_color(0x000000)
  scgra.fill_rect(0,0,w*10,h*10)
  scgra.set_font(SIZE_SMALL|STYLE_BOLD)
  scgra.set_color(0xff0000)
  scgra.fill_rect(0,0,w*10,h)
  scgra.set_color(0xffffff)
  position=x
  for(lisn=x,(lisn<lislen&&(lisn-x)<10),lisn+=1)
  {
   if(lisn==x){scgra.set_color(0x00ff00)}
   scgra.draw_string(""+(lisn+1)+"."+lis.get_string(lisn),0,h*(lisn-x))
   if(lisn==x){scgra.set_color(0xffffff)}
  }
  scgra.fill_rect(0,h*28/3,w*10,h)
  scgra.set_color(0x000000)
  scgra.draw_string("1-Menu",0,h*28/3)
  scgra.draw_string("5-SELECT",w*7/2,h*28/3)
  scgra.draw_string("-BACK",w*8,h*28/3)
  scgra.set_font(SIZE_MED|STYLE_PLAIN)
  scgra.draw_string("*",w*15/2,h*28/3)
  scgra.set_color(0xffffff)
  scgra.fill_rect((w*10)-3,0,3,h*10)
  scgra.set_color(0xff0000)
  scgra.fill_rect((w*10)-3,((canv.get_height()*position)/(lislen-1)),3,h/2)
  shrtcts.refresh()
  ui_set_screen(shrtcts)
 }
}else
{
 if(!okk){actcd=canv.action_code(rk)}
 else{okk=false}
 if(actcd==FIRE&&rk!=KEY_5)
 {
  if(mncnt==2){mncnt=1}
  if(sccnt==3)
  {
   sccnt=1
   ui_set_screen(canv)
  }
  else
  {
   sccnt=3
   scgra.set_color(0x000000)
   scgra.fill_rect(0,0,w*10,h*10)
   shrtcts.refresh()
   ui_set_screen(shrtcts)
   scgra.set_font(SIZE_SMALL|STYLE_BOLD)
   tempevent=SplEfct("Music Player for Alchemy OS.",0,h)
   scgra.set_color(0x000000)
   scgra.fill_rect(0,h,w*10,h)
   scgra.set_color(0xffffff)
   scgra.draw_string("Music Player for Alchemy OS.",0,h)
   shrtcts.refresh()
   tempevent=SplEfct("Created by : jack_5@asia.com",0,h*2)
   scgra.set_color(0x000000)
   scgra.fill_rect(0,h*2,w*10,h)
   scgra.set_color(0xffffff)
   scgra.draw_string("Created by : jack_5@asia.com",0,h*2)
   shrtcts.refresh()
   tempevent=SplEfct("email : jack_5@asia.com",0,h*3)
   scgra.set_color(0x000000)
   scgra.fill_rect(0,h*3,w*10,h)
   scgra.set_color(0x0000ff)
   scgra.draw_string("email : jack_5@asia.com",0,h*3)
   shrtcts.refresh()
   scgra.set_color(0xffffff)
   scgra.draw_string("If  you found any error, report",0,h*4)
   shrtcts.refresh()
   scgra.draw_string("it to above email address.",0,h*5)
   shrtcts.refresh()
   scgra.fill_rect(0,h*28/3,w*10,h)
   scgra.set_color(0xff0000)
   scgra.draw_string("Press 0 to view player",w*2,h*28/3)
   shrtcts.refresh()
  }
 }else if(actcd==UP&&rk!=KEY_2)
 {
  if(sccnt==4)
  {
   if(mncnt==2)
   {
    mnpstn-=1
    if(mnpstn<0){mnpstn=Menulist.len-1}
    Canvas_Menu(mnpstn)
   }
   else
   {
    var pone=position-1
    if(pone<0){pone=lislen-1}
    if(pone>=0)
    {
     Canvas_Playlist(pone)
    }
   }
  }
 }else if(actcd==DOWN&&rk!=KEY_8)
 {
  if(sccnt==4)
  {
   if(mncnt==2)
   {
    mnpstn+=1
    if(mnpstn>=Menulist.len){mnpstn=0}
    Canvas_Menu(mnpstn)
   }
   else
   {
    var pone=position+1
    if(pone>=lislen){pone=0}
    if(pone<lislen)
    {
     Canvas_Playlist(pone)
    }
   }
  }
 }else if(actcd==LEFT&&rk!=KEY_4)
 {
  if(sccnt==4)
  {
   if(mncnt==2)
   {
    mncnt=1
    Canvas_Playlist(position)
   }
   else
   {
    var pone=position-9
    if(pone<0){pone=0}
    if(pone>=0)
    {
     Canvas_Playlist(pone)
    }
   }
  }
  else if(sccnt==1)
  {
   okk=true
   spleffect=2
   rk=KEY_8
  }
  else if(sccnt==2)
  {
   okk=true
   rk=KEY_STAR
  }
 }else if(actcd==RIGHT&&rk!=KEY_6)
 {
  if(sccnt==4)
  {
   if(mncnt==2)
   {
    mncnt=1
    Canvas_Playlist(position)
   }
   else
   {
    var pone=position+9
    if(pone<lislen)
    {
     Canvas_Playlist(pone)
    }
   }
  }
  else if(sccnt==1)
  {
   okk=true
   spleffect=2
   rk=KEY_STAR
  }
  else if(sccnt==2)
  {
   okk=true
   rk=KEY_0
  }
 }
}
}
}while(rk!=KEY_HASH)
try{p.close()}catch{}
e.value=null
ui_set_screen(lis)
}

def main(args:[String])
{
var msg=" directory does not exists.\n "
var msg1="\nUsage : mpl /dir \n \n[where: /dir=/folder name]\n"
if(args.len==0)
{
 wd="/home"
 println(msg1)
 ok=true
}
else if(args[0]=="-h")
{
 println(msg1)
 ok=false
}
else 
{
 var directory:String
 directory=""
 if(args.len==1){directory=args[0]}
 else
 {
  var i:Int
  for(i=0,i<args.len,i+=1)
  {
   if(i!=0){directory=directory+" "}
   directory=directory+args[i]
  }
 }
 if(is_dir(directory))
 {
  wd=directory
  ok=true
 }
 else
 {
  println(msg+msg1)
  ok=false
 }
}
if(ok)
{
 msg=null
 msg1=null
 ok=null
 mounted=false
 println("Starting Music Player...")
 set_cwd(wd)
 if(exists("/cfg/mplcfg"))
 {
  var filei=fopen_r("/cfg/mplcfg")
  var optn:Int
  optn=filei.readutf().toint()
  filei.close()
  switch(optn)
  {
   00:{ckiv=false;cklp=false}
   01:{ckiv=false;cklp=true}
   10:{ckiv=true;cklp=false}
   11:{ckiv=true;cklp=true}
   else:{ckiv=false;cklp=false}
  }
  optn=null
 }
 else
 {
  ckiv=true
  cklp=false
 }
 play=new_menu("Play",1,MT_OK)
 scanFolder=new_menu("Scan folder",2)
 exit=new_menu("Exit player",4)
 Loadimages()
 var lsempty=flistfilter(wd,"*.lsempty")
 lis=new_listbox(lsempty,null,null)
 lsempty=null
 var done:Bool
 done=true
 okk=false
 println("Creating Playlist...")
 CreateAllSongList()
 println(""+lislen+" Songs Found in "+wd+".")
 Menulist=["Play","Goto track","Scan Folder","Create PlayList","All Songs","Options","Help","About","Exit"]
 MenuKey=["","[1]","[2]","[3]","[9]","[7]","[8]","","[#]"]
 canv=new_canvas(true)
 graphic=canv.graphics()
 shrtcts=new_canvas(true)
 scgra=shrtcts.graphics()
 e=ui_wait_event()
 do
 {
  e=ui_wait_event()
  if(e.value==play)
  {
   mPlayer()
  }
  else if(e.value==exit)
  {
   try
   {
    p.close()
   }catch{}
   done=false
  }
  else if(e.value==scanFolder)
  {
   okk=false
   ScanFolder()
  }
 }while(done)
 if(mounted){exec_wait("umount",["/tmp/mpl"])}
 println("Music Player Closed.")
}
}