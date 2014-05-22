use "pkg/pkgutil"

type SourcePackage {
  name: String,
  version: String,
  author: String,
  maintainer: String,
  copyright: String,
  homepage: String,
  license: String,
  section: String,
  buildDepends: [Dependency],
  buildConflicts: [Dependency],
  customFields: Dict
}

def SourcePackage.new(dict: Dict)

type BinaryPackage {
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
  requiredProperties: [Dependency],
  sharedLibs: Dict,
  onInstall: String,
  onUpdate: String,
  onRemove: String,
  files: String,
  customFields: Dict
}

def BinaryPackage.new(dict: Dict, source: SourcePackage)
