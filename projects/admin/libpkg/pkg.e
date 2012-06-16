/* Pkg library.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "pkg_shared.eh"
use "dataio.eh"
use "net.eh"
use "string.eh"
use "sys.eh"
use "vector.eh"

def pkg_init(): PkgManager {
  new PkgManager(lists=pkg_init_lists())
}

def pkg_refresh(pm: PkgManager) {
  // removing old lists
  var slist = flist("/cfg/pkg/db/sources/")
  for (var i=0, i<slist.len, i=i+1) {
    if (slist[i] != "installed") fremove("/cfg/pkg/db/sources/"+slist[i])
  }
  // getting new lists
  var sources = pkg_read_sourcelist()
  for (var i=0, i<sources.len, i=i+1) {
    var line = cast(String) sources[i]
    var sp = strindex(line, ' ')
    var url = substr(line, 0, sp)
    var dist = strtrim(substr(line, sp+1, strlen(line)))
    line = url+"/dists/"+dist+"/Packages"
    println("Get: "+line)
    var in = pkg_read_addr(line)
    var out = fopen_w("/cfg/pkg/db/sources/"+pkg_addr_escape(url+dist))
    pkg_copyall(in, out)
    fclose(in)
    fclose(out)
  }
  // resetting manager
  pm.lists = pkg_init_lists()
}

def pkg_list_installed(pm: PkgManager): Array {
  var inst = cast(PkgList)pm.lists[0]
  ht_keys(inst.specs)
}

def pkg_list_all(pm: PkgManager): Array {
  var names = new_vector()
  for (var i=0, i<pm.lists.len, i=i+1) {
    var list = cast(PkgList)pm.lists[i]
    var listnames = ht_keys(list.specs)
    for (var j=0, j<listnames.len, j=j+1) {
      if (v_indexof(names, listnames[j]) < 0) {
        v_add(names, listnames[j])
      }
    }
  }
  v_toarray(names)
}

def pkg_query(pm: PkgManager, name: String, version: String): PkgSpec {
  // search packages in all lists
  var pkg: PkgSpec = null
  var lists = pm.lists
  var specs = new Array(lists.len)
  for (var i=0, i<lists.len, i=i+1) {
    var list = cast (PkgList) lists[i]
    var spec = pkglist_get(list, name)
    specs[i] = spec
    if (version != null && spec != null
     && pkgspec_get(spec, "Version") == version) {
      pkg = spec
    }
  }
  // choosing most recent package if no version requested
  if (version == null) {
    pkg = cast (PkgSpec) specs[0]
    if (pkg != null) version = pkgspec_get(pkg, "Version")
    for (var i=1, i<specs.len, i=i+1) {
      var spec = cast (PkgSpec) specs[i]
      if (spec != null) {
        if (version == null) {
          pkg = spec
          version = pkgspec_get(pkg, "Version")
        } else {
          var newver = pkgspec_get(spec, "Version")
          if (pkg_cmp_versions(newver, version) > 0) {
            pkg = spec
            version = newver
          }
        }
      }
    }
  }
  pkg
}

def pkg_query_installed(pm: PkgManager, name: String): PkgSpec {
  var inst = cast(PkgList)pm.lists[0]
  pkglist_get(inst, name)
}

const A_DIR = 16

def pkg_arh_extract_spec(file: String): PkgSpec {
  var spec: PkgSpec = null
  var in = fopen_r(file)
  var path = freadutf(in)
  fskip(in, 8)
  var attrs = freadubyte(in)
  if (path == "PACKAGE" && (attrs & A_DIR) == 0) {
    var len = freadint(in)
    var buf = new BArray(len)
    freadarray(in, buf, 0, len)
    spec = pkgspec_parse(ba2utf(buf))
  }
  spec
}
