/*next feature
rearrange lines
 */
 
use "io"
use "ui"
use "stdscreens"
use "textio"
use "ui_edit"
use "string"

var li:ListBox
var e:EditBox
var go:EditBox 
var event:UIEvent
var edit:Menu
var add:Menu
var save:Menu
var close:Menu
var rem:Menu
var gt:Menu
var file:String

def red() {
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

def ed() {
e.title="Line: "+(li.index+1)
e.text=li.get_string(li.index)
ui_set_screen(e)
event=ui_wait_event()
 while(event.kind != EV_MENU) event=ui_wait_event()
  if (event.value == save) li.set(li.index,e.text,null)
  ui_set_screen(li)
 }

def list() {
 println("Loading file: "+file)
red()
 ui_set_screen(li)
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
 else if (event.value == rem) li.delete(li.index)
 else if (event.value == gt) edi()
  }
 }

def main(a:[String]):Int {
 if (a[0] == "-h" || a.len== 0) { println("Line-by-line text editor:\nSyntax: line file") 0}
 else {
file = a[0]
ui_set_app_title(pathfile(file))
edit=new_menu("Edit",1)
li=new_listbox(new [String](0),null,edit)
e=new_editbox(EDIT_ANY)
go=new_editbox(EDIT_NUMBER)
gt=new_menu("Goto",2)
add=new_menu("Add",3)
rem=new_menu("Remove",4)
save=new_menu("Save",5)
close=new_menu("Close",6)
li.add_menu(add)
li.add_menu(gt)
li.add_menu(rem)
li.add_menu(save)
li.add_menu(close)
go.add_menu(gt) 
go.add_menu(close)
e.add_menu(save)
e.add_menu(close)
list() 
0 }
 }
