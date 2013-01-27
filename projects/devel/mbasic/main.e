use "mbasic.eh"
use "textio.eh"
use "string.eh"
use "list.eh"

const VERSION = "mbasic 0.6"
const HELP = "BASIC interpreter\n" +
             "Execute script:\nmbasic [opts] file [args]\n" +
             "Run interactively:\nmbasic [options]\n" +
             "Options:\n" +
             "-nostd  do not load standard functions"

def main(args: [String]) {
  // parse args
  var usestd = true
  var infile = ""
  var arglist = new_list()
  var exit = false
  for (var i=0, i<args.len, i+=1) {
    var arg = args[i]
    if (infile == "") {
      if (arg == "-h") {
        println(HELP)
        exit = true
      } else if (arg == "-v") {
        println(VERSION)
        exit = true
      } else if (arg == "-nostd") {
        usestd = false
      } else {
        infile = arg
      }
    } else {
      arglist.add(arg)
    }
  }
  // load source
  var input: Reader;
  if (infile == "") {
    input = utfreader(stdin())
  } else {
    var buf = new BArray(fsize(infile))
    var in = fopen_r(infile)
    in.readarray(buf, 0, buf.len)
    in.close()
    input = utfreader(istream_from_ba(buf))
  }
  // prepare VM
  var vm = new_basicvm(usestd)
  vm.set_ivar("ARGC%", arglist.len())
  vm.addfunction("ARGS$", "i", 's', arglist.get)
  // execute
  var line = input.readline()
  if (line != null && line.len() > 0 && line[0] == '#')
    line = input.readline()
  while (line != null) {
    vm.parse(line)
    if (vm.state == VM_EXIT)
      line = null
    else
      line = input.readline()
  }
}
