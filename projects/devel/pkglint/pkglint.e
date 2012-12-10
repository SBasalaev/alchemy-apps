use "io.eh"
use "sys.eh"
use "cfgreader.eh"
use "checks.eh"

const HELP = "Check binary packages for common errors\n" +
             "Usage: pkglint file.pkg"
const VERSION = "pkglint 0.1"

var errlevel: Int;
var spec: Dict;

def get_spec(): Dict {
  spec
}

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
    var workdir = "/tmp/pkglint"
    mkdir(workdir)
    var pkgfile = workdir + "/" + pathfile(args[0])
    fcopy(args[0], pkgfile)
    set_cwd(workdir)
    if (exec_wait("arh", ["x", pkgfile]) != 0) {
      report("Fatal: failed to unpack " + args[0], null, TEST_ERR)
    }
    fremove(pkgfile)
    // extract spec
    if (!exists("PACKAGE")) {
      report("No PACKAGE file", "3", TEST_ERR)
    } else {
      var r = new_cfgreader(utfreader(fopen_r("PACKAGE")), "PACKAGE")
      spec = r.next_section()
      r.close()
    }
    // perform checks
    check_spec()
    check_dirs()
    check_libs()
    // remove temp directory
    exec_wait("rm", ["-rf", workdir])
  }
  errlevel
}