use "pkgutil" 

type PkgManager

def initPkgManager(): PkgManager
def PkgManager.loadPkgLists()

/* Info queries */
def PkgManager.getInstalledPackages(): [Package]
def PkgManager.getInstalledPackage(name: String): Package
def PkgManager.getLatestPackage(name: String): Package
def PkgManager.getPackage(dep: Dependency): Package

/* Hooks for interfaces */
def PkgManager.onFail(handle: (String,Error))
def PkgManager.onWarn(handle: (String))

def PkgManager.onInstallRequest(handle: ([Package]): Bool)
def PkgManager.onRemoveRequest(handle: ([Package]): Bool)

def PkgManager.onInstall(handle: (String,String,Int,Int))
def PkgManager.onRemove(handle: (String,String,Int,Int))
def PkgManager.onDownload(handle: (String,String,Int,Int))

/* Package operations */
def PkgManager.refresh(): Bool
def PkgManager.install(names: [String]): Bool
def PkgManager.update(names: [String] = null): Bool
def PkgManager.remove(names: [String]): Bool
def PkgManager.installFile(file: String): Bool
