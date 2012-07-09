use "filetype.eh"
use "hash.eh"
use "string.eh"
use "textio.eh"
use "dataio.eh"

type FTypeDB {
  filetypes: Hashtable
}

def _ftype_addtypes(db: Hashtable, file: String) {
  var in = fopen_r(file)
  var r = utfreader(in)
  var line = freadline(r)
  var lnum = 1
  while (line != null) {
    var ftype = strsplit(line, ',')
    if (ftype.len == 4) {
      ht_put(db, ftype[0], new FileType(description=ftype[1],kind=ftype[2],command=ftype[3]))
    } else if (ftype.len == 3) {
      ht_put(db, ftype[0], new FileType(description=ftype[1],kind=ftype[2],command=""))
    } else {
      fprintln(stderr(), "libfiletype warning: failed to parse line "+lnum+" of "+file)
    }
    line = freadline(r)
    lnum = lnum + 1
  }
  fclose(in)
}

def ftype_loaddb(): FTypeDB {
  var ftypes = new_ht()
  _ftype_addtypes(ftypes, "/res/libfiletype0/filetypes")
  if (exists("/cfg/filetypes")) _ftype_addtypes(ftypes, "/cfg/filetypes")
  new FTypeDB(filetypes=ftypes)
}

def ftype_for_ext(db: FTypeDB, ext: String): FileType {
  cast (FileType) ht_get(db.filetypes, ext)
}

def ftype_for_file(db: FTypeDB, file: String): FileType {
  if (!exists(file)) {
    cast (FileType) null
  } else if (is_dir(file)) {
    ftype_for_ext(db, "/dir/")
  } else {
    var ftype: FileType
    var fname = pathfile(file)
    var dot = strlindex(fname, '.')
    if (dot > 0) {
      var ext = substr(fname, dot+1, strlen(fname))
      ftype = ftype_for_ext(db, ext)
    }
    if (ftype == null && can_read(file)) {
      var in = fopen_r(file)
      var magic = freadushort(in)
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
        var b = fread(in)
        while (b == '\r' || b == '\n' || b == '\t' || b >= ' ' && b < 127) b = fread(in)
        if (b < 0) {
          ftype = ftype_for_ext(db, "/text/")
        } else {
          ftype = ftype_for_ext(db, "/bin/")
        }
      }
      fclose(in)
    }
    if (ftype == null) {
      ftype = ftype_for_ext(db, "/bin/")
    }
    ftype
  }
}
