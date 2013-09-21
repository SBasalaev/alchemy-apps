use "specs.eh"
use "dataio.eh"
use "textio.eh"
use "sys.eh"
use "list.eh"
use "string.eh"
use "error.eh"
use "dict.eh"

def pkgbuild_clean(buildsys: String): Int {
  var exitcode = 0
  try {
    if (exists("PKGBUILD")) {
      println("** purge build dir **")
      exitcode = exec_wait("rm", ["-rf", "PKGBUILD"])
    }
    if (exitcode == 0) {
      if (buildsys == "make") {
        println("** make clean **")
        exitcode = exec_wait("make", ["clean"])
      }
    }
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'clean' failed")
    exitcode = 127
  }
  exitcode
}

def pkgbuild_build(buildsys: String): Int {
  var exitcode = 0
  try {
    if (buildsys == "make") {
      println("** make **")
      exitcode = exec_wait("make", [])
    }
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'build' failed")
    exitcode = 127
  }
  exitcode
}

def pkgbuild_install(buildsys: String, todir: String): Int {
  var exitcode = 0
  try {
    if (!exists("PKGBUILD/" + todir)) exec_wait("mkdir", ["-p", "PKGBUILD/" + todir])
    if (buildsys == "make") {
      println("** make install **")
      exitcode = exec_wait("make", ["install", "DESTDIR=PKGBUILD/" + todir])
    }
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'install' failed")
    exitcode = 127
  }
  exitcode
}

def pkgbuild_genspec(src: Source, pkg: Binary): Int {
  var exitcode = 0
  try {
    if (!exists("PKGBUILD/" + pkg.name)) {
      mkdir("PKGBUILD/" + pkg.name)
    }
    var out = fopen_w("PKGBUILD/" + pkg.name + "/PACKAGE")
    out.println("Package: " + pkg.name)
    out.println("Source: " + src.name)
    out.println("Version: " + if (pkg.version != null) pkg.version else src.version)
    if (pkg.section != null) {
      out.println("Section: " + pkg.section)
    } else if (src.section != null) {
      out.println("Section: " + src.section)
    }
    if (pkg.author != null) {
      out.println("Author: " + pkg.author)
    } else if (src.author != null) {
      out.println("Author: " + src.author)
    }
    if (pkg.maintainer != null) {
      out.println("Maintainer: " + pkg.maintainer)
    } else if (src.maintainer != null) {
      out.println("Maintainer: " + src.maintainer)
    }
    if (pkg.copyright != null) {
      out.println("Copyright: " + pkg.copyright)
    } else if (src.copyright != null) {
      out.println("Copyright: " + src.copyright)
    }
    if (pkg.license != null) {
      out.println("License: " + pkg.license)
    } else if (src.license != null) {
      out.println("License: " + src.license)
    }
    if (pkg.homepage != null) {
      out.println("Homepage: " + pkg.homepage)
    } else if (src.homepage != null) {
      out.println("Homepage: " + src.homepage)
    }
    out.println("Summary: " + if (pkg.summary != null) pkg.summary else "")
    if (pkg.depends.len() > 0) {
      out.print("Depends: ")
      var deplist = pkg.depends
      deplist.sortself(`String.cmp`)
      for (var i=0, i<deplist.len(), i+=1) {
        if (i != 0) out.print(", ")
        out.print(deplist[i])
      }
      out.println("")
    }
    out.close()
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'genspec' failed")
    exitcode = 127
  }
  exitcode
}

def pkgbuild_installfiles(pkg: Binary): Int {
  var exitcode = 0
  try {
    var files = pkg.files.split('\n')
    for (var i=0, exitcode == 0 && i<files.len, i+=1) {
      var path = files[i]
      var fromdir: String
      var todir: String
      var filemask: String
      if (path.len() > 0) {
        var sp = path.indexof(' ')
        if (sp < 0) {
          // installing file from tmp
          fromdir = pathdir("PKGBUILD/tmp/" + path)
          todir = pathdir("PKGBUILD/" + pkg.name + '/' + path)
          filemask = pathfile(path)
        } else {
          // installing file manually
          fromdir = pathdir("./" + path[:sp])
          todir = abspath("PKGBUILD/" + pkg.name + '/' + path[sp:].trim())
          filemask = pathfile(path[:sp])
          path = path[:sp]
        }
        exitcode = exec_wait("mkdir", ["-p", todir])
        var filelist = if (exists(fromdir)) flistfilter(fromdir, filemask) else null
        if (exitcode == 0 && (filelist == null || filelist.len == 0)) {
          exitcode = 1
          stderr().println("pkgbuild: no files matching " + path)
        }
        for (var j=0, exitcode == 0 && j<filelist.len, j+=1) {
          exec_wait("install", [fromdir + '/' + filelist[j], todir])
        }
      }
    }
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'installfiles' failed")
    exitcode = 127
  }
  exitcode
}

def pkgbuild_assemble(src: Source, pkg: Binary): Int {
  var exitcode = 0
  var cwd = get_cwd()
  try {
    println("** assemble " + pkg.name + " **")
    var name = pkg.name
    var version = if (pkg.version != null) pkg.version else src.version
    set_cwd("PKGBUILD/" + name)
    var files = flist(".")
    var args = new [String](files.len + 2)
    args[0] = "c"
    args[1] = "../../../" + name + '_' + version + ".pkg"
    args[2] = "PACKAGE"
    var pos = 3
    for (var i=0, i<files.len, i+=1) {
      if (files[i].ucase() != "PACKAGE") {
        args[pos] = files[i]
        pos += 1
      }
    }
    exitcode = exec_wait("arh", args)
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'assemble' failed")
    exitcode = 127
  }
  set_cwd(cwd)
  exitcode  
}

def pkgbuild_pkglint(src: Source, pkg: Binary): Int {
  try {
    var name = pkg.name
    var version = if (pkg.version != null) pkg.version else src.version
    println("** pkglint " + pkg.name + " **")
    exec_wait("pkglint", ["../" + name + '_' + version + ".pkg"])
    0
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'pkglint' failed")
    127
  }
}

const LFLAG_SONAME = 1  /* Library has soname. */
const LFLAG_DEPS = 2    /* Library has dependencies. */

/* Recursively collects sonames from DEPENDS sections of binary files */
def collect_sodeps(file: String, solist: List) {
  if (is_dir(file)) {
    var subs = flist(file)
    for (var i=0, i<subs.len, i+=1) {
      collect_sodeps(file + subs[i], solist)
    }
  } else {
    var in = fopen_r(file)
    var magic = (in.read() << 8) | in.read()
    if (magic == 0xC0DE) {
      var binver = in.readubyte()
      if (binver != 2) error(ERR_ILL_ARG, "Unsupported binary format: " + binver)
      in.skip(1)
      var flags = in.readubyte()
      if ((flags & LFLAG_SONAME) != 0) {
        in.skip(in.readushort())
      }
      if ((flags & LFLAG_DEPS) != 0) {
        var count = in.readushort()
        for (var i=0, i<count, i+=1) {
          var dep = in.readutf()
          if (solist.indexof(dep) < 0) solist.add(dep)
        }
      }
    }
    in.close()
  }
}

/* Builds map from library names to package names. */
def pkgbuild_libindex(binaries: List): Dict {
  var map = new Dict()
  // scan package database
  var lists = flistfilter("/cfg/pkg/db/lists/", "lib*.files")
  for (var i=0, i<lists.len, i+=1) {
    var listfile = lists[i]
    var r = utfreader(fopen_r("/cfg/pkg/db/lists/" + listfile))
    var line: String;
    while ({line = r.readline(); line != null}) {
      if (line.startswith("lib/") && line != "lib/")
        map[line[4:]] = listfile[:listfile.lindexof('.')]
    }
    r.close()
  }
  // scan just built libraries
  for (var i=0, i<binaries.len(), i+=1) {
    var binary = binaries[i].cast(Binary)
    if (exists("PKGBUILD/" + binary.name + "/lib/")) {
      var locallibs = flist("PKGBUILD/" + binary.name + "/lib/")
      for (var j=0, j<locallibs.len, j+=1) {
        map[locallibs[j]] = binary.name
      }
    }
  }
  map
}

def pkgbuild_libdeps(pkg: Binary, index: Dict): Int {
  var exitcode = 0
  try {
    var root = "PKGBUILD/" + pkg.name
    if (exists(root + "/bin/") || exists(root + "/lib/")) {
      println("** libdeps " + pkg.name + " **")
      // collect dependency sonames
      var solist = new List()
      if (exists(root + "/bin/"))
        collect_sodeps(root + "/bin/", solist)
      if (exists(root + "/lib/"))
        collect_sodeps(root + "/lib/", solist)
      // add dependencies
      var deplist = pkg.depends
      if (solist.len() > 0 && deplist.indexof("${libdeps}") < 0) {
        stderr().println("libdeps warning: has binaries but no ${libdeps} in Depends")
      } else {
        var idx = deplist.indexof("${libdeps}")
        if (idx >= 0) deplist.remove(idx)
        for (var i=0, exitcode == 0 && i<solist.len(), i+=1) {
          var deppkg = index[solist[i]]
          if (deppkg == null) {
            exitcode = 1
            stderr().println("libdeps error: package providing " + solist[i] + " not found")
          } else if (deplist.indexof(deppkg) < 0 && deppkg != pkg.name) {
            deplist.add(deppkg)
          }
        }
      }
    } else if (pkg.depends.indexof("${libdeps}") >= 0) {
      pkg.depends.remove(pkg.depends.indexof("${libdeps}"))
    }
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'libdeps' failed")
    exitcode = 127
  }
  exitcode
}

def pkgbuild_source(src: Source): Int {
  var exitcode = 0
  try {
    println("** zip " + src.name + " **")
    var files = flist(".")
    var args = new [String](files.len + 2)
    args[0] = "-r"
    args[1] = "../" + src.name + '_' + src.version + ".zip"
    acopy(files, 0, args, 2, files.len)
    exitcode = exec_wait("zip", args)
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'libdeps' failed")
    exitcode = 127
  }
  exitcode
}