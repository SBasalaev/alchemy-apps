def Draw_text()
{
 g.set_color(0xffffff)
 g.fill_rect(0,20,wd,ht-40)
 draw_status_area(g)
if(listlen>0)
{
 g.set_font(font)
 var y=23
 for(var k=tsp,(k<listlen&&(k-tsp<11)),k+=1)
 {
  g.draw_string(list.get(k).tostr(),x,y)
  y+=25
 }
 var strtpt=cast(Int)((cast(Float)tsp/cast(Float)listlen)*(ht-55))
 g.set_color(0xff0000)
 g.fill_rect(wd-2,strtpt+20,2,15)
 g.set_color(0x606060)
 g.draw_rect(x,23,str_width(font,list.get(tsp).tostr()),25)
}
 c.refresh()
}
