/* Pkg library.
 * Copyright (c) 2012-2013, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "pkg_shared.eh"
use "dataio.eh"
use "string.eh"
use "sys.eh"
use "list.eh"

def pkg_init(): PkgManager {
  println("Reading database...")
  new PkgManager{lists=pkg_init_lists()}
}

def pkg_refresh(pm: PkgManager) {
  // removing old lists
  var slist = flist("/cfg/pkg/db/sources/")
  for (var i=0, i<slist.len, i+=1) {
    if (slist[i] != "installed") fremove("/cfg/pkg/db/sources/"+slist[i])
  }
  // getting new lists
  var sources = pkg_read_sourcelist()
  for (var i=0, i<sources.len, i+=1) {
    var line = sources[i]
    var sp = line.indexof(' ')
    var url = line[:sp]
    var dist = line[sp+1:].trim()
    line = url+"/dists/"+dist+"/Packages"
    println("Get: "+line)
    var in = readurl(line)
    var out = fopen_w("/cfg/pkg/db/sources/"+pkg_addr_escape(url+dist))
    out.writeall(in)
    in.close()
    out.close()
  }
  // resetting manager
  pm.lists = pkg_init_lists()
}

def pkg_list_installed(pm: PkgManager): [String] {
  var inst = pm.lists[0]
  var keys = inst.specs.keys()
  var ret = new [String](keys.len)
  acopy(keys, 0, ret, 0, keys.len)
  ret
}

def pkg_list_all(pm: PkgManager): [String] {
  var names = new List()
  for (var i=0, i<pm.lists.len, i+=1) {
    var list = pm.lists[i]
    var listnames = list.specs.keys()
    for (var j=0, j<listnames.len, j+=1) {
      if (names.indexof(listnames[j]) < 0) {
        names.add(listnames[j])
      }
    }
  }
  var ret = new [String](names.len())
  names.copyinto(0, ret, 0, ret.len)
  ret
}

def pkg_query(pm: PkgManager, name: String, ver: String): PkgSpec {
  // search packages in all lists
  var pkg: PkgSpec = null
  var lists = pm.lists
  var specs = new [PkgSpec](lists.len)
  for (var i=0, i<lists.len, i+=1) {
    var list = lists[i]
    var spec = list.get(name)
    specs[i] = spec
    if (ver != null && spec != null
     && spec.get("Version") == ver) {
      pkg = spec
    }
  }
  // choosing most recent package if no version requested
  var version = ver
  if (version == null) {
    pkg = specs[0]
    if (pkg != null) version = pkg.get("Version")
    for (var i=1, i<specs.len, i+=1) {
      var spec = specs[i]
      if (spec != null) {
        if (version == null) {
          pkg = spec
          version = pkg.get("Version")
        } else {
          var newver = spec.get("Version")
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
  pm.lists[0].get(name)
}

const A_DIR = 16

def pkg_arh_extract_spec(file: String): PkgSpec {
  var spec: PkgSpec = null
  var in = fopen_r(file)
  var path = in.readutf().ucase()
  in.skip(8)
  var attrs = in.readubyte()
  if (path == "PACKAGE" && (attrs & A_DIR) == 0) {
    var len = in.readint()
    var buf = new [Byte](len)
    in.readarray(buf, 0, len)
    spec = pkgspec_parse(ba2utf(buf))
  } else {
    println("Error: archive "+file+" is not a correct package")
  }
  in.close()
  spec
}
