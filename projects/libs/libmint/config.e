use "config.eh"
use "textio.eh"
use "string.eh"

const CFG_FILE = "/cfg/mintprefs"

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

var cfg_instance: Config;

def getConfig(): Config {
  var cfg = cfg_instance
  if (cfg == null) {
    cfg = new Config{}
    cfg_instance = cfg
    // try to read config
    try {
      var dict = readCfgFile(CFG_FILE)
      cfg.iconTheme = dict["Icon-Theme"].cast(String)
      cfg.listIconSize = dict["List-Icon-Size"].cast(String).toint()
      cfg.dialogIconSize = dict["Dialog-Icon-Size"].cast(String).toint()
      cfg.dialogFont = dict["Dialog-Font"].cast(String).toint()
    } catch {
      cfg.iconTheme = ""
      // try to create/rewrite config
      var out = fopen_w(CFG_FILE)
      out.println("Icon-Theme=")
      out.println("List-Icon-Size=16")
      out.println("Dialog-Icon-Size=24")
      out.println("Dialog-Font=0")
      out.close()
    }
  }
  cfg
}
