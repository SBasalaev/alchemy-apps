/* Pkg library.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "pkg_shared.eh"
use "strbuf.eh"
use "string.eh"
use "textio.eh"

def PkgList.get(name: String): PkgSpec {
  cast (PkgSpec) this.specs.get(name)
}

def PkgList.put(spec: PkgSpec) {
  this.specs.set(spec.get("Package"), spec)
}

def PkgList.remove(package: String) {
  this.specs.remove(package)
}

def pkglist_read(addr: String, distr: String): PkgList {
  var list = new PkgList(url=addr, dist=distr, specs=new_dict())
  var r = utfreader(fopen_r("/cfg/pkg/db/sources/"+pkg_addr_escape(addr+distr)))
  var sb = new_strbuf()
  var addspec = false
  var line = r.readline()
  while (line != null) {
    line = line.trim()
    if (line.len() > 0) {
      addspec = true
      sb.append(line)
      sb.addch('\n')
    } else if (addspec == true) {
      var spec = pkgspec_parse(sb.tostr())
      sb = new_strbuf()
      list.put(spec)
      addspec = false
    }
    line = r.readline()
  }
  if (addspec == true) {
    var spec = pkgspec_parse(sb.tostr())
    list.put(spec)
  }
  r.close()
  list
}

def PkgList.write() {
  var packages = this.specs.keys()
  var out = fopen_w("/cfg/pkg/db/sources/"+pkg_addr_escape(this.url+this.dist))
  for (var i=0, i<packages.len, i=i+1) {
    var pkg = packages[i].tostr()
    this.get(pkg).write(out)
  }
  out.flush()
  out.close()
}
