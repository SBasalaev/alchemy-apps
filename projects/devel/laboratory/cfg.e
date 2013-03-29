use "cfg.eh"
use "textio.eh"
use "string.eh"

def load_cfg(cfg: Dict, file: String) {
  var r = utfreader(fopen_r(file))
  var line = r.readline();
  while (line != null) {
    if (line.len() != 0 && line[0] != '#') {
      var eq = line.indexof('=')
      if (eq > 0) {
        cfg[line[:eq].trim()] = line[eq+1:].trim()
      }
    }
    line = r.readline()
  }
  r.close()
}

def save_cfg(cfg: Dict, file: String) {
  var out = fopen_w(file)
  var keys = cfg.keys()
  for (var i=0, i<keys.len, i+=1) {
    out.println(keys[i].tostr() + "=" + cfg[keys[i]])
  }
  out.close()
}