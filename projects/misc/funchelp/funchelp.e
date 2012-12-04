use "ui"
use "form"
use "abt.e"

var f: Form
var cntrl: Int
var endtxt: String
var srchtxt: String
var me: Menu
var mab: Menu
var mst: Menu
var n: Int

use "srch.e"
use "open.e"
use "set.e"
use "rd.e"
use "adm.e"
use "sys"

def main(a: [String]) {
  //if(cntrl != 2)
    cntrl = 1
  f = new_form()
  var e = new_edititem("Function name", "", EDIT_ANY, 20)
  f.add(e)
  ui_set_screen(f)
  adm(f)
  var hlist = flist("/inc")
  f.set_title("funchelp")
  var t: Item
  var ev: Menu
  var htxt: String
  while (cntrl != 0) {
    n=0
    srchtxt = e.get_text()
    rmitm(f, 1)
    var ans = ""
    var hindx = 0
    for (hindx = 0, hindx < hlist.len && srchtxt != "" && cntrl != 0 && endtxt == srchtxt, hindx += 1) {
      var hname = hlist[hindx]
      if (cntrl == 1) {
      htxt = open("/inc/"+hname)
      var fnlist = htxt.split(';')
      ans = srch(fnlist, e, ' ', '(')
    }

    if (cntrl==2)
      ans=srch(hlist, e, '0', '0')

    if (n==2 && cntrl==2)
    {
      ans = ans[2: ans.len()-1]
      hname = ans
      ans = open("/inc/"+hname)
    }
    if (cntrl == 2 && hindx != 0)
      ans=""
    if(ans != "")
    {
      t = new_textitem(hname, ans)
      if (cntrl==2 && n != 2)
      t = new_textitem(" ", ans)
      f.add(t)
    }
    if (cntrl==2)
      hindx = hlist.len
      rd(e,f)
      sleep(10)
    }
    if (cntrl != 0)
    {
      if(n==1)
      {
        f.remove(1)
        f.add(new_textitem("No Match Found",""))
      }
      n = 1000
      rd(e,f)
    }  
  }
}