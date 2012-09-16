def adm(scad: Screen)
{
  me = new_menu("exit",2)
  screen_add_menu(scad, me)
  mab = new_menu("about", 1)
  screen_add_menu(scad, mab)
  mst = new_menu("setting", 0)
  screen_add_menu(scad, mst)
}