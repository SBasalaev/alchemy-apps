use "libsyms.eh"
use "textio.eh"
use "dataio.eh"
use "string.eh"
use "error.eh"
use "sys.eh"

def loadFromNative(in: IStream): LibInfo {
  var r = utfreader(in);
  var soname: String = null
  var symbolfile: String = null
  var line = r.readline()
  while (line != null) {
    var cl = line.indexof('=')
    if (cl > 0) {
      var key = line[:cl].lcase().trim()
      var value = line[cl+1:].trim()
      if (key == "soname") soname = value
      else if (key == "symbols") symbolfile = value
    }
    line = r.readline();
  }
  r.close();
  var info = new LibInfo {
    soname = soname
  };
  var vsym = new List()
  if (symbolfile != null) {
    var symstream = readurl("res:" + symbolfile);
    var buf = new [Byte](symstream.available());
    symstream.readarray(buf, 0, buf.len);
    symstream.close();
    var syms = ba2utf(buf).split('\n');
    vsym.addfrom(syms, 0, syms.len);
  }
  info.symbols = vsym;
  info;
}

def loadFromEther(in: IStream): LibInfo {
  if (in.readushort() > SUPPORTED)
    error(ERR_LINKER, "Unsupported format version");
  var info = new LibInfo{};
  var symbols = new List();
  var lflags = in.readubyte();
  if ((lflags & LFLAG_SONAME) != 0) { //has soname
    info.soname = in.readutf();
  }
  //skipping dependencies
  var depsize = in.readushort();
  for (var i=0, i<depsize, i+=1) {
    in.skip(in.readushort());
  }
  //reading pool
  var poolsize = in.readushort();
  for (var i=0, i<poolsize, i+=1) {
    var ch = in.readubyte();
    switch (ch) {
      '0': { }
      'i', 'f': in.skip(4);
      'l', 'd': in.skip(8);
      'S': in.skip(in.readushort());
      'E': {
        in.skip(2);
        in.skip(in.readushort());
      }
      'P': {
        var name = in.readutf();
        var flags = in.readubyte();
        in.skip(2);
        in.skip(in.readushort());
        if ((flags & FFLAG_SHARED) != 0) {
          symbols.add(name);
        }
        if ((flags & FFLAG_LNUM) != 0) {
          in.skip(in.readushort()*2);
        }
        if ((flags & FFLAG_ERRTBL) != 0) {
          in.skip(in.readushort()*2);
        }
      }
      else:
        error(ERR_LINKER, "Unknown object type: "+ch);
    }
  }
  in.close();
  info.symbols = symbols;
  info;
}

def loadLibInfo(libname: String): LibInfo {
  var paths = getenv("LIBPATH").split(':')
  var libfile: String = null
  for (var i=0, libfile == null && i < paths.len, i+=1) {
    var testfile = paths[i] + '/' + libname
    if (exists(testfile)) libfile = testfile
  }
  if (libfile == null)
    error(ERR_LINKER, "Library not found: " + libname)
  var in = fopen_r(libfile);
  var magic = in.read() << 8 | in.read();
  var info = switch (magic) {
    ('#'<<8|'='): {
      var link = utfreader(in).readline().trim();
      in.close();
      loadLibInfo(link);
    }
    0xC0DE: {
      loadFromEther(in);
    };
    ('#'<<8|'@'): {
      loadFromNative(in);
    }
    else: {
      in.close();
      error(ERR_LINKER, "Unknown library format: " + magic)
      null;
    }
  }
  if (info.soname == null) info.soname = libname;
  info;
}