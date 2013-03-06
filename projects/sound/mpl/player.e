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

var wd:String;
var twd:String;
var p:Player;
var e:UIEvent;
var b:Bool;
var ok:Bool;
var ckiv:Bool;
var cklp:Bool;
var cnt1:Int;
var cnt2:Int;
var okk:Bool;
var gtn:Int;
var lislen:Int;
var lis:ListBox;
var ls1:[String];
var ls2:[String];
var img:Image;
var ltitle:String;
var z:Bool;
var play:Menu;
var stop:Menu;
var exit:Menu;
var resume:Menu;
var fw:Menu;
var rw:Menu;
var abt:Menu;
var options:Menu;
var gto:Menu;
var scfld:Menu;
var imgpl:Image;
var imgps:Image;
var ind:Int;

def Cplist()
{
	lis.clear();
	ls1=flistfilter(wd,"*.aac")
	ls2=flistfilter(wd,"*.mp3")
	lislen=0;
	lislen=(ls1.len+ls2.len)
	println(""+lislen+" songs found in "+wd)
	var i:Int;
	for(i=0,i<ls1.len,i=i+1)
	{
		lis.add(ls1[i],img)
	}
	for(i=0,i<ls2.len,i=i+1)
	{
		lis.add(ls2[i],img)
	}
	lis.add_menu(exit)
	if(lislen!=0)
		{
		lis.add_menu(play)
		lis.add_menu(gto)
		lis.add_menu(fw)
		lis.add_menu(rw)
		}
	lis.add_menu(scfld)
	lis.add_menu(abt)
	lis.add_menu(options)
	lis.set_title("Music Player") lis
	ui_set_screen(lis)
	ui_set_app_icon(img)
}

def Ldimgs()
{
	if(exists("/res/mpl/audio.png")){img=image_from_file("/res/mpl/audio.png");}else{img=null;}
	if(exists("/res/mpl/play.png")){imgpl=image_from_file("/res/mpl/play.png");}else{imgpl=img;}
	if(exists("/res/mpl/pause.png")){imgps=image_from_file("/res/mpl/pause.png");}else{imgps=img;}
}

def Remmn()
{
	lis.remove_menu(resume)
	lis.add_menu(stop)
	lis.add_menu(fw)
	lis.add_menu(rw)
}

def Eplrpl()
{
	lis.clear();
	var si:Int;
	for(si=0,si<ls1.len,si=si+1)
		{
		lis.add(ls1[si],img)
		}
	for(si=0,si<ls2.len,si=si+1)
		{
		lis.add(ls2[si],img)
		}
	ui_set_screen(lis);
}

def ScFld()
{
	var prs=ui_get_screen()
	try{
		var fom=new_form()
		fom.set_title("Scan Folder")
		var go1=new_menu("Scan",1)
		var bck=new_menu("Back",2)
		var tFlist=flist("/");
		var Flist="";
		var i:Int;
		for(i=0,i<tFlist.len,i=i+1)
			{
			Flist=Flist+"/"+tFlist[i]
			if(i!=tFlist.len-1){Flist=Flist+","}
			}
		var mmssg="Enter folder name\n(/folder_name)\nto scan it for audio files.\nFolders available:\n"+Flist;
		var sedit=new_edititem(mmssg,wd,EDIT_ANY,50);

		fom.add_menu(go1)
		fom.add_menu(bck)
		fom.add_menu(exit)
		fom.add(sedit)
		var fomsize=fom.size();

		ui_set_screen(fom)

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
			if(ndone)
				{
				wd=twd;
				set_cwd(wd)
				try
				{
					lis.remove_menu(play);lis.remove_menu(gto);
					lis.remove_menu(fw);lis.remove_menu(rw);
				}catch{}
				Cplist();
				}
			else
				{
				ui_set_screen(prs)
				}
		}
		if(ev.value==bck)
			{
			ui_set_screen(prs)
			}
	}catch{ui_set_screen(prs)}
}

def About()
{
	try{
		var prs=ui_get_screen()

		var fom=new_form()
		fom.set_title("Music Player : About")
		var ext=new_menu("Back",1)

		var ti=new_textitem("","\nMusic Player for Alchemy OS."
				+"\n\nCreated by :\n Swapnil. \n[ jack_5@asia.com ]\n ")
		fom.add_menu(ext)
		fom.add(ti)

		ui_set_screen(fom)

		var ev:UIEvent;
		do
		{
			ev=ui_wait_event()
		}while(ev.value!=ext);

		fom.clear()
		ui_set_screen(prs)
	}catch{}
}

def Options()
{
	var prs=ui_get_screen()
	try
	{
		var fom=new_form()
		fom.set_title("Music Player : Options")
		var ext=new_menu("Save",1)
		var bck=new_menu("Back",2)

		var cki=new_checkitem(null,"Exit player at the end of playlist.",ckiv);
		var ckl=new_checkitem(null,"Repeat current song.",cklp);
		fom.add_menu(ext)
		fom.add_menu(bck)
		fom.add(cki)
		fom.add(ckl)

		ui_set_screen(fom)

		var ev:UIEvent;
		do
		{
			ev=ui_wait_event()
		}while(ev.value!=ext&&ev.value!=bck);

		if(ev.value==ext)
		{
			ckiv=cki.get_checked();
			var fileo=fopen_w("/cfg/mplst")
			fileo.writebool(ckiv)
			fileo.close();

			cklp=ckl.get_checked();
			z=cklp;
			fileo=fopen_w("/cfg/mplst1")
			fileo.writebool(cklp)
			fileo.close();
		}

		fom.clear()
		ui_set_screen(prs)
	}catch{ui_set_screen(prs)}
}

def Gto()
{
	var prs=ui_get_screen()
	try
	{
		var fom=new_form()
		fom.set_title("Music Player")
		var sedit=new_edititem("Enter track number.\n 0>number<= "+lislen,""+(lis.get_index()+1),EDIT_NUMBER,4);
		var go1=new_menu("Go",1)
		var bck=new_menu("Back",2)

		fom.add_menu(go1)
		fom.add_menu(bck)
		fom.add_menu(exit)
		fom.add(sedit)
		var fomsize=fom.size();

		ui_set_screen(fom)

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
			try
			{
				if(ndone)
				{
					cnt2=2;
					okk=true;
					ui_set_screen(prs)
				}
			}catch{ui_set_screen(prs)}
		}
		else if(ev.value==bck)
		{
		ui_set_screen(prs)
		}
	}catch{ui_set_screen(prs)}
}


def main(args: [ String ])
{
var msg=" directory does not exists.\n "
var msg1="\nUsage : mpl /dir \n \n[where: /dir=/folder name]\n"

if(args.len>1)
	{
	println(msg+msg1)
	}
else
{
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
	var directory=args[0]
		if(is_dir(directory))
			{
			wd=args[0];
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
println("Starting Music player.")
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
scfld=new_menu("Scan Folder",7)
abt=new_menu("About",8);
options=new_menu("Options",9);
exit=new_menu("Exit Player",10)

Ldimgs();

var lsempty=flistfilter(wd,"*.lsempty")
lis=new_listbox(lsempty,null,null)

var fm:Form;

var fn:String;
var typ:String;

var done:Bool;
done=true
var count=1;
cnt2=1;
okk=false;
z=false;
var b5:Bool;

println("Creating Playlist...")
Cplist();
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
	b5=true;
	try
	{
	ui_set_app_icon(imgpl)
		//if player is in stop state then change menu
		if(count==2)
		{
			Remmn();
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
				{
					lis.add_menu(stop)
					try{p.close();}catch{}

					if(cklp&&z){x=x-1;}
					z=cklp;

					if(x<ls1.len){typ="audio/aac"}
					else{typ="audio/mp3"}

					fn=lis.get_string(x)
					if(lis.get_index()==(x-1)&&(ind!=(lislen-1))){lis.set_index(x)}
					try
					{
						p=new_player(fopen_r(fn),typ)
						p.start()
						lis.set(x,fn,imgpl)
						var lgtd=(p.get_duration()/1000000)
						if(lgtd>59)
							{
								var lmin=lgtd/60;
								var lsec=lgtd%60;
								ltitle="["+lmin+":"+lsec+"]"
							}
						else
							{
								ltitle="["+lgtd+"s]"
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
								title="["+min+":"+sec+"]"+ltitle+fn
							}
						else
							{
								title="["+du+"s]"+ltitle+fn
							}

						lis.set_title(title)

						gt=p.get_time()
						sleep(500)
						gt1=p.get_time()
						re=ui_read_event()

						if(re!=null)
						{
							var ptime:Long;
							var pp:Bool;
							pp=false;

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
										p.stop()
										pp=true;
										lis.add_menu(resume)
										lis.set(x,fn,imgps)
										ui_set_app_icon(imgps)
										count=2;
										b1=false;
										re=ui_wait_event()
									}catch{lis.set_title("Music Player")}
								}
							if(re.value==abt){About();if(pp){re=ui_wait_event()}}
							if(re.value==options){Options();if(pp){re=ui_wait_event()}}

							if(re.value==gto)
								{
								Gto();if(okk){b=false;cnt1=2;e.value=play;okk=false;z=false;}
								}
							if(re.value==exit) {b=false;e.value=exit;p.close();}
							else if(re.value==play)
									{
										if((x==lis.get_index())&&pp)
										{
											pp=false;
											re.value=resume
										}
										else{b=false;cnt1=2;z=false;e.value=play;pp=false;}
									}
							else if(re.value==fw)
								{
									try
									{
										var ftime=(p.get_time()+10000000);
										if(!(ftime>=p.get_duration()))
										{
											p.set_time(ftime);
										}
										else
										{
											ftime=(p.get_time()+5000000);
											if(!(ftime>=p.get_duration()))
											{
												p.set_time(ftime);
											}
										}
									}catch{}
								}

							else if(re.value==rw)
								{
									try
									{
										var rtime=(p.get_time()-10000000);
										p.set_time(rtime);
									}catch{}
								}

							if(re.value==resume)
								{
									try
									{
										Remmn();
										b5=true;
										p.set_time(ptime);
										p.start();
										lis.set(x,fn,imgpl)
										ui_set_app_icon(imgpl)
										b1=true;
										count=1;
									}catch{}
								}
							else if(re.value==scfld)
								{
									if(count==2){Remmn();count=1;}
									lis.remove_menu(stop)
									try{p.close();}catch{}
									lis.set(x,fn,img)
									ui_set_app_icon(img)
									b=false;
									cnt1=3;
									e.value=scfld;
								}
						}
						if(b1==false){b2=true}
						else{b2=(gt!=gt1)}
					}while((b)&&(b2));

					lis.set_title("Music Player")
					lis.set(x,fn,img)
					ui_set_app_icon(img)
					b5=true;

					if(cnt1==1)
						{
						if(x==(lislen-1))
							{
							if(ckiv==false)
								{
								Eplrpl();
								b=false;
								}
							else
								{
								done=false;
								}
							}
						}
				}
			}
		}catch{lis.set_title("Music Player");ui_set_app_icon(img);p.close();}
	}catch{}
	}

	if(e.value==gto)
	{
		Gto();
		if(okk){e.value=play;}
	}

	if(e.value==abt)
	{
		About();
	}

	if(e.value==scfld)
	{
		ScFld();
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

}while(done);
println("Music Player Closed.")
}
}
}