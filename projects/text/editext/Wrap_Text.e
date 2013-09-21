def Wrap_Text(args0:String,txtfnt:Int,wid:Int):List
{
    var templist = new List()
    if(str_width(txtfnt,args0)>wid)
    {
     var ch = args0.chars()
     args0 = ""
     var al=0
     while(al<ch.len)
     {
      while(str_width(txtfnt,args0)<wid && al<ch.len)
      {
       args0+=""+ch[al]
       al+=1
      }
      //if(al<ch.len && ch[al-1]!=' ' && ch[al]!=' ')args0+="-"
      templist.add(args0)
      args0 = ""
     }
    }
    else templist.add(args0)
    templist
}
