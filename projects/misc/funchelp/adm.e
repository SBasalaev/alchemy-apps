def adm(scad: Screen)
{
  me = new_menu("exit",2)
  scad.add_menu(me)
  mab = new_menu("about", 1)
  scad.add_menu(mab)
  mst = new_menu("setting", 0)
  scad.add_menu(mst)
}