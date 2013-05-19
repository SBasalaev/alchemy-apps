use "checks.eh"
use "dataio.eh"
use "textio.eh"
use "string.eh"
use "strbuf.eh"
use "list.eh"

const LFLAG_SONAME = 1;
const LFLAG_DEPS = 2;

const MAGIC_LINK = ('#' << 8) | '='
const MAGIC_SH   = ('#' << 8) | '!'
const MAGIC_NLIB = ('#' << 8) | '@'
const MAGIC_ELIB = 0xC0DE

def libtopkgname(name: String): String {
  name = name[:name.len()-3].lcase()
  var sb = new_strbuf()
  for (var i=0, i<name.len(), i += 1) {
    var ch = name[i]
    if (ch == '.') {
      // dot is skipped
    } else if ((ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9')) {
      sb.addch(ch)
    } else {
      sb.addch('-')
    }
  }
  sb.tostr()
}

def check_libname(name: String) {
  var spec = get_spec()
  if (spec != null) {
    var realname = spec["package"]
    var mustname = libtopkgname(name)
    if (mustname != realname) {
      report("Library " + name + " should be installed in package " + mustname, "5.1", TEST_WARN)
    }
  }
}

def check_binary(file: String) {
  var dir = file[:file.indexof('/')]
  // check file magic
  var in = fopen_r(file)
  var magic = try in.readushort() catch -1
  if (magic != MAGIC_ELIB && magic != MAGIC_LINK && magic != MAGIC_NLIB && magic != MAGIC_SH) {
    report("Installed in /" + dir + " but not executable: " + file, "2.1", TEST_ERR)
  }
  in.close()
}

def check_shlib(file: String) {
  var in = fopen_r(file)
  var magic = in.readushort()
  // check if package name is correct
  if (magic != MAGIC_LINK) {
    check_libname(pathfile(file))
  }
  // check if soname is set
  if (magic == MAGIC_NLIB) {
    // TODO: read soname
  } else if (magic == MAGIC_ELIB) {
    in.skip(2)
    var lflags = in.readubyte()
    if ((lflags & LFLAG_SONAME) == 0) {
      report("Public library without soname: " + file, "2.2", TEST_ERR)
    } else {
      var soname = in.readutf()
      if (!exists("lib/" + soname))
        report("Soname mentions file that is not provided by this package: " + soname, null, TEST_WARN)
    }
  }
  in.close()
}

def check_libs() {
  // check libs in bin directory
  if (is_dir("bin/")) {
    var files = flist("bin/")
    for (var i=0, i<files.len, i+=1) {
      if (!is_dir("bin/"+files[i])) check_binary("bin/"+files[i])
    }
  }
  // check libs in lib directory recursively
  if (is_dir("lib/")) {
    var files = flist("lib/")
    for (var i=0, i<files.len, i+=1) {
      if (is_dir("lib/"+files[i])) {
        // TODO: check_binaries_in("lib/"+files[i])
      } else {
        var file = "lib/" + files[i]
        check_binary(file)
        check_shlib(file)
      }
    }
  }
}
