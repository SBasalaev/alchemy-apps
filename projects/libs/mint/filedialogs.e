use "dialog.eh"
use "themeicon.eh"
use "io.eh"
use "list.eh"
use "string.eh"
use "stdscreens.eh"

/* Ordering function for file names. */
def filecmp(f1: String, f2: String): Int {
  var isdir1 = f1[f1.len()-1] == '/'
  var isdir2 = f2[f2.len()-1] == '/'
  if (isdir1 ^ isdir2) {
    if (isdir1) -1 else 1
  } else {
    f1.lcase().cmp(f2.lcase())
  }
}

def showFolderDialog(title: String, dir: String = null): String {
  // search existing folder
  if (dir == null) dir = get_cwd()
  else dir = abspath(dir)
  while (!is_dir(dir)) dir = pathdir(dir)
  // init UI
  var select = new Menu("Select", 1)
  var cancel = new Menu("Cancel", 2)
  var list = new ListBox(new [String](0), null, select)
  list.title = title
  list.add_menu(cancel)
  // start UI
  var back = ui_get_screen()
  ui_set_screen(list)
  var quit = false
  do {
    // build file list
    list.clear()
    list.add("[This folder - " + pathfile(dir) + "/]", themeIcon(DIALOG_YES))
    list.add("[New folder]", themeIcon(FOLDER_NEW))
    if (dir != "") list.add("..", themeIcon(GO_UP))
    var filearray = flist(dir)
    var filelist = new List()
    for (var i=0, i<filearray.len, i+=1) {
      var file = filearray[i]
      if (file[file.len()-1] == '/') filelist.add(file)
    }
    filelist.sortself(filecmp)
    for (var i=0, i<filelist.len(), i+=1) {
      list.add(filelist[i].cast(String), themeIcon(FOLDER))
    }
    // read answer
    var e: UIEvent
    do {
      e = ui_wait_event()
    } while (e.source != list || e.kind != EV_MENU)
    if (e.value == cancel) {
      dir = null
      quit = true
    } else switch (list.index) {
      0: {
        quit = true
      }
      1: {
        var newfolder = showInput("New folder", "Input name of the new folder")
        if (newfolder != null) {
          if (newfolder == "" || newfolder.indexof('/') >= 0) {
            showError("Error", "Invalid folder name")
          } else try {
            newfolder = abspath(dir + '/' + newfolder)
            mkdir(newfolder)
            dir = newfolder
          } catch (var err) {
            showError("Error", err.tostr())
          }
        }
      }
      else: {
        dir = abspath(dir + '/' + list.get_string(list.index))
      }
    }
  } while (!quit)
  ui_set_screen(back)
  dir
}

def showOpenFileDialog(title: String, dir: String = null, filters: [String] = null): String {
  // search existing folder
  if (dir == null) dir = get_cwd()
  else dir = abspath(dir)
  while (!is_dir(dir)) dir = pathdir(dir)
  // init UI
  var select = new Menu("Select", 1)
  var cancel = new Menu("Cancel", 2)
  var list = new ListBox(new [String](0), null, select)
  list.title = title
  list.add_menu(cancel)
  // start UI
  var back = ui_get_screen()
  ui_set_screen(list)
  var quit = false
  do {
    // build file list
    list.clear()
    if (dir != "") list.add("..", themeIcon(GO_UP))
    var filearray = flist(dir)
    var filelist = new List()
    for (var i=0, i<filearray.len, i+=1) {
      var file = filearray[i]
      if (file[file.len()-1] == '/') {
        filelist.add(file)
      } else {
        var matches = filters == null
        for (var j=0, !matches && j<filters.len, j+=1) {
          matches = matches_glob(file, filters[j])
        }
        if (matches) filelist.add(file)
      }
    }
    filelist.sortself(filecmp)
    for (var i=0, i<filelist.len(), i+=1) {
      var file = filelist[i].cast(String)
      list.add(file, themeIcon(if (file[file.len()-1] == '/') FOLDER else FILE_BINARY))
    }
    // read answer
    var e: UIEvent
    do {
      e = ui_wait_event()
    } while (e.source != list || e.kind != EV_MENU)
    if (e.value == cancel) {
      dir = null
      quit = true
    } else {
      var choice = list.get_string(list.index)
      dir = abspath(dir + '/' + choice)
      if (choice != ".." && choice[choice.len()-1] != '/') {
        quit = true
      }
    }
  } while (!quit)
  ui_set_screen(back)
  dir
}

def showSaveFileDialog(title: String, dir: String = null, filters: [String] = null): String {
  // search existing folder
  if (dir == null) dir = get_cwd()
  else dir = abspath(dir)
  while (!is_dir(dir)) dir = pathdir(dir)
  // init UI
  var select = new Menu("Select", 1)
  var cancel = new Menu("Cancel", 2)
  var list = new ListBox(new [String](0), null, select)
  list.title = title
  list.add_menu(cancel)
  // start UI
  var back = ui_get_screen()
  ui_set_screen(list)
  var quit = false
  do {
    // build file list
    list.clear()
    list.add("[New file]", themeIcon(DOCUMENT_NEW))
    if (dir != "") list.add("..", themeIcon(GO_UP))
    var filearray = flist(dir)
    var filelist = new List()
    for (var i=0, i<filearray.len, i+=1) {
      var file = filearray[i]
      if (file[file.len()-1] == '/') {
        filelist.add(file)
      } else {
        var matches = filters == null
        for (var j=0, !matches && j<filters.len, j+=1) {
          matches = matches_glob(file, filters[j])
        }
        if (matches) filelist.add(file)
      }
    }
    filelist.sortself(filecmp)
    for (var i=0, i<filelist.len(), i+=1) {
      var file = filelist[i].cast(String)
      list.add(file, themeIcon(if (file[file.len()-1] == '/') FOLDER else FILE_BINARY))
    }
    // read answer
    var e: UIEvent
    do {
      e = ui_wait_event()
    } while (e.source != list || e.kind != EV_MENU)
    if (e.value == cancel) {
      dir = null
      quit = true
    } else if (list.index == 0) {
      var newfile = showInput("New file", "Input name of the new file")
      if (newfile != null) {
        if (newfile == "" || newfile.indexof('/') >= 0) {
          showError("Error", "Invalid file name")
        } else {
          dir = abspath(dir + '/' + newfile)
          quit = true
        }
      }
    } else {
      var choice = list.get_string(list.index)
      if (choice == ".." || choice[choice.len()-1] == '/') {
        dir = abspath(dir + '/' + choice)
      } else if (showYesNo("Overwrite file", "File " + choice + " already exists. Overwrite it?")) {
        dir = abspath(dir + '/' + choice)
        quit = true
      }
    }
  } while (!quit)
  ui_set_screen(back)
  dir
}
