use "io.eh"
use "sys.eh"
use "cfgreader.eh"
use "checks.eh"
use "error.eh"
use "string.eh"

const HELP = "Check binary packages for common errors\n" +
             "Usage: pkglint file.pkg"
const VERSION = "pkglint 0.5"

var errlevel: Int;
var spec: Dict;
var depends: List;

def get_spec(): Dict = spec

def get_depends(): List = depends

def get_errlevel(): Int = errlevel
def set_errlevel(level: Int) = errlevel = level

def main(args: [String]): Int {
  errlevel = TEST_OK
  if (args.len == 0 || args[0] == "-h") {
    println(HELP)
  } else if (args[0] == "-v") {
    println(VERSION)
  } else {
    // unpack package to temp directory
    if (!exists(args[0])) error(TEST_FATAL, "Fatal: file does not exist")
    var workdir = "/tmp/pkglint"
    if (exists(workdir)) error(TEST_FATAL, "Fatal: /tmp/pkglint already exists")
    mkdir(workdir)
    var pkgfile = workdir + "/" + pathfile(args[0])
    fcopy(args[0], pkgfile)
    set_cwd(workdir)
    if (exec_wait("arh", ["x", pkgfile]) != 0) {
      error(TEST_FATAL, "Fatal: failed to unpack " + args[0])
    }
    fremove(pkgfile)
    // extract spec
    if (!exists("PACKAGE")) {
      report("No PACKAGE file", "4", TEST_ERR)
    } else {
      var r = new_cfgreader(utfreader(fopen_r("PACKAGE")), "PACKAGE")
      spec = r.next_section()
      r.close()
      // parse depends
      depends = new_list()
      if (spec["depends"] != null) {
        var deparray = spec["depends"].tostr().split(',')
        for (var i=0, i < deparray.len, i += 1) {
          deparray[i] = deparray[i].trim()
        }
        depends.addall(deparray)
      }
    }
    // perform checks
    try {
      check_spec()
      check_dirs()
      check_libs()
    } catch {
      errlevel = TEST_ERR
    }
    // remove temp directory
    exec_wait("rm", ["-rf", workdir])
  }
  errlevel
}