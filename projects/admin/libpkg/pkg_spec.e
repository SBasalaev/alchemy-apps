/* Pkg library.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "io.eh"
use "dict.eh"
use "string.eh"

type PkgSpec < Dict;

def pkgspec_parse(text: String): PkgSpec {
  var spec = new_dict()
  var lines = text.split('\n')
  for (var i=0, i<lines.len, i=i+1) {
    var line = lines[i]
    var colon = line.indexof(':')
    if (colon > 0) {
      var key = line.substr(0, colon).trim()
      var value = line.substr(colon+1, line.len()).trim()
      spec.set(key, value)
    }
  }
  if (spec.get("Package") != null && spec.get("Version") != null) {
    cast (PkgSpec) spec
  } else {
    null
  }
}

def PkgSpec.get(key: String): String = cast (String) `Dict.get`(this, key)

def PkgSpec.set(key: String, value: String) = `Dict.set`(this, key, value)

def PkgSpec.write(out: OStream) {
  var keys = this.keys()
  for (var i=0, i<keys.len, i=i+1) {
    out.print(keys[i])
    out.write(':')
    out.write(' ')
    out.println(`Dict.get`(this, keys[i]))
  }
  out.write('\n')
}
