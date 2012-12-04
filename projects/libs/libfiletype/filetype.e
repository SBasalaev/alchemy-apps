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
      db.set(ftype[0].trim(), new FileType {
        description=ftype[1].trim(),
        category=ftype[2].trim(),
        command=ftype[3].trim()
      })
    } else if (ftype.len == 3) {
      db.set(ftype[0].trim(), new FileType {
        description=ftype[1].trim(),
        category=ftype[2].trim(),
        command=""
      })
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
  new FTypeDB(ftypes)
}

def ftype_for_ext(db: FTypeDB, ext: String): FileType {
  db.filetypes.get(ext)
}

def ftype_for_file(db: FTypeDB, file: String): FileType {
  var ftype: FileType
  // check if this is directory
  if (is_dir(file)) {
    ftype = ftype_for_ext(db, "/dir/")
  }
  // check extension
  if (ftype == null) {
    var fname = pathfile(file)
    var dot = fname.lindexof('.')
    if (dot > 0) {
      var ext = fname.substr(dot+1, fname.len())
      ftype = ftype_for_ext(db, ext)
    }
  }
  // check contents, TODO: make this optional
  if (ftype == null && can_read(file)) {
    var in = fopen_r(file)
    var magic = in.readushort()
    if (magic == null) ftype = ftype_for_ext(db, "/empty/")
    else switch (magic) {
      0xC0DE : { ftype = ftype_for_ext(db, "/eprog/") };
      ('#'<<8)|'!' : { ftype = ftype_for_ext(db, "/script/") };
      ('#'<<8)|'@' : { ftype = ftype_for_ext(db, "/nprog/") };
      ('#'<<8)|'=' : { ftype = ftype_for_ext(db, "/link/") };
      else: {
        var b = in.read()
        while (b == '\r' || b == '\n' || b == '\t' || b >= ' ' && b < 127) b = in.read()
        if (b < 0) {
          ftype = ftype_for_ext(db, "/text/")
        } else {
          ftype = ftype_for_ext(db, "/?/")
        }
      }
    }
    in.close()
  }
  if (ftype == null) {
    ftype = ftype_for_ext(db, "/?/")
  }
  ftype
}
