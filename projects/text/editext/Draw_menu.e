def Draw_menu()
{
 g.set_font(font)
 g.set_color(0xffff00)
 var ht20 = ht-20
 g.fill_rect(0,ht20,wd,20)
 g.set_color(0)
 small_font=STYLE_BOLD|SIZE_SMALL
 g.set_font(small_font)
 g.draw_string("Edit(5)",0,ht20)
 var size = str_width(small_font,"Menu")
 g.draw_string("Menu",wd/2-(size/2),ht20)
 size = str_width(small_font,"View(#)")
 g.draw_string("View(#)",wd-size,ht20)
}