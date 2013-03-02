/*to execute this program type 
"ex player.e -o mpl -lui -lmedia -Xtry" in Terminal.
*/
/*to run this program type "./mpl /dir" in Terminal
(e.g. dir=/home , dir=/tmp/music)
(default settings: dir=/home) 
*/

use "ui.eh"
use "io.eh"
use "dataio.eh"
use "stdscreens.eh"
use "media.eh"
use "form.eh"
use "sys.eh"
use "image.eh"
use "string.eh"
use "ui_edit.eh"

var wd:String;
var ok:Bool;
var ckiv:Bool;
var cnt1:Int;
var cnt2:Int;
var okk:Bool;
var gtn:Int;
var lislen:Int;
var lis:ListBox;
var tlis:ListBox;
var ls1:[String];
var img:Image;

def About()
{
	try{
		var prs=ui_get_screen()

		var fom=new_form()
		fom.set_title("Music Player : About")
		var ext=new_menu("Back",1)

		var ti=new_textitem("","\nMusic Player for Alchemy OS.\n  Version : 2.0.0"
				+"\n\nCreated by :\n jack_5 \n[ jack_5@asia.com]\n ")
		fom.add_menu(ext)
		fom.add(ti)

		//set screen to form (fom)
		ui_set_screen(fom)

		var ev:UIEvent;
		do
		{
			ev=ui_wait_event()
		}while(ev.value!=ext);

		//return to music player
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
		fom.add_menu(ext)
		fom.add_menu(bck)
		fom.add(cki)

		//set screen to form (fom)
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
		}

		//return to music player
		fom.clear()
		ui_set_screen(prs)
	}catch{ui_set_screen(prs)}
}

def Gto()
{
		var prs=ui_get_screen()
	try
	{

		var fom=new_editbox(EDIT_NUMBER)
		fom.set_title("Enter track number. [<="+lislen+"]")
		fom.set_maxsize(3);
		var go1=new_menu("Go",1)
		var bck=new_menu("Back",2)

		fom.add_menu(go1)
		fom.add_menu(bck)

		//set screen to form (fom)
		ui_set_screen(fom)

		var ev:UIEvent;
		do
		{
			ev=ui_wait_event()
		}while(ev.value!=go1&&ev.value!=bck);

		if(ev.value==go1)
		{
			try
			{
				gtn=fom.get_text().toint();
				if((gtn>0)&&(gtn<=lislen))
				{
					cnt2=2;
					okk=true;
				}
			}catch{}
		}
		//return to music player
		ui_set_screen(prs)
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
println("Creating Playlist...")
set_cwd(wd)//change current working directory

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

//define menu
var play=new_menu("Play",1)
var stop=new_menu("Pause",2)//pause
var exit=new_menu("Exit Player",10)
var resume=new_menu("Resume",3)
var abt=new_menu("About",9);
var options=new_menu("Options",8);
var gto=new_menu("Play track number",4);
var lsempty=flistfilter(wd,"*.lsempty")

if(exists("/res/mpl/audio.png"))
	{
	img=image_from_file("/res/mpl/audio.png");
	}
else
	{
	img=null;
	}

var imgpl:Image;
if(exists("/res/mpl/play.png"))
	{
	imgpl=image_from_file("/res/mpl/play.png");
	}
else
	{
	imgpl=img;
	}

var imgps:Image;
if(exists("/res/mpl/pause.png"))
	{
	imgps=image_from_file("/res/mpl/pause.png");
	}
else
	{
	imgps=img;
	}

//filter out the files from music directory
ls1=flistfilter(wd,"*.aac")
var ls2=flistfilter(wd,"*.mp3")

lislen=(ls1.len+ls2.len)

lis=new_listbox(lsempty,null,null)

var i:Int;
for(i=0,i<ls1.len,i=i+1)
{
	lis.add(ls1[i],img)
}
for(i=0,i<ls2.len,i=i+1)
{
	lis.add(ls2[i],img)
}
println(""+lislen+" songs found.")

//add menu to listbox (lis)
lis.add_menu(exit)
if(lislen!=0)
{
	lis.add_menu(play)
	lis.add_menu(gto)
}
lis.add_menu(abt)
lis.add_menu(options)

lis.set_title("Music Player") lis

//set screen to listbox
println("Music player Started.")
ui_set_screen(lis)
ui_set_app_icon(img)

var fm:Form;
//define new Player
var p:Player;

var fn:String;
var typ:String;

var done:Bool;
done=true
var count=1;
cnt2=1;
var e:UIEvent;
okk=false;

//wait for user to press key
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
		//if player is in stop state then change menu
		if(count==2)
		{
			lis.remove_menu(resume)
			lis.add_menu(stop)
			lis.add_menu(abt)
			lis.add_menu(options)
			count=1;
		}

		//get the name(fn) of selected file from listbox(lis)
		var ind:Int;

		if(cnt2==2)
			{
			ind=gtn-1;
			cnt2=1;
			}
		else
			{
			ind=lis.get_index()
			}
	

		//play the audio file
		try
		{
			var x:Int;
			var gt:Long;
			var gt1:Long;
			var b:Bool;
			b=true;
			var b1:Bool;
			b1=true;
			var b2:Bool;
			b2=true;
			var re:UIEvent;

			for(x=ind,x<lislen,x+=1)
			{
				if(b)
				{
					lis.add_menu(stop)
					try{p.close();}catch{}
	
					//choose the file type
					if(x<ls1.len)
						{
							typ="audio/aac"
						}
					else
						{
							typ="audio/mp3"
						}

					fn=lis.get_string(x)
					if(lis.get_index()==(x-1)&&(ind!=(lislen-1)))
						{
						lis.set_index(x)
						}
					try
					{
						p=new_player(fopen_r(fn),typ)
						p.start()
						lis.set(x,fn,imgpl)
						ui_set_app_icon(imgpl)

						//get the duration of file
						var dur=p.get_duration()
						var du=dur/1000000;
						var title:String;
						if(du>59)
							{
								var min=du/60;
								var sec=du%60;
								title="["+min+":"+sec+"]"+fn
							}
						else
							{
								title="["+du+"s]"+fn
							}

						//set title of listbox to duration and
						//name of current file
						lis.set_title(title)
					}catch{lis.set(x,fn,img);ui_set_app_icon(img);lis.set_title("Unable to play ?");}

					do
					{
						gt=p.get_time()
						sleep(500)
						gt1=p.get_time()
						re=ui_read_event()

						if(re!=null)
						{
							if(re.value==stop)
								{
							 		try
									{
										p.stop()
										lis.set(x,fn,imgps)
										ui_set_app_icon(imgps)
										b1=false;
										lis.remove_menu(stop)
										lis.remove_menu(abt)
										lis.remove_menu(options)
										lis.add_menu(resume)
										count=2;
										re=ui_wait_event()
									}catch{lis.set_title("Music Player")}
								}

							if(re.value==exit) {b=false;p.close();e.value=exit;}
							else if(re.value==play) {b=false;cnt1=2;e.value=play;}
							else if(re.value==abt){About();}
							else if(re.value==options){Options();}
							else if(re.value==gto){Gto();if(okk){b=false;cnt1=2;e.value=play;okk=false;}}

							if(re.value==resume)
								{
									try
									{
										p.start();
										lis.set(x,fn,imgpl)
										ui_set_app_icon(imgpl)
										b1=true;
										lis.remove_menu(resume)
										lis.add_menu(stop)
										lis.add_menu(abt)
										lis.add_menu(options)
										count=1;
									}catch{}
								}
						}
						if(b1==false){b2=true}
						else{b2=(gt!=gt1)}
					}while((b)&&(b2));

					lis.set(x,fn,img)
					ui_set_app_icon(img)

					if(cnt1==1)
						{
						if(x==(lislen-1))
							{
							if(ckiv==false)
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
								lis.set_index(0)
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
		}catch{lis.set_title("Music Player");ui_set_app_icon(img)}
	}catch{}
	}

	if(e.value==gto)
	{
		Gto();
		e.value=play;
	}

	if(e.value==abt)
	{
		About();
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
