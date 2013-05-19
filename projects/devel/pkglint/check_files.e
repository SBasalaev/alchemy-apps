use "checks.eh"
use "io.eh"
use "string.eh"

def check_files_recursive(dir: String) {
  var list = flist(dir)
  for (var i=0, i<list.len, i+=1) {
    var name = list[i]
    if (name[name.len()-1] == '/') {
      if (name == ".svn/" || name == ".git/" || name == ".hg/") {
        report("Package contains VCS directory: " + dir + name, null, TEST_WARN)
      } else {
        check_files_recursive(dir + name)
      }
    } else if (name == ".svnignore" || name == ".gitignore" || name == ".hgignore") {
      report("Package contains VCS control file: " + dir + name, null, TEST_WARN)
    } else if (name == "Thumbs.db" || name == "Thumbs.db.gz") {
      report("Package contains Windows thumbnail database: " + dir + name, null, TEST_WARN)
    } else if (name == ".DS_Store" || name == ".DS_Store.gz") {
      report("Package contains Mac OS X store file: " + dir + name, null, TEST_WARN)
    } else if (name.startswith("._")) {
      report("Package contains Mac OS X resource fork: " + dir + name, null, TEST_WARN)
    }
  }
}

def check_files() {
  var list = flist(".")
  for (var i=0, i<list.len, i+=1) {
    var name = list[i]
    if (name[name.len()-1] == '/') {
      check_files_recursive(name)
    }
  }
}