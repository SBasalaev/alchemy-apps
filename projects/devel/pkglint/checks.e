use "io.eh"
use "checks.eh"

def report(msg: String, ref: String, level: Int) {
  var err = stderr()
  err.print( switch (level) { 1: "W: "; 2: "E: "; else: "?: " } )
  err.println(msg)
  if (ref != null) err.println(" See Policy " + ref)
  if (get_errlevel() < level) set_errlevel(level)
}