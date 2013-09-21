/* Since our shell still
 * can not expand file masks we use
 * Ether program to build translations.
 */

use "io"
use "string"
use "sys"

def main(args: [String]): Int {
  var locales = flistfilter("locale/", "*.txt")
  for (var i=0, i<locales.len, i+=1) {
    // strip extension
    var locfile = locales[i]
    locales[i] = locfile[:locfile.lindexof('.')]
  }
  var exitcode = 0
  if (args.len < 1) {
    // build .lc files
    for (var i=0, exitcode == 0 && i<locales.len, i+=1) {
      exitcode = exec_wait("msgfmt", ["locale/" + locales[i] + ".txt", "locale/" + locales[i] + ".lc"])
    }
  } else if (args[0] == "clean") {
    // remove .lc files
    var params = new [String](locales.len+1)
    params[0] = "-f"
    for (var i=0, i < locales.len, i+=1) {
      params[i+1] = "locale/" + locales[i] + ".lc"
    }
    exitcode = exec_wait("rm", params)
  } else if (args[0] == "install") {
    // install .lc files
    var DESTDIR = getenv("DESTDIR")
    for (var i=0, exitcode == 0 && i<locales.len, i+=1) {
      var locdir = DESTDIR + "/res/locale/" + locales[i] + '/'
      exitcode = exec_wait("mkdir", ["-p", locdir])
      exitcode = exec_wait("cp", ["locale/" + locales[i] + ".lc", locdir + "hello.lc"])
    }
  }
  exitcode
}
