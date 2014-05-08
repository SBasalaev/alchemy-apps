use "pkg_private"
use "pkgfile"
use "io"

type Conflict {
  pkg: Package,
  dep: Dependency
}

/* Finds reason for this package to not be installed. */
def PkgManager.findConflict(pkg: Package): Conflict {
  for (var conflict in pkg.conflicts) {
    var conflictPackage = this.getInstalledPackage(conflict.name)
    if (conflictPackage != null && conflictPackage.satisfies(conflict)) {
      return new Conflict(conflictPackage, conflict)
    }
  }
  return null
}

/* Builds sequence of packages and their dependencies to install. */
def PkgManager.makeInstallSeq(deps: List): [Package] {
  var seq = new List()
  while (deps.len() > 0) {
    var dep = deps[deps.len()-1].cast(Dependency)
    deps.remove(deps.len()-1)

    // skip if satisfying package is already installed
    var pkg = this.getInstalledPackage(dep.name)
    if (pkg != null && pkg.satisfies(dep)) continue

    // find suitable package
    pkg = this.getPackage(dep)
    if (pkg == null) {
      this.fail("Could not find package " + dep.tostr(), null)
      return null
    }

    // check if similar package is already in sequence
    var inseq = false
    var replaces = false
    for (var i in 0 .. seq.len()-1) {
      var seqpkg = seq[i].cast(Package)
      if (seqpkg.name == pkg.name) {
        inseq = true
        if (seqpkg.satisfies(dep)) {
          if (pkg > seqpkg) {
            seq.remove(i)
            replaces = true
          }
        } else {
          seq.remove(i)
          replaces = true
        }
        break
      }
    }
    if (!inseq || replaces) {
      seq.add(pkg)
      deps.addFrom(pkg.depends)
    }
  }

  // check sequence for conflicts with installed packages
  for (var i in 0 .. seq.len()-1) {
    var pkg = seq[i].cast(Package)
    var conflict = this.findConflict(pkg)
    if (conflict != null) {
      this.fail("Cannot install " + pkg.name + " " + pkg.version + "\nPackage " + conflict.pkg.name + " conflicts: " + conflict.dep.tostr(), null)
      return null
    }
  }
  seq = seq.reverse()
  var packages = new [Package](seq.len())
  seq.copyInto(0, packages)
  return packages
}

def PkgManager.installSeq(seq: [Package]): Bool {
  if (seq == null) return false
  var len = seq.len
  if (!this.installRequest(seq) || len == 0) return true
  var isDirect = new [Bool](len)
  var paths = new [String](len)
  var status = true

  // downloading packages
  for (var i in 0..len-1) {
    var pkg = seq[i]
    this.downloadProgress(pkg.baseUrl, pkg.name, i+1, len)
    if (pkg.baseUrl.startsWith("file:/")) {
      isDirect[i] = true
      paths[i] = pkg.baseUrl[5:] + '/' + pkg.file
    } else {
      var tmpfile = "/tmp/" + pkg.name + '_' + pkg.version + ".pkg"
      paths[i] = tmpfile
      try {
        var input = readUrl(pkg.baseUrl + '/' + pkg.file)
        var output = fwrite(tmpfile)
        output.writeAll(input)
        input.close()
        output.flush()
        output.close()
      } catch (var err) {
        this.fail("Failed to download package " + pkg.name, err)
        status = false
        len = i
        break
      }
    }
  }

  // installing packages
  for (var i in 0..len-1) {
    var pkg = pkgExtractSpec(paths[i])
    this.installProgress(pkg.name, pkg.version, i+1, len)
    try {
      pkgInstallFile(pkg, paths[i])
      if (!isDirect[i]) fremove(paths[i])
    } catch (var err) {
      this.fail("Failed to install package " + pkg.name, err)
      status = false
      len = i
      break
    }
  }

  // saving list of installed packages
  if (len > 0) {
    // insert/replace packages in the list
    var packages = this.installedList.packages
    for (var i in 0..len-1) {
      var pkg = seq[i]
      pkg.file = null
      var low = 0
      var high = packages.len() - 1
      var found = false
      while (!found && low <= high) {
        var c = (high + low) / 2
        var cmp = packages[c].cast(Package).name.cmp(pkg.name)
        if (cmp == 0) { packages[c] = pkg; found = true }
        else if (cmp < 0) low = c+1
        else if (cmp > 0) high = c-1
      }
      if (!found) packages.insert(low, pkg)
    }
    // save package list
    status = this.saveInstalledList()
  }

  return status
}

def PkgManager.install(names: [String]): Bool {
  var deps = new List()
  for (var name in names) {
    var eq = name.indexof('=')
    if (eq > 0) {
      deps.add(new Dependency(name[:eq], REL_EQ, name[eq+1:]))
    } else {
      deps.add(new Dependency(name, REL_NOREL, null))
    }
  }
  return this.installSeq(this.makeInstallSeq(deps))
}

def PkgManager.update(names: [String]): Bool {
  var deps = new List()
  if (names == null || names.len == 0) {
    var packages = this.installedList.packages
    for (var i in 0 .. packages.len()-1) {
      var pkg = this.getLatestPackage(packages[i].cast(Package).name)
      deps.add(new Dependency(pkg.name, REL_GE, pkg.version))
    }
  } else {
    for (var name in names) {
      var pkg = this.getLatestPackage(name)
      if (pkg == null) {
        this.fail("Could not find package " + pkg.name, null)
        return false
      }
      deps.add(new Dependency(pkg.name, REL_GE, pkg.version))
    }
  }
  return this.installSeq(this.makeInstallSeq(deps))
}

def PkgManager.installFile(file: String): Bool {
  try {
    var pkg = pkgExtractSpec(file)

    // searching if already installed
    var instpkg = this.getInstalledPackage(pkg.name)
    if (instpkg != null) {
      var cmp = compareVersions(instpkg.version, pkg.version)
      if (cmp > 0) this.warn("Installing older version of package (" + pkg.version + " over " + instpkg.version + ")")
      if (cmp == 0) this.warn("Installing the same version of package (" + pkg.version + ")")
    }

    // searching for conflicts
    var conflict = this.findConflict(pkg)
    if (conflict != null) {
      this.fail("Cannot install file " + file + "\nPackage " + conflict.pkg.name + " conflicts " + conflict.dep.tostr(), null)
      return false
    }

    // installing file and its dependencies
    var deps = this.makeInstallSeq(new List(pkg.depends))
    var seq = new [Package](deps.len+1)
    acopy(deps, 0, seq, 0, deps.len)
    seq[deps.len] = pkg
    pkg.baseUrl = "file:/"
    pkg.file = abspath(file)

    return this.installSeq(seq)
  } catch (var e) {
    this.fail("Error reading file " + file, e)
    return false
  }
}
