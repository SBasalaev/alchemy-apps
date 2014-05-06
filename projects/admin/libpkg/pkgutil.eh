use "dict"

def compareVersions(v1: String, v2: String): Int

/* Dependency class. */

const REL_NOREL = -1
const REL_LT = 0
const REL_LE = 1
const REL_EQ = 2
const REL_NE = 3
const REL_GT = 4
const REL_GE = 5

type Dependency {
  name: String,
  relation: Int = REL_NOREL,
  version: String
}

def Dependency.tostr(): String
def parseDependencies(deps: String): [Dependency]

/* Package class. */

type Package {
  name: String,
  version: String,
  author: String,
  maintainer: String,
  copyright: String,
  homepage: String,
  license: String,
  section: String,
  summary: String,
  depends: [Dependency],
  conflicts: [Dependency],
  sharedLibs: String,
  onInstall: String,
  onUpdate: String,
  onRemove: String,
  baseUrl: String,
  file: String,
  size: Int = 0
}

def Package.new(dict: Dict)
def Package.satisfies(dep: Dependency): Bool
def Package.cmp(other: Package): Int
def Package.tostr(): String
