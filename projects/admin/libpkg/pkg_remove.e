use "pkg_private"
use "pkgfile"
use "io"

// In current implementation package removing is inefficient
// operation because we have to scan entire list of installed
// packages for reverse dependencies. We probably should add
// a field with reverse deps in the Package structure and fill
// it when scanning installed list.

def PkgManager.getReverseDep(pkg: Package): Package {
  var pkglist = this.installedList.packages
  for (var i in 0 .. pkglist.len()-1) {
    var instpkg = pkglist[i].cast(Package)
    for (var dep in instpkg.depends) {
      if (pkg.satisfies(dep)) return instpkg
    }
  }
  return null
}

def PkgManager.makeRemoveSequence(names: [String]): [Package] {
  var namelist = new List()
  var seq = new List()
  for (var name in names) {
    if (namelist.indexof(name) < 0) {
      var pkg = this.getInstalledPackage(name)
      if (pkg != null) {
        var deppkg = this.getReverseDep(pkg)
        if (deppkg == null || deppkg.name in names) {
          namelist.add(name)
          seq.add(pkg)
        } else {
          this.fail("Cannot remove " + name + "\n" + deppkg.name + " depends on it", null)
          return null
        }
      }
    }
  }
  var packages = new [Package](seq.len())
  seq.copyInto(0, packages)
  return packages
}

def PkgManager.remove(names: [String]): Bool {
  // read packages to be removed
  var seq = this.makeRemoveSequence(names)
  if (seq == null) return false
  if (!this.removeRequest(seq) || seq.len == 0) return true

  // remove package files
  var status = true
  var len = seq.len
  for (var i in 0..len-1) try {
    var pkg = seq[i]
    this.removeProgress(pkg.name, pkg.version, i+1, len)
    pkgRemovePackage(pkg.name)
  } catch (var err) {
    this.fail("Failed to fully remove package " + seq[i].name, err)
    status = false
  }

  // removing entries from list of installed packages
  var packages = this.installedList.packages
  for (var i=0, i < packages.len(), {}) {
    var pkg = packages[i].cast(Package)
    if (pkg.name in names) packages.remove(i)
    else i += 1
  }

  // save package list
  return this.saveInstalledList()
}
