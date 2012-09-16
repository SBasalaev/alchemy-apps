use"io"
use"form"
use"textio"
use"sys"
use"string"
use"rmitm.e"
use"cmpr.e"

def srch(list: Array, ei: Item, ch1: Int, ch2: Int): String
{
  var indx = 0
  var sb = new_sb()
  var ti = new_textitem(" searching:-", "")
  if (n==0) {
    form_add(f,ti)
    n = 1
  }
  var srhtxt = edititem_get_text(ei)
  var result=""
  for (indx=0, indx<list.len && endtxt==srhtxt, indx = indx+1)
  {
    var listxt = to_str(list[indx])
    if (strlen(srhtxt) < strlen(listxt))
      result = cmpr(listxt, strlcase(srhtxt), ch1, ch2)
    if (result != "") {
    n = n+1
    if (n==2)
      form_remove(f,1)
      sb = sb_append(sb, result+"\n")
    }
    endtxt = edititem_get_text(ei)
  }
  result=to_str(sb)
  result
}