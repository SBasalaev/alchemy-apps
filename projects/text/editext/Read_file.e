def Read_file(args0:String)
{
 list = new_list()
 var is = fopen_r(args0)
 var reader = utfreader(is)
 var str=reader.readline()
 var tmaxsz:Int
 while(str!=null)
 {
  list.add(str)
  str=reader.readline()
 }
 listlen = list.len()
 reader.close()
 is.close()
}

def Reload_file(args0:String)
{
  status = title
  title = "Reloading file..."
  draw_status_area(g)
  tsp=0
  x=0
  Read_file(args0)
  title = status
  Draw_text()
}