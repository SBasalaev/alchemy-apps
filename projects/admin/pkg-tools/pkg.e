/* Package manager for Alchemy
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "pkg.eh"
use "io.eh"
use "sys.eh"

const HELP = "Usage: pkg command ...\n\npkg install packages...\n install/update packages\npkg update\n update all packages\npkg remove packages...\n remove packages\npkg refresh\n refresh package lists\npkg show packages...\n show packages info\npkg list\n list available packages"
const VERSION = "pkg 0.1.1"

def _print_spec_field(spec: PkgSpec, f: String) {
  var value = spec.get(f)
  if (value != null) {
    print(f)
    print(": ")
    println(value)
  }
}

def main(args: [String]) {
  if (args.len == 0 || args[0] == "-h") {
    println(HELP)
  } else if (args[0] == "-v") {
    println(VERSION)
  } else if (args[0] == "refresh") {
    pkg_refresh(pkg_init())
  } else if (args[0] == "show") {
    if (args.len == 1) {
      println("pkg show: no packages specified")
    }
    var pm = pkg_init()
    var fields = new [String] {"Package", "Version", "Section", "Depends", "Summary"}
    for (var i=1, i<args.len, i=i+1) {
      var spec = pkg_query(pm, args[i], null)
      if (spec == null) {
        println("pkg show: package "+args[i]+" not found")
      } else {
        for (var j=0, j<fields.len, j=j+1) _print_spec_field(spec, fields[j])
      }
      write('\n')
    }
  } else if (args[0] == "list") {
    var pm = pkg_init()
    var packages = pkg_list_all(pm)
    //TODO: sort alphabetically
    for (var i=0, i<packages.len, i=i+1) {
      if (pkg_query_installed(pm, cast(String)packages[i]) != null)  {
        print("i ")
      } else {
        print("d ")
      }
      println(packages[i])
    }
  } else if (args[0] == "install") {
    if (args.len == 1) {
      println("pkg install: no packages specified")
    } else {
      var pm = pkg_init()
      var names = new Array(args.len-1)
      acopy(args, 1, names, 0, names.len)
      pkg_install(pm, names)
    }
  } else if (args[0] == "update") {
    var pm = pkg_init()
    pkg_install(pm, pkg_list_installed(pm))
  } else if (args[0] == "remove") {
    if (args.len == 1) {
      println("pkg remove: no packages specified")
    } else {
      var pm = pkg_init()
      var names = new Array(args.len-1)
      acopy(args, 1, names, 0, names.len)
      pkg_remove(pm, names)
    }
  } else {
    println("Unknown pkg command: "+args[0])
    println(HELP)
  }
}
