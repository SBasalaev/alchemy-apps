// KIn Korean Input
// November 18, 2012
// Kyle Alexander Buan

// Whew! First ever way to input Korean on non-korean phones is here!
// Thanks to Alchemy, this program is possible!
// Please enjoy! :)

use "ui"
use "form"
use "ui_edit"
use "textio"
use "strbuf"
use "list"
use "string"
use "sys"

def getsyl(syl: String): String {
  syl = syl.lcase();
  var data = new_list();
  var nofirst = 0;
  var toadd = 0;
// process a syllable
  var s = new_strbuf();
  s.append(syl + "    ");
  var lcount = 0;
// process a letter (first)
  nofirst = 0;
  toadd = 0;
  if (s[0] == '.') data.add(0)
  else if (s[0] == '!') data.add(0)
  else if (s[0] == '?') data.add(0)
  else {
    if (s[lcount] == 'g') {
      if (s[lcount+1] == 'g') {
        data.add(2);
        toadd = 1; }
      else data.add(1); }
    else if (s[lcount] == 'n') data.add(3)
    else if (s[lcount] == 'd') {
      if (s[lcount+1] == 'd') {
        data.add(5);
        toadd = 1; }
      else data.add(4); }
    else if (s[lcount] == 'r' || s[lcount] == 'l') data.add(6)
    else if (s[lcount] == 'm') data.add(7)
    else if (s[lcount] == 'b') {
      if (s[lcount+1] == 'b') {
        data.add(9);
        toadd = 1; }
      else data.add(8); }
    else if (s[lcount] == 's') {
      if (s[lcount+1] == 's') {
        data.add(11);
        toadd = 1; }
      else data.add(10); }
    else if (s[lcount] == 'j') {
      if (s[lcount+1] == 'j') {
        data.add(14);
        toadd = 1; }
      else data.add(13); }
    else if (s[lcount] == 'c') data.add(15)
    else if (s[lcount] == 'k') data.add(16)
    else if (s[lcount] == 't') data.add(17)
    else if (s[lcount] == 'p') data.add(18)
    else if (s[lcount] == 'h') data.add(19)
    else {
      nofirst = -1;
      data.add(12); } }
  lcount += toadd + 1 + nofirst;
// process a letter (second)
  toadd = 0;
  if (s[0] == '.') data.add(0)
  else if (s[0] == '!') data.add(0)
  else if (s[0] == '?') data.add(0)
  else {
    if (s[lcount] == 'a') {
      if (s[lcount+1] == 'e') {
        data.add(2);
         toadd = 1; }
      else data.add(1); }
    else if (s[lcount] == 'y') {
      if (s[lcount+1] == 'a') {
        if (s[lcount+2] == 'e') {
          data.add(4);
          toadd = 2; }
        else {
          data.add(3);
          toadd = 1; } }
      else if (s[lcount+1] == 'e') {
        if (s[lcount+2] == 'o') {
          data.add(7);
          toadd = 2; }
        else {
          data.add(8);
        toadd = 1; } }
      if (s[lcount+1] == 'o') {
        data.add(13);
        toadd = 1; }
      else if (s[lcount+1] == 'u') {
        data.add(18);
        toadd = 1; }
      else if (s[lcount+1] == 'i') {
        data.add(20);
        toadd = 1; } }
    else if (s[lcount] == 'e') {
      if (s[lcount+1] == 'o') {
        data.add(5);
        toadd = 1; }
      else if (s[lcount+1] == 'u') {
        data.add(19);
        toadd = 1; }
      else data.add(6); }
    else if (s[lcount] == 'o') {
      if (s[lcount+1] == 'e') {
        data.add(12);
        toadd = 1; }
      else data.add(9); }
    else if (s[lcount] == 'w') {
      if (s[lcount+1] == 'a') {
        if (s[lcount+2] == 'e') {
          data.add(11);
          toadd = 2; }
        else {
          data.add(10);
          toadd = 1; } }
      if (s[lcount+1] == 'e') {
        if (s[lcount+2] == 'o') {
          data.add(15);
          toadd = 2; }
        else {
          data.add(16);
          toadd = 1; } }
      if (s[lcount+1] == 'i') {
        data.add(17);
        toadd = 1; } }
    else if (s[lcount] == 'u') data.add(14)
    else if (s[lcount] == 'i') data.add(21); }
  lcount += toadd + 1;
  if (lcount < s.len()-4) {
// process letter (last)
    toadd = 0;
    if (s[lcount] == 'g') {
      if (s[lcount+1] == 'g') {
        data.add(2);
        toadd = 1; }
      else if (s[lcount+1] == 's') {
        data.add(3);
        toadd = 1; }
      else data.add(1); }
    else if (s[lcount] == 'n') {
      if (s[lcount+1] == 'j') {
        data.add(5);
        toadd = 1; }
      else if (s[lcount+1] == 'h') {
        data.add(6);
        toadd = 1; }
      else if (s[lcount+1] == 'g') {
        data.add(21);
        toadd = 1; }
      else data.add(4); }
    else if (s[lcount] == 'd') data.add(7)
    else if (s[lcount] == 'l' || s[lcount] == 'r') {
      if (s[lcount+1] == 'g' || s[lcount+1] == 'k') {
        data.add(9);
        toadd = 1; }
      else if (s[lcount+1] == 'm') {
        data.add(10);
        toadd = 1; }
      else if (s[lcount+1] == 'b') {
        data.add(11);
        toadd = 1; }
      else if (s[lcount+1] == 's') {
        data.add(12);
        toadd = 1; }
      else if (s[lcount+1] == 't') {
        data.add(13);
        toadd = 1; }
      else if (s[lcount+1] == 'p') {
        data.add(14);
        toadd = 1; }
      else if (s[lcount+1] == 'h') {
        data.add(15);
        toadd = 1; }
      else data.add(8); }
    else if (s[lcount] == 'm') data.add(16)
    else if (s[lcount] == 'b') {
      if (s[lcount+1] == 's') {
        data.add(18);
        toadd = 1; }
      else data.add(17); }
    else if (s[lcount] == 's') {
      if (s[lcount+1] == 's') {
        data.add(20);
        toadd = 1; }
      else data.add(19); }
    else if (s[lcount] == 'j') data.add(22)
    else if (s[lcount] == 'c') data.add(23)
    else if (s[lcount] == 'k') data.add(24)
    else if (s[lcount] == 't') data.add(25)
    else if (s[lcount] == 'p') data.add(26)
    else if (s[lcount] == 'h') data.add(27) }
  else {
    if (s[0] == '!') data.add(1)
    else if (s[0] == '?') data.add(2)
    else data.add(0); }
    if ((cast(Int)data[0])+(cast(Int)data[1])+(cast(Int)data[2]) == 0) " "
    else if ((cast(Int)data[0])+(cast(Int)data[1])+(cast(Int)data[2]) == 1) "! "
    else if ((cast(Int)data[0]) == 0 && (cast(Int)data[1]) == 0 && (cast(Int)data[2]) == 2) "? "
    else chstr((cast(Int)data[2]) + ((cast(Int)data[1])-1)*28 + ((cast(Int)data[0])-1)*588 + 44032); }

def convert(l: String): String {
  var data=new_list();
  var syl = l.split(' ');
  var hangul = new_strbuf();;
  for (var sylcount = 0, sylcount < syl.len, sylcount += 1) {
    hangul.append(getsyl(syl[sylcount])); }
  hangul.tostr(); }

def main(args: [String]) {
  var f = new_form();
  f.set_title("KIn v1.2");
  var latin = new_edititem("Latin:", "", EDIT_ANY, 500);
  f.add(latin);
  var hangul = new_edititem("Han geul:", "", EDIT_ANY, 350);
  f.add(hangul);
  var c = new_menu("Convert", 0);
  f.add_menu(c);
  var savehan = new_menu("Save han geul", 1);
  f.add_menu(savehan);
  var savelat = new_menu("Save latin", 2);
  f.add_menu(savelat);
  var exit = new_menu("Exit", 3);
  f.add_menu(exit);
  ui_set_screen(f);
  var event: UIEvent;
  var q = false;
  var lastlen = 0;
  while (!q) {
    event = ui_wait_event();
    if (event.value == c) hangul.set_text(convert(latin.get_text()))
    else if (event.value == savehan) {
      var w = utfwriter(fopen_w("/home/hangul.txt"));
      w.print(hangul.get_text());
      w.close(); }
    else if (event.value == exit) q = true; } }