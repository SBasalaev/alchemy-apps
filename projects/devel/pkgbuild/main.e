use "io.eh"
use "pkgbuild.eh"
use "cfgreader.eh"
use "string.eh"
use "list.eh"
use "specs.eh"

const HELP = "Build Alchemy OS package\n" +
             "Usage: pkgbuild [options] [specfile]"
const VERSION = "pkgbuild 0.4.1"

def parsedeps(deps: String): List {
  var list = new List()
  if (deps != null) {
    var array = deps.split(',')
    for (var i=array.len-1, i>=0, i-=1) {
      list.add(array[i].trim())
    }
  }
  list
}

def String.indexofspace(from: Int = 0): Int {
  var len = this.len()
  while (from < len && this[from] > ' ')
    from += 1
  from
}

def main(args: [String]): Int {
  // parse args
  var pkgspec = ""
  var mode = MODE_BINARY
  var quit = false
  var exitcode = 0
  for (var i=0, !quit && i<args.len, i+=1) {
    var arg = args[i]
    if (arg == "-h") {
      quit = true
      println(HELP)
    } else if (arg == "-v") {
      quit = true
      println(VERSION)
    } else if (arg == "-c") {
      mode = MODE_CLEAN
    } else if (arg == "-s") {
      mode = MODE_SOURCE
    } else if (pkgspec != "") {
      quit = true
      exitcode = 2
      stderr().println("pkgbuild: excess parameter: " + arg)
    } else {
      pkgspec = arg
    }
  }
  if (pkgspec == "") {
    var files = flistfilter(".", "*.package")
    switch (files.len) {
      0: {
        exitcode = 2
        stderr().println("pkgbuild: no package file")
      }
      1: {
        pkgspec = files[0]
      }
      2: {
        exitcode = 2
        stderr().println("pkgbuild: multiple package files")
        for (var i=0, i<files.len, i+=1) {
          stderr().println(" " + files[i])
        }
      }
    }
  }
  
  // read spec
  var src: Source
  var binaries = new List()
  var buildsys = "none"
  if (!quit) {
    var in = fopen_r(pkgspec)
    var r = new CfgReader(utfreader(in), pkgspec)
    // reading source section
    var spec = r.nextSection()
    src = new Source {
      name = spec["source"].cast(String),
      version = spec["version"].cast(String),
      author = spec["author"].cast(String),
      maintainer = spec["maintainer"].cast(String),
      copyright = spec["copyright"].cast(String),
      homepage = spec["homepage"].cast(String),
      section = spec["section"].cast(String),
      license = spec["license"].cast(String),
      builddepends = parsedeps(spec["build-depends"].cast(String))
    }
    // checking build-deps and guessing build system
    for (var i=0, i < src.builddepends.len(), i+=1) {
      var dep = src.builddepends[i].cast(String)
      if (!exists("/cfg/pkg/db/lists/" + dep + ".files")) {
        exitcode = 1
        stderr().println("pkgbuild: missing build dependency: " + dep)
      }
      if (dep == "make") {
        buildsys = "make"
      }
    }
    // reading binary sections
    while ({spec = r.nextSection(); spec != null}) {
      var binary = new Binary {
        name = spec["package"].cast(String),
        version = spec["version"].cast(String),
        author = spec["author"].cast(String),
        maintainer = spec["maintainer"].cast(String),
        copyright = spec["copyright"].cast(String),
        homepage = spec["homepage"].cast(String),
        license = spec["license"].cast(String),
        section = spec["section"].cast(String),
        summary = spec["summary"].cast(String),
        depends = parsedeps(spec["depends"].cast(String)),
        files = spec["files"].cast(String)
      }
      binaries.add(binary)
    }
    r.close()
    // check required fields
    if (src.name == null) {
      exitcode = 1
      stderr().println("pkgbuild: source section misses required field Source")
    } else if (src.version == null) {
      exitcode = 1
      stderr().println("pkgbuild: source section misses required field Version")
    } else if (binaries.len() == 0) {
      exitcode = 1
      stderr().println("pkgbuild: missing binary section")
    } else {
      for (var i=0, exitcode == 0 && i<binaries.len(), i+=1) {
        var binary = binaries[i].cast(Binary)
        if (binary.name == null) {
          exitcode == 1
          stderr().println("pkgbuild: binary section misses required field Package")
        }
      }
    }
  }
  
  // build
  if (!quit && exitcode == 0)
  switch (mode) {
    MODE_CLEAN: {
      exitcode = pkgbuild_clean(buildsys)
    }
    MODE_BINARY: {
      // build project
      exitcode = pkgbuild_build(buildsys)
      // install project
      if (binaries.len() == 1 && binaries[0].cast(Binary).files == null) {
        // single package mode
        if (exitcode == 0)
          exitcode = pkgbuild_install(buildsys, binaries[0].cast(Binary).name)
      } else {
        // multiple package mode
        if (exitcode == 0)
          exitcode = pkgbuild_install(buildsys, "tmp")
        for (var i=0, exitcode == 0 && i<binaries.len(), i+=1) {
          var binary = binaries[i].cast(Binary)
          exitcode = pkgbuild_installfiles(binary)
        }
      }
      // generate specs
      var index = pkgbuild_libindex(binaries)
      for (var i=0, exitcode == 0 && i<binaries.len(), i+=1) {
        var binary = binaries[i].cast(Binary)
        exitcode = pkgbuild_libdeps(binary, index)
        if (exitcode == 0)
          exitcode = pkgbuild_genspec(src, binary)
      }
      // build packages
      for (var i=0, exitcode == 0 && i<binaries.len(), i+=1) {
        var binary = binaries[i].cast(Binary)
        exitcode = pkgbuild_assemble(src, binary)
      }
      // check packages
      if (exists("/bin/pkglint")) {
        for (var i=0, exitcode == 0 && i<binaries.len(), i+=1) {
          var binary = binaries[i].cast(Binary)
          exitcode = pkgbuild_pkglint(src, binary)
        }
      }
    }
    MODE_SOURCE: {
      exitcode = pkgbuild_clean(buildsys)
      if (exitcode == 0)
        exitcode = pkgbuild_source(src)
    }
  }
  
  exitcode
}
