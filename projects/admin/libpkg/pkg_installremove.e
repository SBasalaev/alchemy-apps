/* Pkg library.
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under LGPL v3
 */

use "pkg_shared.eh"
use "dataio.eh"
use "string.eh"
use "list.eh"

def pkg_db_remove(pm: PkgManager, name: String) {
  // reading file list
  var lsfile = "/cfg/pkg/db/lists/"+name+".files"
  var buf = new BArray(fsize(lsfile))
  var in = fopen_r(lsfile)
  in.readarray(buf, 0, buf.len)
  in.close()
  var list = ba2utf(buf).split('\n')
  // removing files
  for (var i=list.len-1, i>=0, i=i-1) {
    var file = "/"+list[i]
    if (exists(file) && (!is_dir(file) || flist(file).len == 0))
      fremove(file)
  }
  fremove(lsfile)
  // removing database entry
  var instlist = pm.lists[0]
  instlist.remove(name)
  instlist.write()
}

//attribute flags
const A_DIR = 16
const A_READ = 4
const A_WRITE = 2
const A_EXEC = 1

def pkg_arh_list(file: String): Array {
  var in = fopen_r(file)
  // skipping PACKAGE entry
  in.readutf()
  in.skip(9)
  in.skip(in.readint())
  // reading file names
  var names = new_list()
  var f = in.readutf()
  while (f != null) {
    in.skip(8)
    var attrs = in.readubyte()
    if ((attrs & 16) != 0) {
      names.add(f+"/")
    } else {
      names.add(f)
      in.skip(in.readint())
    }
    f = in.readutf()
  }
  in.close()
  names.toarray()
}

def pkg_unarh(file: String) {
  var in = fopen_r(file)
  // skipping PACKAGE entry
  in.readutf()
  in.skip(9)
  in.skip(in.readint())
  // unpacking in root
  var f = in.readutf()
  while (f != null) {
    f = "/"+f
    in.skip(8)
    var attrs = in.readubyte()
    if ((attrs & A_DIR) != 0) {
      if (!exists(f)) mkdir(f)
    } else {
      var out = fopen_w(f)
      var len = in.readint()
      if (len > 0) {
        var buf = new BArray(4096)
        while (len > 4096) {
          in.readarray(buf, 0, 4096)
          out.writearray(buf, 0, 4096)
          len = len - 4096
        }
        in.readarray(buf, 0, len)
        out.writearray(buf, 0, len)
      }
      out.flush()
      out.close()
    }
    set_read(f, (attrs & A_READ) != 0)
    set_write(f, (attrs & A_WRITE) != 0)
    set_exec(f, (attrs & A_EXEC) != 0)
    f = in.readutf()
  }
  in.close()
}

def pkg_arh_unpack(pm: PkgManager, f: String) {
  // extract metadata
  var file = abspath(f)
  var spec = pkg_arh_extract_spec(file)
  var name = spec.get("Package")
  // warn if version decreases
  var oldspec = pm.lists[0].get(name)
  if (oldspec != null) {
    println("Replacing package "+name+" with new version")
    var oldver = oldspec.get("Version")
    var newver = spec.get("Version")
    var cmp = pkg_cmp_versions(newver, oldver)
    if (cmp < 0) println("Warning: version of the package decreases ("+oldver+" -> "+newver+")")
    else if (cmp == 0) println("Warning: reinstalling the same version of the package")
    pkg_db_remove(pm, name)
  } else {
    println("Installing new package "+name)
  }
  // writing file list
  var namelist = pkg_arh_list(file)
  var out = fopen_w("/cfg/pkg/db/lists/"+name+".files")
  for (var i=0, i<namelist.len, i=i+1) {
    var buf = namelist[i].tostr().utfbytes()
    out.writearray(buf, 0, buf.len)
    out.write('\n')
  }
  out.close()
  // writing metadata
  var list = pm.lists[0]
  list.put(spec)
  list.write()
  // unpacking archive
  println("Unpacking "+pathfile(file))
  pkg_unarh(file)
}

def pkg_install_seq(pm: PkgManager, names: Array): Array {
  var seq = new_list()
  var check = new_list()
  for (var i=0, i<names.len,  i=i+1) {
    if (check.indexof(names[i]) < 0) {
      check.add(names[i])
    }
  }
  // adding all needed packages and their addresses
  var err = false
  while (check.len() > 0 && !err) {
    var name = cast (String) check.get(0)
    check.remove(0)
    if (seq.indexof(name) < 0) {
      var instspec = pkg_query_installed(pm, name)
      var newspec = pkg_query(pm, name, null)
      if (newspec == null) {
        println("Error: package "+name+" not found in any available source")
        err = true
      } else if (instspec != newspec) {
        // adding new package
        for (var i=1, i<pm.lists.len, i=i+1) {
          var list = pm.lists[i]
          if (list.get(name) == newspec) {
            i = pm.lists.len
            seq.add(name)
            seq.add(list.url+"/"+newspec.get("File"))
          }
        }
        // checking package dependencies
        var depstring = newspec.get("Depends")
        if (depstring != null) {
          var deps = depstring.split(',')
          for (var i=0, i<deps.len, i=i+1) {
            var dep = deps[i].trim()
            if (seq.indexof(dep) < 0 && pkg_query_installed(pm, dep) == null) {
              check.add(dep)
            }
          }
        }
      }
    }
  }
  if (err)
    null
  else
    seq.toarray()
}

def pkg_install(pm: PkgManager, names: Array): Bool {
  var seq = pkg_install_seq(pm, names)
  if (seq != null) {
    // printing package sequence
    if (seq.len == 0) {
      println("No packages will be installed or updated.")
    } else {
      println("Packages to be installed:")
      for (var i=0, i<seq.len, i=i+2) {
        if (i != 0) write(',')
        write(' ')
        print(seq[i])
      }
    }
    write('\n')
    // downloading packages
    for (var i=0, i<seq.len, i=i+2) {
      var addr = cast (String) seq[i+1]
      var tmpfile = "/tmp/"+addr.substr(addr.lindexof('/')+1, addr.len())
      println("Get: "+addr)
      var in = pkg_read_addr(addr)
      var out = fopen_w(tmpfile)
      pkg_copyall(in, out)
      in.close()
      out.close()
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
  var depstring = spec.get("Depends")
  var ok = true
  if (depstring != null) {
    var deps = depstring.split(',')
    for (var i=0, i<deps.len, i=i+1) {
      deps[i] = deps[i].trim()
    }
    ok = pkg_install(pm, deps)
  }
  if (ok) {
    println("Installing "+spec.get("Package")+" from archive")
    pkg_arh_unpack(pm, file)
  }
  ok
}

def pkg_installed_rdeps(pm: PkgManager, names: Array): Array {
  var vnames = new_list()
  for (var i=0, i<names.len, i=i+1) {
    if (vnames.indexof(names[i]) < 0) {
      vnames.add(names[i])
    }
  }
  var rdeps = new_list()
  var list = pkg_list_installed(pm)
  for (var i=0, i<list.len, i=i+1) {
    var name = cast(String)list[i]
    if (vnames.indexof(name) < 0) {
      var spec = pkg_query_installed(pm, name)
      var depstring = spec.get("Depends")
      if (depstring != null) {
        var deps = depstring.split(',')
        for (var j=0, j<deps.len, j=j+1) {
          var dep = deps[j].trim()
          if (vnames.indexof(dep) >= 0) rdeps.add(name)
        }
      }
    }
  }
  rdeps.toarray()
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
      pkg_db_remove(pm, names[i].tostr())
    }
  }
}
