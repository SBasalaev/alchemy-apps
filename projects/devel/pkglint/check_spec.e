use "cfgreader.eh"
use "checks.eh"
use "string.eh"
use "list.eh"

def check_pkg_name(name: String): Bool {
  var ok = name.len() > 1
  for (var i=0, ok && i < name.len(), i += 1) {
    var ch = name[i]
    ok = (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'z') || ("+-.".indexof(ch) >= 0)
  }
  ok
}

def check_pkg_version(version: String): Bool {
  var ok = version.len() > 0 && version[0] >= '0' && version[0] <= '9'
  for (var i=1, ok && i < version.len(), i += 1) {
    var ch = version[i]
    ok = (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'z') || ("+-.~".indexof(ch) >= 0)
  }
  ok
}

def is_num(str: String): Bool {
  var ok = str.len() > 0
  for (var i=0, ok && i < str.len(), i += 1) {
    var ch = str[i]
    ok = (ch >= '0' && ch <= '9')
  }
  ok
}

def check_spec_fields(spec: Dict) {
  // check package field
  var str: String = spec["package"]
  if (str == null) {
    report("missing required field: Package", null, TEST_ERR)
  } else if (!check_pkg_name(str)) {
    report("invalid package name: " + str, "3.1", TEST_ERR)
  }
  // check version field
  str = spec["version"]
  if (str == null) {
    report("missing required field: Version", null, TEST_ERR)
  } else if (!check_pkg_version(str)) {
    report("invalid package version: " + str, "3.2", TEST_ERR)
  } else {
    var hyphen = str.indexof('-')
    if (hyphen <= 0) {
      report("missing package revision number in version", "3.2", TEST_ERR)
    } else if (!is_num(str[hyphen+1:])) {
      report("package revision must be a number", "3.2", TEST_ERR)
    }
  }
  // check summary field
  str = spec["summary"]
  if (str == null) {
    report("missing Summary field", "3.3", TEST_WARN)
  }
  // check section field
  str = spec["section"]
  if (str == null) {
    report("missing Section field", "3.4", TEST_WARN)
  } else {
    var list = new_list()
    list.addall(["admin", "devel", "doc", "graphics", "games", "gui", "libdevel", "libs", "net", "sound", "text", "utils", "video", "misc"])
    if (list.indexof(str) < 0) {
      report("unusual section: " + str, "3.4", TEST_WARN)
    }
    // check if appropriate section is used for name
    var name = spec["package"].tostr()
    var suffix = ""
    if (name.len() >= 4) suffix = name[name.len()-4:]
    if (suffix == "-doc" && str != "-doc") {
      report("Package name suggests that section should be doc", null, TEST_WARN)
    } else if (suffix == "-dev") {
      if (name[:3] == "lib") {
        report("Package name suggests that section should be libdevel", null, TEST_WARN)
      } else {
        report("Package name suggests that section should be devel", null, TEST_WARN)
      }
    }
  }
  // check copyright field
  str = spec["copyright"]
  if (str == null) {
    report("missing Copyright field", "3.6", TEST_WARN)
  }
  // check author field
  str = spec["author"]
  if (str == null) {
    report("missing Author field", "3.7", TEST_WARN)
  }
  // check maintainer field
  str = spec["maintainer"]
  if (str == null) {
    report("missing Maintainer field", "3.8", TEST_WARN)
  }
  // check license field
  str = spec["license"]
  if (str == null) {
    report("missing License field", "3.9", TEST_WARN)
  }
}

def check_spec() {
  var spec = get_spec()
  if (spec != null) check_spec_fields(spec)
}