/* Make utility for Alchemy OS
 * Copyright (c) 2012-2013, Sergey Basalaev
 * Licensed under GPL v3
 */

use "dict.eh"
use "list.eh"
use "strbuf.eh"
use "string.eh"
use "sys.eh"
use "textio.eh"

const VERSION = "make 1.3"
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
  var sb = new StrBuf()
  while (line.len() > 0) {
    var S = line.indexof('$')
    if (S < 0 || S >= line.len()) {
      sb.append(line)
      line = ""
    } else {
      sb.append(line[:S])
      line = line[S+1:]
      var ch = line[0]
      if (ch == '$') {
        sb.addch('$')
        line = line[1:]
      } else if (ch == '{') {
        var rbrace = line.indexof('}')
        if (rbrace < 0) rbrace = line.len()
        var value = vars[line[1:rbrace]]
        if (value == null) value = ""
        sb.append(value)
        line = line[rbrace+1:]
      } else {
        var value = vars[ch.tostr()]
        if (value == null) value = ""
        sb.append(value)
        line = line[1:]
      }
    }
  }
  sb.tostr()
}

/* Build named target. */
def build(target: String, silent: Bool): Bool {
  var rule = rules[target].cast(Rule)
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
        for (var i=0, !needs && i<rule.deps.len, i+=1) {
          needs = time < fmodified(rule.deps[i])
        }
      }
      // build target
      if (needs) {
        for (var i=0, ok && i<rule.exec.len, i+=1) {
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
  var commands = new List()
  while (ok && line != null) {
    if (line.len() == 0 || line[0] == '#') {
      //skip this line
    } else if (line[0] == ' ') {
      // add command to the target
      if (rule == null) {
        stderr().println(fname+":"+lineno+": Commands before first target. Stop.")
        ok = false
      } else {
        commands.add(substvars(line.trim()))
      }
    } else if (line.indexof('=') > 0) {
      // end target
      if (rule != null) {
        rule.exec = new [String](commands.len())
        commands.copyinto(0, rule.exec, 0, rule.exec.len)
        rules[rule.target] = rule
        commands = new List()
        if (def_rule == null) def_rule = rule
        vars.remove("@")
        vars.remove("<")
      }
      // add variable
      var eq = line.indexof('=')
      vars[line[:eq].trim()] = substvars(line[eq+1:].trim())
    } else if (line.indexof(':') > 0) {
      // start new target
      if (rule != null) {
        rule.exec = new [String](commands.len())
        commands.copyinto(0, rule.exec, 0, rule.exec.len)
        rules[rule.target] = rule
        commands = new List()
        if (def_rule == null) def_rule = rule
        vars.remove("<")
        vars.remove("@")
      }
      var cl = line.indexof(':')
      var target = substvars(line[:cl])
      var deps = substvars(line[cl+1:])
      vars["<"] = target
      vars["@"] = deps
      rule = new Rule { target = target, deps = deps.split(' ') }
    } else if (line.find("include ") == 0) {
      var incl_name = line[8:].trim()
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
    rule.exec = new [String](commands.len())
    commands.copyinto(0, rule.exec, 0, rule.exec.len)
    rules[rule.target] = rule
    if (def_rule == null) def_rule = rule
  }
  r.close()
  ok
}

def main(args: [String]): Int {
  // init
  rules = new Dict()
  vars = new Dict()
  var result = 0
  var exit = false
  // parse args
  var targets = new List()
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