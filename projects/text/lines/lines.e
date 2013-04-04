 
use "io"
use "ui"
use "stdscreens"
use "textio"
use "ui_edit"
use "string"
use "error" 
use "sys" 
use "temp.eh"

var li:ListBox
var code:Bool
var e:EditBox
var go:EditBox 
var sir:EditBox
var ten:ListBox
var event:UIEvent
var edit:Menu
var add:Menu
var save:Menu
var close:Menu
var cut:Menu
var gt:Menu
var searc:Menu
var file:String
var temp:Menu
var copy:Menu
var paste:Menu
var buff:String 

def red() {
 if (!exists(file)) fcreate(file)
var re:Reader =utfreader(fopen_r(file))
 var s:String = re.readline()
 li.clear()
 while (s != null) {
  li.add(s,null)
  s = re.readline()
 if (s == " ") {s=re.readline()
 if (s != null) li.add(" ",null) }
 }
re.close()
  li.add(" ",null)
  }

def writ() {
var wri:Writer = utfwriter(fopen_w(file))
var i:Int
 for (i=0,i<li.len()-1,i+=1) { wri.println(li.get_string(i)) wri.flush() }
 if (li.get_string(li.len()-1).trim() != "") wri.println(li.get_string(li.len()-1))
wri.close()
  }
  
 def edi() {
go.title="Line no. < "+li.len()
go.text="" 
ui_set_screen(go)
event=ui_wait_event()
 while(event.kind != EV_MENU) event=ui_wait_event()
 if (event.value == gt) { if (go.text.toint() <= li.len() && go.text.toint() > 0) li.index=go.text.toint()-1 }
 ui_set_screen(li)
 }
 
def search() {
 ui_set_screen(sir)
 event=ui_wait_event()
 while(event.kind != EV_MENU) event=ui_wait_event()
 if (event.value == searc && sir.text.len()>0) {
 var found:Bool=false
 var i:Int
 for(i=li.index+1, i < li.len() && !found, i=i+1) found= li.get_string(i).find(sir.text) != -1 
 if (i != li.len()) li.index=i-1 }
 ui_set_screen(li)
 }
 
def ed() {
e.title="Line: "+(li.index+1)+" - "+pathfile(file)
e.text=li.get_string(li.index)
ui_set_screen(e)
event=ui_wait_event()
 while(event.kind != EV_MENU) event=ui_wait_event()
  if (event.value == save) li.set(li.index,e.text,null)
  ui_set_screen(li)
 }

def list(l:Int) {
 println("Loading file: "+file)
red()
 ui_set_screen(li)
 li.index=l
var end:Bool=false

while(!end) {
 event = ui_wait_event()
 if (event.value == add) li.insert(li.index," ",null)
 else if(event.value == edit) ed()
 
 else if (event.value ==save) { var tmp:Int=li.index
 ui_set_screen(new_msgbox("Saving file...",null))
 writ()
 red()
 ui_set_screen(li)
 li.index=tmp }
 
 else if (event.value == close) end=true
 else if (event.value == cut) { buff=li.get_string(li.index) li.delete(li.index) }
 else if (event.value == copy) buff=li.get_string(li.index)
 else if (event.value == paste) li.set(li.index,li.get_string(li.index)+buff,null)
 else if (event.value == gt) edi()
 else if (event.value == searc) search()
 else if (event.value==temp) templa(ten,li)
  }
 }

def main(a:[String]):Int {
 if (a.len== 0) { println("Line-by-line text editor:\nSyntax:\nlines <filename>\nlines <filename> [options]\nOptions:\n+<line no.>  Go to a specific line\n-c         Open in code editing mode") 0}
 else if (a[0] == "-h" ) { println("Line-by-line text editor:\nSyntax:\nlines <filename>\nlines <filename> [options]\nOptions:\n+<line no.>  Go to a specific line\n-c         Open in code editing mode") 0}
 else {
var line:Int=0
code=false
 
 for (var i:Int=0, i<a.len, i+=1) {
  if (a[i]=="-c" || a[i].endswith(".e")) code=true
  if (a[i][:1]=="+") line=a[i][1:].toint()
  if (!(a[i].startswith("+") || a[i].startswith("-")) ) file =a[i] }
 
ui_set_app_title(pathfile(file)+" - Lines")
edit=new Menu("Edit",1)
add=new_menu("Add",4)
li=new_listbox(new [String](0),null,edit)
ten=new_listbox(new [String](0),null,add)
e=new_editbox(EDIT_ANY)
go=new_editbox(EDIT_NUMBER)
sir=new_editbox(EDIT_ANY)
gt=new_menu("Goto",3)
searc=new_menu("Search",2)
temp=new Menu("Templates",5)
cut=new_menu("Cut",6)
copy=new_menu("Copy",7)
paste=new_menu("Paste",8)
save=new_menu("Save",9)
close=new_menu("Close",10)
 
li.add_menu(searc)
if(code) li.add_menu(temp)
li.add_menu(add)
li.add_menu(gt)
li.add_menu(cut)
li.add_menu(copy)
li.add_menu(paste)
li.add_menu(save)
li.add_menu(close)
go.add_menu(gt) 
go.add_menu(close)
e.add_menu(save)
e.add_menu(close)
ten.title="Templates"
ten.add_menu(close)
sir.title="Search"
sir.add_menu(searc)
sir.add_menu(close)
buff=""
list(line)
0 }
 }
