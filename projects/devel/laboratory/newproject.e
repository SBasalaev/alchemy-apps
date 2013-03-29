use "newproject.eh"
use "dialog.eh"
use "form.eh"

def run_newproject(): Dict {
  var out = new Dict()
  // input fields
  var pdir = new EditItem("Working dir", "/home/project1/")
  var ptype = new PopupItem("Project type", ["program"])
  var pname = new EditItem("Name", "project1")
  // prepare form
  var form = new Form()
  form.title = "New project"
  form.add_menu(new Menu("Ok", 1, MT_OK))
  form.add(pdir)
  form.add(ptype)
  form.add(pname)
  form.show_modal()
  // output data
  out["DIR"] = pdir.text
  out["TYPE"] = ptype[ptype.index]
  out["TARGET"] = pname.text
  out
}