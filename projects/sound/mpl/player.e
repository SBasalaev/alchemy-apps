use "ui"
use "io"
use "dataio"
use "stdscreens"
use "media"
use "form"
use "sys"
use "image"
use "string"
use "ui_edit"

var b:Bool;
var ok:Bool;
var ckiv:Bool;
var cklp:Bool;
var okk:Bool;
var z:Bool;
var pp:Bool;//player_paused
var pc:Bool;
var fom:Form;
var img:Image;
var imgpl:Image;//play
var imgps:Image;//pause
var ind:Int;//index
var gtn:Int;//get_track_number
var cnt1:Int;
var cnt2:Int;
var lislen:Int;
var ps:Int;
var lis:ListBox;
var lispl:ListBox;
var lgtd:Long;//get_duration_of_player
var lgtd1:Long;
var ptime:Long;//get_current_time_of_player
var play:Menu;
var stop:Menu;
var exit:Menu;
var resume:Menu;
var fw:Menu;//Forward
var rw:Menu;//rewind
var abt:Menu;//about
var options:Menu;
var gto:Menu;//play_track_number
var scfld:Menu;//scan_folder
var go1:Menu;
var bck:Menu;
var crpl:Menu;//create_playlist
var asng:Menu;//all_songs
var p:Player;
var wd:String;//working_directory
var twd:String;//temporary_wd
var ltitle:String;
var ls1:[String];
var cType:[String];
var e:UIEvent;

def InitForm(tstrng:String,gstrng:String,bstrng:String)
{
fom=new_form()
if(tstrng!=null){fom.set_title(tstrng)}
if(gstrng!=null){go1=new_menu(gstrng,1);fom.add_menu(go1)}
if(bstrng!=null){bck=new_menu(bstrng,2);fom.add_menu(bck)}
}

def Loadimages()
{
if(exists("/res/mpl/audio.png")){img=image_from_file("/res/mpl/audio.png");}else{img=null;}
if(exists("/res/mpl/play.png")){imgpl=image_from_file("/res/mpl/play.png");}else{imgpl=img;}
if(exists("/res/mpl/pause.png")){imgps=image_from_file("/res/mpl/pause.png");}else{imgps=img;}
}

def RemoveMenu()
{
lis.remove_menu(resume)
lis.add_menu(stop)
lis.add_menu(fw)
lis.add_menu(rw)
}

def SetScreen(scr:Screen)
{
ui_set_screen(scr)
}

def CreateAllSongList()
{
lis.clear();
pc=false;
cType=["*.aac","*.mp3","*.wav","*.m4a","*.amr"]
lislen=0;
var i:Int;
var j:Int;
for(i=0,i<cType.len,i=i+1)
{
	ls1=flistfilter(wd,cType[i])
	lislen=lislen+ls1.len;
	for(j=0,j<ls1.len,j=j+1)
	{
		lis.add(ls1[j],img)
	}
}
lis.add_menu(exit)
if(lislen!=0)
{
	lis.add_menu(play)
	lis.add_menu(gto)
	lis.add_menu(fw)
	lis.add_menu(rw)
	lis.add_menu(crpl)
}
lis.add_menu(scfld)
lis.add_menu(abt)
lis.add_menu(options)
lis.set_title("Music Player") lis
SetScreen(lis)
ui_set_app_icon(img)
}

def CreatePlayList()
{
var lsplempty=flistfilter(wd,"*.lsplempty")
lispl=new_listbox(lsplempty,null,null)
lispl.set_title("Select Songs") lispl
var cki:CheckItem;
var imgs:Image;
var imgus:Image;
if(exists("/res/alpaca/deleted.png")){imgus=image_from_file("/res/alpaca/deleted.png");}else{imgus=null;}
if(exists("/res/alpaca/installed.png")){imgs=image_from_file("/res/alpaca/installed.png");}else{imgs=img;}
for(var i=0,i<lislen,i+=1)
{
lispl.add(lis.get_string(i),imgus)
}
var select=new_menu("Select",1)
var create=new_menu("Create",2)
var cancel=new_menu("Cancel",3)
lispl.add_menu(select)
lispl.add_menu(create)
lispl.add_menu(cancel)
SetScreen(lispl)
var plgi:Int;
var ev:UIEvent;
do
{
	ev=ui_wait_event()
	if(ev.value==select)
	{
	plgi=lispl.get_index()
	if(lispl.get_image(plgi)==imgus)
		{lispl.set(plgi,lispl.get_string(plgi),imgs)}
	else {lispl.set(plgi,lispl.get_string(plgi),imgus)}
	}
}while(ev.value!=create&&ev.value!=cancel);
if(ev.value==create)
	{
		lis.clear()
		for(var i=0,i<lislen,i+=1)
		{
		if(lispl.get_image(i)==imgs)
			{
			lis.add(lispl.get_string(i),img)
			}
		}
	pc=true;
	lispl.clear();
	lis.remove_menu(crpl)
	lis.add_menu(asng)
	lislen=lis.len()
	}
SetScreen(lis)
}

def ScanFolder()
{
try{
	InitForm("Scan Folder","Scan","Back")
	var tFlist=flist("/");
	var FiList="";
	var i:Int;
	for(i=0,i<tFlist.len,i=i+1)
	{
		FiList=FiList+"/"+tFlist[i]
		if(i!=tFlist.len-1){FiList=FiList+","}
	}
	var mmssg="Enter folder name\n(/folder_name)\nFolders found:\n"+FiList;
	var sedit=new_edititem(mmssg,wd,EDIT_ANY,50);
	fom.add_menu(exit)
	fom.add(sedit)
	var fomsize=fom.size();
	SetScreen(fom)
	var ev:UIEvent;
	var ndone:Bool;
	ndone=false;
	do
	{
		ev=ui_wait_event()
		if(ev.value==go1)
		{
			try{fom.remove(fomsize)}catch{}
			try{twd=sedit.get_text().trim();}catch{}
			if((twd.len()==0)||(is_dir(twd)==false))
			{
				var ti=new_textitem("","\nFolder does not exists. Enter valid folder name.")
				fom.add(ti)
			}
			else {ndone=true;}
		}
		if(ev.value==exit)
		{
			ndone=true;
			e.value=exit;
		}
	}while((!ndone)&&ev.value!=bck);
	if(ev.value==go1)
	{
		wd=twd;
		set_cwd(wd)
		try
		{
			lis.remove_menu(play);lis.remove_menu(gto);
			lis.remove_menu(fw);lis.remove_menu(rw);
			lis.remove_menu(asng);
		}catch{}
		fom.clear()
		CreateAllSongList();
	}
	if(ev.value==bck)
	{
		fom.clear()
		z=false;
		SetScreen(lis)
	}
}catch{SetScreen(lis)}
}

def About()
{
InitForm("Music Player : About",null,"Back")
var ti=new_textitem("","\nMusic Player for Alchemy OS."
			+"\n\nCreated by :\n Swapnil. \n[ jack_5@asia.com]\n ")
fom.add(ti)
SetScreen(fom)
var ev:UIEvent;
do
{
	ev=ui_wait_event()
}while(ev.value!=bck);
fom.clear()
SetScreen(lis)
}

def Options()
{
InitForm("Music Player : Options","Save","Back")
var cki=new_checkitem(null,"Exit player at the end of playlist.",ckiv);
var ckl=new_checkitem(null,"Repeat current song.",cklp);
fom.add(cki)
fom.add(ckl)
SetScreen(fom)
var ev:UIEvent;
do
{
	ev=ui_wait_event()
}while(ev.value!=go1&&ev.value!=bck);
if(ev.value==go1)
{
	ckiv=cki.get_checked();
	var fileo=fopen_w("/cfg/mplst")
	fileo.writebool(ckiv)
	fileo.close();

	cklp=ckl.get_checked();
	if(ps!=1){z=cklp;}
	fileo=fopen_w("/cfg/mplst1")
	fileo.writebool(cklp)
	fileo.close();
}
fom.clear()
SetScreen(lis)
}

def PlayTrackNumber()
{
InitForm("Music Player","Play","Back")
var sedit=new_edititem("Enter track number.\n  [ 1 to "+lislen+" ]",""+(lis.get_index()+1),EDIT_NUMBER,4);
fom.add_menu(exit)
fom.add(sedit)
var fomsize=fom.size();
SetScreen(fom)
var ev:UIEvent;
var ndone:Bool;
ndone=false;
do
{
	ev=ui_wait_event()
	if(ev.value==go1)
	{
		try{fom.remove(fomsize)}catch{}
		try{gtn=sedit.get_text().toint();}catch{}
		if((sedit.get_size()==0)||(gtn>lislen)||(gtn<=0))
		{
			var ti=new_textitem("","\nEnter valid track number <="+lislen)
			fom.add(ti)
		}
		else {ndone=true;}
	}
	else if(ev.value==exit)
	{
		ndone=true;
		e.value=exit;
	}
}while((!ndone)&&ev.value!=bck);

if(ev.value==go1)
{
	cnt2=2;
	okk=true;
	fom.clear()
	SetScreen(lis)
}
else if(ev.value==bck)
{
	fom.clear()
	SetScreen(lis)
}
}



def main(args:[String])
{
var msg=" directory does not exists.\n "
var msg1="\nUsage : mpl /dir \n \n[where: /dir=/folder name]\n"

if(args.len==0)
	{
	wd="/home";
	println(msg1)
	ok=true;
	}
else if(args[0]=="-h")
	{
	println(msg1)
	ok=false;
	}
else 
{
	var directory:String;
	directory=""
	if(args.len==1){directory=args[0]}
	else
	{
		var i:Int;
		for(i=0,i<args.len,i+=1)
		{
			if(i!=0){directory=directory+" "}
			directory=directory+args[i]
		}
	}

	if(is_dir(directory))
		{
		wd=directory;
		ok=true;
		}
	else
		{
		println(msg+msg1)
		ok=false;
		}
}
if(ok)
{
println("Starting Music Player...")
set_cwd(wd)

if(exists("/cfg/mplst"))
	{
	var filei=fopen_r("/cfg/mplst")
	ckiv=filei.readbool()
	filei.close();
	}
else
	{
	ckiv=true;
	}

if(exists("/cfg/mplst1"))
	{
	var filei=fopen_r("/cfg/mplst1")
	cklp=filei.readbool()
	filei.close();
	}
else
	{
	cklp=false;
	}

play=new_menu("Play",1)
stop=new_menu("Pause",2)
resume=new_menu("Resume",3)
gto=new_menu("Play track number",4);
fw=new_menu("Forward",5)
rw=new_menu("Rewind",6)
scfld=new_menu("Scan folder",7)
crpl=new_menu("Create playlist",8)
asng=new_menu("All songs",8)
abt=new_menu("About",9);
options=new_menu("Options",10);
exit=new_menu("Exit player",11)

Loadimages();

var lsempty=flistfilter(wd,"*.lsempty")
lis=new_listbox(lsempty,null,null)

var fn:String;
var typ:String;

var done:Bool;
done=true
var count=1;
cnt2=1;
okk=false;
z=false;
var b5:Bool;
ps=1;

println("Creating Playlist...")
CreateAllSongList();
println(""+lislen+" Songs Found in "+wd+".")
e=ui_wait_event()
do
{
if(e.value!=play)
	{
	e=ui_wait_event()
	}

if(e.value==play)
	{
	cnt1=1;
	try
	{
	ui_set_app_icon(imgpl)
		//if player is in stop state then change menu
		if(count==2)
		{
			RemoveMenu();
			count=1;
		}

		if(cnt2==2)
			{
			ind=gtn-1;
			cnt2=1;
			}
		else
			{
			ind=lis.get_index()
			}
		try
		{
			var x:Int;
			var gt:Long;
			var gt1:Long;
			b=true;
			var b1:Bool;b1=true;
			var b2:Bool;b2=true;
			var re:UIEvent;

			for(x=ind,x<lislen,x+=1)
			{
				if(b)
				{	b5=true;
					lis.add_menu(stop)
					try{p.close();}catch{}

					if(cklp&&z){if(x!=0){x=x-1;}}
					z=cklp;ps=2;

					fn=lis.get_string(x)

					     if(fn.endswith(".mp3")){typ="audio/mp3"}
					else if(fn.endswith(".aac")){typ="audio/aac"}
					else if(fn.endswith(".wav")){typ="audio/wav"}
					else if(fn.endswith(".m4a")){typ="audio/m4a"}
					else if(fn.endswith(".amr")){typ="audio/amr"}

					if(lis.get_index()==(x-1)&&(ind!=(lislen-1))){lis.set_index(x)}

					try
					{
						p=new_player(fopen_r(fn),typ)
						lis.set(x,fn,imgpl)
						p.start()
						if(typ=="audio/wav"){lgtd1=p.get_duration()/100;
										lgtd=p.get_duration()/100000000;if(lgtd==0){lgtd=1;}}
						else{lgtd1=p.get_duration();lgtd=p.get_duration()/1000000}
						if(lgtd>59)
							{
								var lmin=lgtd/60;
								var lsec=lgtd%60;
								ltitle="["+lmin+":"+lsec+"]"
							}
						else
							{
								ltitle="["+lgtd
								ltitle=ltitle+"s]"
							}

					}catch{lis.set(x,fn,img);ui_set_app_icon(img);lis.set_title("Unable to play ?");}

					do
					{
						var dur=p.get_time()
						var du=dur/1000000;
						var title:String;
						if(du>59)
							{
								var min=du/60;
								var sec=du%60;
								title="["+min+":"+sec+"]"+ltitle+"["+(x+1)+"]"+fn
							}
						else
							{
								title="["+du+"s]"+ltitle+"["+(x+1)+"]"+fn
							}

						lis.set_title(title)

						gt=p.get_time()
						sleep(200)
						gt1=p.get_time()
						re=ui_read_event()

						if(re!=null)
						{
							if(re.value==play)
									{
									if((x==lis.get_index())&&b5)
										{
										re.value=stop
										}
									}

							if(re.value==stop)
								{
							 		try
									{
										b5=false;
										ptime=p.get_time();
										lis.remove_menu(stop)
										lis.remove_menu(fw)
										lis.remove_menu(rw)
										pp=true;
										lis.add_menu(resume)
										count=2;
										b1=false;
										p.stop()
										lis.set(x,fn,imgps)
										ui_set_app_icon(imgps)
										re=ui_wait_event()
									}catch{lis.set_title("Music Player")}
								}
							if(re.value==abt){About();}
							if(re.value==options){Options();}

							if(re.value==gto)
								{
								PlayTrackNumber();if(okk){b=false;cnt1=2;e.value=play;okk=false;z=false;}
								}
							if(re.value==exit) {b=false;e.value=exit;p.close();}
							else if(re.value==play)
									{
										if((x==lis.get_index())&&pp)
											{
											re.value=resume
											}
										else
											{
											b=false;cnt1=2;z=false;e.value=play;pp=false;
											}
									}

							else if(re.value==fw)
								{
									try
									{
										var ftime=(p.get_time()+10000000);
										if(!(ftime>=lgtd1))
										{
											p.set_time(ftime);
										}
										else
										{
											ftime=(p.get_time()+5000000);
											if(!(ftime>=lgtd1))
											{
												p.set_time(ftime);
											}
											else
											{
												ftime=(p.get_time()+2000000);
												if(!(ftime>=lgtd1))
												{
													p.set_time(ftime);
												}
											}
										}
									}catch{}
								}

							else if(re.value==rw)
								{
									try
									{
										var rtime=(p.get_time()-10000000);
										if(!(rtime<=0))
										{
											p.set_time(rtime);
										}
										else
										{
											rtime=(p.get_time()-5000000);
											if(!(rtime<=0))
											{
												p.set_time(rtime);
											}
											else
											{
												rtime=(p.get_time()-2000000);
												if(!(rtime<=0))
												{
													p.set_time(rtime);
												}
											}
										}
									}catch{}
								}

							if(re.value==resume)
								{
									try
									{
										RemoveMenu();
										b5=true;
										p.set_time(ptime);
										b1=true;
										count=1;
										pp=false;
										p.start();
										lis.set(x,fn,imgpl)
										ui_set_app_icon(imgpl)
									}catch{}
								}
							else if(re.value==scfld)
								{
									b=false;
									cnt1=3;
									e.value=scfld;
								}
							if(re.value==crpl)
								{
									b=false;
									cnt1=3;
									e.value=crpl
								}
							if(re.value==asng)
								{
									b=false;
									cnt1=3;
									e.value=asng
								}
						}
						if(b1==false){b2=true}
						else{b2=(gt!=gt1)}
					}while((b)&&(b2));

					lis.set_title("Music Player")
					lis.set(x,fn,img)
					ui_set_app_icon(img)

					if(cnt1==3)
					{
						if(count==2){RemoveMenu();count=1;}
						lis.remove_menu(stop)
						try{p.close();}catch{}
					}

					if(!cklp)
					{
						if(cnt1==1)
						{
						if(x==(lislen-1))
							{
							if(ckiv==false)
								{
								b=false
								if(pc)
								{
									for(var i=0,i<lislen,i+=1)
									{
									lispl.add(lis.get_string(i),img)
									}									
									lis.clear()
									for(var i=0,i<lislen,i+=1)
									{
									lis.add(lispl.get_string(i),img)
									}
								lis.set_index(0)
								}
								else
								{
									CreateAllSongList()
								}
								}
							else
								{
								done=false;
								}
							}
						}
					}
				}
				if(cklp&&z){if(x==lislen-1){z=false;x=x-1;}}
			}
		}catch{lis.set_title("Music Player");ui_set_app_icon(img);p.close();}
	}catch{}
	}

	if(e.value==gto)
	{
		PlayTrackNumber();
		if(okk){e.value=play;}
	}

	if(e.value==abt)
	{
		About();
	}

	if(e.value==scfld)
	{
		ScanFolder();
	}

	if(e.value==options)
	{
		Options();
	}

	if(e.value==exit)
	{
		try
		{
			p.close()
		}catch{}
		done=false
	}
	if(e.value==crpl)
	{
		CreatePlayList()
	}
	if(e.value==asng)
	{
		lis.remove_menu(asng)
		CreateAllSongList()
	}

}while(done);
println("Music Player Closed.")
}
}