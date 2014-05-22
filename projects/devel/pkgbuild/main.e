use "pkg/cfgreader"
use "pkg/pkg"
use "io"

use "specs"
use "rules"

const HELP = "Build Alchemy OS package\n" +
             "Usage: pkgbuild [options] [specfile]"
const VERSION = "pkgbuild 0.5"

def String.indexOfSpace(from: Int = 0): Int {
  var len = this.len()
  while (from < len && this[from] > ' ')
    from += 1
  return from
}

def main(args: [String]): Int {
  // parse args
  var pkgspec = ""
  var mode = MODE_BINARY
  for (var arg in args) {
    if (arg == "-h") {
      println(HELP)
      return SUCCESS
    } else if (arg == "-v") {
      println(VERSION)
      return SUCCESS
    } else if (arg == "-c") {
      mode = MODE_CLEAN
    } else if (arg == "-s") {
      mode = MODE_SOURCE
    } else if (pkgspec != "") {
      stderr().println("pkgbuild: excess parameter: " + arg)
      return FAIL
    } else {
      pkgspec = arg
    }
  }
  if (pkgspec == "") {
    var files = flistfilter(".", "*.package")
    switch (files.len) {
      0: {
        stderr().println("pkgbuild: no package file")
        return FAIL
      }
      1: {
        pkgspec = files[0]
      }
      else: {
        stderr().println("pkgbuild: multiple package files")
        for (var i=0, i<files.len, i+=1) {
          stderr().println(" " + files[i])
        }
        return FAIL
      }
    }
  }

  // read source section and guess build system
  var binaries = new List()
  var buildsys = BUILD_NONE
  var input = fread(pkgspec)
  var r = new CfgReader(utfreader(input), pkgspec)
  // reading source section
  var spec = r.nextSection()
  var src = new SourcePackage(spec)
  // checking build-deps and guessing build system
  var pm = initPkgManager()
  pm.loadPkgLists()
  for (var dep in src.buildDepends) {
    var pkg = pm.getInstalledPackage(dep.name)
    if (pkg == null || !pkg.satisfies(dep)) {
      stderr().println("pkgbuild: missing build dependency: " + dep)
      return FAIL
    }
    if (dep.name == "make") {
      buildsys = BUILD_MAKE
    }
  }
  pm = null
  // reading binary sections
  while (spec = r.nextSection(), spec != null) {
    var binary = new BinaryPackage(spec, src)
    binaries.add(binary)
  }
  r.close()

  // check required fields
  if (src.name == null) {
    stderr().println("pkgbuild: source section misses required field Source")
    return FAIL
  } else if (src.version == null) {
    stderr().println("pkgbuild: source section misses required field Version")
    return FAIL
  } else if (binaries.len() == 0) {
    stderr().println("pkgbuild: missing binary section")
    return FAIL
  } else {
    for (var i=0, i < binaries.len(), i+=1) {
      var binary = binaries[i].cast(BinaryPackage)
      if (binary.name == null) {
        stderr().println("pkgbuild: binary section misses required field Package")
        return FAIL
      }
    }
  }

  // build
  var exitcode = SUCCESS
  switch (mode) {
    MODE_CLEAN: {
      exitcode = pkgbuild_clean(buildsys)
    }
    MODE_SOURCE: {
      exitcode = pkgbuild_clean(buildsys)
      if (exitcode == 0)
        exitcode = pkgbuild_source(src)
    }
    MODE_BINARY: {
      // build project
      exitcode = pkgbuild_build(buildsys)
      // install project
      if (binaries.len() == 1 && binaries[0].cast(BinaryPackage).files == null) {
        // single package mode
        if (exitcode == 0)
          exitcode = pkgbuild_install(buildsys, binaries[0].cast(BinaryPackage).name)
      } else {
        // multiple package mode
        if (exitcode == 0)
          exitcode = pkgbuild_install(buildsys, "tmp")
        for (var i=0, exitcode == 0 && i<binaries.len(), i+=1) {
          var binary = binaries[i].cast(BinaryPackage)
          exitcode = pkgbuild_installfiles(binary)
        }
      }
      // scan for shared libs
      for (var i=0, exitcode == 0 && i<binaries.len(), i+=1) {
        var binary = binaries[i].cast(BinaryPackage)
        exitcode = pkgbuild_makeshlibs(binary)
      }
      // substitute variables in dependencies
      var index = pkgbuild_libindex(binaries)
      for (var i=0, exitcode == 0 && i<binaries.len(), i+=1) {
        var binary = binaries[i].cast(BinaryPackage)
        exitcode = pkgbuild_gendeps(src, binary, index)
      }
      // generate binary specs
      for (var i=0, exitcode == 0 && i<binaries.len(), i+=1) {
        var binary = binaries[i].cast(BinaryPackage)
        exitcode = pkgbuild_genspec(src, binary)
      }
      // assemble packages
      for (var i=0, exitcode == 0 && i<binaries.len(), i+=1) {
        var binary = binaries[i].cast(BinaryPackage)
        exitcode = pkgbuild_assemble(src, binary)
      }
      // check packages
      if (exists("/bin/pkglint")) {
        for (var i=0, exitcode == 0 && i<binaries.len(), i+=1) {
          var binary = binaries[i].cast(BinaryPackage)
          exitcode = pkgbuild_pkglint(src, binary)
        }
      }
    }
  }

  return exitcode
}
