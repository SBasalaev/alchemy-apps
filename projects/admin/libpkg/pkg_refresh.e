use "pkg_private"
use "cfgreader"
use "io"

def PkgManager.parsePkgList(file: String, baseUrl: String): List {
  var list = new List()
  var cfg = new CfgReader(utfreader(fread(file)), file)
  while (var section = cfg.nextSection(), section != null) {
    if (section["package"] == null || section["version"] == null) {
      this.fail("Invalid package entry: " + section, null)
    } else {
      var pkg = new Package(section)
      pkg.baseUrl = baseUrl
      list.add(pkg)
    }
  }
  cfg.close()
  list.sortself(`Package.cmp`)
  return list
}

def emptyPkgList(baseUrl: String, section: String): PkgList {
  return new PkgList {
    baseUrl = baseUrl,
    section = section,
    packages = new List()
  }
}

def PkgManager.readInstalledPkgList(): PkgList {
  if (!exists(PKG_SOURCELIST_DIR + "installed")) {
    fcreate(PKG_SOURCELIST_DIR + "installed")
  }
  try {
    return new PkgList {
      baseUrl = "",
      section = "",
      packages = this.parsePkgList(PKG_SOURCELIST_DIR + "installed", "")
    }
  } catch (var err) {
    this.fail("Failed to process list of installed packages", err)
    return null
  }
}

def PkgManager.readPkgList(baseUrl: String, section: String): PkgList {
  var name = escapeAddress(baseUrl + '/' + section)
  if (!exists(PKG_SOURCELIST_DIR + name)) {
    return emptyPkgList(baseUrl, section)
  }
  try {
    return new PkgList {
      baseUrl = baseUrl,
      section = section,
      packages = this.parsePkgList(PKG_SOURCELIST_DIR + name, baseUrl)
    }
  } catch (var err) {
    this.fail("Failed to process package list " + name, err)
    return null
  }
}

/* Reads package lists. */
def PkgManager.readLists(parseContents: Bool = true) {
  var input = fread(PKG_SOURCE_LIST)
  var buf = input.readFully()
  input.close()
  var sources = ba2utf(buf).split('\n', true)
  var pkgLists = new List()
  for (var src in sources) {
    src = src.trim()
    if (src.len() == 0 || src[0] == '#') continue
    var sp = src.indexof(' ')
    if (sp < 0) {
      this.fail("Failed to parse source list, line '" + src + "'", null)
      continue
    }
    var baseUrl = src[:sp]
    src = src[sp:].trim()
    sp = src.indexof(' ')
    if (sp < 0) {
      var pkgList =
        if (parseContents) this.readPkgList(baseUrl, src)
        else emptyPkgList(baseUrl, src)
      pkgLists.add(pkgList)
    } else {
      var sectionBase = src[:sp] + '/'
      var subsections = src[sp+1:].split(' ', true)
      for (var sub in subsections) {
        var pkgList =
          if (parseContents) this.readPkgList(baseUrl, sectionBase + sub)
          else emptyPkgList(baseUrl, sectionBase + sub)
        pkgLists.add(pkgList)
      }
    }
  }
  this.pkgLists = new [PkgList](pkgLists.len())
  pkgLists.copyInto(0, this.pkgLists)
}

def PkgManager.loadPkgLists() {
  this.installedList = this.readInstalledPkgList()
  this.readLists(true)
}

def PkgManager.refresh(): Bool {
  this.readLists(false)
  var status = true
  var total = this.pkgLists.len
  for (var step in 0 .. total-1) {
    var list = this.pkgLists[step]
    try {
      var url = list.baseUrl + "/dists/" + list.section + "/Packages"
      var outfile = PKG_SOURCELIST_DIR + escapeAddress(list.baseUrl + '/' + list.section)
      var tmpfile = "/tmp/pkg-download"
      var directMode = url.startsWith("file:/")
      if (url.startsWith("file:/")) {
        tmpfile = url[5:]
        if (exists(outfile)) fremove(outfile)
        fcopy(tmpfile, outfile)
      } else {
        this.downloadProgress(list.baseUrl, "Packages", step+1, total)
        var input = readUrl(url)
        var output = fwrite(tmpfile)
        output.writeAll(input)
        input.close()
        output.flush()
        output.close()
        if (exists(outfile)) fremove(outfile)
        fmove(tmpfile, outfile)
      }
    } catch (var e) {
      this.fail("Unable to fetch source list \"" + list.baseUrl + " " + list.section + "\"", e)
      status = false
    }
  }
  this.readLists(true)
  return status
}
