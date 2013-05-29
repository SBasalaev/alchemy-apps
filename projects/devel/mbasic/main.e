use "mbasic.eh"
use "textio.eh"
use "string.eh"
use "list.eh"

const VERSION = "MBASIC 0.7"
const HELP = "MBASIC interpreter\n" +
             "Run interactively:\nmbasic [options]\n" +
             "Load program:\nmbasic file [args]\n" +
             "Run program:\nmbasic -run file [args]\n" +
             "Run command:\nmbasic -c 'command' [args]"

def main(args: [String]) {
  // parse args
  var runprog = false
  var infile = ""
  var arglist = new List()
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
      } else if (arg == "-run") {
        runprog = true
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
    // interactive mode
    input = utfreader(stdin())
    println(VERSION)
    runprog = false
  } else if (infile == "-") {
    // non-interactive stdin
    input = utfreader(stdin())
  } else if (infile == "-c") {
    // execute first argument as a command
    if (arglist.len() == 0) {
      stderr().println("mbasic: -c requires argument")
      exit = true
    } else {
      var cmd = arglist[0].cast(String)
      arglist.remove(0)
      input = utfreader(istream_from_ba(cmd.utfbytes()))
    }
  } else {
    // load file
    var in = fopen_r(infile)
    var buf = in.readfully()
    in.close()
    input = utfreader(istream_from_ba(buf))
  }
  // prepare VM
  if (!exit) {
    var vm = new BasicVM(true)
    vm.set_ivar("ARGC%", arglist.len())
    vm.addfunction("ARGS$", "i", 's', arglist.get)
    // read commands from the command line
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
    // run
    if (runprog && vm.state != VM_EXIT) vm.run()
  }
}
