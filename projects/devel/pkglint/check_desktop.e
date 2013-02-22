use "checks.eh"
use "textio.eh"
use "string.eh"

def check_desktop() {
  if (is_dir("res/apps/")) {
    var desktops = flist("res/apps/")
    for (var i=0, i < desktops.len, i+=1) {
      var desktop = "res/apps/" + desktops[i]
      if (!is_dir(desktop)) {
        var r = utfreader(fopen_r(desktop))
        var line = r.readline()
        while (line != null) {
          var eq = line.indexof('=')
          if (eq > 0) {
            var key = line[:eq].trim()
            var val = line[eq+1:].trim()
            if (key == "Icon" && !exists(val) && !exists("res/icons/" + val)) {
              report("Icon " + val + " referenced in " + desktop + " is not in package", null, TEST_WARN)
            } else if (key == "Exec") {
              if (val.indexof(' ') > 0) val = val[:val.indexof(' ')]
              if (!exists("bin/" + val))
                report("Program " + val + " referenced in " + desktop + " is not in package", null, TEST_WARN)
            }
          }
          line = r.readline()
        }
      }
    }
  }
}