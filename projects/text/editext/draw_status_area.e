def draw_status_area(gr:Graphics)
{
 gr.set_color(0xffff00)
 gr.fill_rect(0,0,wd,20)
 gr.set_font(small_font)
 gr.set_color(0)
 gr.draw_string(title,0,0)
 var size = str_width(small_font,"Line : "+(tsp+1)+"/"+listlen)
 gr.set_color(0x00ff00)
 gr.fill_rect(wd-(size+4),0,size+4,20)
 gr.set_color(0)
 gr.draw_string("Line : "+(tsp+1)+"/"+listlen,wd-size,0)
 c.refresh()
}