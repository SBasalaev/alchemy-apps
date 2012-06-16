/* Utility to work with package archives
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "pkg.eh"
use "io.eh"

const HELP = "Usage: pkg-arh command ...\n\npkg-arh show file\n shows archive info\npkg-arh install file\n installs archive"
const VERSION = "pkg-arh 0.1"

def _print_spec_field(spec: PkgSpec, f: Any) {
  var value = pkgspec_get(spec, to_str(f))
  if (value != null) {
    print(f)
    print(": ")
    println(value)
  }
}

def main(args: Array) {
  if (args.len == 0 || args[0] == "-h") {
    println(HELP)
  } else if (args[0] == "-v") {
    println(VERSION)
  } else if (args[0] == "show") {
    if (args.len == 1) {
      println("pkg-arh show: file not specified")
    } else {
      var spec = pkg_arh_extract_spec(to_str(args[1]))
      var fields = new Array {"Package", "Version", "Summary"}
      for (var j=0, j<fields.len, j=j+1) _print_spec_field(spec, fields[j])
    }
  } else if (args[0] == "install") {
    if (args.len == 1) {
      println("pkg-arh install: file not specified")
    } else {
      pkg_arh_install(pkg_init(), to_str(args[1]))
    }
  }
}
