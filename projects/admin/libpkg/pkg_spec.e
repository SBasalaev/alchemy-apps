/* Pkg library.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "io.eh"
use "hash.eh"
use "string.eh"

type PkgSpec = Hashtable;

def pkgspec_parse(text: String): PkgSpec {
  var spec = new_ht()
  var lines = strsplit(text, '\n')
  for (var i=0, i<lines.len, i=i+1) {
    var line = cast (String) lines[i]
    var colon = strindex(line, ':')
    if (colon > 0) {
      var key = strtrim(substr(line, 0, colon))
      var value = strtrim(substr(line, colon+1, strlen(line)))
      ht_put(spec, key, value)
    }
  }
  if (ht_get(spec, "Package") != null && ht_get(spec, "Version") != null) {
    spec
  } else {
    cast (PkgSpec) null
  }
}

def pkgspec_get(spec: PkgSpec, key: String): String
  = cast (String) ht_get(spec, key)

def pkgspec_set(spec: PkgSpec, key: String, value: String)
  = ht_put(spec, key, value)

def pkgspec_write(spec: PkgSpec, out: OStream) {
  var keys = ht_keys(spec)
  for (var i=0, i<keys.len, i=i+1) {
    fprint(out, keys[i])
    fwrite(out, ':')
    fwrite(out, ' ')
    fprintln(out, ht_get(spec, keys[i]))
  }
  fwrite(out, '\n')
}
