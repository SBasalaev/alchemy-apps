/* Pkg library.
 * Copyright (c) 2012-2013, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "io.eh"
use "dict.eh"
use "string.eh"

type PkgSpec < Dict;

def pkgspec_parse(text: String): PkgSpec {
  var spec = new Dict()
  var lines = text.split('\n')
  for (var i=0, i<lines.len, i+=1) {
    var line = lines[i]
    var colon = line.indexof(':')
    if (colon > 0) {
      var key = line[:colon].trim()
      var value = line[colon+1:].trim()
      spec[key] = value
    }
  }
  if (spec["Package"] != null && spec["Version"] != null) {
    spec.cast(PkgSpec)
  } else {
    null
  }
}

def PkgSpec.get(key: String): String = cast (String) `Dict.get`(this, key)

def PkgSpec.set(key: String, value: String) = `Dict.set`(this, key, value)

def PkgSpec.write(out: OStream) {
  var keys = this.keys()
  for (var i=0, i<keys.len, i+=1) {
    out.print(keys[i])
    out.write(':')
    out.write(' ')
    out.println(`Dict.get`(this, keys[i]))
  }
  out.write('\n')
}
