use "desktop.eh" 

use "dict"
use "list"
use "string"
use "textio"

const DESKTOPDB = "/cfg/desktop"

def readCfgFile(file: String): Dict {
  var r = utfreader(fopen_r(file))
  var line = r.readline()
  var dict = new Dict()
  while (line != null) {
    if (line.len() != 0 && line[0] != '#') {
      var eq = line.indexof('=')
      if (eq > 0) {
        dict[line[:eq].trim()] = line[eq+1:].trim()
      }
    }
    line = r.readline()
  }
  r.close()
  dict
}

type DesktopDB {
  ftypes: Dict,     // String -> FileType
  apps: Dict,       // String -> String
  cachedapps: Dict, // String -> Application
  checkContents: Bool = false
}

def DesktopDB.loadTypes(file: String) {
  var in: IStream
  try {
    var r = utfreader(fopen_r(file))
    var line: String
    while ({line = r.readline(); line != null}) {
      if (line.len() > 0 && line[0] != '#') {
        var cl1 = line.indexof(':')
        var cl2 = line.lindexof(':')
        if (cl2 > cl1) {
          var ftype = new FileType {
            extension = line[:cl1].trim(),
            category = line[cl1+1:cl2].trim(),
            description = line[cl2+1:].trim()
          }
          this.ftypes[ftype.extension] = ftype
        }
      }
    }
  } catch { }
  try in.close() catch {}
}

def readApplication(file: String): Application {
  var app = new Application { }
  var in: IStream
  try {
    var appspec = readCfgFile(file)
    app.name = appspec["Name"].cast(String)
    app.icon = appspec["Icon"].cast(String)
    app.exec = appspec["Exec"].cast(String)
    var str = appspec["Categories"].cast(String)
    app.categories = if (str != null) str.split(';') else new [String](0)
    str = appspec["Extensions"].cast(String)
    app.extensions = if (str != null) str.split(';') else new [String](0)
  } catch {
    app = null
  }
  try in.close() catch { }
  if (app.name == null || app.exec == null) app = null
  app
}

def DesktopDB.new() {
  // load configuration and desktop database
  if (exists(DESKTOPDB)) {
    this.apps = readCfgFile(DESKTOPDB)
    this.checkContents = this.apps["Check-Contents"] == "true"
    this.apps.remove("Check-Contents")
  } else {
    this.apps = new Dict()
    var cfgout = fopen_w(DESKTOPDB)
    cfgout.println(
      "[Preferences]\n" +
      "Check-Contents=false\n" +
      "\n" +
      "[Filetypes]"
    )
    cfgout.close()
  }
  this.cachedapps = new Dict()
  // load file types
  // standard types are loaded first
  // so others can override them
  this.ftypes = new Dict()
  this.loadTypes("/res/filetypes/libdesktop")
  var files = flist("/res/filetypes")
  for (var i=files.len-1, i>=0, i-=1) {
    if (files[i] != "libdesktop") {
      this.loadTypes("/res/filetypes/" + files[i])
    }
  }
  if (exists("/cfg/filetypes")) this.loadTypes("/cfg/filetypes")
}

def DesktopDB.getType(ext: String): FileType {
  this.ftypes[ext].cast(FileType)
}

def DesktopDB.typeForFile(file: String): FileType {
  var ftype = null
  // check if this is a directory
  if (is_dir(file)) {
    ftype = this.ftypes["/dir/"]
  }
  // check by extension
  if (ftype == null) {
    var dot = file.lindexof('.')
    if (dot > 0) {
      var ext = file[dot+1:]
      if (ext.indexof('/') < 0) {
        ftype = this.ftypes[ext]
      }
    }
  }
  // check contents
  if (ftype == null && this.checkContents) {
    var in : IStream
    try {
      in = fopen_r(file)
      var magic = (in.read() << 8) + in.read()
      switch (magic) {
        0xC0DE:       ftype = this.ftypes["/ebin/"];
        ('#'<<8)|'@': ftype = this.ftypes["/nbin/"];
        ('#'<<8)|'!': ftype = this.ftypes["/script/"];
        ('#'<<8)|'=': ftype = this.ftypes["/link/"];
        -1:           ftype = this.ftypes["/empty/"];
        else: {
          // check if first 127 bytes are valid UTF-8
          var bytes = new [Byte](127)
          bytes[0] = magic >> 8
          bytes[1] = magic
          var len = 2 + in.readarray(bytes, 2, 125)
          var isUTF = true
          var utfchunks = 0
          for (var i=0, isUTF && i <= 127, i+=1) {
            var b = bytes[i]
            if (utfchunks > 0) {
              if ((b & 0xC0) == 0x80) utfchunks -= 1
              else isUTF = false
            } else if (b < 0x7f) {
              // skip
            } else if ((b & 0xe0) == 0xc0) {
              utfchunks = 1
            } else if ((b & 0xf0) == 0xe0) {
              utfchunks = 2
            } else {
              isUTF = false
            }
          }
          if (isUTF) {
            ftype = this.ftypes["/text/"]
          } else {
            ftype = this.ftypes["/?/"]
          }
        }
      }
    } catch {}
    if (in != null) try in.close() catch {}
  }
  // if not detected, report as binary
  if (ftype != null) {
    ftype.cast(FileType)
  } else {
    this.ftypes["/?/"].cast(FileType)
  }
}

def DesktopDB.getApp(desktop: String): Application {
  var app = this.cachedapps[desktop].cast(Application)
  if (app == null) {
    if (exists("/res/apps/" + desktop)) {
      app = readApplication("/res/apps/" + desktop)
      this.cachedapps[desktop] = app
    } else if (exists("/cfg/apps/" + desktop)) {
      app = readApplication("/cfg/apps/" + desktop)
      this.cachedapps[desktop] = app
    }
  }
  app
}

def DesktopDB.defaultAppFor(ext: String): Application {
  var app: Application = null
  var desktopline = this.apps[ext].cast(String)
  if (desktopline != null) {
    var tests = desktopline.split(';')
    for (var i=0, app == null && i<tests.len, i+=1) {
      if (tests[i] != null) app = this.getApp(tests[i])
    }
  }
  app
}

def DesktopDB.allAppsFor(ext: String): [Application] {
  var applist = new List()
  var desktopline = this.apps[ext].cast(String)
  if (desktopline != null) {
    var tests = desktopline.split(';')
    for (var i=0, i<tests.len, i+=1) {
      if (tests[i] != null) applist.add(this.getApp(tests[i]))
    }
  }
  var apps = new [Application](applist.len())
  applist.copyinto(0, apps, 0, apps.len)
  apps
}
