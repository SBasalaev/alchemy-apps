/* Make utility for Alchemy OS
 * Copyright (c) 2012, Sergey Basalaev
 * Licensed under GPL v3
 */

use "dict.eh"
use "list.eh"
use "strbuf.eh"
use "string.eh"
use "sys.eh"
use "textio.eh"

const VERSION = "make 1.2"
const HELP = "Usage: make [options] [targets]\n" +
             "Options:\n" +
             "-h this help\n" +
             "-v product version\n" +
             "-s silent mode\n" +
             "-C change directory"

type Rule {
  target: String,
  deps: [String],
  exec: [String]
}

var def_rule: Rule
var rules: Dict
var vars: Dict

/* Do variable substitution in line. */
def substvars(line: String): String {
  var sb = new_strbuf()
  while (line.len() > 0) {
    var S = line.indexof('$')
    if (S < 0 || S >= line.len()) {
      sb.append(line)
      line = ""
    } else {
      sb.append(line.substr(0, S))
      line = line.substr(S+1, line.len())
      var ch = line.ch(0)
      if (ch == '$') {
        sb.addch('$')
        line = line.substr(1,line.len())
      } else if (ch == '{') {
        var rbrace = line.indexof('}')
        if (rbrace < 0) rbrace = line.len()
        var value = vars[line.substr(1, rbrace)]
        if (value == null) value = ""
        sb.append(value)
        line = line.substr(rbrace+1, line.len())
      } else {
        var chstr = new_strbuf().addch(ch).tostr()
        var value = vars[chstr]
        if (value == null) value = ""
        sb.append(value)
        line = line.substr(1, line.len())
      }
    }
  }
  sb.tostr()
}

/* Build named target. */
def build(target: String, silent: Bool): Bool {
  var rule = cast (Rule) rules[target]
  if (rule == null) {
    // if no rule just check if file exists
    if (exists(target)) {
      true
    } else {
      stderr().println("** No rule to build target "+target)
      false
    }
  } else {
    var ok = true
    // build dependencies
    for (var i=0, ok && i<rule.deps.len, i+=1) {
      ok = build(rule.deps[i], silent)
    }
    if (ok) {
      // test if we need to build target
      var needs = !exists(target)
      if (!needs) {
        var time = fmodified(target)
        for (var i=0, !needs && i<rule.deps.len, i=i+1) {
          needs = time < fmodified(rule.deps[i])
        }
      }
      // build target
      if (needs) {
        for (var i=0, ok && i<rule.exec.len, i=i+1) {
          if (!silent) println(rule.exec[i])
          ok = 0 == exec_wait("sh", ["-c", rule.exec[i]])
        }
      }
      if (!ok) {
        stderr().println("** Failed to build target "+target)
      }
    }
    ok
  }
}

/* Parses makefile. */
def readmf(fname: String): Bool {
  var r = utfreader(fopen_r(fname))
  var ok = true
  var lineno = 1
  var line = r.readline()
  var rule: Rule
  var commands = new_list()
  while (ok && line != null) {
    if (line.len() == 0 || line.ch(0) == '#') {
      //skip this line
    } else if (line.ch(0) == ' ') {
      // add command to the target
      if (rule == null) {
        stderr().println(fname+":"+lineno+": Commands before first target. Stop.")
        ok = false
      } else {
        commands.add(substvars(line.trim()))
      }
    } else if (line.indexof('=') > 0) {
      // add variable
      var eq = line.indexof('=')
      vars[line.substr(0,eq).trim()] = substvars(line.substr(eq+1,line.len()).trim())
    } else if (line.indexof(':') > 0) {
      // start new target
      if (rule != null) {
        rule.exec = commands.toarray()
        rules[rule.target] = rule
        commands = new_list()
        if (def_rule == null) def_rule = rule
      }
      var cl = line.indexof(':')
      rule = new Rule(
        target = substvars(line.substr(0,cl)),
        deps = substvars(line.substr(cl+1, line.len())).split(' ')
      )
      rule = new Rule(
        target = substvars(line.substr(0,cl)),
        deps = substvars(line.substr(cl+1, line.len())).split(' ')
      )
    } else if (line.find("include ") == 0) {
      var incl_name = line.substr(8, line.len()).trim()
      if (exists(incl_name)) {
        ok = readmf(incl_name)
      } else {
        ok = false
        stderr().println(fname+":"+lineno+": Included file does not exist: "+incl_name)
      }
    } else {
      stderr().println(fname+":"+lineno+": Syntax error")
      ok = false
    }
    line = r.readline()
    lineno += 1
  }
  if (rule != null) {
    rule.exec = commands.toarray()
    rules[rule.target] = rule
    if (def_rule == null) def_rule = rule
  }
  r.close()
  ok
}

def main(args: [String]): Int {
  // init
  rules = new_dict()
  vars = new_dict()
  var result = 0
  var exit = false
  // parse args
  var targets = new_list()
  var todir = ""
  var silent = false
  var readdir = false
  for (var i=0, i < args.len, i+=1) {
    if (readdir) {
      readdir = false
      todir = args[i]
    } else {
      var arg = args[i]
      if (arg == "-h") {
        println(HELP)
        exit = true
      } else if (arg == "-v") {
        println(VERSION)
        exit = true
      } else if (arg == "-s") {
        silent = true
      } else if (arg == "-C") {
        readdir = true
      } else if (arg.ch(0) == '-') {
        stderr().println("make: Unknown option: "+arg)
        result = 2
        exit = true
      } else {
        targets.add(arg)
      }
    }
  }
  // apply args
  if (todir.len() > 0) set_cwd(todir)
  if (readdir) {
    stderr().println("** -C must precede dir name")
    result = 2
    exit = true
  }
  // check makefile
  var fname = "Makefile"
  if (!exit) {
    if (!exists(fname)) {
      fname = "makefile"
      if (!exists(fname)) {
        stderr().println("** Makefile not found")
        exit = true
        result = 2
      }
    }
  }
  // parse makefile
  if (!exit) {
    if (!readmf(fname)) {
      exit = true
      result = 2
    }
  }
  // build
  if (!exit) {
    var ok = true
    if (targets.len() == 0) {
      ok = build(def_rule.target, silent)
    } else for (var i=0, ok && i < targets.len(), i+=1) {
      ok = build(targets[i].tostr(), silent)
    }
    result = if (ok) 0 else 1
  }
  result
}