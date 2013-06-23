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

type NameAndMail {
  name: String,
  mail: String
}

def split_name_email(str: String): NameAndMail {
  var langle = str.indexof('<')
  var rangle = if (langle >= 0)
    langle + str[langle:].indexof('>')
  else
    -1
  if (rangle >= 0) {
    new NameAndMail {
      name = str[:langle].trim(),
      mail = str[langle+1:rangle].trim()
    }
  } else if (str.indexof('@') >= 0) {
    new NameAndMail {
      name = "",
      mail = str
    }
  } else {
    new NameAndMail {
      name = str,
      mail = ""
    }
  }
}

def check_spec_fields(spec: Dict) {
  // check package field
  var str = spec["package"].cast(String)
  if (str == null) {
    report("missing Package field", "3.10", TEST_ERR)
  } else if (!check_pkg_name(str)) {
    report("invalid package name: " + str, "3.10", TEST_ERR)
  }
  // check version field
  str = spec["version"].cast(String)
  if (str == null) {
    report("missing Version field", "3.2", TEST_ERR)
  } else if (!check_pkg_version(str)) {
    report("invalid package version: " + str, "3.2", TEST_ERR)
  }
  // check summary field
  str = spec["summary"].cast(String)
  if (str == null) {
    report("missing Summary field", "3.11", TEST_WARN)
  }
  // check section field
  str = spec["section"].cast(String)
  if (str == null) {
    report("missing Section field", "3.3", TEST_WARN)
  } else {
    var list = new_list()
    list.addall(["admin", "devel", "doc", "graphics", "games", "gui", "libdevel", "libs", "net", "sound", "text", "utils", "video", "misc"])
    if (list.indexof(str) < 0) {
      report("unusual section: " + str, "3.3", TEST_WARN)
    }
    // check if appropriate section is used for name
    var name = spec["package"].tostr()
    var suffix = ""
    if (name.len() >= 4) suffix = name[name.len()-4:]
    if (suffix == "-doc" && str != "-doc") {
      report("Package name suggests that section should be doc", null, TEST_WARN)
    } else if (suffix == "-dev") {
      if (name[:3] == "lib") {
        if (str != "libdevel")
          report("Package name suggests that section should be libdevel", null, TEST_WARN)
      } else if (str != "devel") {
        report("Package name suggests that section should be devel", null, TEST_WARN)
      }
    }
  }
  // check copyright field
  str = spec["copyright"].cast(String)
  if (str == null) {
    report("missing Copyright field", "3.4", TEST_WARN)
  }
  // check author field
  str = spec["author"].cast(String)
  if (str == null) {
    report("missing Author field", "3.5", TEST_WARN)
  }
  // check maintainer field
  str = spec["maintainer"].cast(String)
  if (str != null) {
    var maint = split_name_email(str)
    var authstr = spec["author"].cast(String)
    if (authstr != null) {
      var author = split_name_email(authstr)
      if (author.name == maint.name || author.mail == maint.mail) {
        report("Maintainer field is not needed if the same as Author", "3.6", TEST_WARN)
      }
    }
    if (maint.name == "" || maint.mail == "") {
      report("Maintainer field should be in format\nYour name <your@email>", "3.6", TEST_WARN)
    }
  }
  // check license field
  str = spec["license"].cast(String)
  if (str == null) {
    report("missing License field", "3.7", TEST_WARN)
  } else {
    var licfile = "res/doc/licenses/" + spec["package"] + ".txt"
    var list = new_list()
    list.addall(["MIT", "BSD-2", "BSD-3", "GPL-2", "GPL-3", "LGPL-2.1", "LGPL-3", "GPL-3+exception"])
    if (list.indexof(str) < 0 && !exists(licfile)) {
      report("uncommon license, but no license file: " + licfile, "3.7", TEST_WARN)
    }
  }
  // check for unusual fields
  var knownfields = new_list()
  knownfields.addall(["package", "source", "author", "version",
                      "depends", "conflicts",  "provides",
                      "summary", "section",    "license",
                      "maintainer", "copyright", "homepage"])
  var keys = spec.keys()
  for (var i=0, i<keys.len, i += 1) {
    var key = keys[i]
    if (knownfields.indexof(key) < 0)
      report("unusual field in spec: " + key, "4", TEST_WARN)
  }
}

def check_spec() {
  var spec = get_spec()
  if (spec != null) check_spec_fields(spec)
}