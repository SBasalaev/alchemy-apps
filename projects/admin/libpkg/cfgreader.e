use "cfgreader.eh"
use "strbuf.eh"

type CfgReader {
  r: Reader,
  file: String,
  lineno: Int = 0,
  nextLine: String
}

def CfgReader.new(r: Reader, name: String) {
  this.r = r
  this.file = name
  this.lineno = 0
}

def CfgReader.nextline(): String {
  var next = this.nextLine
  if (next != null) {
    this.nextLine = null
    return next
  }
  do {
    next = this.r.readLine()
    this.lineno += 1
  } while (next != null && next.len() > 0 && next[0] == '#')
  return next
}

def CfgReader.nextSection(): Dict {
  var section = new Dict()
  var line: String
  // skip empty lines
  do { line = this.nextline() }
  while (line != null && line.trim().len() == 0)
  // line must not start with whitespace
  if (line != null && line[0] <= ' ') {
    throw(ERR_IO, this.file+":"+this.lineno+": Continuation line at the start of paragraph")
  }
  while (line != null && line.trim().len() > 0) {
    var cl = line.indexof(':')
    if (cl <= 0) {
      throw(ERR_IO, this.file+":"+this.lineno+": Key:Value pair expected")
    }
    var key = line[0:cl].trim().lcase()
    var value = new StrBuf().append(line[cl+1:].trim())
    line = this.nextline()
    while (line != null && line.len() > 0 && line[0] <= ' ') {
      if (line.trim() == ".") value.addch('\n')
      else value.addch('\n').append(line[1:])
      line = this.nextline()
    }
    section[key] = value.tostr()
  }
  if (section.keys().len == 0) return null
  return section
}

def CfgReader.close() {
  this.r.close()
}
