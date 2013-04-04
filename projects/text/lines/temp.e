use "ui"
use "stdscreens"
use "textio"
use "io"
use "string"
 
 def give(a:String):String {
  var temple:IStream=fopen_r("/res/lines/templates/"+(a.split(' ')[0]) + ".tmp");
 var arr:[Byte]=temple.readfully();
 temple.close();
 ba2utf(arr);
  }
 
def templa(a:ListBox,b:ListBox) {
 ui_set_screen(a)
 a.clear()
 var temps=flistfilter("/res/lines/templates/","*.tmp")
 for (var i:Int=0,i<temps.len, i+=1) a.add(temps[i].split('.')[0]+" block",null)
 
  var eve:UIEvent=ui_wait_event()
 while(eve.kind != EV_MENU) eve=ui_wait_event()
  if (eve.value.cast(Menu).text == "Add") b.insert(b.index,give(a.get_string(a.index)),null);
 ui_set_screen(b)
 } 
