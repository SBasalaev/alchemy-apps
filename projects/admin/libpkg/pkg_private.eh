use "pkg"
use "list"

def escapeAddress(addr: String): String

/* Path definitions */

const PKG_DATA_ROOT = "/cfg/pkg/"

const PKG_SOURCE_LIST = PKG_DATA_ROOT + "sources"
const PKG_FILELIST_DIR = PKG_DATA_ROOT + "db/filelists/"
const PKG_SOURCELIST_DIR = PKG_DATA_ROOT + "db/sourcelists/"

const PKG_OLD_FILELIST_DIR = PKG_DATA_ROOT + "db/lists/"
const PKG_OLD_SOURCELIST_DIR =PKG_DATA_ROOT + "db/sources/"

/* Package list */

type PkgList {
  baseUrl: String,
  section: String,
  packages: List
}

def emptyPkgList(baseUrl: String, section: String): PkgList
def PkgList.getPackage(name: String): Package

/* Package manager */

type PkgManager {
  installedList: PkgList,
  pkgLists: [PkgList],
  failHook: (String,Error),
  warnHook: (String),
  installHook: (String,String,Int,Int),
  removeHook: (String,String,Int,Int),
  downloadHook: (String,String,Int,Int),
  installRequestHook: ([Package]): Bool,
  removeRequestHook: ([Package]): Bool
}

def PkgManager.saveInstalledList(): Bool

/* Hook callers */
def PkgManager.fail(msg: String, err: Error)
def PkgManager.warn(msg: String)
def PkgManager.installProgress(name: String, version: String, count: Int, total: Int)
def PkgManager.removeProgress(name: String, version: String, count: Int, total: Int)
def PkgManager.downloadProgress(baseUrl: String, name: String, count: Int, total: Int)
def PkgManager.installRequest(packages: [Package]): Bool
def PkgManager.removeRequest(packages: [Package]): Bool
