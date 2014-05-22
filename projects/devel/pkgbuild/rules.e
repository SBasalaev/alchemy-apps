use "pkg/pkgutil"
use "dataio"
use "textio"
use "sys"
use "list"
use "dict"
use "strbuf"

use "rules"

def pkgbuild_clean(buildsys: Int): Int {
  var exitcode = SUCCESS
  try {
    if (exists("PKGBUILD")) {
      println("** purge build dir **")
      exitcode = execWait("rm", ["-rf", "PKGBUILD"])
    }
    if (exitcode == 0) switch (buildsys) {
      BUILD_MAKE: {
        println("** make clean **")
        exitcode = execWait("make", ["clean"])
      }
    }
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'clean' failed")
    exitcode = FAIL
  }
  return exitcode
}

def pkgbuild_build(buildsys: Int): Int {
  var exitcode = SUCCESS
  try switch (buildsys) {
    BUILD_MAKE: {
      println("** make **")
      exitcode = execWait("make", [])
    }
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'build' failed")
    exitcode = FAIL
  }
  return exitcode
}

def pkgbuild_install(buildsys: Int, todir: String): Int {
  todir = abspath("PKGBUILD/" + todir)
  try {
    mkdirTree(todir)
    switch (buildsys) {
      BUILD_MAKE: {
        println("** make install **")
        return execWait("make", ["install", "DESTDIR=" + todir])
      }
      else: {
        return SUCCESS
      }
    }
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'install' failed")
    return FAIL
  }
}

def pkgbuild_fieldname(str: String): String {
  if (!str.startsWith("x-")) throw(ERR_ILL_ARG)
  var sb = new StrBuf()
  var dash = str.indexof('-')
  while (dash > 0) {
    sb.append(str[0:0].ucase()).append(str[1:dash+1])
    str = str[dash+1:]
  }
  sb.append(str[0:0].ucase()).append(str[1:])
  return sb.tostr()
}

def OStream.printDeps(deps: [Dependency]) {
  var first = true
  for (var dep in deps) {
    if (first) first = false
    else this.print(", ")
    this.print(dep.tostr())
  }
}

def pkgbuild_genspec(src: SourcePackage, pkg: BinaryPackage): Int {
  try {
    mkdirTree("PKGBUILD/" + pkg.name)
    var out = fwrite("PKGBUILD/" + pkg.name + "/PACKAGE")
    out.println("Package: " + pkg.name)
    out.println("Source: " + src.name)
    out.println("Version: " + pkg.version)
    if (pkg.section != null) {
      out.println("Section: " + pkg.section)
    }
    if (pkg.author != null) {
      out.println("Author: " + pkg.author)
    }
    if (pkg.maintainer != null) {
      out.println("Maintainer: " + pkg.maintainer)
    }
    if (pkg.copyright != null) {
      out.println("Copyright: " + pkg.copyright)
    }
    if (pkg.license != null) {
      out.println("License: " + pkg.license)
    }
    if (pkg.homepage != null) {
      out.println("Homepage: " + pkg.homepage)
    }
    out.println("Summary: " + if (pkg.summary != null) pkg.summary else "")
    if (pkg.depends.len > 0) {
      out.print("Depends: ")
      out.printDeps(pkg.depends)
      out.println("")
    }
    if (pkg.conflicts.len > 0) {
      out.print("Conflicts: ")
      out.printDeps(pkg.conflicts)
      out.println("")
    }
    if (pkg.requiredProperties.len > 0) {
      out.print("Required-Properties: ")
      out.printDeps(pkg.requiredProperties)
      out.println("")
    }
    if (pkg.sharedLibs.len() > 0) {
      out.print("Shared-Libs:")
      for (var lib in pkg.sharedLibs.keys()) {
        out.print("\n " + lib + " ")
        out.printDeps(pkg.sharedLibs[lib].cast([Dependency]))
      }
      out.println("")
    }
    if (pkg.onInstall != null) {
      out.println("On-Install:")
      for (var line in pkg.onInstall.split('\n', false)) {
        out.write(' ')
        if (line == "") out.println(".")
        else out.println(line)
      }
    }
    if (pkg.onUpdate != null) {
      out.println("On-Update:")
      for (var line in pkg.onUpdate.split('\n', false)) {
        out.write(' ')
        if (line == "") out.println(".")
        else out.println(line)
      }
    }
    if (pkg.onRemove != null) {
      out.println("On-Remove:")
      for (var line in pkg.onRemove.split('\n', false)) {
        out.write(' ')
        if (line == "") out.println(".")
        else out.println(line)
      }
    }
    for (var key in pkg.customFields.keys()) {
      out.println(pkgbuild_fieldname(key) + ": " + pkg.customFields[key])
    }
    out.close()
    return SUCCESS
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'genspec' failed")
    return FAIL
  }
}

def pkgbuild_installfiles(pkg: BinaryPackage): Int {
  if (pkg.files == null) return SUCCESS
  try {
    for (var line in pkg.files.split('\n')) {
      if (line.len() == 0) continue
      var fromdir = ""
      var todir = ""
      var filemask = ""
      var sp = line.indexof(' ')
      if (sp < 0) {
        // installing files from PKGBUILD/tmp
        fromdir = pathdir("PKGBUILD/tmp/" + line)
        todir = pathdir("PKGBUILD/" + pkg.name + '/' + line)
        filemask = pathfile(line)
      } else {
        // installing files from source tree
        fromdir = pathdir("./" + line[:sp])
        todir = "PKGBUILD/" + pkg.name + '/' + line[sp:].trim()
        filemask = pathfile(line[:sp])
        line = line[:sp]
      }
      var filelist = if (exists(fromdir)) flistfilter(fromdir, filemask) else null
      if (filelist == null || filelist.len == 0) {
        stderr().println("pkgbuild: no files matching " + line)
        return FAIL
      }
      for (var file in filelist) {
        if (execWait("install", [fromdir + '/' + file, todir]) != SUCCESS) return FAIL
      }
    }
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'installfiles' failed")
    return FAIL
  }
  return SUCCESS
}

def pkgbuild_assemble(src: SourcePackage, pkg: BinaryPackage): Int {
  var exitcode = SUCCESS
  var cwd = getCwd()
  try {
    println("** assemble " + pkg.name + " **")
    var name = pkg.name
    var version = if (pkg.version != null) pkg.version else src.version
    setCwd("PKGBUILD/" + name)
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
    exitcode = execWait("arh", args)
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'assemble' failed")
    exitcode = FAIL
  }
  setCwd(cwd)
  return exitcode  
}

def pkgbuild_pkglint(src: SourcePackage, pkg: BinaryPackage): Int {
  try {
    var name = pkg.name
    var version = if (pkg.version != null) pkg.version else src.version
    println("** pkglint " + pkg.name + " **")
    execWait("pkglint", ["../" + name + '_' + version + ".pkg"])
    return SUCCESS
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'pkglint' failed")
    return FAIL
  }
}

const LFLAG_SONAME = 1  /* Library has soname. */
const LFLAG_DEPS = 2    /* Library has dependencies. */

/* Recursively collects sonames from DEPENDS sections of binary files */
def collect_sodeps(file: String, solist: List) {
  if (isDir(file)) {
    var subs = flist(file)
    for (var i=0, i<subs.len, i+=1) {
      collect_sodeps(file + subs[i], solist)
    }
  } else {
    var input = fread(file)
    var magic = (input.read() << 8) | input.read()
    if (magic == 0xC0DE) {
      var binver = input.readUByte()
      if (binver != 2) throw(ERR_ILL_ARG, "Unsupported binary format: " + binver)
      input.skip(1)
      var flags = input.readUByte()
      if ((flags & LFLAG_SONAME) != 0) {
        input.skip(input.readUShort())
      }
      if ((flags & LFLAG_DEPS) != 0) {
        var count = input.readUShort()
        for (var i=0, i<count, i+=1) {
          var dep = input.readUTF()
          if (solist.indexof(dep) < 0) solist.add(dep)
        }
      }
    }
    input.close()
  }
}

def read_soname(file: String): String {
  var input = fread(file)
  var soname: String
  switch (input.readUShort()) {
    0xC0DE: {
      var binver = input.readUByte()
      if (binver != 2) throw(ERR_ILL_ARG, "Unsupported binary format: " + binver)
      input.skip(1)
      var flags = input.readUByte()
      if ((flags & LFLAG_SONAME) != 0) {
        soname = input.readUTF()
      }
    }
    '#' << 8 | '@': {
      var r = utfreader(input)
      r.readLine()
      while (var line = r.readLine(), line != null) {
        if (line.startsWith("soname=")) soname = line[7:]
      }
    }
    '#' << 8 | '=': { soname = "" }
  }
  input.close()
  return soname
}

def pkgbuild_makeshlibs(pkg: BinaryPackage): Int {
  var libdir = abspath("PKGBUILD/" + pkg.name + "/lib/")
  if (!exists(libdir)) return SUCCESS
  var locallibs = flistfilter(libdir, "*.so")
  for (var lib in locallibs) {
    var soname = read_soname(libdir + '/' + lib)
    if (soname == null) {
      stderr().println("No soname in " + lib)
      return FAIL
    } else if (soname != "" && pkg.sharedLibs[soname] == null) {
      pkg.sharedLibs[soname] = [ new Dependency(pkg.name, REL_NOREL, null) ]
    }
  }
  return SUCCESS
}

def pkgbuild_libindex(binaries: List): Dict {
  var map = new Dict()
  var shlibfiles = flistfilter("/cfg/pkg/db/filelists/", "*.shlibs")
  for (var shlibfile in shlibfiles) {
    var r = utfreader(fread("/cfg/pkg/db/filelists/" + shlibfile))
    while (var line = r.readLine(), line != null) {
      line = line.trim()
      if (line.len() > 0 && line[0] != '#') {
        var sp = line.indexof(' ')
        var soname = line[:sp]
        map[soname] = parseDependencies(line[sp:])
      }
    }
    r.close()
  }
  return map
}

def pkgbuild_libdeps(pkg: BinaryPackage, index: Dict): [Dependency] {
  try {
    var root = "PKGBUILD/" + pkg.name
    // collect dependency sonames
    var solist = new List()
    if (exists(root + "/bin/"))
      collect_sodeps(root + "/bin/", solist)
    if (exists(root + "/lib/"))
      collect_sodeps(root + "/lib/", solist)
    // generate dependencies
    var deplist = new List()
    for (var i=0, i<solist.len(), i+=1) {
      var soname = solist[i].cast(String)
      if (pkg.sharedLibs[soname] != null) continue
      var deps = index[soname].cast([Dependency])
      if (deps == null) {
        stderr().println("libdeps error: package providing " + soname + " not found")
        return null
      } else {
        deplist.addFrom(deps)
      }
    }
    var deparray = new [Dependency](deplist.len())
    deplist.copyInto(0, deparray)
    return deparray
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'libdeps' failed")
    return null
  }
}

def pkgbuild_source(src: SourcePackage): Int {
  try {
    println("** zip " + src.name + " **")
    var files = flist(".")
    var args = new [String](files.len + 2)
    args[0] = "-r"
    args[1] = "../" + src.name + '_' + src.version + ".zip"
    acopy(files, 0, args, 2, files.len)
    return execWait("zip", args)
  } catch (var e) {
    stderr().println(e)
    stderr().println("pkgbuild: target 'libdeps' failed")
    return FAIL
  }
}

def Dependency.cmp(other: Dependency): Int {
  var cmp = this.name.cmp(other.name)
  if (cmp != 0 || this.version == null || other.version == null) return cmp
  return compareVersions(this.version, other.version)
}

def pkgbuild_gendeps(src: SourcePackage, pkg: BinaryPackage, index: Dict): Int {
  // substitute variables in Depends
  println("** gendeps " + pkg.name + " **")
  var deplist = new List()
  for (var dep in pkg.depends) {
    if (dep.name[0] == '$') {
      switch (dep.name) {
        "${libdeps}": {
          var libdeps = pkgbuild_libdeps(pkg, index)
          if (libdeps == null) return FAIL
          deplist.addFrom(libdeps)
        }
        else:
          stderr().println("pkgbuild_gendeps: unknown variable " + dep.name)
      }
      continue;
    }
    if (dep.version != null && dep.version[0] == '$') {
      switch (dep.version) {
        "${version}": {
          dep.version = pkg.version
        }
        "${srcversion}": {
          dep.version = src.version
        }
        else: {
          stderr().println("gendeps: unknown variable " + dep.version)
          dep.relation = REL_NOREL
        }
      }
    }
    deplist.add(dep)
  }

  // sort dependencies and intersect overlapping
  deplist.sortself(`Dependency.cmp`)
  var i = 0
  while (i < deplist.len()-1) {
    var dep1 = deplist[i].cast(Dependency)
    var dep2 = deplist[i+1].cast(Dependency)
    if (dep1.name != dep2.name) {
      i += 1
    } else {
      var equal =
        dep1.version == null || dep2.version == null ||
        compareVersions(dep1.version, dep2.version) == 0
      var fail = false
      switch (dep1.relation) {
        REL_NOREL: {
          deplist.remove(i)
        }
        REL_LT: switch (dep2.relation) {
          REL_NOREL, REL_LT, REL_LE, REL_NE: deplist.remove(i+1)
          REL_GT, REL_GE, REL_EQ: fail = true
        }
        REL_LE: switch (dep2.relation) {
          REL_NOREL, REL_LE: deplist.remove(i+1)
          REL_LT, REL_NE: {
            if (equal) {
              dep1.relation = REL_LT
            }
            deplist.remove(i+1)
          }
          REL_GT: fail = true
          REL_GE, REL_EQ: {
            if (equal) {
              dep1.relation = REL_EQ
              deplist.remove(i+1)
            } else {
              fail = true
            }
          }
        }
        REL_GT: switch (dep2.relation) {
          REL_NOREL: deplist.remove(i+1)
          REL_LT, REL_LE: if (equal) fail = true else i += 1
          REL_GT: deplist.remove(i)
          REL_GE: if (equal) deplist.remove(i) else deplist.remove(i+1)
          REL_EQ: if (equal) fail = true else deplist.remove(i)
          REL_NE: if (equal) deplist.remove(i+1) else i += 1
        }
        REL_GE: switch (dep2.relation) {
          REL_NOREL: deplist.remove(i+1)
          REL_LT: if (equal) fail = true else i += 1
          REL_LE: {
            if (equal) {
              dep1.relation = REL_EQ
              deplist.remove(i+1)
            } else {
              i += 1
            }
          }
          REL_GT, REL_GE, REL_EQ: deplist.remove(i)
          REL_NE: {
            if (equal) {
              dep1.relation = REL_GT
              deplist.remove(i+1)
            } else {
              i += 1
            }
          }
        }
        REL_EQ: switch(dep2.relation) {
          REL_NOREL, REL_LE: deplist.remove(i+1)
          REL_LT, REL_NE: if (equal) fail = true else deplist.remove(i+1)
          REL_GT: fail = true
          REL_GE, REL_EQ: if (equal) deplist.remove(i+1) else fail = true
        }
        REL_NE: switch (dep2.relation) {
          REL_NOREL: deplist.remove(i+1)
          REL_LT, REL_LE: {
            if (equal) {
              dep2.relation = REL_LT
              deplist.remove(i)
            } else {
              i += 1
            }
          }
          REL_GT, REL_GE: {
            if (equal) {
              dep2.relation = REL_GT
            }
            deplist.remove(i)
          }
          REL_EQ: if (equal) fail = true else deplist.remove(i)
          REL_NE: if (equal) deplist.remove(i+1) else i += 1
        }
      }
      if (fail) {
        stderr().println("gendeps: conflicting dependencies " + dep1.tostr() + ", " + dep2.tostr())
        return FAIL
      }
    }
  }

  // update Depends field
  pkg.depends = new [Dependency](deplist.len())
  deplist.copyInto(0, pkg.depends)
  return SUCCESS
}
