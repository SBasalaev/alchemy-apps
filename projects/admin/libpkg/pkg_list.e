/* Pkg library.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "pkg_shared.eh"
use "string.eh"
use "textio.eh"

def pkglist_get(list: PkgList, name: String): PkgSpec {
  cast (PkgSpec) ht_get(list.specs, name)
}

def pkglist_put(list: PkgList, spec: PkgSpec) {
  ht_put(list.specs, pkgspec_get(spec, "Package"), spec)
}

def pkglist_remove(list: PkgList, package: String) {
  ht_rm(list.specs, package)
}

def pkglist_read(addr: String, distr: String): PkgList {
  var list = new PkgList(url=addr, dist=distr, specs=new_ht())
  var in = fopen_r("/cfg/pkg/db/sources/"+pkg_addr_escape(addr+distr))
  var r = utfreader(in)
  var sb = new_sb()
  var addspec = false
  var line = freadline(r)
  while (line != null) {
    line = strtrim(line)
    if (strlen(line) > 0) {
      addspec = true
      sb_append(sb, line)
      sb_addch(sb, '\n')
    } else if (addspec == true) {
      var spec = pkgspec_parse(to_str(sb))
      sb = new_sb()
      pkglist_put(list, spec)
      addspec = false
    }
    line = freadline(r)
  }
  if (addspec == true) {
    var spec = pkgspec_parse(to_str(sb))
    pkglist_put(list, spec)
  }
  fclose(in)
  list
}

def pkglist_write(list: PkgList) {
  var packages = ht_keys(list.specs)
  var out = fopen_w("/cfg/pkg/db/sources/"+pkg_addr_escape(list.url+list.dist))
  for (var i=0, i<packages.len, i=i+1) {
    var pkg = to_str(packages[i])
    pkgspec_write(pkglist_get(list, pkg), out)
  }
  fflush(out)
  fclose(out)
}
