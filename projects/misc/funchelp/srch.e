use"io"
use"form"
use"textio"
use"sys"
use "strbuf"
use"string"
use"rmitm.e"
use"cmpr.e"

def srch(list: [String], ei: EditItem, ch1: Int, ch2: Int): String
{
  var indx = 0
  var sb = new_strbuf()
  var ti = new_textitem(" searching:-", "")
  if (n==0) {
    f.add(ti)
    n = 1
  }
  var srhtxt = ei.get_text()
  var result=""
  for (indx=0, indx<list.len && endtxt==srhtxt, indx = indx+1)
  {
    var listxt = list[indx]
    if (srhtxt.len() < listxt.len())
      result = cmpr(listxt, srhtxt.lcase(), ch1, ch2)
    if (result != "") {
    n = n+1
    if (n==2)
      f.remove(1)
      sb = sb.append(result+"\n")
    }
    endtxt = ei.get_text()
  }
  result=sb.tostr()
  result
}