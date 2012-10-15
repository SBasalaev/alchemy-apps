use "filetype.eh"
use "dict.eh"
use "string.eh"
use "textio.eh"
use "dataio.eh"

type FTypeDB {
  filetypes: Dict
}

def _ftype_addtypes(db: Dict, file: String) {
  var r = utfreader(fopen_r(file))
  var line = r.readline()
  var lnum = 1
  while (line != null && line.len() > 0 && line.ch(0) != '#') {
    var ftype = line.split(',')
    if (ftype.len == 4) {
      db.set(ftype[0].trim(), new FileType(
        description=ftype[1].trim(),
        category=ftype[2].trim(),
        command=ftype[3].trim()))
    } else if (ftype.len == 3) {
      db.set(ftype[0].trim(), new FileType(
        description=ftype[1].trim(),
        category=ftype[2].trim(),
        command=""))
    } else {
      stderr().println("libfiletype warning: failed to parse line "+lnum+" of "+file)
    }
    line = r.readline()
    lnum = lnum + 1
  }
  r.close()
}

def _ftype_createcfg() {
  var out = fopen_w("/cfg/filetypes")
  out.println("#File format:")
  out.println("#ext,descripition,category,exec")
  out.close()
}

def ftype_loaddb(): FTypeDB {
  var ftypes = new_dict()
  _ftype_addtypes(ftypes, "/res/libfiletype1/filetypes")
  if (!exists("/cfg/filetypes")) _ftype_createcfg()
  _ftype_addtypes(ftypes, "/cfg/filetypes")
  new FTypeDB(filetypes=ftypes)
}

def ftype_for_ext(db: FTypeDB, ext: String): FileType {
  cast (FileType) db.filetypes.get(ext)
}

def ftype_for_file(db: FTypeDB, file: String): FileType {
  if (!exists(file)) {
    null
  } else if (is_dir(file)) {
    ftype_for_ext(db, "/dir/")
  } else {
    var ftype: FileType
    var fname = pathfile(file)
    var dot = fname.lindexof('.')
    if (dot > 0) {
      var ext = fname.substr(dot+1, fname.len())
      ftype = ftype_for_ext(db, ext)
    }
    if (ftype == null && can_read(file)) {
      var in = fopen_r(file)
      var magic = in.readushort()
      if (magic == 0xC0DE) {
        ftype = ftype_for_ext(db, "/eprog/")
      } else if (magic == (('#'<<8)|'!')) {
        ftype = ftype_for_ext(db, "/script/")
      } else if (magic == (('#'<<8)|'@')) {
        ftype = ftype_for_ext(db, "/nprog/")
      } else if (magic == (('#'<<8)|'=')) {
        ftype = ftype_for_ext(db, "/link/")
      } else if (magic == null) {
        ftype = ftype_for_ext(db, "/empty/")
      } else {
        var b = in.read()
        while (b == '\r' || b == '\n' || b == '\t' || b >= ' ' && b < 127) b = in.read()
        if (b < 0) {
          ftype = ftype_for_ext(db, "/text/")
        } else {
          ftype = ftype_for_ext(db, "/?/")
        }
      }
      in.close()
    }
    if (ftype == null) {
      ftype = ftype_for_ext(db, "/?/")
    }
    ftype
  }
}
