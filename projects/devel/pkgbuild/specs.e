use "specs"
use "io"
use "strbuf"

def SourcePackage.new(dict: Dict) {
  this.customFields = new Dict()
  this.buildDepends = new [Dependency](0)
  this.buildConflicts = this.buildDepends
  for (var key:String in dict.keys()) {
    var value = dict[key].cast(String)
    switch (key) {
      "source":
        this.name = value
      "version":
        this.version = value
      "author":
        this.author = value
      "maintainer":
        this.maintainer = value
      "copyright":
        this.copyright = value
      "homepage":
        this.homepage = value
      "license":
        this.license = value
      "section":
        this.section = value
      "build-depends":
        this.buildDepends = parseDependencies(value)
      "build-conflicts":
        this.buildConflicts = parseDependencies(value)
      else:
        if (key.startsWith("x-")) {
          this.customFields[key] = value
        } else {
          stderr().println("Unknown key: " + key)
        }
    }
  }
}

def parseSharedLibs(libs: Dict, text: String) {
  for (var line in text.split('\n', true)) {
    line = line.trim()
    if (line.len() > 0) {
      var sp = line.indexof(' ')
      libs[line[:sp]] = parseDependencies(line[sp:])
    }
  }
}

def BinaryPackage.new(dict: Dict, source: SourcePackage) {
  this.customFields = new Dict()
  this.sharedLibs = new Dict()
  this.version = source.version
  this.author = source.author
  this.maintainer = source.maintainer
  this.copyright = source.copyright
  this.homepage = source.homepage
  this.license = source.license
  this.section = source.section
  this.depends = new [Dependency](0)
  this.conflicts = this.depends
  this.requiredProperties = this.depends
  for (var key:String in dict.keys()) {
    var value = dict[key].cast(String)
    switch (key) {
      "package":
        this.name = value
      "version":
        this.version = value
      "author":
        this.author = value
      "maintainer":
        this.maintainer = value
      "copyright":
        this.copyright = value
      "homepage":
        this.homepage = value
      "license":
        this.license = value
      "section":
        this.section = value
      "summary":
        this.summary = value
      "depends":
        this.depends = parseDependencies(value)
      "conflicts":
        this.conflicts = parseDependencies(value)
      "files":
        this.files = value
      "shared-libs":
        parseSharedLibs(this.sharedLibs, value)
      "required-properties":
        this.requiredProperties = parseDependencies(value)
      "on-install":
        this.onInstall = value
      "on-update":
        this.onUpdate = value
      "on-remove":
        this.onRemove = value
      else:
        if (key.startsWith("x-")) {
          this.customFields[key] = value
        } else {
          stderr().println("Unknown key: " + key)
        }
    }
  }
}
