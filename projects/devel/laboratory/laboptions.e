use "laboptions.eh"
use "dialog.eh"
use "form.eh"
use "cfg.eh"

def run_options(cfg: Dict) {
  var form = new Form()
  form.title = "Options"
  var editor = new EditItem("Editor", cfg["EDITOR"].cast(String), EDIT_ANY, 40)
  form.add(editor)
  // run
  var ok = new Menu("Ok", 1, MT_OK)
  var cancel = new Menu("Cancel", 2)
  form.add_menu(ok)
  form.add_menu(cancel)
  if (form.show_modal() == ok) {
    cfg["EDITOR"] = editor.text
    save_cfg(cfg, "/cfg/laboratory")
  }
}