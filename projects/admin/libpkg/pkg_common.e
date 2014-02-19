use "pkg_private"
use "io"

var instance: PkgManager

def initPkgManager(): PkgManager {
  if (instance != null) return instance
  if (exists(PKG_OLD_FILELIST_DIR)) {
    fmove(PKG_OLD_FILELIST_DIR, PKG_FILELIST_DIR)
  }
  if (exists(PKG_OLD_SOURCELIST_DIR)) {
    fmove(PKG_OLD_SOURCELIST_DIR, PKG_SOURCELIST_DIR)
  }
  if (!exists(PKG_FILELIST_DIR)) {
    mkdirTree(PKG_FILELIST_DIR)
  }
  if (!exists(PKG_SOURCELIST_DIR)) {
    mkdirTree(PKG_SOURCELIST_DIR)
    fcreate(PKG_SOURCELIST_DIR + "installed")
  }
  if (!exists(PKG_SOURCE_LIST)) {
    fcreate(PKG_SOURCE_LIST)
  }
  instance = new PkgManager {
    installedList = emptyPkgList("", ""),
    pkgLists = new [PkgList](0)
  }
  return instance
}

/* Searching package using binary search. */
def PkgList.getPackage(name: String): Package {
  var packages = this.packages
  var low = 0
  var high = packages.len() - 1
  while (low <= high) {
    var c = (high + low) / 2
    var cmp = packages[c].cast(Package).name.cmp(name)
    if (cmp == 0) return packages[c].cast(Package)
    else if (cmp < 0) low = c+1
    else if (cmp > 0) high = c-1
  }
  return null
}

def PkgManager.getInstalledPackage(name: String): Package {
  return this.installedList.getPackage(name)
}

def PkgManager.getLatestPackage(name: String): Package {
  var pkg = this.installedList.getPackage(name)
  for (var list in this.pkgLists) {
    var newpkg = list.getPackage(name)
    if (newpkg != null && (pkg == null || compareVersions(pkg.version, newpkg.version) < 0)) {
      pkg = newpkg
    }
  }
  return pkg
}

def PkgManager.getPackage(dep: Dependency): Package {
  var pkg = this.installedList.getPackage(dep.name)
  if (pkg != null && pkg.satisfies(dep)) return pkg
  for (var list in this.pkgLists) {
    pkg = list.getPackage(dep.name)
    if (pkg != null && pkg.satisfies(dep)) return pkg
  }
  return null
}

def PkgManager.onFail(handle: (String,Error)) {
  this.failHook = handle
}

def PkgManager.onInstall(handle: (String,String,Int,Int)) {
  this.installHook = handle
}

def PkgManager.onRemove(handle: (String,String,Int,Int)) {
  this.removeHook = handle
}

def PkgManager.onDownload(handle: (String,String,Int,Int)) {
  this.downloadHook = handle
}

def PkgManager.onInstallRequest(handle: ([Package]): Bool) {
  this.installRequestHook = handle
}

def PkgManager.onRemoveRequest(handle: ([Package]): Bool) {
  this.removeRequestHook = handle
}

def PkgManager.fail(msg: String, err: Error) {
  if (this.failHook != null) try {
    this.failHook(msg, err)
  } catch { }
}

def PkgManager.installProgress(name: String, version: String, step: Int, total: Int) {
  if (this.installHook != null) try {
    this.installHook(name, version, step, total)
  } catch { }
}

def PkgManager.removeProgress(name: String, version: String, step: Int, total: Int) {
  if (this.removeHook != null) try {
    this.removeHook(name, version, step, total)
  } catch { }
}

def PkgManager.downloadProgress(baseUrl: String, name: String, step: Int, total: Int) {
  if (this.downloadHook != null) try {
    this.downloadHook(baseUrl, name, step, total)
  } catch { }
}

def PkgManager.installRequest(packages: [Package]): Bool {
  if (this.installRequestHook == null) return true
  try {
    return this.installRequestHook(packages)
  } catch {
    return false
  }
}

def PkgManager.removeRequest(packages: [Package]): Bool {
  if (this.removeRequestHook == null) return true
  try {
    return this.removeRequestHook(packages)
  } catch {
    return false
  }
}

def PkgManager.saveInstalledList(): Bool {
  var packages = this.installedList.packages
  try {
    var output = fwrite(PKG_SOURCELIST_DIR + "installed")
    for (var i in 0 .. packages.len()-1) {
      output.print(packages[i].cast(Package).tostr())
    }
    output.flush()
    output.close()
    return true
  } catch (var e) {
    this.fail("Failed to save list of installed packages. The list is probably broken!!", e)
    return false
  }
}
