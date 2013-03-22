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

var ok:Bool
var ckiv:Bool
var cklp:Bool
var okk:Bool
var pp:Bool//player_paused
var fom:Form
var img:Image
var img1:Image//previous
var img2:Image//play
var img3:Image//next
var img4:Image//pause
var rk:Int
var x:Int
var gtn:Int//get_track_number
var lislen:Int
var w:Int
var h:Int
var stringlen:Int
var lis:ListBox
var lispl:ListBox
var lgtd:Long//get_duration_of_player
var lgtd1:Long
var play:Menu
var scanFolder:Menu
var exit:Menu
var go1:Menu
var bck:Menu
var msbx:MsgBox
var p:Player
var wd:String//working_directory
var twd:String//temporary_wd
var ltitle:String
var ltitle1:String
var typ:String
var fn:String
var substrng:String
var ls1:[String]
var cType:[String]
var tFlist:[String]
var e:UIEvent
var canv:Canvas
var graphic:Graphics
var shrtcts:Canvas
var scgra:Graphics
var lisn:Int
var position:Int

def get_type(fnn:String)
{
     if(fnn.endswith(".mp3")){typ="audio/mp3"}
else if(fnn.endswith(".aac")){typ="audio/aac"}
else if(fnn.endswith(".wav")){typ="audio/wav"}
else if(fnn.endswith(".m4a")){typ="audio/m4a"}
else if(fnn.endswith(".amr")){typ="audio/amr"}
}

def InitForm(tstrng:String,gstrng:String,bstrng:String)
{
fom=new_form()
if(tstrng!=null){fom.set_title(tstrng)}
if(gstrng!=null){go1=new_menu(gstrng,1);fom.add_menu(go1)}
if(bstrng!=null){bck=new_menu(bstrng,2);fom.add_menu(bck)}
}

def Loadimages()
{
try{img=image_from_file("/res/mpl/audio.png")}catch{img=null}
try{img1=image_from_file("/res/mpl/previous.png")}catch{img1=img}
try{img2=image_from_file("/res/mpl/play.png")}catch{img2=img}
try{img3=image_from_file("/res/mpl/next.png")}catch{img3=img}
try{img4=image_from_file("/res/mpl/pause.png")}catch{img4=img}
}

def SetScreen(scr:Screen)
{
ui_set_screen(scr)
}

def Show_msbx(msg:String,image:Image)
{
msbx=new_msgbox(msg,image)
msbx.set_title("Wait...")
SetScreen(msbx)
}

def CreateAllSongList()
{
lis.clear()
cType=["*.aac","*.mp3","*.wav","*.m4a","*.amr"]
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
	if(!okk){SetScreen(lis)}
}

def CreatePlayList()
{
var prvscr=ui_get_screen()
Show_msbx("Creating list...",null)
var lsplempty=flistfilter(wd,"*.lsplempty")
lispl=new_listbox(lsplempty,null,null)
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
var select=new_menu("Select",1)
var Mark_all=new_menu("Mark all",3)
var Unmark_all=new_menu("Unmark all",4)
var create=new_menu("Create",2)
var cancel=new_menu("Cancel",5)
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
			try{p.close()}catch{}
			Show_msbx("Creating Playlist...",null)
			lis.clear()
			for(var i=0,i<lislen,i+=1)
			{
			if(lispl.get_image(i)==imgs)
				{
				lis.add(lispl.get_string(i),img)
				}
			}
			lispl.clear()
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
else if(ev.value==cancel)
	{
	SetScreen(prvscr)
	}
}

def ScanFolder()
{
var prvscr=ui_get_screen()
try{
	InitForm("Music Player : Scan Folder","Scan","Back")
	tFlist=flistfilter("/","*/")
	var FiList=""
	var i:Int

	for(i=0,i<tFlist.len,i=i+1)
	{
		FiList=FiList+"/"+tFlist[i]
		if(i!=tFlist.len-1){FiList=FiList+","}
	}
	var mmssg="Enter folder name\n(/folder_name)\nFolders found:\n"+FiList
	var sedit=new_edititem(mmssg,wd,EDIT_ANY,50)
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
			try{twd=sedit.get_text().trim()}catch{}
			if((twd.len()==0)||(is_dir(twd)==false))
			{
				var ti=new_textitem("","\nFolder does not exists. Enter valid folder name.")
				fom.add(ti)
			}
			else {ndone=true}
		}
		if(ev.value==exit)
		{
			ndone=true
			e.value=exit
		}

	}while((!ndone)&&ev.value!=bck)
	if(ev.value==go1)
	{
		try{p.close()}catch{}
		wd=twd
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

	else if(ev.value==bck)
	{
		fom.clear()
		SetScreen(prvscr)
	}
}catch{SetScreen(prvscr)}
}

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
fom.clear()
SetScreen(prvscr)
}

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
	fom.clear()
	if(lislen>7)
	{
		if(gtn<7)
		{
			for(var i=0,i<7,i+=1)
			{
				lis.set_index(i)
			}
		}
	}
	for(var i=0,i<gtn,i+=1)
	{
		lis.set_index(i)
	}
	fom.clear()
	SetScreen(prvscr)
}
else if(ev.value==bck)
{
	fom.clear()
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

def Init_GUI()
{
	w=canv.get_width()/10
	h=canv.get_height()/10
	graphic.set_color(0x606060)
	graphic.fill_rect(0,0,canv.get_width(),canv.get_height())
	graphic.set_color(0x000000)
	graphic.fill_rect(0,0,w*10,h*3/4)//up
	graphic.fill_rect(0,((h*9)+(h/4)),w*10,h)//down
	graphic.set_font(SIZE_MED|STYLE_PLAIN)
	graphic.set_color(0xffffff)
	graphic.draw_string(" Music Player",0,0)
	graphic.draw_string(" Press 8 to view shortcuts",0,((h*9)+(h/4)))
	graphic.draw_image(img1,w*2,h*7)
	graphic.draw_image(img4,w*4,h*7)
	graphic.draw_image(img3,w*6,h*7)
	graphic.set_color(0x000000)
	graphic.fill_roundrect(w,h*2,w*8,h,w,w)//sname
	graphic.set_color(0xff0000)
	graphic.draw_roundrect(w,h*2,w*8,h,w,w)//sname
}

def Load_song()
{
try{p.close()}catch{}
get_type(fn)
try{p=new_player(fopen_r(fn),typ)}catch{}
}

def get_duration()
{
if(typ=="audio/wav")
{
	lgtd=p.get_duration()/100000000
	if(lgtd==0){lgtd=1}
}
else{lgtd=p.get_duration()/1000000}
if(lgtd>59)
{
	var lmin=lgtd/60
	var lsec=lgtd%60
	ltitle1=""+lmin+":"+lsec
}
else
{
	ltitle1=""+lgtd
}
}

def Set_title()
{
	stringlen=fn.len()
	if(stringlen<(w-w/4))
		{
		substrng=fn
		}
	else
		{
		substrng=fn.substr(0,(w-w/4))
		}
	pp=false;
	lis.set_index(x)
	graphic.set_color(0x606060)
	graphic.fill_rect(0,h*2,w*10,h*3)//songname
	graphic.set_color(0x000000)
	graphic.fill_roundrect(w,h*2,w*8,h,w,w)//songname
	graphic.fill_rect(((w*6)+(w/2)),0,w*10,h*3/4)//songcount
	try{p.start()}catch{}
	get_duration()
	graphic.set_color(0xffffff)
	graphic.draw_string(substrng.lcase(),w+2,((h*2)+2))
	graphic.set_color(0xff0000)
	graphic.draw_roundrect(w,h*2,w*8,h,w,w)//songname
	graphic.draw_string(""+(x+1)+"/"+lislen,((w*6)+(w/2)),0)
	graphic.set_color(0x606060)
	graphic.fill_rect(w*9+1,h*2,w,h)//aftersongname
	canv.refresh()
}

def set_image()
{
	graphic.set_color(0x606060)
	graphic.fill_rect(w*4,h*7,48,48)
	graphic.draw_image(img4,w*4,h*7)
	canv.refresh()
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
		if(lisn==x)
		{
			scgra.set_color(0x00ff00)
		}
		scgra.draw_string(""+(lisn+1)+"] "+lis.get_string(lisn),0,h*(lisn-tracknum))
		if(lisn==x)
		{
			scgra.set_color(0xffffff)
		}
	}
	position=tracknum
	shrtcts.refresh()
	ui_set_screen(shrtcts)
}

def mPlayer()
{
okk=false
var actcd:Int
var count=1
var sccnt=1
Init_GUI()
graphic.set_color(0xffffff)
x=lis.get_index()
fn=lis.get_string(x)
stringlen=fn.len()
if(stringlen<(w-w/4))
	{
	substrng=fn
	}
else
	{
	substrng=fn.substr(0,(w-w/4))
	}
graphic.draw_string(substrng.lcase(),w+2,((h*2)+2))
graphic.set_color(0x606060)
graphic.fill_rect(w*9+1,h*2,w,h)//asname
canv.refresh()
Load_song()
ui_set_screen(canv)
try{p.start()}catch{}
pp=false
get_duration()
graphic.set_color(0xff0000)
graphic.draw_roundrect(w,h*2,w*8,h,w,w)//sname
graphic.draw_string(""+(x+1)+"/"+lislen,((w*6)+(w/2)),0)
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
	else
	{
		title=""+du
	}

	graphic.set_color(0x606060)
	graphic.fill_rect(w,h*3/4,w*9,h-3)
	graphic.set_color(0x000000)
	graphic.set_font(SIZE_MED|STYLE_BOLD)
	graphic.draw_string("[ "+title+" ] [ "+ltitle1+" ]",w+w/2,(h*3/4+h/6))
	graphic.set_font(SIZE_MED|STYLE_PLAIN)
	canv.refresh()
var gt=p.get_time()
sleep(200)
var gt1=p.get_time()

if(!okk)
	{
	if(sccnt==1){rk=canv.read_key()}
	else{rk=shrtcts.read_key()}
	if((gt==gt1)&&(!pp)){rk=KEY_6;if(cklp){x=x-1}}
	}
if(rk!=0)
{
	if(rk==KEY_5)
	{
		if(sccnt==4)
			{
			x=position-1;rk=KEY_6
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
			Showmsg("Press # to close the Player")
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
				for(var i=0,i<7,i+=1)
				{
					lis.set_index(i)
				}
				x=0
			}
			fn=lis.get_string(x)
			Load_song()
			Set_title()
		}
		set_image()
	}else if(rk==KEY_0)
	{
		if(sccnt!=1)
		{
			sccnt=1
			ui_set_screen(canv)
		}
	}else if(rk==KEY_1)
	{
		PlayTrackNumber()
		if(okk){rk=KEY_6;x=gtn-2}
	}else if(rk==KEY_2)
	{
		ScanFolder()
		if(okk)
		{
		okk=false
		rk=KEY_HASH
		}
	}else if(rk==KEY_3)
	{
		CreatePlayList()
		if(okk)
		{
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
		if(sccnt==2)
		{
			sccnt=1
			ui_set_screen(canv)
		}
		else
		{
			sccnt=2
			scgra.set_color(0x000000)
			scgra.fill_rect(0,0,w*10,h*10)
			scgra.set_font(SIZE_SMALL|STYLE_BOLD)
			scgra.set_color(0xffffff)
			scgra.draw_string(" 1 : Play track number",0,0)
			scgra.draw_string(" 2 : Scan Folder",0,h/2)
			scgra.draw_string(" 3 : Create PlayList",0,h)
			scgra.draw_string(" 4 : Previous Song",0,h*3/2)
			scgra.draw_string(" 5 : Play-Pause Song",0,h*2)
			scgra.draw_string(" 6 : Next Song",0,h*5/2)
			scgra.draw_string(" 7 : Options",0,h*3)
			scgra.draw_string(" 8 : View-Hide SHORTCUTS",0,h*7/2)
			scgra.draw_string(" 9 : All Songs List",0,h*4)
			scgra.set_font(SIZE_MED|STYLE_PLAIN)
			scgra.draw_string(" *",0,h*9/2)
			scgra.set_font(SIZE_SMALL|STYLE_BOLD)
			scgra.draw_string(": View-Hide PlayList",w,h*9/2)
			scgra.draw_string(" 0 : Player",0,h*5)
			scgra.draw_string(" # : Close Player",0,h*11/2)
			scgra.draw_string("Call button : View-Hide About",0,h*6)
			scgra.draw_string("Note: Pressing 5 while viewing",0,h*7)
			scgra.draw_string("playlist will play selected song.",0,h*15/2)
			scgra.draw_string("Note: Pressing 9 will clear the",0,h*8)
			scgra.draw_string("current playlist.",0,h*17/2)
			scgra.set_color(0xff0000)
			scgra.draw_string("press 0 to view player",w,h*9)
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
			if(sccnt==4)
			{
				sccnt=1
				ui_set_screen(canv)
			}
			else
			{
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
					scgra.draw_string(""+(lisn+1)+"] "+lis.get_string(lisn),0,h*(lisn-x))
					if(lisn==x){scgra.set_color(0xffffff)}
				}
				shrtcts.refresh()
				ui_set_screen(shrtcts)
			}
	}else
	{
		actcd=canv.action_code(rk)
		if(actcd==FIRE&&rk!=KEY_5)
		{
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
				scgra.set_font(SIZE_SMALL|STYLE_BOLD)
				scgra.set_color(0xffffff)
				scgra.draw_string("About : ",0,0)
				scgra.draw_string("Music Player for Alchemy OS.",0,h)
				scgra.draw_string("Created by : Swapnil.",0,h*2)
				scgra.set_color(0x0000ff)
				scgra.draw_string("email : jack_5@asia.com",0,h*3)
				scgra.set_color(0xffffff)
				scgra.draw_string("If  you found any error, report",0,h*4)
				scgra.draw_string("it to above email address.",0,h*5)
				scgra.set_color(0xff0000)
				scgra.draw_string("press 0 to view player",w,h*9)
				shrtcts.refresh()
				ui_set_screen(shrtcts)
			}
		}else if(actcd==UP&&rk!=KEY_2)
		{
			if(sccnt==4)
				{
				var pone=position-1
				if(pone>=0)
					{
					Canvas_Playlist(pone)
					}
				}
		}else if(actcd==DOWN&&rk!=KEY_8)
		{
			if(sccnt==4)
				{
				var pone=position+1
				if(pone<lislen)
					{
					Canvas_Playlist(pone)
					}
				}
		}else if(actcd==LEFT&&rk!=KEY_4)
		{
			if(sccnt==4)
				{
				var pone=position-9
				if(pone<0){pone=0}
				if(pone>=0)
					{
					Canvas_Playlist(pone)
					}
				}
		}else if(actcd==RIGHT&&rk!=KEY_6)
		{
			if(sccnt==4)
				{
				var pone=position+9
				if(pone<lislen)
					{
					Canvas_Playlist(pone)
					}
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
	}
else
	{
	ckiv=true
	cklp=false
	}

play=new_menu("Play",1)
scanFolder=new_menu("Scan folder",2)
exit=new_menu("Exit player",4)

Loadimages()

var lsempty=flistfilter(wd,"*.lsempty")
lis=new_listbox(lsempty,null,null)

var done:Bool
done=true
var count=1
okk=false

println("Creating Playlist...")
CreateAllSongList()
println(""+lislen+" Songs Found in "+wd+".")
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
println("Music Player Closed.")
}
}
