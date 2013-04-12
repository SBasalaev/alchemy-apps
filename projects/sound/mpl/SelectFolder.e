
/*
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
To use this code in your application : 
------------------------------------ -
add  use "SelectFolder.e"  in your code file.
     --- ----------------
&

add ' -lui ' to your compiling options.
      ----

To get folder selected name type :

var FolderName = SelectFolder()
--- ---------- - --------------

then variable 'FolderName' contains the selected folder name or null if user select cancel.

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
*/

use "io"
use "stdscreens"
use "ui"
use "image"
use "sys"

var listfolder:ListBox
var openfolder:Menu

def Add_Remove_menu(dirlen:Int)
{
	if(dirlen!=0)
	{
		listfolder.add_menu(openfolder)
	}
	else
	{
		listfolder.remove_menu(openfolder)
	}
}

def SelectFolder():String
{
	var folder_Icon:Image
	try{folder_Icon=image_from_file("/res/navigator/dir.png")}catch{folder_Icon=null}
	var returnvalue:String;returnvalue=null
	var lstbxindex:Int
	var backPath=new [String](50);backPath[0]="/"
	var backIndex=new [Int](50);backIndex[0]=0
	var BackPathCount=0
	var uievent:UIEvent
	var select_or_cancel=false
	openfolder=new_menu("Open",1,MT_OK)
	var choosefolder=new_menu("Select",2,MT_OK)
	var moveback=new_menu("Back",3,MT_CANCEL)
	var cancelselection=new_menu("Cancel",4,MT_CANCEL)
	var mCard=new_menu("Memory Card",5)
	var local=new_menu("Local folders",5)
	var localDrive=true
	var lsempty=flistfilter("/","*.lsempty")
	listfolder=new_listbox(lsempty,null,null)
	var directorylist=flistfilter("/","*/")

	listfolder.clear()
	for(var i=0,i<directorylist.len,i+=1)
	{
		listfolder.add(directorylist[i],folder_Icon)
	}
	listfolder.add_menu(choosefolder)
	listfolder.add_menu(cancelselection)
	listfolder.add_menu(mCard)
	if(directorylist.len!=0)
	{
		listfolder.add_menu(openfolder)
	}
	listfolder.set_title("/")
	ui_set_screen(listfolder)
	do
	{
		uievent=ui_wait_event()
		if(uievent.value==cancelselection||uievent.value==choosefolder)
		{
			select_or_cancel=true
		}
		else if(uievent.value==openfolder)
		{
		try{
			if(localDrive)
			{
				backPath[0]="/"
			}
			else
			{
				backPath[0]="/tmp/mpl/"
			}
			lstbxindex=listfolder.get_index()
			backIndex[BackPathCount]=lstbxindex
			BackPathCount+=1
			if(BackPathCount>0)
			{
				listfolder.add_menu(moveback)
			}
			backPath[BackPathCount]=listfolder.get_string(lstbxindex)
			var current_directory=""
			for(var j=0,j<BackPathCount,j+=1)
			{
				current_directory=current_directory+backPath[j]
			}
			listfolder.set_title(current_directory+listfolder.get_string(lstbxindex))

			var sub_directory=flistfilter(current_directory+listfolder.get_string(lstbxindex),"*/")

			Add_Remove_menu(sub_directory.len)

			listfolder.clear()
			for(var i=0,i<sub_directory.len,i+=1)
			{
				listfolder.add(sub_directory[i],folder_Icon)
			}
		}catch(var e){println(e)}
		}
		else if(uievent.value==moveback)
		{
			backPath[BackPathCount]=""
			BackPathCount-=1
			if(BackPathCount<=0)
			{
				listfolder.remove_menu(moveback)
			}
			var current_directory=""
			for(var j=0,j<=BackPathCount,j+=1)
			{
				current_directory=current_directory+backPath[j]
			}
			listfolder.set_title(current_directory)
			var sub_directory=flistfilter(current_directory,"*/")

			Add_Remove_menu(sub_directory.len)

			listfolder.clear()
			for(var i=0,i<sub_directory.len,i+=1)
			{
				listfolder.add(sub_directory[i],folder_Icon)
			}
			listfolder.set_index(backIndex[BackPathCount])
		}
		else if (uievent.value==mCard)
		{
			backPath=new [String](50)
			BackPathCount=0
			localDrive=false
			mounted=true
			listfolder.remove_menu(mCard)
			listfolder.add_menu(local)
			try{if(!exists("/tmp/mpl")){mkdir("/tmp/mpl")}}catch{}
			exec_wait("mount",["/tmp/mpl","jsr75","E:/"])
			var sub_directory=flistfilter("/tmp/mpl","*/")

			Add_Remove_menu(sub_directory.len)

			listfolder.clear()
			for(var i=0,i<sub_directory.len,i+=1)
			{
				listfolder.add(sub_directory[i],folder_Icon)
				listfolder.set_title("Memory card/")
			}
		}else if (uievent.value==local)
		{
			backPath=new [String](50)
			BackPathCount=0
			localDrive=true
			mounted=false
			exec_wait("umount",["/tmp/mpl"])
			try{fremove("/tmp/mpl")}catch{}
			listfolder.remove_menu(local)
			listfolder.add_menu(mCard)
			var sub_directory=flistfilter("/","*/")

			Add_Remove_menu(sub_directory.len)

			listfolder.clear()
			for(var i=0,i<sub_directory.len,i+=1)
			{
				listfolder.add(sub_directory[i],folder_Icon)
				listfolder.set_title("/")
			}
		}
	}while(!select_or_cancel)

	if(uievent.value==choosefolder)
	{
		var current_directory=""
		for(var j=0,j<=BackPathCount,j+=1)
		{
			current_directory=current_directory+backPath[j]
		}
		if(listfolder.len()==0)
		{
			returnvalue=current_directory
		}
		else
		{
			returnvalue=current_directory+listfolder.get_string(listfolder.get_index())
		}
	}
	returnvalue
}