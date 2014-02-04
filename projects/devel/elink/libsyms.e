use "libsyms.eh"
use "textio.eh"
use "dataio.eh"
use "sys.eh"

def loadFromNative(inp: IStream): LibInfo {
  var r = utfreader(inp)
  var soname: String = null
  var symbolfile: String = null
  while (var line = r.readLine(), line != null) {
    var cl = line.indexof('=')
    if (cl > 0) {
      var key = line[:cl].lcase().trim()
      var value = line[cl+1:].trim()
      if (key == "soname") soname = value
      else if (key == "symbols") symbolfile = value
    }
  }
  r.close()
  var info = new LibInfo {
    soname = soname
  }
  var vsym = new List()
  if (symbolfile != null) {
    var symstream = readUrl("res:" + symbolfile)
    r = utfreader(symstream)
    while (var line = r.readLine(), line != null) {
      vsym.add(line)
    }
    r.close()
  }
  info.symbols = vsym
  return info
}

def loadFromEther(inp: IStream): LibInfo {
  if (inp.readUShort() > SUPPORTED)
    throw(ERR_LINKER, "Unsupported format version")
  var info = new LibInfo { }
  var symbols = new List()
  var lflags = inp.readUByte()
  if ((lflags & LFLAG_SONAME) != 0) { //has soname
    info.soname = inp.readUTF()
  }
  //skipping dependencies
  var depsize = inp.readUShort()
  for (var i in 0 .. depsize-1) {
    inp.skip(inp.readUShort())
  }
  //reading pool
  var poolsize = inp.readUShort()
  for (var i in 0 .. poolsize-1) {
    var ch = inp.readUByte()
    switch (ch) {
      '0': { }
      'i', 'f': inp.skip(4)
      'l', 'd': inp.skip(8)
      'S': inp.skip(inp.readUShort())
      'E': {
        inp.skip(2)
        inp.skip(inp.readUShort())
      }
      'P': {
        var name = inp.readUTF()
        var flags = inp.readUByte()
        inp.skip(2)
        inp.skip(inp.readUShort())
        if ((flags & FFLAG_SHARED) != 0) {
          symbols.add(name)
        }
        if ((flags & FFLAG_LNUM) != 0) {
          inp.skip(inp.readUShort()*2)
        }
        if ((flags & FFLAG_ERRTBL) != 0) {
          inp.skip(inp.readUShort()*2)
        }
      }
      else:
        throw(ERR_LINKER, "Unknown object type: "+ch)
    }
  }
  inp.close()
  info.symbols = symbols
  return info
}

def loadLibInfo(libname: String): LibInfo {
  var paths = getenv("LIBPATH").split(':')
  var libfile: String = null
  for (var i=0, libfile == null && i < paths.len, i+=1) {
    var testfile = paths[i] + '/' + libname
    if (exists(testfile)) libfile = testfile
  }
  if (libfile == null)
    throw(ERR_LINKER, "Library not found: " + libname)
  var inp = fread(libfile)
  var magic = inp.read() << 8 | inp.read()
  var info: LibInfo = null
  switch (magic) {
    ('#'<<8|'='): {
      var link = utfreader(inp).readLine().trim()
      inp.close()
      info = loadLibInfo(link)
    }
    0xC0DE: {
      info = loadFromEther(inp)
    }
    ('#'<<8|'@'): {
      info = loadFromNative(inp)
    }
    else: {
      inp.close()
      throw(ERR_LINKER, "Unknown library format: " + magic)
    }
  }
  if (info.soname == null) info.soname = libname
  return info
}
