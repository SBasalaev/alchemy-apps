use "dialog.eh"
use "cfg.eh"
use "newproject.eh"
use "laboptions.eh"
use "project.eh"
use "io.eh"
use "sys.eh"
use "ui_edit.eh"
use "error.eh"

def main(args: [String]) {
  // load configuration
  var cfg = new Dict()
  cfg["EDITOR"] = "edit"
  cfg["LAST"] = "/home/project1/"
  if (exists("/cfg/laboratory")) {
    load_cfg(cfg, "/cfg/laboratory")
  }
  // main loop
  var choice: Int;
  do {
    choice = run_listbox(
      "Laboratory",
      ["New project", "Open project", "Preferences"],
      "Select", "Quit")
    switch (choice) {
      0: {
        var projcfg = run_newproject()
        try {
          var dirname = projcfg["DIR"].cast(String)
          if (!exists(dirname)) exec_wait("mkdir", ["-p", dirname])
          set_cwd(dirname)
          cfg["LAST"] = abspath(dirname)
          save_cfg(cfg, "/cfg/laboratory")
          projcfg.remove("DIR")
          projcfg["SOURCES"] = "main.e"
          projcfg["HEADERS"] = ""
          save_cfg(projcfg, "project.lab")
          // create main.e
          var out = fopen_w("main.e")
          out.println("def main(args: [String]) {\n}")
          out.close()
          // create Makefile
          out = fopen_w("Makefile")
          out.println("include project.lab\n")
          var in = fopen_r("/res/laboratory/templates/" + projcfg["TYPE"] + ".mk")
          out.writeall(in)
          in.close()
          out.close()
          // show project page
          run_project(cfg, projcfg)
        } catch (var e) {
          run_msgbox("I/O Error", if (e.msg() != null) e.msg() else "I/O error")
          println(e)
        }
      }
      1: {
        var proj = run_editbox("Choose directory", cfg["LAST"].cast(String), EDIT_ANY)
        if (proj != null) try {
          set_cwd(proj)
          cfg["LAST"] = abspath(proj)
          save_cfg(cfg, "/cfg/laboratory")
          var projcfg = new Dict()
          load_cfg(projcfg, "project.lab")
          run_project(cfg, projcfg)
        } catch (var e) {
          run_msgbox("I/O Error", if (e.msg() != null) e.msg() else "I/O error")
          println(e)
        }
      }
      2: run_options(cfg)
    }
  } while (choice >= 0)
}