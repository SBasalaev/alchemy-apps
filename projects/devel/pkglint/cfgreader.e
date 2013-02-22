use "cfgreader.eh"
use "error.eh"
use "string.eh"
use "strbuf.eh"

type CfgReader {
  r: Reader,
  file: String,
  lineno: Int,
  nextLine: String
}

def new_cfgreader(r: Reader, name: String): CfgReader {
  new CfgReader {
    r = r,
    file = name,
    lineno = 0
  }
}

def CfgReader.next_line(): String {
  var next = this.nextLine;
  if (next == null) {
    next = this.r.readline();
    this.lineno += 1
  } else {
    this.nextLine = null;
  }
  // skip comments
  if (next != null && next.len() > 0 && next[0] == '#') {
    this.next_line()
  } else {
    next
  }
}

def CfgReader.next_section(): Dict {
  var section = new_dict()
  var line: String
  // skip empty lines
  do { line = this.next_line(); }
  while (line != null && line.trim().len() == 0);
  // line must not start with whitespace
  if (line != null && line[0] <= ' ') {
    error(ERR_IO, this.file+":"+this.lineno+": Continuation line at the start of paragraph");
  }
  while (line != null && line.trim().len() > 0) {
    var cl = line.indexof(':');
    if (cl <= 0) {
      error(ERR_IO, this.file+":"+this.lineno+": Key:Value pair expected");
    }
    var key = line[0: cl].trim().lcase()
    var value = new_strbuf().append(line[cl+1:].trim())
    line = this.next_line();
    while (line != null && line.len() > 0 && line[0] <= ' ') {
      if (line.trim() == ".") value.addch('\n')
      else value.addch('\n').append(line[1:]);
      line = this.next_line();
    }
    section[key] = value.tostr();
  }
  if (section.keys().len == 0) null else section;
}

def CfgReader.close() {
  this.r.close()
}
 
