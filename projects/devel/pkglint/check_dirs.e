use "checks.eh"
use "list.eh"
use "io.eh"

def check_dirs() {
  // check root dirs
  var okpaths = new_list()
  okpaths.addall(["PACKAGE", "bin/", "lib/", "inc/", "res/"])
  var filelist = flist(".")
  for (var i=0, i<filelist.len, i+=1) {
    if (okpaths.indexof(filelist[i]) < 0) {
      var file = filelist[i]
      if (file == "cfg/") {
        report("Package must not install anything in /cfg", "2.7", TEST_ERR)
      } else if (file == "home/") {
        report("Package must not install anything in /home", "2.8", TEST_ERR)
      } else if (file == "tmp/") {
        report("Package must not install anything in /tmp", "2.9", TEST_ERR)
      } else if (is_dir(file)) {
        report("Non-standard directory in root: " + file, "2", TEST_ERR)
      } else {
        report("File in root: " + file, "2", TEST_ERR)
      }
    }
  }
  // check dirs in /bin
  if (is_dir("bin/")) {
    filelist = flist("bin/")
    for (var i=0, i<filelist.len, i+=1) {
      if (is_dir("bin/"+filelist[i]))
        report("Directory in /bin: bin/" + filelist[i], "2.1", TEST_ERR)
    }
  }
}
