/* Pkg library.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "pkg_shared.eh"
use "dataio.eh"
use "string.eh"
use "vector.eh"

def pkg_db_remove(pm: PkgManager, name: String) {
  // reading file list
  var lsfile = "/cfg/pkg/db/lists/"+name+".files"
  var buf = new BArray(fsize(lsfile))
  var in = fopen_r(lsfile)
  freadarray(in, buf, 0, buf.len)
  fclose(in)
  var list = strsplit(ba2utf(buf), '\n')
  // removing files
  for (var i=list.len-1, i>=0, i=i-1) {
    var file = "/"+list[i]
    if (exists(file) && (!is_dir(file) || flist(file).len == 0))
      fremove(file)
  }
  fremove(lsfile)
  // removing database entry
  var instlist = cast(PkgList)pm.lists[0]
  pkglist_remove(instlist, name)
  pkglist_write(instlist)
}

//attribute flags
const A_DIR = 16
const A_READ = 4
const A_WRITE = 2
const A_EXEC = 1

def pkg_arh_list(file: String): Array {
  var in = fopen_r(file)
  // skipping PACKAGE entry
  freadutf(in)
  fskip(in, 9)
  fskip(in, freadint(in))
  // reading file names
  var names = new_vector()
  var f = freadutf(in)
  while (f != null) {
    fskip(in, 8)
    var attrs = freadubyte(in)
    if ((attrs & 16) != 0) {
      v_add(names, f+"/")
    } else {
      v_add(names, f)
      fskip(in, freadint(in))
    }
    f = freadutf(in)
  }
  fclose(in)
  v_toarray(names)
}

def pkg_unarh(file: String) {
  var in = fopen_r(file)
  // skipping PACKAGE entry
  freadutf(in)
  fskip(in, 9)
  fskip(in, freadint(in))
  // unpacking in root
  var f = freadutf(in)
  while (f != null) {
    f = "/"+f
    fskip(in,8)
    var attrs = freadubyte(in)
    if ((attrs & A_DIR) != 0) {
      if (!exists(f)) mkdir(f)
    } else {
      var out = fopen_w(f)
      var len = freadint(in)
      if (len > 0) {
        var buf = new BArray(4096)
        while (len > 4096) {
          freadarray(in, buf, 0, 4096)
          fwritearray(out, buf, 0, 4096)
          len = len - 4096
        }
        freadarray(in, buf, 0, len)
        fwritearray(out, buf, 0, len)
      }
      fflush(out)
      fclose(out)
    }
    set_read(f, (attrs & A_READ) != 0)
    set_write(f, (attrs & A_WRITE) != 0)
    set_exec(f, (attrs & A_EXEC) != 0)
    f = freadutf(in)
  }
  fclose(in)
}

def pkg_arh_unpack(pm: PkgManager, file: String) {
  // extract metadata
  file = abspath(file)
  var spec = pkg_arh_extract_spec(file)
  var name = pkgspec_get(spec, "Package")
  // warn if version decreases
  var oldspec = pkglist_get(cast(PkgList)pm.lists[0], name)
  if (oldspec != null) {
    println("Replacing package "+name+" with new version")
    var cmp = pkg_cmp_versions(pkgspec_get(spec, "Version"), pkgspec_get(oldspec, "Version"))
    if (cmp < 0) println("Warning: version of the package decreases")
    else if (cmp == 0) println("Warning: reinstalling the same version of the package")
    pkg_db_remove(pm, name)
  } else {
    println("Installing new package "+name)
  }
  // writing file list
  var namelist = pkg_arh_list(file)
  var out = fopen_w("/cfg/pkg/db/lists/"+name+".files")
  for (var i=0, i<namelist.len, i=i+1) {
    var buf = utfbytes(to_str(namelist[i]))
    fwritearray(out, buf, 0, buf.len)
    fwrite(out, '\n')
  }
  fclose(out)
  // writing metadata
  var list = cast(PkgList)pm.lists[0]
  pkglist_put(list, spec)
  pkglist_write(list)
  // unpacking archive
  println("Unpacking "+pathfile(file))
  pkg_unarh(file)
}

def pkg_install_seq(pm: PkgManager, names: Array): Array {
  var seq = new_vector()
  var check = new_vector()
  for (var i=0, i<names.len,  i=i+1) {
    if (v_indexof(check, names[i]) < 0) {
      v_add(check, names[i])
    }
  }
  // adding all needed packages and their addresses
  var err = false
  while (v_size(check) > 0 && !err) {
    var name = cast (String) v_get(check, 0)
    v_remove(check, 0)
    if (v_indexof(seq, name) < 0) {
      var instspec = pkg_query_installed(pm, name)
      var newspec = pkg_query(pm, name, cast(String)null)
      if (newspec == null) {
        println("Error: package "+name+" not found in any available source")
        err = true
      } else if (instspec != newspec) {
        // adding new package
        for (var i=1, i<pm.lists.len, i=i+1) {
          var list = cast (PkgList) pm.lists[i]
          if (pkglist_get(list, name) == newspec) {
            i = pm.lists.len
            v_add(seq, name)
            v_add(seq, list.url+"/"+pkgspec_get(newspec, "File"))
          }
        }
        // checking package dependencies
        var depstring = pkgspec_get(newspec, "Depends")
        if (depstring != null) {
          var deps = strsplit(depstring, ',')
          for (var i=0, i<deps.len, i=i+1) {
            var dep = strtrim(to_str(deps[i]))
            if (v_indexof(seq, dep) < 0 && pkg_query_installed(pm, dep) == null) {
              v_add(check, dep)
            }
          }
        }
      }
    }
  }
  if (err)
    cast(Array)null
  else
    v_toarray(seq)
}

def pkg_install(pm: PkgManager, names: Array): Bool {
  var seq = pkg_install_seq(pm, names)
  if (seq != null) {
    // printing package sequence
    println("Packages to be installed:")
    for (var i=0, i<seq.len, i=i+2) {
      if (i != 0) write(',')
      write(' ')
      print(seq[i])
    }
    write('\n')
    // downloading packages
    for (var i=0, i<seq.len, i=i+2) {
      var addr = cast (String) seq[i+1]
      var tmpfile = "/tmp/"+substr(addr, strlindex(addr, '/')+1, strlen(addr))
      println("Get: "+addr)
      var in = pkg_read_addr(addr)
      var out = fopen_w(tmpfile)
      pkg_copyall(in, out)
      fclose(in)
      fclose(out)
      seq[i] = tmpfile
    }
    // installing and removing archives
    for (var i=0, i<seq.len, i=i+2) {
      var arh = cast (String) seq[i]
      pkg_arh_unpack(pm, arh)
      fremove(arh)
    }
  }
  seq != null
}

def pkg_arh_install(pm: PkgManager, file: String): Bool {
  var spec = pkg_arh_extract_spec(file)
  var depstring = pkgspec_get(spec, "Depends")
  var ok = true
  if (depstring != null) {
    var deps = strsplit(depstring, ',')
    for (var i=0, i<deps.len, i=i+1) {
      deps[i] = strtrim(cast(String)deps[i])
    }
    ok = pkg_install(pm, deps)
  }
  if (ok) {
    println("Installing "+pkgspec_get(spec, "Package")+" from archive")
    pkg_arh_unpack(pm, file)
  }
  ok
}

def pkg_installed_rdeps(pm: PkgManager, names: Array): Array {
  var vnames = new_vector()
  for (var i=0, i<names.len, i=i+1) {
    if (v_indexof(vnames, names[i]) < 0) {
      v_add(vnames, names[i])
    }
  }
  var rdeps = new_vector()
  var list = pkg_list_installed(pm)
  for (var i=0, i<list.len, i=i+1) {
    var name = cast(String)list[i]
    if (v_indexof(vnames, name) < 0) {
      var spec = pkg_query_installed(pm, name)
      var depstring = pkgspec_get(spec, "Depends")
      if (depstring != null) {
        var deps = strsplit(depstring, ',')
        for (var j=0, j<deps.len, j=j+1) {
          var dep = strtrim(cast(String)deps[j])
          if (v_indexof(vnames, dep) >= 0) v_add(rdeps, name)
        }
      }
    }
  }
  v_toarray(rdeps)
}

def pkg_remove(pm: PkgManager, names: Array) {
  var deps = pkg_installed_rdeps(pm, names)
  if (deps.len > 0) {
    println("Cannot remove specified packages. There are still packages that depend on them:")
    for (var i=0, i<deps.len, i=i+1) {
      if (i != 0) write(',')
      write(' ')
      print(deps[i])
    }
    write('\n')
  } else {
    for (var i=0, i<names.len, i=i+1) {
      println("Removing package "+names[i])
      pkg_db_remove(pm, to_str(names[i]))
    }
  }
}
