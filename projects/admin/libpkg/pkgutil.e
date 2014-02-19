use "io"
use "pkgutil"
use "strbuf"

const EQUAL = 0
const LESS = -1
const GREATER = 1

def compareStringParts(s1: String, s2: String): Int {
  var ofs = 0
  var len1 = s1.len()
  var len2 = s2.len()
  while (ofs < len1 && ofs < len2) {
    var ch1 = s1[ofs]
    var ch2 = s2[ofs]
    if (ch1 != ch2) {
      if (ch1 == '~') return LESS
      else if (ch2 == '~') return GREATER
      else if (ch1 < ch2) return LESS
      else return GREATER
    }
    ofs += 1
  }
  if (len1 > ofs) {
    if (s1[ofs] == '~') return LESS else return GREATER
  } else if (len2 > ofs) {
    if (s2[ofs] == '~') return GREATER else return LESS
  }
  return EQUAL
}

def compareNumberParts(s1: String, s2: String): Int {
  var l = s1.tolong()-s2.tolong()
  if (l > 0) return GREATER
  else if (l < 0) return LESS
  else return EQUAL
}

def compareVersions(v1: String, v2: String): Int {
  var ofs1 = 0
  var ofs2 = 0
  var len1 = v1.len()
  var len2 = v2.len()
  while (ofs1 < len1 && ofs2 < len2) {
    /* number parts */
    var end1 = ofs1
    var end2 = ofs2
    var ch = v1[end1].cast(Int)
    while (ch >= '0' && ch <= '9') {
      end1 += 1
      ch = if (end1 < len1) v1[end1] else -1
    }
    ch = v2[end2]
    while (ch >= '0' && ch <= '9') {
      end2 += 1
      ch = if (end2 < len2) v2[end2] else -1
    }
    var ret = compareNumberParts(v1[ofs1:end1], v2[ofs2:end2])
    if (ret != 0) return ret
    /* text parts */
    ofs1 = end1
    ofs2 = end2
    ch = if (ofs1 < len1) v1[ofs1] else -1
    while (ch > 0 && (ch < '0' || ch > '9')) {
      end1 += 1
      ch = if (end1 < len1) v1[end1] else -1
    }
    ch = if (ofs2 < len2) v2[ofs2] else -1
    while (ch > 0 && (ch < '0' || ch > '9')) {
      end2 += 1
      ch = if (end2 < len2) v2[end2] else -1
    }
    ret = compareStringParts(v1[ofs1:end1], v2[ofs2:end2])
    if (ret != 0) return ret
    ofs1 = end1
    ofs2 = end2
  }
  return EQUAL
}

def parseDependencies(depstr: String): [Dependency] {
  var depstrings = depstr.split(',', true)
  var deps = new [Dependency](depstrings.len)
  for (var i in 0 .. depstrings.len-1) {
    var dep = new Dependency { }
    var str = depstrings[i].trim()
    var sp = str.indexof(' ')
    if (sp < 0) {
      dep.name = str
    } else {
      dep.name = str[:sp]
      str = str[sp+1:].trim()
      sp = str.indexof(' ')
      if (sp > 0) {
        var depversion = str[sp+1:].trim()
        switch (str[:sp]) {
          "<":  dep.relation = REL_LT
          ">":  dep.relation = REL_GT
          "<=": dep.relation = REL_LE
          ">=": dep.relation = REL_GE
          "!=": dep.relation = REL_NE
          "==": dep.relation = REL_EQ
          else: stderr().println("libpkg: Failed to parse dependency " + str)
        }
      } else {
        stderr().println("libpkg: Failed to parse dependency " + str)
      }
    }
    deps[i] = dep
  }
  return deps
}

def Dependency.tostr(): String {
  if (this.relation == REL_NOREL) return this.name
  var sb = new StrBuf().append(this.name).addch(' ')
  switch (this.relation) {
    REL_LT: sb.append("<")
    REL_LE: sb.append("<=")
    REL_GT: sb.append(">")
    REL_GE: sb.append(">=")
    REL_EQ: sb.append("==")
    REL_NE: sb.append("!=")
  }
  return sb.addch(' ').append(this.version).tostr()
}

def Package.new(dict: Dict) {
  this.name = dict["package"].cast(String)
  this.version = dict["version"].cast(String)
  this.author = dict["author"].cast(String)
  this.maintainer = dict["maintainer"].cast(String)
  this.copyright = dict["copyright"].cast(String)
  this.homepage = dict["homepage"].cast(String)
  this.license = dict["license"].cast(String)
  this.section = dict["section"].cast(String)
  this.summary = dict["summary"].cast(String)
  try {
    this.size = dict["size"].cast(String).toint()
  } catch { }
  this.file = dict["file"].cast(String)
  if (dict["depends"] != null) {
    this.depends = parseDependencies(dict["depends"].cast(String))
  } else {
    this.depends = new [Dependency](0)
  }
  if (dict["conflicts"] != null) {
    this.conflicts = parseDependencies(dict["conflicts"].cast(String))
  } else {
    this.conflicts = new [Dependency](0)
  }
}

def Package.satisfies(dep: Dependency): Bool {
  var enjoys = this.name == dep.name
  if (!enjoys || dep.relation == REL_NOREL) {
    return enjoys
  }
  var cmp = compareVersions(this.version, dep.version)
  switch (dep.relation) {
    REL_LT: enjoys = cmp < 0
    REL_LE: enjoys = cmp <= 0
    REL_GT: enjoys = cmp > 0
    REL_GE: enjoys = cmp >= 0
    REL_EQ: enjoys = cmp == 0
    REL_NE: enjoys = cmp != 0
  }
  return enjoys
}

def Package.cmp(other: Package): Int {
  var cmp = this.name.cmp(other.name)
  if (cmp == 0) {
    cmp = compareVersions(this.version, other.version)
  }
  return cmp
}

def Package.tostr(): String {
  var sb = new StrBuf()
  .append("\nPackage: ").append(this.name)
  .append("\nVersion: ").append(this.version)
  if (this.author != null) {
    sb.append("\nAuthor: ").append(this.author)
  }
  if (this.maintainer != null) {
    sb.append("\nMaintainer: ").append(this.maintainer)
  }
  if (this.copyright != null) {
    sb.append("\nCopyright: ").append(this.copyright)
  }
  if (this.homepage != null) {
    sb.append("\nHomepage: ").append(this.homepage)
  }
  if (this.license != null) {
    sb.append("\nLicense: ").append(this.license)
  }
  if (this.section != null) {
    sb.append("\nSection: ").append(this.section)
  }
  if (this.summary != null) {
    sb.append("\nSummary: ").append(this.summary)
  }
  if (this.depends.len != 0) {
    sb.append("\nDepends: ")
    var first = true
    for (var dep in this.depends) {
      if (first) first = false
      else sb.append(", ")
      sb.append(dep.tostr())
    }
  }
  if (this.conflicts.len != 0) {
    sb.append("\nConflicts: ")
    var first = true
    for (var dep in this.depends) {
      if (first) first = false
      else sb.append(", ")
      sb.append(dep.tostr())
    }
  }
  if (this.size != 0) {
    sb.append("\nSize: ").append(this.size)
  }
  if (this.file != null) {
    sb.append("\nFile: ").append(this.file)
  }
  return sb.addch('\n').tostr()
}

def escapeAddress(addr: String): String {
  var sb = new StrBuf()
  var uscoreWritten = false
  for (var i in 0 .. addr.len()-1) {
    var ch = addr[i]
    if ( (ch >= 'a' && ch <= 'z')
      || (ch >= 'A' && ch <= 'Z')
      || (ch >= '0' && ch <= '9')
      || ch == '.' || ch == '-') {
      sb.addch(ch)
      uscoreWritten = false
    } else if (!uscoreWritten) {
      sb.addch('_')
      uscoreWritten = true
    }
  }
  return sb.tostr()
}
